require 'thor'
require 'yaml'
require 'json'
require 'byebug'
require 'active_support'
require 'active_support/core_ext'
require 'terminal-table'

module ZaimCli
  class CLI < Thor

    desc "login", "login"
    def login
      OAuth.get_access_token
    end

    desc "list", "list zaim"
    def list month = Time.current.strftime("%Y-%m-%d")

      categories = Models::Category.all
      genres = Models::Genre.all
      accounts = Models::Account.all
      month = Time.strptime("#{month}-01", "%Y-%m-%d") rescue Time.current
      moneys = Models::Money.where time: month

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

    desc 'pay', 'add payment'
    option :category, aliases: :c, required: true
    option :genre,    aliases: :g, required: true
    option :account,  aliases: :a, required: false
    option :date,     aliases: :d, required: false
    option :comment,  aliases: :x, required: false
    option :place,    aliases: :p, required: false
    def pay amount
      item = Models::Money.new({
        amount: amount,
        category: options[:catedory],
        genre: options[:genre] ,
        account: options[:account] ,
        date: options[:date] ,
        comment: options[:comment] ,
        place: options[:place] ,
      })
      item.save
    end

    desc 'category', 'show categories'
    option :income, aliases: :i
    option :payment, aliases: :p
    def category
      categories = Models::Category.all
      if options[:income]
        categories = categories.select {|c| c["mode"] == "income" }
      end
      if options[:payment]
        categories = categories.select {|c| c["mode"] == "payment" }
      end
      categories.each {|c| puts c}
    end

    desc 'genre', 'show genre'
    def genre
      categories = Models::Category.all
      genres = Models::Genre.all
      grouped = genres.group_by {|c| c["category_id"]}
      p grouped.size
      grouped.each {|category_id, g_genres|
        puts categories[category_id]["name"]
        padding = " " * 4
        g_genres.each {|g|
          puts "#{padding}#{g["name"]}, #{g["id"]}"
        }
      }
    end

    desc 'account', ''
    def account
      accounts = Models::Account.all
      table = ::Terminal::Table.new({
        headings: %w{id name},
        rows: accounts.select{|c|c["active"] != -1}.map {|c|[c["id"], c["name"]]}
      })
      puts table
    end

  end
end
