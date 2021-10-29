
class HomeController < ApplicationController
  def index
    params = {
      email: 'nishant22@gmail.com',
      password: '12121212'
    }
    
    data = Users::SignIn.new(email: params[:email], password: params[:password]).call
    @posts = Posts::List.new(data["access_token"], false).call
  end
end
