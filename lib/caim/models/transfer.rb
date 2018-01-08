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

      def initialize values
        super values, :transfer
      end
    end
  end
end
