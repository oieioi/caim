require 'terminal-table'

module Caim
  module Helpers
    module CategoryHelper
      extend self

      def table categories
        ::Terminal::Table.new({
          headings: %w{index mode name},
          rows: categories.map {|c|[c[:index], c[:mode], c[:name]]}
        })
      end

    end
  end
end
