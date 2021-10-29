# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'


class Users::SignOut
  attr_accessor :user

  BASE_URL = 'http://localhost:3000'

  def initialize(options = {})
    @user = user
  end

  def call
    url = URI("#{BASE_URL}/oauth/revoke")
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new(url)
    req['Content-Type'] = 'application/json'
    req.body = JSON.dump({
                           client_id: Rails.application.credentials.send(Rails.env)[:app][:client_id],
                           client_secret: Rails.application.credentials.send(Rails.env)[:app][:client_secret],
                           token: user.access_token
                         })

    response = http.request(req)
    data = JSON.parse response.read_body
    data
  end
end
