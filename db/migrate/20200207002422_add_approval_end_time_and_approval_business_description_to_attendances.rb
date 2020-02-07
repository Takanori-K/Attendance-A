class AddApprovalEndTimeAndApprovalBusinessDescriptionToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :approval_end_time, :datetime
    add_column :attendances, :approval_business_description, :string
  end
end
