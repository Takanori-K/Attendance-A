class AddEditRequestSignToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_request_sign, :string
  end
end
