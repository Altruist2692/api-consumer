class ApplicationController < ActionController::Base
  helper_method :current_user
  def authenticate_user
    unless current_user
      redirect_to users_sign_in_path
    end
  end
  
  def current_user
    begin
      @current_user ||= User.find(session[:user_id])
    rescue
    end
  end
end
