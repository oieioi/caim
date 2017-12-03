require 'terminal-table'

module Caim
  module OutputHelper
    extend self

    def account_table accounts
      puts ::Terminal::Table.new({
        headings: %w{index id name},
        rows: accounts.select{|c|c["active"] != -1}.map {|c| [ c["index"], c["id"], c["name"]]}
      })
    end

    def category_table categories
      puts ::Terminal::Table.new({
        headings: %w{index id name},
        rows: categories.map {|c|[c["index"], c["id"], c["name"]]}
      })
    end

    def genre_table genres
      categories = Models::Category.all
      puts ::Terminal::Table.new({
        headings: %w{index category id name},
        rows: genres
          .map {|c|
          [
            c["index"],
            categories.find_by_id(c["category_id"])["name"],
            c["id"],
            c["name"]
          ]
        }
      })
    end

    def table array, header
    end
  end
end
