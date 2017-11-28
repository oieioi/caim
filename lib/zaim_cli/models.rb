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

      def each
        keys = instance_variables

      end

      private
      def self.all_with_key key, opt
        key = key.to_s
        keys = key.pluralize
        cache = Cache.get(keys.to_sym)

        if cache.blank?
          result = API.get "/v2/home/#{key}"
          obj = {}
          obj[keys.to_sym] = result[keys]
          Cache.save obj
          cache = Cache.get(keys.to_sym)
        end

        @@list = Collection.new cache
        return @@list
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
      attr_accessor :id, :amount, :category, :genre, :date, :account, :comment, :place, :name
      def self.where time:
        url = "/v2/home/money?start_date=#{time.beginning_of_month.strftime("%Y-%m-%d")}&end_date=#{time.end_of_month.strftime("%Y-%m-%d")}"
        result = API.get url
        @@list = Collection.new result["money"]
      end

      def initialize id:, amount:, category:, genre:, date:, account:, comment:, place:, name:
        @id       = id
        @amount   = amount.to_i
        @category = category.to_i
        @genre    = genre.to_i
        @account  = account.to_i
        @date     = date
        @comment  = comment
        @name     = name
        @place    = place
      end

      def to_h
        {
          mapping: 1,
          category_id: @category,
          genre_id: @genre,
          amount: @amount,
          date: @date,
          from_account_id: @account,
          comment: @comment,
          name: @name,
          place: @place,
        }
      end

      def fetch
        raise 'not implemented'
      end

      def save
        path = @id.nil? ? "/v2/home/money/payment" : "/v2/home/money/payment/#{@id.to_s}"
        result = API.post path, to_h
        if result["money"]
          @id = result["money"]["id"]
        else
          raise "failed save"
        end
      end

    end
  end

end
