module Caim
  module Models

    class Account < Model
      MODEL_KEY = :account
    end

    class Accounts < Collection
      def model
        Account
      end
    end

  end
end
