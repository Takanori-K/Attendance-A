class UsersController < ApplicationController
  
  before_action :set_user,       only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :set_one_month,  only: :show
  
  
  def new
    @user = User.new
  end
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def show
    @attendance = Attendance.find(params[:id])
    @worked_sum = @attendances.where.not(started_at: nil).count
    @users = User.all
    @count = Attendance.where(instructor_sign: current_user.name, overtime_status: 0).count
    @notice = Attendance.where(instructor_sign: current_user.name).where(overtime_status: 0)
    @superiors = User.where.not(id: current_user.id).where(superior: true)
    @month = Attendance.where(one_month_sign: current_user.name)
   
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
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_time, :work_time)
    end
end    