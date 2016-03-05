class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy]

  def latest
    # receive codes corresponding to a student
    codes = params[:id].map{|id| id[:codes]}

    # find the group based on the given codes
    students = Student.by_codes(codes)
    groups = students.map{ |s| s.groups }.flatten

    # find messages based on the groups found
    @messages = Message.by_group_ids(groups)
    render json: @messages
  end

  # GET /messages
  def index
    @messages = Message.all

    render json: @messages
  end

  # GET /messages/1
  def show
    render json: @message
  end

  # POST /messages
  def create
    @message = Message.new(message_params)

    if @message.save
      render json: @message, status: :created, location: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /messages/1
  def update
    if @message.update(message_params)
      render json: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /messages/1
  def destroy
    @message.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def message_params
      params.require(:message).permit(:title, :content)
    end
end
