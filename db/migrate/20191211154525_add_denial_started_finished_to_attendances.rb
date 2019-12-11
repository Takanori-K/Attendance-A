class AddDenialStartedFinishedToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :denial_started, :datetime
    add_column :attendances, :denial_finished, :datetime
  end
end
