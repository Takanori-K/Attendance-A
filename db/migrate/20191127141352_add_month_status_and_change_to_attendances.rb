class AddMonthStatusAndChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :month_status, :integer, default: 0
    add_column :attendances, :month_change, :string
  end
end
