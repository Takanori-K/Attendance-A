class AddDenialRequestSignToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :denial_request_sign, :string
  end
end
