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

    def money_table moneys
      categories = Models::Category.all
      genres = Models::Genre.all
      accounts = Models::Account.all

      rows = moneys.reverse_each.map {|money|
        [
          money["id"],
          money["date"],
          money["amount"],
          accounts.find_by_id(money["from_account_id"]).try(:[], "name"),
          accounts.find_by_id(money["to_account_id"]).try(:[], "name"),
          categories.find_by_id(money["category_id"]).try(:[], "name"),
          genres.find_by_id(money["genre_id"]).try(:[], "name"),
          money["comment"],
          money["place"],
        ]
      }
      puts ::Terminal::Table.new({
        headings: %w{
            id 日付 代金 金額 入金 カテゴリ 細カテゴリ メモ お店
        },
          rows: rows
      })
    end

    def table array, header
    end
  end
end
