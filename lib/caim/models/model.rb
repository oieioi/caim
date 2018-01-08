module Caim
  module Models
    class Model

      def self.resource_name
        self.name.split('::').last.downcase
      end

      def self.resource_names
        resource_name.pluralize
      end

      def initialize attrs = {}
        @attrs = {}
        attrs.each { |k, v| self[k] = v }
        self
      end

      def []= key, val
        key = key.to_sym
        @attrs[key] = val
      end

      def [] key
        key = key.to_sym
        @attrs[key]
      end

      def id
        self[:id]
      end

      def local_id
        self[:local_id]
      end

      def active?
        self[:active].to_i != -1
      end

      def <=> other
        self[:id] <=> other[:id]
      end

      def to_h
        result = { mapping: 1 }
        self.class.attrs.each{|name| result[name] = self[name] }
        result
      end

      def to_s
        to_h.to_a.map{|item|
          key, value = item
          "#{key}: #{value}"
        }.join("\n")
      end

      def save
        result = API.post path, to_h
        if result[self.class.resource_names]
          self[:id] = result[self.class.resource_names]["id"].to_i
        else
          raise "failed save:#{result['message']}"
        end
      end

      def destroy

        if id.nil?
          raise 'nothing ID, Unremovable!'
        end

        result = API.delete path
        if result[self.class.resource_names]
          self[:id] = result[self.class.resource_names]["id"]
        else
          raise "failed destroy"
        end
      end


    end
  end
end
