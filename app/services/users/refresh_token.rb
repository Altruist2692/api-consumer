class Users::RefreshToken
  GRANT_TYPE = 'refresh_token'
  BASE_URL = 'http://localhost:3000'

  def initialize(options = {})
    @user = user
  end

  def call
    url = URI("#{BASE_URL}/oauth/token")
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new(url)
    req['Content-Type'] = 'application/json'
    req.body = JSON.dump({
                           grant_type: GRANT_TYPE,
                           refresh_token: user.refresh_token,
                           client_id: Rails.application.credentials.send(Rails.env)[:app][:client_id],
                           client_secret: Rails.application.credentials.send(Rails.env)[:app][:client_secret],
                         })

    response = http.request(req)
    data = JSON.parse response.read_body
    JwtParser.new.decode(data["access_token"])
    data
end