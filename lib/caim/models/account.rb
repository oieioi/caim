module Caim
  module Models

    class Account < Model
    end

    class Accounts < Collection
      def model_class
        Account
      end
    end

  end
end
