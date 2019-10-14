require 'csv'
require 'date'


CSV.generate do |csv|
  csv_column_names = %w(日付 出勤 退勤)
  csv << csv_column_names
  @attendances.each do |day|
    column_values = [
        l(day.worked_on, format: :short),
        if day.started_at.present?
          day.started_at.strftime("%R")
        end,
        if day.finished_at.present?
          day.finished_at.strftime("%R")
        end,
    ]
    csv << column_values
  end
end