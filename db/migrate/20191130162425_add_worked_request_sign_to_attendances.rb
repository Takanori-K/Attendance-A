class AddWorkedRequestSignToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :worked_request_sign, :string
  end
end
