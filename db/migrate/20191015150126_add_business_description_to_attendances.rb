class AddBusinessDescriptionToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :business_description, :string
  end
end
