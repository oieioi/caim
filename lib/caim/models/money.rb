module Caim
  module Models
    class Money < Model
      MODEL_KEY = :money

      def self.attrs
        raise 'not implemented'
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

      def save
        result = API.post request_path, to_h
        if result["money"]
          @id = result["money"]["id"]
        else
          raise "failed save:" + result['message']
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
    end

    class Moneys < Collection

      def model
        Money
      end

      def where param
        param = param.dup

        if param[:time].present?
           param[:start_date] = param[:time].beginning_of_month.strftime("%Y-%m-%d")
           param[:end_date] = param[:time].end_of_month.strftime("%Y-%m-%d")
           param.delete :time
        end

        fetch param.to_param
      end

      def fetch query = nil
        queried = root_path
        queried << "?#{query}" if query.present?
        result = API.get queried
        set_new_list result["money"]
        self
      end

    end
  end
end
