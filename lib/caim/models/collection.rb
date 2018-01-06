module Caim
  module Models
    class Collection
      include Enumerable

      attr_accessor :list
      def initialize opt = {}
        opt = {fetch: true}.merge opt

        @Model = model
        @list = []
        fetch if opt[:fetch].present?
        self
      end

      def model
        raise 'not implemnted!'
      end

      def key
        @Model::MODEL_KEY.to_s
      end

      def root_path
        "/v2/home/#{key}"
      end

      def fetch
        keys = key.pluralize
        cache = Cache.get(keys.to_sym)

        if cache.blank?
          result = API.get root_path
          obj = {}
          obj[keys.to_sym] = result[keys]
          Cache.save obj
          cache = Cache.get(keys.to_sym)
        end

        set_new_list cache
        self
      end

      def each
        @list.each {|item| yield item if item.active?}
      end

      def find_by_id id
        id = id.to_i
        @list.find {|item| item["id"] == id }
      end

      def [] index
        if index =~ /^[a-z]+$/
          index = var2num(index)
          @list[index]
        else
          find_by_id index
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
          model.new raw_model
        }
      end
    end
  end
end
