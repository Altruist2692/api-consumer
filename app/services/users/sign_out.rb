# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

class Users::SignOut
  attr_accessor :user

  BASE_URL = 'http://localhost:3000'

  def initialize(options = {})
    @user = options[:user]
  end

  def call
    url = URI("#{BASE_URL}/oauth/revoke")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = JSON.dump({
                               client_id: Rails.application.credentials.send(Rails.env)[:app][:client_id],
                               client_secret: Rails.application.credentials.send(Rails.env)[:app][:client_secret],
                               token: user.access_token
                             })

    response = http.request(request)
    JSON.parse response.read_body
  end
end
