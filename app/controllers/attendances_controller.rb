class AttendancesController < ApplicationController
  
  before_action :set_user,       only: [:edit_one_month, :update_one_month, :edit_overtime_work, :update_overtime_work]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overtime_work, :update_overtime_work]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_mnth]
  before_action :set_one_month,  only: :edit_one_month
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
    flash[:success] = "１ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def edit_overtime_work
    @day = Date.parse(params[:day])
    @youbi = $days_of_the_week[@day.wday]
    @attendance = @user.attendances.find_by(worked_on: @day)
    @superiors = User.where.not(id: current_user.id).where(superior: true)
  end
  
  def update_overtime_work
    @attendance = @user.attendances.find(params[:id])
    if @attendance.update_attributes(overtime_params)
      flash[:success] = "残業申請を送信しました。"
    else
      flash[:danger] = "#{@user.name}の残業申請の送信は失敗しました。<br>" + @attendance.errors.full_messages.join("<br>")
    end
    redirect_to @user
  end
  
  private
    
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def overtime_params
      params.require(:attendance).permit(:scheduled_end_time , :next_day, :business_description, :instructor_sign)
    end
    
     def admin_or_correct_user
       @user = User.find(params[:user_id]) if @user.blank?
       unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
       end
     end
end
