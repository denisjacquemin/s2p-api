class ApiController < ApplicationController
  def code_label
    code_label = Student.by_codes(params[:code])
    message = 'Code erroné'
    if code_label.first
      message = code_label.first.fullname
    end
    render json: message
  end
end
