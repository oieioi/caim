module ZaimCli
  module Models

    class Model
      include Enumerable
      def each
        @list.each {|item| yield item }
      end
      def size
        @list.size
      end
      def [] id
        @@list.find {|item| item["id"] == id }
      end

      private
      def self.all_with_key key, opt
        force = opt[:force]
        key = key.to_s
        keys = key.pluralize
        cache = Cache.get(keys.to_sym)

        if not force && cache.present?
          @@list = Collection.new cache
          return @@list
        end

        api = API.new "/v2/home/#{key}", :get
        result =  api.request
        obj = {}
        obj[keys.to_sym] = result[keys]
        Cache.save obj
        @@list = Collection.new result
      end
    end

    class Collection
      include Enumerable
      def initialize list
        @list = list
      end
      def each
        @list.each {|item| yield item }
      end
      def [] id
        @list.find {|item| item["id"] == id }
      end
      def size
        @list.size
      end
    end

    class Category < Model
      def self.all opt = {}
        all_with_key :category, opt
      end
    end

    class Genre < Model
      def self.all opt = {}
        all_with_key :genre, opt
      end
    end

    class Account < Model
      def self.all opt = {}
        all_with_key :account, opt
      end
    end

    class Money < Model
      def self.where time:
        url = "/v2/home/money?start_date=#{time.beginning_of_month.strftime("%Y-%m-%d")}&end_date=#{time.end_of_month.strftime("%Y-%m-%d")}"
        api = API.new url, :get
        @@list = Collection.new api.request["money"]
      end

    end
  end

end
