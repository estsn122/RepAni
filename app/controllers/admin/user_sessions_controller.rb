class Admin::UserSessionsController < Admin::BaseController
  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_ ack_or_to(admin_root_path, notice: 'ログインしました')
    else
      flash.now[:danger] = 'ログインに失敗しました'
      render :new
    end
  end

  def destroy
    logout
    redirect_to root_path, notice: 'ログアウトしました'
  end
end
