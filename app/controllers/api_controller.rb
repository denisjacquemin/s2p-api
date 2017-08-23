class ApiController < ApplicationController

  def messages
    # receive codes corresponding to a student
    #codes = params[:codes].map{|code| {code: code[:code], latest_update: code[:latest_update]}}
    if params[:codes].present?

      codes = params[:codes].map {|c| c.downcase}
      student_codes = codes.select {|code| code.start_with?('s')} # get all students' codes from querystring
      group_codes = codes.select {|code| code.start_with?('g')}

      # build message.groups list based on code received (group's code or student's code)
      groups_ids = build_groups_ids(student_codes, group_codes)

      student_ids = build_students_ids(student_codes)

      duuid = params[:uuid]
      device = Device.find_by_uuid(duuid)
      # find messages based on the groups found
      @messages =   Message.published.includes(:photo_files).for_app.by_group_and_student_ids(groups_ids, student_ids).order(updated_at: :desc).limit(30) #.includes(:mfiles)
      students = Student.by_codes(student_codes)
      groups = Group.by_codes(group_codes)

      # add student firstname targeted for each message
      @messages_with_students = @messages.map { |m|

        # finds pdf and append a link to that file in content
        if device.nil? or device.platform != 'Android'
          m.photos.each do |p|
            if p.format == 'pdf'
              m.content << "<div>"\
                "<a style='display:block;overflow:hidden;background-color:#ddd;position:relative;margin:7px 0;height:50px;line-height:50px;border-radius:3px;padding-right:10px' target='_blank' href='https://res.cloudinary.com/#{ENV["CLOUDINARY_CLOUD_NAME"]}/#{p.resource_type}/upload/#{p.public_id}.pdf'>"\
                  "<img src='https://res.cloudinary.com/#{ENV["CLOUDINARY_CLOUD_NAME"]}/image/upload/pdf.png' style='position:relative;top:5px;left:17px;zIndex:1'/>"\
                  "<span style='position:absolute;top:3px;left:40px'>#{p.public_id}</span>"\
                "</a>"\
              "</div>"
            end
          end
        end

        # if payment is required append a payconiq button
        if m.amount_to_pay > 0
          m.content << "<div style='background: #ff4785; padding: 0; width: 100%; text-align: center; margin: 0;'>"\
              "<a style='padding: 15px 10px; background: #00cb75; color:#fff;' href='thetransaction'>Payer avec payconiq</a>"\
            "</div>"
        end


        # for each message, find all targeted students
        list_of_students = students.collect { |s|
          # for one message check each students
          # if student's groups have at least one group in common with message's groups
          # or if student.id in contained in message.students
          # then add firstname in list of students
          gic = group_in_common?(s.groups, m.groups)

          s_contained_in_m = false
          s_contained_in_m = m.students.include?(s.id) if (m.students.present?)

          s.firstname if (gic or s_contained_in_m)
        }
        list_of_groups = groups.collect { |g|
          g.name if (m.groups.include? g.id)
        }


        m.student_names = list_of_students.compact + list_of_groups.compact
        m.signature = {
          fullname: m.author.fullname,
          function: m.author.function,
          schoolname: m.school.name,
          address: m.school.address,
          url: m.school.url,
          phone: m.school.phone,
          logo_url: m.school.file_url
        }
        m.signature.merge!(email: m.author.reply_to) if m.author.display_email_address

        unless m.formdata.nil? or m.muuid.nil? or duuid.nil?
          forms_submitted = Form.by_muuid(m.muuid).by_duuid(duuid).pluck(:created_at).map{|d| I18n.l(d.in_time_zone, format: :long)}
          m.forms = forms_submitted
        end
        m
      }

      render json: @messages_with_students.to_json(:include => [:photos])
    else
      render json: [].to_json
    end
  end

  def get_fullname_by_code
    name = 'notfound'
    schoolname='notfound'
    code = params[:code].downcase
    if code.start_with?("s")
      s = Student.by_codes(code).first
      name = s.fullname unless s.nil?
      schoolname = s.school.name unless s.nil?
    elsif code.start_with?("g")
      g = Group.by_codes(code).first
      name = g.name unless g.nil?
      schoolname =  g.school.name unless g.nil?
    elsif code.start_with?("u")
      u = User.by_codes(code).active.first
      name = u.fullname unless u.nil?
      schoolname = School.find(u.schools).pluck(:name).join(', ') unless u.nil?
    end
    render json: {code: code, fullname: name, schoolname: schoolname}
  end

  def link_code_to_device
    code = params[:code].downcase
    begin
      device = Device.find_or_create_by(uuid: params[:uuid])
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    device.codes_will_change!
    device.codes.push(code)
    if device.save
      render json: {res: 'ok'}
    else
      render json: {res: 'not ok'}
    end
  end

  def unlink_code_to_device
    code = params[:code].downcase
    device = Device.find_by uuid: params[:uuid]

    unless device.nil?
      device.codes_will_change!
      device.codes.delete(code)
      if device.save
        render json: {res: 'ok'}
      else
        render json: {res: 'not ok'}
      end
    end
  end

  def resetcodeonserver
    device = Device.where(uuid: params[:uuid]).first
    device.codes = []

    if device.save
      logger.info "resetcodeonserver for #{device.uuid}"
    else
      logger.error "Error when saving resetcodeonserver UUID: #{params[:uuid]}"
      logger.error device.errors.inspect
    end

  end

  def saveform #.force_encoding('ISO-8859-1')
    j = JSON.parse params[:formdata]
    j.prepend({label: 'horodateur', name: 'horodateur', value: I18n.l(Time.now.to_datetime().in_time_zone, format: :short)})
    logger.info "params[:uuid]: #{params[:uuid]}"
    @form = Form.new(duuid: params[:uuid], muuid: params[:muuid], formdata: JSON.generate(j))

    if @form.save
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  def savedevicestatetoserver

    codes = params[:codes].map {|c| c.downcase} if params[:codes].present?
    uuid = params[:uuid]
    rid = params[:rid]
    platform = params[:platform]

    begin
      device = Device.find_or_create_by(uuid: uuid)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    device.registration_id = rid
    device.platform = platform

    syncCodes = []
    unless codes.blank?
      syncCodes = codes.select { |code| Student.by_code(code).exists? } # save only a code if it is still valid
    end
    device.codes_will_change!
    device.codes = syncCodes
    if device.save
      logger.info "Saving Device State (#{device.registration_id}) saved for #{device.uuid}, platform #{device.platform}, codes #{device.codes}"
    else
      logger.error "Error when saving Device State (#{params[:rid]}) for #{params[:uuid]}, platform #{params[:platform]}, codes #{params[:codes]}"
      logger.error device.errors.inspect
    end
    render json: {res: 'ok'}
  end

  def saveregistrationid
    begin
      device = Device.find_or_create_by(uuid: params[:uuid])
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    device.registration_id = params[:rid]
    device.platform = params[:platform]

    if device.save
      logger.info "Registartion ID (#{device.registration_id}) saved for #{device.uuid}, platform #{device.platform}"
    else
      logger.error "Error when saving Registration ID (#{params[:rid]}) for #{params[:uuid]}, platform #{params[:platform]}"
      logger.error device.errors.inspect
    end
    render json: {res: 'ok'}
  end

  def disabledevicenotifictation
    begin
      device = Device.find_or_create_by(uuid: params[:uuid])
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    device.platform = params[:platform]
    device.disable
    if device.save
      logger.info "Disabling device notification for #{device.uuid} done"
    else
      logger.error "Error when Disabling device notification for #{params[:uuid]}"
      logger.error device.errors.inspect
    end
    render json: {res: 'ok'}
  end

  def enabledevicenotifictation
    begin
      device = Device.find_or_create_by(uuid: params[:uuid])
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    device.platform = params[:platform]
    device.enable
    if device.save
      logger.info "Enabling device notification for #{device.uuid} done"
    else
      logger.error "Error when Enabling device notification for #{params[:uuid]}"
      logger.error device.errors.inspect
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

  private
    def build_groups_ids(student_codes, group_codes)
      students = Student.by_codes(student_codes)
      groups = Group.by_codes(group_codes)
      groups_ids = students.map{ |s| s.groups } + groups.pluck(:id)
      groups_ids.flatten
    end

    def build_students_ids(student_codes)
      Student.by_codes(student_codes).pluck(:id)
    end

    def group_in_common?(student_groups, message_groups)
      sg = student_groups || []
      mg = message_groups || []
      (sg & mg).any?
    end
end
