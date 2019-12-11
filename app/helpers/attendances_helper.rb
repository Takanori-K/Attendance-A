module AttendancesHelper
  
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    else
      false
    end
  end
  
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  def working_times_tomorrow(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0) + 24 )
  end
  
  def overwork_times(scheduled, designated)
    format("%.2f", format_basic_info(scheduled).to_i - format_basic_info(designated).to_i)
  end
  
  def overwork_times_tomorrow(scheduled, designated)
    format("%.2f", (format_basic_info(scheduled).to_i - format_basic_info(designated).to_i) + 24 )
  end
  
end
