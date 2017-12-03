module Caim
  module Models
    class Money < Model
      @@attrs = [
        :id,
        :amount,
        :category_id,
        :genre_id,
        :date,
        :from_account_id,
        :comment,
        :place,
        :name
      ]
      attr_accessor(*@@attrs)

      def self.where time:
        url = "/v2/home/money?start_date=#{time.beginning_of_month.strftime("%Y-%m-%d")}&end_date=#{time.end_of_month.strftime("%Y-%m-%d")}"
        result = API.get url
        @@list = Collection.new result["money"]
      end

      def initialize values
        @@attrs.each {|name|
          self.send("#{name}=".to_sym, values[name])
        }
      end

      def to_h
        result = {
          mapping: 1,
        }
        @@attrs.each{|name|
          result[name] = self.send(name)
        }
        result
      end

      def to_s
        to_h.to_a.map{|item|
          key, value = item
          "#{key}: #{value}"
        }.join("\n")
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

      def destroy

      end

      private
      def path

      end
    end
  end
end
