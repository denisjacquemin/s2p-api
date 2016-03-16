class ApiController < ApplicationController

  # /messages?last_update=2016-03-16&codes[]=123456&codes[]=7KGWpG"
  def messages
    # receive codes corresponding to a student
    #codes = params[:codes].map{|code| {code: code[:code], latest_update: code[:latest_update]}}
    codes = params[:codes]

    # find the group based on the given codes
    students = Student.by_codes(codes)
    groups = students.map{ |s| s.groups }.flatten

    last_update = params[:last_update]
    # find messages based on the groups found
    @messages = Message.by_group_ids(groups).since(last_update)
    render json: @messages
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
