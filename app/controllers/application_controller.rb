class ApplicationController < ActionController::Base
  protect_from_forgery
  attr_accessor :nav

  helper_method :nav
end
