class AddWorkedMonthToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :worked_month, :date
  end
end
