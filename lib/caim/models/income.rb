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
      attr_accessor(*self.attrs)

      def initialize values
        super :income, values
      end
    end
  end
end
