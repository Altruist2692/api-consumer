require 'monitor'

class JwtParser
  ALGORITHM = 'RS256'.freeze
  JWT_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAllEa6vln6m7wmfoEK6YO\n4bS3mWwQw+007fxRxxaU4ocowPljBhOMgaeOWgEJpgKxFBh3Dyul20oeF9Swvyw6\n00jko6UiGS9YCb8JiWOACXrv+I0bQcRJYnJch/l+ZS2kDLZzu2f2YKJkZdLlIUqt\neuKRGa03N1UNXjPK3rlrNdCvSRHZ+o3SCcLQL/Cvd2+tZFlrLCcVGpZZwBL2Nh4O\nPgvSQKlqOQ71dnXfl2uZK7dxIhXhzc1zb51K/vfgRIClszaeh8Hhn3e22m8CODCB\ngB1har6Ei3NS81FOiMiNEyLoAekq9q7dr7glMoGD/U3XWR2Gn8kRu/WlA/Hdg4p9\nQwIDAQAB\n-----END PUBLIC KEY-----"

  # rubocop:disable Metrics/AbcSize
  def decode(jwt_string)
    jwt = JSON::JWT.decode(jwt_string, :skip_verification)
    key = public_key(jwt.header['kid'])

    begin
      jwt.verify!(key, ALGORITHM.to_sym)
    rescue JSON::JWT::VerificationFailed => e
      Rails.logger.info("Verification failed; tried to verify against key ID #{jwt.header['kid']} with key #{key}")
      raise e
    end

    if jwt['exp'].present? && Time.current.to_i > jwt['exp']
      msg = 'Token has expired'
      raise JSON::JWT::VerificationFailed, msg
    end

    # 3 minute leeway for if servers have different times
    # https://tools.ietf.org/html/rfc7519#section-4.1.5
    if jwt['nbf'].present? && Time.current.to_i < (jwt['nbf'] - 180)
      msg = 'Token nbf (not before time) has not been reached'
      Rollbar.error(msg)
      raise JSON::JWT::VerificationFailed, msg
    end

    jwt
  end
  # rubocop:enable Metrics/AbcSize

  def public_key(key_id)
    jwk_json = Rails.cache.fetch("identity/jwt_parser/public_keys/#{key_id}", expires_in: 1.day) do
      if public_key_from_config['kid'] == key_id
        public_key_from_config.as_json
      else
        response = Net::HTTP.get(URI("#{ENV['AUTH_URL']}/oauth/jwks"))
        JSON.parse(response)['keys'].find { |jwk| jwk['kid'] == key_id }
      end
    end

    JSON::JWK.new(jwk_json)
  end

  private

  def public_key_from_config
    @public_key_from_config ||= if JWT_PUBLIC_KEY
                                  OpenSSL::PKey::RSA.new(JWT_PUBLIC_KEY).to_jwk
                                else
                                  JSON::JWK.new
                                end
  end
end
