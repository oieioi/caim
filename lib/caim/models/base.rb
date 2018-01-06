module Caim
  module Models
    class Model

      def self.key
        self::MODEL_KEY
      end

      def initialize attrs = {}
        @attrs = attrs
      end

      def [] key
        key = key.to_s
        @attrs[key]
      end

      def id
        self[:id]
      end

      def active?
        self[:active].to_i != -1
      end

      def <=> other
        self[:id] <=> other[:id]
      end

    end
  end
end
