require 'oauth'

module ZaimCli
  class API
    def initialize endpoint_path, method
      @tokens = Cache.get(:auth)
      @consumer = OAuth.consumer
      @endpoint = ::OAuth::AccessToken.new(@consumer, @tokens[:token], @tokens[:secret])
      @endpoint_path = endpoint_path
      @method = method
    end

    def request
      r = @endpoint.send(@method, "https://api.zaim.net#{@endpoint_path}")
      JSON.parse(r.body)
    end
  end
end
