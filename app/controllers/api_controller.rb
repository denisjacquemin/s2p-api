class ApiController < ApplicationController
  def code_label
    code_label = Student.by_codes(params[:code])
    render json: code_label.first.fullname
  end
end
