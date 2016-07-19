class ApiController < ApplicationController

  def messages
    # receive codes corresponding to a student
    #codes = params[:codes].map{|code| {code: code[:code], latest_update: code[:latest_update]}}
    codes = params[:codes].map {|c| c.downcase}

    student_codes = codes.select {|code| code.start_with?('s')} # get all students' codes from querystring
    group_codes = codes.select {|code| code.start_with?('g')}

    # find the group based on the given codes for students
    students = Student.by_codes(student_codes)
    groups = Group.by_codes(group_codes)

    groups_ids = (students.map{ |s| s.groups } + groups.pluck(:id)).flatten

    last_update = params[:last_update]
    # find messages based on the groups found
    @messages =   Message.published.by_group_ids(groups_ids).includes(:mfiles).order(publish_date: :desc).limit(30)

    # add student firstname targeted for each message
    @messages_with_students = @messages.map { |m|
      list_of_students = students.collect { |s|
        s.firstname if (!(s.groups & m.groups).empty?)
      }
      list_of_groups = groups.collect { |g|
        g.name if (m.groups.include? g.id)
      }


      m.students = list_of_students.compact + list_of_groups.compact
      m.signature = {
        fullname: m.author.fullname,
        function: m.author.function,
        schoolname: m.school.name,
        address: m.school.address,
        url: m.school.url,
        email: m.author.email,
        phone: m.school.phone,
        logo_url: m.school.file_url
      }
      m
    }

    render json: @messages_with_students.to_json(:include => :mfiles)
  end

  def get_fullname_by_code
    name = 'nothing found'
    code = params[:code].downcase
    if code.start_with?("s")
      s = Student.by_codes(code).first
      name = s.fullname unless s.nil?
    elsif code.start_with?("g")
      g = Group.by_codes(code).first
      name = g.name unless g.nil?
    elsif code.start_with?("u")
      u = User.by_codes(code).first
      name = u.fullname unless u.nil?
    end
    render json: {code: code, fullname: name}
  end

  def link_code_to_device
    code = params[:code].downcase
    device = Device.find_or_create_by(uuid: params[:uuid])
    device.add_code(code)
    if code.start_with?("s")
      Student.by_code(code).first.follow
    end

    render json: {res: 'ok'}
  end

  def unlink_code_to_device
    code = params[:code].downcase
    device = Device.find_by uuid: params[:uuid]
    device.remove_code(code) unless device.nil?

    if code.start_with?("s")
      Student.by_code(code).first.unfollow
    end

    render json: {res: 'ok'}
  end

  def saveregistrationid
    device = Device.find_or_create_by(uuid: params[:uuid])
    if device.update(registration_id: params[:rid], platform: params[:platform])
      logger.info "Registartion ID (#{device.registration_id}) saved for #{device.uuid}, platform #{device.platform}"
    else
      logger.info "Error when saving Registration ID"
      logger.error "Error when saving Registration ID (#{params[:rid]}) for #{params[:uuid]}, platform #{params[:platform]}"
    end
    render json: {res: 'ok'}
  end

  def disabledevicenotifictation
    device = Device.find_or_create_by(uuid: params[:uuid], platform: params[:platform])
    unless device.nil?
      device.disable
    end
    render json: {res: 'ok'}
  end

  def enabledevicenotifictation
    device = Device.find_or_create_by(uuid: params[:uuid], platform: params[:platform])
    unless device.nil?
      device.enable
    end
    render json: {res: 'ok'}
  end

  def code_label
    code = params[:code].downcase
    code_label = Student.by_codes(code)
    message = 'Code erroné'
    if code_label.first N7ljVx
      message = code_label.first.fullname
    end
    render json: message
  end
end
