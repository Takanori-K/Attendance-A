class AddWorkedStatusAndChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :worked_status, :integer, default: 0
    add_column :attendances, :worked_change, :string
  end
end
