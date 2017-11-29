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

      rows = moneys.reverse_each.map {|money|
        [
          money["id"],
          money["date"],
          money["amount"],
          accounts[money["from_account_id"]].try(:[], "name"),
          accounts[money["to_account_id"]].try(:[], "name"),
          categories[money["category_id"]].try(:[], "name"),
          genres[money["genre_id"]].try(:[], "name"),
          money["comment"],
          money["place"],
        ]
      }
      table = ::Terminal::Table.new({
        headings: %w{
            id 日付 代金 金額 入金 カテゴリ 細カテゴリ メモ お店
        },
          rows: rows
      })
      puts table
    end

    desc 'pay', 'add payment'
    option :genre,    aliases: :g, required: true
    option :account,  aliases: :a, required: false
    option :date,     aliases: :d, required: false
    option :comment,  aliases: :c, required: false
    option :name,     aliases: :n, required: false
    option :place,    aliases: :p, required: false
    option :id,       aliases: :i, required: false
    def pay amount
      genre = Models::Genre.all[options[:genre].to_i]
      if genre.nil?
        warn 'genre not found'
        return
      end

      category = Models::Category.all[genre["category_id"]]
      if category.nil?
        warn 'category not found'
        return
      end

      item = Models::Money.new({
        id:       options[:id] || nil,
        amount:   amount,
        category: category["local_id"],
        genre:    genre['id'],
        account:  options[:account] ,
        date:     options[:date] || Time.new.strftime('%Y-%m-%d'),
        comment:  options[:comment] ,
        name:     options[:name] ,
        place:    options[:place] ,
      })
      puts 'sure? y/n'
      puts "#{category['name']} #{genre['name']}"
      p item.to_h
      yes = STDIN.gets.strip

      if yes == 'n'
        return
      end

      puts item.save rescue warn "失敗した"
    end

    desc 'update', 'update payment/income/exchange'
    option :genre,    aliases: :g, required: false
    option :account,  aliases: :a, required: false
    option :date,     aliases: :d, required: false
    option :comment,  aliases: :c, required: false
    option :name,     aliases: :n, required: false
    option :place,    aliases: :p, required: false
    def update id
      item = Models::Money.new(id: id)
      raise 'Error' unless item.fetch()
      item.set options
      p item.save
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
      grouped.each {|category_id, g_genres|
        puts "#{categories[category_id]["name"]} #{categories[category_id]["id"]}"
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
