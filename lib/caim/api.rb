require 'oauth'

module Caim
  class API
    def self.get endpoint_path
      result = endpoint.get "https://api.zaim.net#{endpoint_path}"
      JSON.parse(result.body)
    end

    def self.post endpoint_path, body
      result = endpoint.post "https://api.zaim.net#{endpoint_path}", body, {
        'Accept'=>'application/json',
        'Content-Type' => 'application/json'
      }
      JSON.parse(result.body)
    end

    private
    def self.endpoint
      tokens = Cache.get(:auth)
      if tokens.nil?
        raise 'please login!'
      end
      consumer = OAuth.consumer
      ::OAuth::AccessToken.new(consumer, tokens[:token], tokens[:secret])
    end
  end
end
