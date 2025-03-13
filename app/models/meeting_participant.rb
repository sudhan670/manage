class MeetingParticipant < ApplicationRecord
  belongs_to :booking
  belongs_to :user
  
  validates :status, inclusion: { in: ['pending', 'accepted', 'rejected'] }
  
  def can_respond?
    booking.start_time > Time.current
  end
end