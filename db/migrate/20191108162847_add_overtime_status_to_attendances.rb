class AddOvertimeStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_status, :integer, default: 0
  end
end
