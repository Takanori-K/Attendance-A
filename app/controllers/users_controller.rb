class UsersController < ApplicationController
  
  before_action :set_user,       only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:index, :import, :destroy, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :set_one_month,  only: :show
  before_action :superior_or_correct_user, only: :show
  
  def new
    @user = User.new
  end
  
  def index
    @users = User.where.not(admin: true)
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
    @worked_request = Attendance.where(worked_request_sign: current_user.name).where(worked_change: "0")
    @worked_count = Attendance.where(worked_request_sign: current_user.name, worked_status: 0).count
   
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
      redirect_to @user
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
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation, :employee_number, :uid,
                                   :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_time, :work_time)
    end
    
    def superior_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.superior?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end
    end
end    