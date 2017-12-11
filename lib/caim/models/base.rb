module Caim
  module Models
    class Model

      def self.key
        self::MODEL_KEY
      end

      def self.all opt = {}
        all_with_key key, opt
      end

      private
      def self.all_with_key key, opt = {}
        key = key.to_s
        keys = key.pluralize
        cache = Cache.get(keys.to_sym)
        cache = nil if opt[:update].present?

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
