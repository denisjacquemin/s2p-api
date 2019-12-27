class ApiController < ApplicationController

  def messages
    # receive codes corresponding to a student
    #codes = params[:codes].map{|code| {code: code[:code], latest_update: code[:latest_update]}}
    if params[:codes].present?

      codes = params[:codes].map {|c| c.downcase}
      student_codes = codes.select {|code| code.start_with?('s')} # get all students' codes from querystring

      # build message.groups list based on code received (group's code or student's code)
      groups_ids = build_groups_ids(student_codes)

      student_ids = build_students_ids(student_codes)

      duuid = params[:uuid]
      device = Device.find_by_uuid(duuid)
      # find messages based on the groups found

      @messages =   Message.published.includes(:photo_files, :school, :author).for_app.by_group_and_student_ids(groups_ids, student_ids).order(updated_at: :desc).limit(30) #.includes(:mfiles)
      students = Student.by_codes(student_codes)

      # removes messages after not before limit
      
      @messages = @messages.to_a.delete_if { |m| 
        unless m.school.activate_message_date_limit
          false
        end

        
        if m.school.activate_message_date_limit
          not_before_limit = Date.new(Date.today.year, m.school.message_month_limit, m.school.message_day_limit).yield_self{ |date| date.advance(years: (date > Date.today ? -1 : 0)) }
          m.publish_date < not_before_limit 
        end

      }

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

        # Si form_due_date est passée, retirer formdata du message et ajouter un message disant qu'il est fermé
        if m.formdata.present? && m.formdata != "[]" && !m.form_due_date.nil? && m.form_due_date < Date.today
          m.formdata = nil
          m.content << "<div>"\
            "<p style='background:yellow; color:red;'>La date limite pour remplir le formulaire est dépassée.</p>"\
          "</div>"
        end

        if m.school.allow_translation
          url = "https://#{ENV["KONECTOAPP_HOST"]}/m/#{m.muuid}"
          m.content << "<a href='" + url + "' type='button' class='btn' style='display: inline-block;"\
            "font-weight: 400;text-align: center;vertical-align: middle;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;user-select: none;border: 1px solid transparent;padding: .375rem .75rem;font-size: 1rem;line-height: 1.5;"\
            "border-radius: .25rem;transition: color .15s ease-in-out,background-color .15s ease-in-out,border-color .15s ease-in-out,box-shadow .15s ease-in-out;color: #fff;background-color: #6c757d;border-color: #6c757d;overflow: visible;    padding: .25rem .5rem;font-size: .875rem;line-height: 1.5;border-radius: .2rem;'>Traduire</button>"
        end

        list_of_students_firstname_and_lastname = []
        # for each message, find all targeted students
        list_of_students = students.collect { |s|
          # for one message check each students
          # if student's groups have at least one group in common with message's groups
          # or if student.id in contained in message.students
          # then add firstname in list of students
          gic = group_in_common?(s.groups, m.groups)

          s_contained_in_m = false
          s_contained_in_m = m.students.include?(s.id) if (m.students.present?)

          list_of_students_firstname_and_lastname <<  s.fullname if (gic or s_contained_in_m)
          s.firstname if (gic or s_contained_in_m)
        }

        # if payment is required append a payconiq button
        if m.include_payment?
          account_number = m.account.account_number unless m.account.nil? or m.account.account_number.blank?
          # m.content << "<table cellpadding='0' cellspacing='0' border='0' align='left' style='border-collapse:separate;border:1px solid #1791c8;width:100%'>"\
          #   "<tbody>"\
          #     "<tr>"\
          #       "<td height='15' colspan='3'> </td>"\
          #     "</tr>"\
          #     "<tr>"\
          #       "<td width='30'> </td>"\
          #       "<td>"\
          #         "<p style='margin-bottom:0px;text-align:left;margin:0px;padding:0px;color:#000;font-family:Verdana,Geneva,sans-serif;font-size:14px;line-height:22px'>"\
          #           "Le montant de <strong style='color:#1d92c4'>" + ActionController::Base.helpers.humanized_money(m.amount_to_pay) + " EUR</strong> est à payer"
          #           unless m.billing_due_date.blank?
          #             m.content << "&nbsp;avant le <strong style='color:#1d92c4'>" + m.billing_due_date + "</strong>"
          #           end
          #           unless account_number.blank?
          #             m.content << "<br>sur le compte <strong style='color:#1d92c4'>" + account_number + "</strong>"
          #           end
          #           unless m.billing_description.blank?
          #             m.content << "<br>avec la communication <strong style='color:#1d92c4'>" + m.billing_description + "</strong>."
          #           end
          #           unless m.billing_comment.blank?
          #             m.content << "<br><br>" + m.billing_comment
          #           end
          #         m.content << "</p>"\
          #       "</td>"\
          #       "<td width='30'> </td>"\
          #     "</tr>"\
          #     "<tr>"\
          #       "<td height='15' colspan='3'></td>"\
          #     "</tr>"\
          #   "</tbody>"\
          # "</table>"

          if m.school.payconiq_enable?
            konectoapp_host = ENV["KONECTOAPP_HOST"]
            m.content << "<div style='margin: 0;display:inline-block;padding: 40px 0; width: 100%; text-align: center; margin: 50px 0 0 0;'>"\
                "<a style='padding: 25px 30px; background: #ff4785; color:#fff;' href='https://#{konectoapp_host}/p/#{m.muuid}?s=#{list_of_students_firstname_and_lastname.compact.join(', ')}#paysection'>Payer #{m.amount_to_pay}&euro; avec payconiq</a>"\
              "</div>"
          end
        end


        m.student_names = list_of_students.compact
        # m.signature = {
        #   fullname: m.author.fullname,
        #   function: m.author.function,
        #   schoolname: m.school.name,
        #   address: m.school.address,
        #   url: m.school.url,
        #   phone: m.school.phone,
        #   logo_url: m.school.file_url
        # }
        # m.signature.merge!(email: m.author.reply_to) if m.author.display_email_address
        unless m.formdata.nil? or m.muuid.nil? or duuid.nil?
          forms_submitted = Form.by_muuid(m.muuid).by_duuid(duuid).pluck(:created_at).map{|d| I18n.l(d.in_time_zone, format: :long)}
          m.forms = forms_submitted
        end
        # unless m.formdata.nil? or m.muuid.nil? or duuid.nil?
        #   forms_submitted = m.forms.map {|f| I18n.l(f.created_at.in_time_zone, format: :long)}
        #   m.forms = forms_submitted
        # end
        m
      }

      # render json: @messages_with_students.to_json(:include => [:photos, :forms => {only: :created_at}])

      #render json: @messages_with_students.to_json(:include => [:photos])
      render json: @messages_with_students

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
    def build_groups_ids(student_codes)
      groups_ids = Student.by_codes(student_codes).pluck(:groups)
      groups_ids.flatten.compact.uniq
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
