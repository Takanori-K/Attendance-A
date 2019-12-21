class BasesController < ApplicationController
  before_action :set_base, only: [:edit, :update, :destroy]
  before_action :logged_in_user
  before_action :admin_user
  
  def new
    @base = Base.new
  end
  
  def index
    @bases = Base.all
  end
  
  def edit
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点情報を追加しました。"
    else
      flash[:danger] = "拠点情報の追加は失敗しました。</br>" + @base.errors.full_messages.join("<br>")
    end
    redirect_to bases_url  
  end
  
  def update
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を更新しました。"
    else
      flash[:danger] = "拠点情報の更新は失敗しました。</br>" + @base.errors.full_messages.join("</br>")
    end
    redirect_to bases_url
  end
  
  def destroy
    @base.destroy
    
    flash[:success] = "拠点情報を削除しました。"
    redirect_to bases_url
  end
  
  private
    
    def base_params
      params.require(:base).permit(:base_number, :base_name, :base_type)
    end
    
    #beforeフィルター
    def set_base
      @base = Base.find(params[:id])
    end
end
