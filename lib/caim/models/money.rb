module Caim
  module Models
    class Money < Model
      MODEL_KEY = :money

      def self.where param
        param = param.dup

        if param[:time].present?
           param[:start_date] = param[:time].beginning_of_month.strftime("%Y-%m-%d")
           param[:end_date] = param[:time].end_of_month.strftime("%Y-%m-%d")
           param.delete :time
        end

        self.fetch param.to_param
      end

      # TODO: Models::base なんとかする
      def self.all
        self.fetch
      end

      def self.attrs
        raise 'not implemented'
      end

      def initialize mode, values
        @mode = mode
        self.class.attrs.each {|name|
          self.send("#{name}=".to_sym, values[name])
        }
      end

      def to_h
        result = {
          mapping: 1,
        }
        self.class.attrs.each{|name|
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
        result = API.post request_path, to_h
        if result["money"]
          @id = result["money"]["id"]
        else
          raise "failed save"
        end
      end

      def destroy

        if @id.nil?
          raise 'nothing ID, Undeletable!'
        end

        result = API.delete request_path
        if result["money"]
          @id = result["money"]["id"]
        else
          raise "failed destroy"
        end
      end

      private
      def request_path
        @id.nil? ? "/v2/home/money/#{@mode.to_s}" : "/v2/home/money/#{@mode.to_s}/#{@id.to_s}"
      end

      # TODO: Models::base なんとかする
      def self.fetch query = nil
        url = "/v2/home/money"
        url << "?#{query}" if query.present?
        result = API.get url
        @@list = Collection.new result["money"]
      end

    end
  end
end
