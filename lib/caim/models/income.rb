module Caim
  module Models
    class Income < Money
      def self.attrs
        [
          :id,
          :category_id,
          :amount,
          :date,
          :to_account_id,
          :place,
          :comment,
        ]
      end

      def initialize values
        super values, :income
      end
    end
  end
end
