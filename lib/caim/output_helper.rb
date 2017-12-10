require 'terminal-table'

module Caim
  module OutputHelper
    extend self

    def pretty_money money, opt = {padding: ""}
      category = Models::Category.all.find {|item| item["local_id"] == money.category_id } rescue nil
      genre    = Models::Genre.all.find_by_id(money.genre_id) rescue nil
      from_account  = Models::Account.all.find_by_id(money.from_account_id) rescue nil
      to_account    = Models::Account.all.find_by_id(money.to_account_id) rescue nil

      target = money.to_h.merge({
        category: category.try(:fetch, "name"),
        genre: genre.try(:fetch, "name"),
        from_account: from_account.try(:fetch, "name"),
        to_account: to_account.try(:fetch, "name"),
      })

      puts ::Terminal::Table.new({
        headings: %w{name value},
        rows: target.to_a
      })
    end

    def account_table accounts
      puts ::Terminal::Table.new({
        headings: %w{index id name},
        rows: accounts.select{|c|c["active"] != -1}.map {|c| [ c["index"], c["id"], c["name"]]}
      })
    end

    def category_table categories
      puts ::Terminal::Table.new({
        headings: %w{index id mode name},
        rows: categories.map {|c|[c["index"], c["id"], c["mode"], c["name"]]}
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

  end
end
