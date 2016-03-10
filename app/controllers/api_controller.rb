class ApiController < ApplicationController
  def code_label
    code_label = Student.by_codes(params[:code])
    message = ''
    if code_label
      message = code_label.first.fullname
    else
      message = 'Code erroné'
    render json: message
  end
end
