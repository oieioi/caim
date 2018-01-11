require 'terminal-table'

module Caim
  module Helpers
    module GenreHelper
      extend self

      def table genres
        categories = Models::Categories.new
        ::Terminal::Table.new({
          headings: %w{index category name},
          rows: genres
          .map {|g|
          category = categories[g[:category_id]]
          [
            g[:index],
            category[:name],
            g[:name]
          ]
        }
        })
      end
    end
  end
end
