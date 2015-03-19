class UsersController < ApplicationController
  before_filter { self.nav = 'alpha' }

  def login
    if request.get?
    elsif request.post?
      if authorize_user?(params[:username], params[:password])
        flash[:success] = '登陆成功'

        session[:user] = params[:username]

        redirect_to '/alpha'
      else
        flash[:danger] = '登陆失败:用户名或密码不正确!'

        redirect_to '/login'
      end
    end
  end

  def logout
    session.clear

    flash[:success] = '退出成功'

    redirect_to :login
  end

  private

  def authorize_user?(username, password)
    Settings.admin.username == username &&
      Settings.admin.password == password
  end
end
