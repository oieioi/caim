require 'thor'
require 'yaml'
require 'json'
require 'byebug'
require 'active_support'
require 'active_support/core_ext'
require 'terminal-table'

module ZaimCli
  class CLI < Thor

    desc "list", "list zaim"
    def list month = Time.current.strftime("%Y-%m-%d")

      categories = Models::Category.new
      genres = Models::Genre.new
      accounts = Models::Account.new
      month = Time.strptime("#{month}-01", "%Y-%m-%d") rescue Time.current
      moneys = Models::Money.new month

      rows = moneys.map {|m|
        [
          m["id"],
          m["date"],
          m["amount"],
          accounts[m["from_account_id"]].try(:[], "name"),
          accounts[m["to_account_id"]].try(:[], "name"),
          categories[m["category_id"]].try(:[], "name"),
          genres[m["genre_id"]].try(:[], "name"),
          m["comment"],
          m["place"],
        ]
      }
      table = ::Terminal::Table.new({
          headings: %w{
            id 日付 代金 出金口座 入金口座 品目 細品目 メモ お店
          },
          rows: rows
      })
      puts table

    end

    desc "login", "login"
    def login
      OAuth.get_access_token
    end

  end
end
