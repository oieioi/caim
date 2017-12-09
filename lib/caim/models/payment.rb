module Caim
  module Models
    class Payment < Money
      def self.attrs
        [
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
      end
      attr_accessor(*self.attrs)

      def initialize values
        super :payment, values
      end
    end
  end
end
