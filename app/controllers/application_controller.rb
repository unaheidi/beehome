class ApplicationController < ActionController::Base
  protect_from_forgery
  attr_accessor :nav

  def current_user
    session[:user]
  end

  def login?
    current_user
  end

  def authorize_user
    redirect_to :login unless login?
  end

  helper_method :nav
  helper_method :current_user
  helper_method :login?
end
