class User < ApplicationRecord
  def display_name
    email.split('@').first
  end
end
