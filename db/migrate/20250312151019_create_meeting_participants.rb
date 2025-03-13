class CreateMeetingParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :meeting_participants do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
