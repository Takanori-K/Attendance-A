class AddEditNextDayAndTomorrowEditTomorrowToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_next_day, :string
    add_column :attendances, :tomorrow, :string
    add_column :attendances, :edit_tomorrow, :string
  end
end
