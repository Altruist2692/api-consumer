# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

class Users::SignUp
  attr_accessor :email, :password

  BASE_URL = 'http://localhost:3000'

  def initialize(options = {})
    @email = options[:email]
    @password = options[:password]
  end

  def call
    url = URI("#{BASE_URL}/api/v1/users")

    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = JSON.dump({
                               "client_id": Rails.application.credentials.send(Rails.env)[:app][:client_id],
                               "email": email,
                               "password": password
                             })

    response = http.request(request)
    data = JSON.parse(response.read_body)
    user_data = data['user']
    if data['error'].present?
      {
        error: data['error'].join(', '),
        message: data['error_description']
      }
    else
      decoded_jwt = JwtParser.new.decode(user_data['access_token'])
      if decoded_jwt
        user = User.find_or_create_by({
          email: user_data['email'],
          access_token: user_data['access_token'],
          refresh_token: user_data['refresh_token'],
          resource_reference_id: decoded_jwt['sub']
        })
        data[:user] = user
      end
      data
    end
  end
end
