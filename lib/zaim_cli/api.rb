require 'oauth'

module ZaimCli
  class API
    def self.get endpoint_path
      result = endpoint.get "https://api.zaim.net#{endpoint_path}"
      JSON.parse(result.body)
    end

    def self.post endpoint_path, body
      result = endpoint.post "https://api.zaim.net#{endpoint_path}", body
      JSON.parse(result.body)
    end

    private
    def self.endpoint
      tokens = Cache.get(:auth)
      consumer = OAuth.consumer
      ::OAuth::AccessToken.new(consumer, tokens[:token], tokens[:secret])
    end
  end
end
