
class HomeController < ApplicationController
  before_action :authenticate_user, except: :public_posts

  def index
    data = Posts::List.new(current_user, false).call
    if data[:error]
      flash.now[:error] = 'Unauthorized user access. Please login again'
      redirect_to users_sign_in_path 
    else
      @posts = data['data']
    end
  end

  def public_posts
    data = Posts::List.new(current_user).call
    @posts = data['data']
  end
end
