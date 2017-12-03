module Caim
  module Models
    class Model

      def self.key
        self::MODEL_KEY
      end

      def self.all
        all_with_key key
      end

      private
      def self.all_with_key key
        key = key.to_s
        keys = key.pluralize
        cache = Cache.get(keys.to_sym)

        if cache.blank?
          result = API.get "/v2/home/#{key}"
          obj = {}
          obj[keys.to_sym] = result[keys]
          Cache.save obj
          cache = Cache.get(keys.to_sym)
        end

        @@list = Collection.new cache
        return @@list
      end
    end
  end
end