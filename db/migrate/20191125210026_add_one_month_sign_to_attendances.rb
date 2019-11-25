class AddOneMonthSignToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :one_month_sign, :string
  end
end
