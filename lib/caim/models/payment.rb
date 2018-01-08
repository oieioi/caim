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

      def initialize values
        super values, :payment
      end
    end
  end
end
