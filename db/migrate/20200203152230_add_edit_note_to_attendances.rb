class AddEditNoteToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_note, :string
  end
end
