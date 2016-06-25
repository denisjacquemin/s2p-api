class ApiController < ApplicationController

  def messages
    # receive codes corresponding to a student
    #codes = params[:codes].map{|code| {code: code[:code], latest_update: code[:latest_update]}}
    codes = params[:codes]
    student_codes = codes.select {|code| code.start_with?('s')}
    group_codes = codes.select {|code| code.start_with?('g')}

    # find the group based on the given codes for students
    students = Student.by_codes(student_codes)
    groups = students.map{ |s| s.groups }.flatten

    groups = groups + group_codes.map{|g| Group.find_by_code(g).id}.flatten

    last_update = params[:last_update]
    # find messages based on the groups found
    @messages =   Message.published.by_group_ids(groups).includes(:mfiles).order(publish_date: :desc).limit(30)

    # add student firstname targeted for each message
    @messages_with_students = @messages.map { |m|
      list_of_students = students.collect { |s|
        s.firstname if (!(s.groups & m.groups).empty?)
      }
      m.students = list_of_students.compact
      m.signature = {
        fullname: m.author.fullname,
        function: m.author.function,
        schoolname: m.school.name,
        address: m.school.address,
        contact: [m.school.phone, m.school.url, m.author.email].join(' - ')
      }
      byebug
      m
    }

    render json: @messages_with_students.to_json(:include => :mfiles)
  end

  def get_fullname_by_code
    name = 'nothing found'
    if params[:code].start_with?("s")
      s = Student.by_codes(params[:code]).first
      name = s.fullname unless s.nil?
    elsif params[:code].start_with?("g")
      g = Group.by_codes(params[:code]).first
      name = g.name unless g.nil?
    end
    render json: {code: params[:code], fullname: name}
  end

  def link_code_to_device
    device = Device.find_or_create_by(uuid: params[:uuid], platform: params[:platform])
    device.add_code(params[:code])
    render json: {res: 'ok'}
  end

  def unlink_code_to_device
    device = Device.find_by uuid: params[:uuid]
    device.remove_code(params[:code]) unless device.nil?
    render json: {res: 'ok'}
  end

  def saveregistrationid
    device = Device.find_by_uuid(params[:uuid])
    puts 'saveregistrationid: ' + device.inspect
    if device.update(registration_id: params[:rid])
      puts 'save ok'
    else
      puts 'save not ok'
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
    code_label = Student.by_codes(params[:code])
    message = 'Code erroné'
    if code_label.first N7ljVx
      message = code_label.first.fullname
    end
    render json: message
  end
end
