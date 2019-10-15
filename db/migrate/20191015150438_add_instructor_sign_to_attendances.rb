class AddInstructorSignToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :instructir_sign, :string
  end
end
