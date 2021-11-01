require "uri"
require "json"
require "net/http"

class Posts::List
  attr_accessor :user, :public_posts

  BASE_URL = 'http://localhost:3000'

  def initialize(user, public_posts = true)
    @user = user
    @public_posts = public_posts
  end

  def call
    url = public_posts ? URI("#{BASE_URL}/api/v1/posts/public_posts") : URI("#{BASE_URL}/api/v1/posts") 
    http = Net::HTTP.new(url.host, url.port);
    request = Net::HTTP::Get.new(url)
    request['Authorization'] = "Bearer #{user.access_token}" unless public_posts
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    response = http.request(request)
    case response.code_type.to_s
    when 'Net::HTTPUnauthorized'
      { error: 'Not authorized' }
    when 'Net::HTTPOK'
      JSON.parse(response.read_body)
    end
  end
end