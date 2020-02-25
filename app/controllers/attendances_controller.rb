class AttendancesController < ApplicationController
  
  before_action :set_user,       only: [:edit_one_month, :update_one_month, :edit_overtime_work, :update_overtime_work, :update_one_month_info, :worked_log]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overtime_work, :update_overtime_work]
  before_action :correct_user,   only: [:edit_one_month, :update_one_month, :edit_overtime_work, :update_overtime_work, :worked_log]
  #before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month,  only: [:edit_one_month,:update_one_month_info, :worked_log]
  before_action :superior_user, only: [:edit_overtime_work_info, :edit_month_work_info, :update_month_work_info, :edit_worked_info, :update_worked_info]
  before_action :admin_user_show_edit_one_month, only: :edit_one_month
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
    if attendances_invalid?  #helperメソッド(true or flase)
      attendances = []
      params[:user][:attendances].each do |id|
        Attendance.where(id: id.to_i).each do |attendance|
          if params[:user][:attendances][id][:worked_request_sign].present?
            attendance.applying_started_at =  params[:user][:attendances][id][:applying_started_at]
            attendance.applying_finished_at = params[:user][:attendances][id][:applying_finished_at]
            attendance.edit_tomorrow = params[:user][:attendances][id][:edit_tomorrow]
            attendance.edit_note = params[:user][:attendances][id][:edit_note]
            attendance.worked_request_sign = params[:user][:attendances][id][:worked_request_sign]
            attendance.worked_change = params[:user][:attendances][id][:worked_change]
            attendance.worked_status = params[:user][:attendances][id][:worked_status]
            attendances << attendance
          end
        end
      end
      Attendance.import(attendances, on_duplicate_key_update: [:applying_started_at, :applying_finished_at, :edit_tomorrow,
                                                               :edit_note, :worked_request_sign, :worked_change, :worked_status])
      flash[:success] = "必須項目記入済みの勤怠変更を申請しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = "不正な時間入力、または未入力のため勤怠変更を送信できませんでした。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end
  end
  
  def worked_log
    @all_worked_on = Attendance.where(user_id: current_user.id)
    if params[:search].present?
      @attendances_search = @all_worked_on.where(worked_on: Date.parse("#{params[:search]}-01").all_month).order(:worked_on)
    else
      @attendances_search = @all_worked_on.where(worked_on: @first_day..@last_day).order(:worked_on)
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
    if params[:attendance][:scheduled_end_time].blank? || params[:attendance][:instructor_sign].blank? || params[:attendance][:business_description].blank?
      flash[:danger] = "必須箇所が空欄です。"
      redirect_to user_url(date: @attendance.worked_on)
    else
      @attendance.update_attributes(overtime_params)
      flash[:success] = "残業申請が完了しました。"
      redirect_to user_url(date: @attendance.worked_on) and return
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
      flash[:success] = "変更にチェック済みの残業申請の変更を送信しました。"
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
      flash[:success] = "#{l(@attendance.worked_month, format: :middle)}の勤怠承認を申請しました。"
      redirect_to user_path(@user, date: @first_day)
    else
      flash[:danger] = "所属長を選択してください。"
      redirect_to user_path(@user, date: @first_day)
    end
  end
  
  def edit_month_work_info
    @users = User.all
    @user = User.find(params[:user_id])
  end
  
  def update_month_work_info
    @user = User.find(params[:user_id])
    ActiveRecord::Base.transaction do
      month_request_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
      flash[:success] = "変更にチェック済みの勤怠承認を送信しました。"
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
      if item[:worked_change] == "true"
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
      flash[:success] = "変更にチェック済みの勤怠変更を送信しました。"
      redirect_to user_url(current_user)
  end
  
  private
    
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :applying_started_at, :applying_finished_at, :denial_started, :denial_finished, :note, :edit_note, :tomorrow, :edit_tomorrow, :worked_request_sign, :edit_request_sign, :denial_request_sign, :worked_status, :worked_change])[:attendances]
    end
    
    def attendances_reset_params
      params.require(:user).permit(attendances: [:started_at])[:attendances]
    end
    
    def overtime_params
      params.require(:attendance).permit(:scheduled_end_time, :next_day, :edit_next_day, :business_description, :instructor_sign, :overtime_status, :overtime_change, :approval_business_description, :approval_end_time)
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
