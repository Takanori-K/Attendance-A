class UsersController < ApplicationController
  
  before_action :set_user,       only: [:show, :edit, :update, :destroy, :admin_update, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :logged_in_new_or_login, only: :new
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:index, :import, :destroy, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :set_one_month,  only: :show
  before_action :superior_or_correct_user, only: :show
  before_action :admin_user_show_edit_one_month, only: :show
  
  def new
    @user = User.new
  end
  
  def index
    @users = User.where(admin: [nil, false]).order(:id)
    if params[:id].present?
      @user = User.find_by(id: @users.id)
    else
      @user = User.new
    end
  end
  
  def admin_update
    @users = User.where.not(admin: true).order(:id)
    if @user.update_attributes(users_params)
      flash[:success] = "#{@user.name}のアカウント情報の更新に成功しました。"
    else
      flash[:danger] = "アカウント情報の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def import
    if params[:file].blank?
      flash[:danger] = "CSVファイルを選択して下さい。"
      redirect_to users_url
    else
      User.import(params[:file])
      flash[:success] = "CSVファイルをインポートしました。"
      redirect_to users_url
    end
  end
  
  def show
    @superior = Attendance.find_by(user_id: @user.id)
    @attendance = Attendance.find(params[:id])
    @worked_sum = @attendances.where.not(started_at: nil).count
    @users = User.all
    @month_request = Attendance.where.not(one_month_sign: nil).where.not(worked_month: nil)
    @count_2 = Attendance.where(instructor_sign: current_user.name).where(overtime_change: "false").where(overtime_status: [1, 2]).count
    @count = Attendance.where(instructor_sign: current_user.name).where(overtime_change: ["true", "false"]).where(overtime_status: 0).count
    
    @notice = Attendance.where(instructor_sign: current_user.name).where(overtime_change: ["true", "false"]).where(overtime_status: 0)
    @notice_2 = Attendance.where(instructor_sign: current_user.name).where(overtime_change: "false").where(overtime_status: [1, 2])
    
    @superiors = User.where.not(id: current_user.id).where(superior: true)
    
    @month = Attendance.where(one_month_sign: current_user.name).where(month_change: ["true", "false"]).where(month_status: 0)
    @month_2 = Attendance.where(one_month_sign: current_user.name).where(month_change: "false").where(month_status: [1, 2])
    
    @month_count = Attendance.where(one_month_sign: current_user.name).where(month_change: ["true", "false"]).where(month_status: 0).count
    @month_2_count = Attendance.where(one_month_sign: current_user.name).where(month_change: "false").where(month_status: [1, 2]).count
    
    @worked_request = Attendance.where(worked_request_sign: current_user.name).where(worked_change: "false").where(worked_status: 0)
    @worked_request_2 = Attendance.where(worked_request_sign: current_user.name).where(worked_change: "false").where(worked_status: [1, 2])
    
    @worked_count = Attendance.where(worked_request_sign: current_user.name).where(worked_change: ["true", "false"]).where(worked_status: 0).count
    @worked_count_2 = Attendance.where(worked_request_sign: current_user.name).where(worked_change: "false").where(worked_status: [1, 2]).count
   
    respond_to do |format|
      format.html do
      end 
      format.csv do
          #csv用の処理を書く
          send_data render_to_string, filename: "attendance.csv", type: :csv
      end
    end
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "新規作成しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      if @user.admin?
        redirect_to users_url
      else  
        redirect_to @user
      end
    else
      render :edit
    end
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def working_employee
    @working_users = Attendance.where.not(started_at: nil).where(finished_at: nil).where(worked_on: Date.today)
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
    
  
  private
    
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation, :employee_number, :uid)
    end
    
    def users_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation, :employee_number, :uid,
                                   :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end                               
    
    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_time, :work_time)
    end
    
end    