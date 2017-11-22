require 'thor'
require 'yaml'
require 'json'
require 'oauth'
require 'byebug'

module ZaimCli
  class CLI < Thor

    desc "list", "list zaim"
    def list
      tokens = YAML.load(File.open('config.yml'))
      consumer = OAuth.consumer
      endpoint = ::OAuth::AccessToken.new(consumer, tokens[:token], tokens[:secret])
      r = endpoint.get('https://api.zaim.net/v2/home/money?start_date=2017-11-01&end_date=2017-11-30&page=1&limit=10')
      list = JSON.parse(r.body)
      list["money"].each {|m|
        puts [
          m["id"],
          m["date"],
          m["amount"],
          m["category_id"],
          m["genre_id"],
          m["name"]
        ].join(',')
      }

    end

    desc "login", "login"
    def login
      OAuth.get_access_token
    end
  end
end
