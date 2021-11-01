# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

class Users::SignIn
  attr_accessor :email, :password

  GRANT_TYPE = 'password'
  BASE_URL = 'http://localhost:3000'

  def initialize(options = {})
    @email = options[:email]
    @password = options[:password]
  end

  def call
    url = URI("#{BASE_URL}/oauth/token")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = JSON.dump({
                               grant_type: GRANT_TYPE,
                               client_id: Rails.application.credentials.send(Rails.env)[:app][:client_id],
                               client_secret: Rails.application.credentials.send(Rails.env)[:app][:client_secret],
                               email: email,
                               password: password
                             })

    response = http.request(request)
    data = JSON.parse response.read_body
    if data['error'].present?
      data = {
        error: data['error'].join(', '),
        message: data['error_description']
      }
    else
      decoded_jwt = JwtParser.new.decode(data['access_token'])
      if decoded_jwt
        user = User.find_by_resource_reference_id(decoded_jwt['sub'])
        user.update(access_token: data['access_token'])
        user.reload
        data[:user] = user
      end
    end
    data
  end
end
