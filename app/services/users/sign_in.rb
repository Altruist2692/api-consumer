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
    req = Net::HTTP::Post.new(url)
    req['Content-Type'] = 'application/json'
    req.body = JSON.dump({
                           grant_type: GRANT_TYPE,
                           client_id: Rails.application.credentials.send(Rails.env)[:app][:client_id],
                           client_secret: Rails.application.credentials.send(Rails.env)[:app][:client_secret],
                           email: email,
                           password: password
                         })

    response = http.request(req)
    data = JSON.parse response.read_body
    JwtParser.new.decode(data["access_token"])
    data
  end
end
