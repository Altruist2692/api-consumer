class UsersController < ApplicationController
  def sign_in
    if request.post?
      data = Users::SignIn.new({
        email: params[:email],
        password: params[:password]
      }).call
      if data[:error].present?
        flash.now[:error] = data[:error]
      elsif data[:user].present?
        session[:user_id] = data[:user].id
        redirect_to root_path
        @posts = Posts::List.new(current_user, false).call
      end
    end
  end

  def sign_up
    if request.post?
      data = Users::SignUp.new({
        email: params[:email],
        password: params[:password]
      }).call
      if data[:error].present?
        flash.now[:error] = data[:error]
      elsif data[:user].present?
        session[:user_id] = data[:user].id
        redirect_to root_path
        @posts = Posts::List.new(current_user, false).call
      end
    end
  end

  def sign_out
    Users::SignOut.new(user: current_user).call
    session.clear
    redirect_to users_sign_in_path
  end
end
