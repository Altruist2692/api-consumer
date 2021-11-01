Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'

  namespace :users do
    match 'sign_in', via: [:get, :post]
    match 'sign_up', via: [:get, :post]
    delete 'sign_out'
  end
  get 'public_posts' => 'home#public_posts'
end
