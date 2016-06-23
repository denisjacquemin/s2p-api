class ApiController < ApplicationController

  def messages
    # receive codes corresponding to a student
    #codes = params[:codes].map{|code| {code: code[:code], latest_update: code[:latest_update]}}
    codes = params[:codes]

    # find the group based on the given codes
    students = Student.by_codes(codes)
    groups = students.map{ |s| s.groups }.flatten
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
        phone: [m.school.phone, m.school.url, m.author.email].join('-')
      }
      m
    }

    render json: @messages_with_students.to_json(:include => :mfiles)
  end

  def get_fullname_by_code
    s = Student.by_codes(params[:code]).first
    if s.nil?
      render 	:no_content, json: {message: 'nothing found'}
    else
      render json: {code: params[:code], fullname: s.fullname}
    end
  end

  def link_code_to_device
    device = Device.find_or_create_by(token: params[:token], platform: params[:platform])
    device.add_code(params[:code])
    render nothing: true
  end

  def unlink_code_to_device
    device = Device.find_by token: params[:token]
    device.remove_code(params[:code]) unless device.nil?
    render nothing: true
  end

  def disabledevicenotifictation
    device = Device.find_by_uuid(params[:uuid])
    unless device.nil?
      device.disable
    end
  end

  def enabledevicenotifictation
    device = Device.find_by_uuid(params[:uuid])
    unless device.nil?
      device.enable
    end
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
