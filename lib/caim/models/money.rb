module Caim
  module Models
    class Money < Model

      def self.attrs
        raise 'not implemented'
      end

      def self.resource_name
        "money"
      end

      def initialize values, mode = nil
        @mode = mode
        super values
        if self[:mode].present?
          @mode = self[:mode]
        end
      end

      def path
        id.nil? ? "/v2/home/money/#{@mode.to_s}" : "/v2/home/money/#{@mode.to_s}/#{id}"
      end
    end

    class Moneys < Collection

      def model_class
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
        queried = path
        queried << "?#{query}" if query.present?
        result = API.get queried
        set_new_list result["money"]
        self
      end

    end
  end
end
