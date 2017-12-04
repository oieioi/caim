module Caim
  module Models
    class Collection
      include Enumerable

      def initialize list
        @list = list
        @list.each.with_index {|item, index|
          item["index"] = num2var(index)
        }
      end

      def each
        @list.each {|item| yield item }
      end

      def find_by_id id
        @list.find {|item| item["id"] == id }
      end

      def [] index
        if index =~ /^[a-z]+$/
          index = var2num(index)
        end
        @list[index]
      end

      def size
        @list.size
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

    end
  end
end
