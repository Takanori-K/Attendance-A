class AddApprovalStartedFinishedToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :approval_started, :datetime
    add_column :attendances, :approval_finished, :datetime
  end
end
