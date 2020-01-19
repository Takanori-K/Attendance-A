class AttendancesController < ApplicationController
  
  before_action :set_user,       only: [:edit_one_month, :update_one_month, :edit_overtime_work, :update_overtime_work, :update_one_month_info, :worked_log]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overtime_work, :update_overtime_work]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_mnth]
  before_action :set_one_month,  only: [:edit_one_month, :update_one_month_info, :worked_log]
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0),
                                       applying_started_at: Time.current.change(sec: 0),
                                       approval_started: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0),
                                       applying_finished_at: Time.current.change(sec: 0),
                                       approval_finished: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
    @superiors = User.where.not(id: current_user.id).where(superior: true)
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
    flash[:success] = "勤怠変更申請を送信しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def worked_log
    @all_worked_on = Attendance.where(user_id: current_user.id).where.not(approval_date: nil)
    if params[:search].present?
      @attendances_search = @all_worked_on.where('worked_on LIKE ?', "%#{params[:search]}%")
    else
      @attendances_search = Attendance.none
    end
  end
  
  def edit_overtime_work
    @day = Date.parse(params[:day])
    @youbi = $days_of_the_week[@day.wday]
    @attendance = @user.attendances.find_by(worked_on: @day)
    @superiors = User.where.not(id: current_user.id).where(superior: true)
  end
  
  def update_overtime_work
    @user = User.find(params[:attendance][:user_id])
    @attendance = @user.attendances.find(params[:attendance][:id])
    # binding.pry
    if params[:attendance][:scheduled_end_time].blank? || params[:attendance][:instructor_sign].blank?
      flash[:danger] = "必須箇所が空欄です。"
      redirect_to @user
    else
      @attendance.update_attributes(overtime_params)
      flash[:success] = "残業申請が完了しました。"
      redirect_to @user and return
    end
  end
  
  def edit_overtime_work_info
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    @users = User.all
  end
  
  def update_overtime_work_info
    @user = User.find(params[:user_id])
    ActiveRecord::Base.transaction do
      overtimes_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
      flash[:success] = "残業申請の変更を送信しました。"
      redirect_to user_url(current_user)
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "変更にチェックを入れてください。"
      redirect_to user_url(current_user)
  end
  
  def update_one_month_info
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(user_id: @user.id, worked_on: @first_day)
    if params[:user][:attendances][:one_month_sign].present?
      @attendance.update_attributes(month_params)
      flash[:success] = "1ヶ月分の勤怠承認を申請しました。"
      redirect_to user_path(@user, date: @first_day)
    else
      flash[:danger] = "所属長を選択してください。"
      redirect_to user_path(@user, date: @first_day)
    end
  end
  
  def edit_month_work_info
    @users = User.all
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
  end
  
  def update_month_work_info
    @user = User.find(params[:user_id])
    ActiveRecord::Base.transaction do
      month_request_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
      flash[:success] = "１ヵ月分の勤怠変更を送信しました。"
      redirect_to user_url(current_user)
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "変更にチェックを入れてください。"
      redirect_to user_url(current_user)
  end
  
  def edit_worked_info
    @users = User.all
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
  end
  
  def update_worked_info
    @user = User.find(params[:user_id])
      worked_request_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.update_attributes!(item)
     end
      flash[:success] = "勤怠変更を送信しました。"
      redirect_to user_url(current_user)
  end
  
  private
    
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :applying_started_at, :applying_finished_at, :note, :next_day, :worked_request_sign, :worked_status, :worked_change])[:attendances]
    end
    
    def overtime_params
      params.require(:attendance).permit(:scheduled_end_time, :next_day, :business_description, :instructor_sign, :overtime_status, :overtime_change)
    end
    
    def overtimes_params
      params.require(:user).permit(attendances: [:overtime_status, :overtime_change])[:attendances]
    end
    
    def month_params
      params.require(:user).permit(attendances: [:one_month_sign, :month_status, :month_change, :worked_month])[:attendances]
    end
    
    def month_request_params
      params.require(:user).permit(attendances: [:month_status, :month_change])[:attendances]
    end
    
    def worked_request_params
      params.require(:user).permit(attendances: [:approval_started, :approval_finished, :denial_started, :denial_finished, :worked_status, :worked_change, :approval_date])[:attendances]
    end
    
     def admin_or_correct_user
       @user = User.find(params[:user_id]) if @user.blank?
       unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
       end
     end
     
end
