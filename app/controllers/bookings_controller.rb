class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show, :destroy], on: [:invite, :respond_to_invitation]


  def index
    @bookings = current_user.admin? ? Booking.all : current_user.bookings
  end
  
  def show
  end
  
  def new
    @booking = Booking.new
    @room = Room.find(params[:room_id])
  end
  
  def create
    @booking = current_user.bookings.new(booking_params)
    @booking.status = 'pending'
    
    if @booking.save
      if params[:participant_ids].present?
        params[:participant_ids].each do |user_id|
          @booking.meeting_participants.create(user_id: user_id, status: 'pending')
        end
      end
      redirect_to @booking, notice: 'Booking was successfully created.'
    else
      @room = @booking.room
      render :new
    end
  end
  
  def destroy
    if @booking.can_cancel?
      @booking.update(status: 'canceled')
      redirect_to bookings_path, notice: 'Booking was successfully canceled.'
    else
      redirect_to bookings_path, alert: 'Cannot cancel this booking.'
    end
  end

  def my_invitations
    @invitations = Booking.where(invitee_email: current_user.email, status: "pending")
  end

  class BookingsController < ApplicationController
    before_action :authenticate_user!
  
    def my_invitations
      @invitations = Booking.where(invitee_email: current_user.email, status: "pending")
    end
  
    def invite
      @booking = Booking.find(params[:id])
      invitee_email = params[:invitee_email]
  
      if invitee_email.present?
        @booking.update(invitee_email: invitee_email, status: "pending")
        flash[:notice] = "Invitation sent to #{invitee_email}."
      else
        flash[:alert] = "Invitee email is required."
      end
      redirect_to bookings_path
    end
  
    def respond_to_invitation
      @booking = Booking.find(params[:id])
      if params[:response] == "accept"
        @booking.update(status: "accepted")
        flash[:notice] = "Meeting accepted."
      else
        @booking.update(status: "rejected")
        flash[:alert] = "Meeting rejected."
      end
      redirect_to my_invitations_bookings_path
    end
  end
  

  private
  
  def set_booking
    @booking = Booking.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Booking not found."
    redirect_to bookings_path
  end
  
  def booking_params
    params.require(:booking).permit(:room_id, :start_time, :end_time)
  end
end
