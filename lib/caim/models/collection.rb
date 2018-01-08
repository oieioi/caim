module Caim
  module Models
    class Collection
      include Enumerable

      attr_accessor :list
      def initialize opt = {}
        opt = {fetch: true}.merge opt

        @list = []
        fetch if opt[:fetch].present?
        self
      end

      def model_class
        raise 'not implemnted!'
      end

      def resource_name
        model_class.resource_name
      end

      def resource_names
        resource_name.pluralize
      end

      def path
        "/v2/home/#{resource_name}"
      end

      def fetch
        cache = Cache.get(resource_names.to_sym)

        if cache.blank?
          result = API.get path
          obj = {}
          obj[resource_names.to_sym] = result[resource_names]
          Cache.save obj
          cache = Cache.get(resource_names.to_sym)
        end

        set_new_list cache
        self
      end

      def each
        @list.each {|item| yield item if item.active?}
      end

      def find_by name, id
        id = id.to_i
        @list.find {|item| item.send(name.to_sym) == id }
      end

      def [] index
        if index =~ /^[a-z]+$/
          index = var2num(index)
          @list[index]
        else
          by_id = find_by :id, index
          return by_id if by_id.present?

          by_local_id = find_by :local_id, index
          return by_local_id if by_local_id.present?
        end
      end

      def size
        @list.size
      end

      def sort!
        @list = @list.sort
      end

      private
      def var2num_table
        ('a'..'zz').to_a
      end

      def var2num var
        var2num_table.index var
      end

      def num2var num
        var2num_table[num]
      end

      def set_new_list list
        @list = list.map.with_index {|raw_model, index|
          raw_model['index'] = num2var index
          model_class.new raw_model
        }
      end
    end
  end
end
