require 'terminal-table'

module Caim
  module Helpers
    module OutputHelper
      extend self

      def account_table accounts
        puts ::Terminal::Table.new({
          headings: %w{index id name},
          rows: accounts.map {|c| [ c[:index], c[:id], c[:name]]}
        })
      end

      def category_table categories
        puts ::Terminal::Table.new({
          headings: %w{index id mode name},
          rows: categories.map {|c|[c[:index], c[:id], c[:mode], c[:name]]}
        })
      end

      def genre_table genres
        categories = Models::Categories.new
        puts ::Terminal::Table.new({
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
