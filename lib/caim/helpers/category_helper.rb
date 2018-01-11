require 'terminal-table'

module Caim
  module Helpers
    module CategoryHelper
      extend self

      def table categories
        ::Terminal::Table.new({
          headings: %w{index id mode name},
          rows: categories.map {|c|[c[:index], c[:id], c[:mode], c[:name]]}
        })
      end

    end
  end
end
