class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include AttendancesHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
  end

  # ログイン済みのユーザーか確認します。
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
  
  def logged_in_new_or_login
    if logged_in?
      flash[:danger] = "すでにログインしています。"
      redirect_to current_user
    end
  end

  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    unless current_user?(@user)
      flash[:danger] = "アクセス権限がありません。"
      redirect_to(root_url)
    end
  end

  # システム管理権限所有かどうか判定します。
  def admin_user
    unless current_user.admin?
      flash[:danger] = "アクセス権限がありません。"
      redirect_to root_url 
    end
  end
  
  def admin_user_show_edit_one_month
    if current_user.admin?
      flash[:danger] = "管理者に勤怠情報はありません。"
      redirect_to root_url
    end
  end
      
  
  def superior_user
    unless current_user.superior?
      flash[:danger] = "アクセス権限がありません。"
      redirect_to root_url
    end
  end
  
  def superior_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.superior?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end
  
  def set_one_month 
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
  
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
  
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  
  end
end
