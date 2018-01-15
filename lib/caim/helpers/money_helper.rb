require 'terminal-table'
require 'csv'
require 'json'

module Caim
  module Helpers
    module MoneyHelper
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

        ::Terminal::Table.new({
          headings: %w{name value},
          rows: target.to_a
        })
      end

      def pretty_moneys moneys, format:
        format = :table if format.nil?
        send("#{format.to_s}_format", moneys)
      end

      private

      def table_format moneys
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

        ::Terminal::Table.new({
          headings: %w{
            id 日付 代金 金額 入金 カテゴリ 細カテゴリ メモ お店
          },
            rows: rows
        })
      end

      def raw_format moneys
        moneys.to_s
      end

      def json_format moneys
        JSON.dump moneys.map(&:to_h)
      end

      def csv_format moneys, attr_names = nil
        if attr_names.blank?
          attr_names = %w{
            id
            date
            amount
            mode
            to_account_id
            from_account_id
            category_id
            genre_id
            comment
            place
          }
        end
        accounts = Models::Accounts.new
        genres = Models::Genres.new
        categories = Models::Categories.new

        CSV.generate {|csv|
          csv << attr_names
          moneys.reverse_each {|money|
            csv << attr_names.map {|key|
              case key
              when 'to_account_id' then accounts[money[key]].try(:[], :name)
              when 'from_account_id' then accounts[money[key]].try(:[], :name)
              when 'genre_id' then genres[money[key]].try(:[], :name)
              when 'category_id' then categories[money[key]].try(:[], :name)
              else money[key]
              end
            }
          }
        }
      end
    end
  end
end
