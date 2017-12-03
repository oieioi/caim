module Caim
  module Models

    class Model
      include Enumerable
      def each
        @list.each {|item| yield item }
      end

      def size
        @list.size
      end

      def find_by_id id
        @@list.find {|item| item["id"] == id }
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
        @list.each.with_index {|item, index|
          item["index"] = num2var(index)
        }
      end
      def each
        @list.each {|item| yield item }
      end
      def find_by_id id
        @list.find {|item| item["id"] == id }
      end
      def [] index
        if index.class == String
          index = var2num(index)
        end
        @list[index]
      end
      def size
        @list.size
      end
      def var2num_table
        ("aa".."zz").to_a
      end
      def var2num var
        var2num_table.index var
      end
      def num2var num
        var2num_table[num]
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

      def self.all opt = {}
        all_with_key :money, opt
      end

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
