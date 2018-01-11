require 'terminal-table'

module Caim
  module Helpers
    module OutputHelper
      extend self

      def pretty_money money, opt = {padding: ""}
        category = Models::Categories.new[money[:category_id]] rescue nil
        genre    = Models::Genres.new[money[:genre_id]] rescue nil
        accounts = Models::Accounts.new
        from_account  = accounts[money[:from_account_id]] rescue nil
        to_account    = accounts[money[:to_account_id]] rescue nil

        target = money.to_h.merge({
          category: category.try(:[], :name),
          genre: genre.try(:[], :name),
          from_account: from_account.try(:[], :name),
          to_account: to_account.try(:[], :name),
        })

        puts ::Terminal::Table.new({
          headings: %w{name value},
          rows: target.to_a
        })
      end

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

      def money_table moneys
        categories = Models::Categories.new
        genres = Models::Genres.new
        accounts = Models::Accounts.new

        rows = moneys.reverse_each.map {|money|
          [
            money[:id],
            money[:date],
            money[:amount],
            accounts[money[:from_account_id]].try(:[], "name"),
            accounts[money[:to_account_id]].try(:[], "name"),
            categories[money[:category_id]].try(:[], "name"),
            genres[money[:genre_id]].try(:[], "name"),
            money[:comment],
            money[:place],
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
end
