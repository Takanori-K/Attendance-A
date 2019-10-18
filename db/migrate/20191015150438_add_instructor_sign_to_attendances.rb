class AddInstructorSignToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :instructor_sign, :string
  end
end
