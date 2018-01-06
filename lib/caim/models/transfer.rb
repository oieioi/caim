module Caim
  module Models
    class Transfer < Money
      def self.attrs
        [
          :id,
          :amount,
          :date,
          :from_account_id,
          :to_account_id,
          :comment,
        ]
      end
      attr_accessor(*self.attrs)

      def initialize values
        super :transfer, values
      end
    end
  end
end
