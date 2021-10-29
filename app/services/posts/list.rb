require "uri"
require "json"
require "net/http"

class Posts::List
  attr_accessor :token, :public_posts

  BASE_URL = 'http://localhost:3000'

  def initialize(token, public_posts = true)
    @token = token
    @public_posts = public_posts
  end

  def call
    if public_posts
      url = URI("#{BASE_URL}/api/v1/posts/public_posts")
      http = Net::HTTP.new(url.host, url.port);
      request = Net::HTTP::Get.new(url)
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      response = http.request(request)
      JSON.parse(response.read_body)['data']
    else
      url = URI("#{BASE_URL}/api/v1/posts")
      http = Net::HTTP.new(url.host, url.port);
      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Bearer #{token}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
  
      response = http.request(request)
      JSON.parse(response.read_body)['data']
    end


    
  end
end