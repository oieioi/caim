require 'oauth'
require 'yaml'

module ZaimCli
  module OAuth
    extend self

    SECRET = "a17971fa3cf20ac3b82cc60494fac5ead8335df6"
    KEY = "6fb7889473645591e373148d7db8d49923b80257"

    def consumer
      ::OAuth::Consumer.new(
        KEY,
        SECRET,
        request_token_path: "https://api.zaim.net/v2/auth/request",
        access_token_path: "https://api.zaim.net/v2/auth/access",
        authorize_path: "https://auth.zaim.net/users/auth"
      )
    end

    def get_access_token
      consumer = self.consumer

      begin
        request_token = consumer.get_request_token
      rescue => e
        puts "だめ！"
        puts e.message
        raise e
      end
      puts "1) OAuth #{request_token.authorize_url}"
      puts "2) Enter token:"
      token = STDIN.gets.strip

      access_token = request_token.get_access_token(:oauth_verifier => token)

      YAML.dump({
        token: access_token.token,
        secret: access_token.secret
      }, File.open('config.yml', 'w'))

      puts 'authed!'
    end
  end
end
