require 'thor'
require 'yaml'
require 'json'
require 'byebug'
require 'active_support'
require 'active_support/core_ext'
require 'terminal-table'

module Caim
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
          accounts.find_by_id(money["from_account_id"]).try(:[], "name"),
          accounts.find_by_id(money["to_account_id"]).try(:[], "name"),
          categories.find_by_id(money["category_id"]).try(:[], "name"),
          genres.find_by_id(money["genre_id"]).try(:[], "name"),
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
    option :account,  aliases: :a, required: false
    option :date,     aliases: :d, required: false
    option :comment,  aliases: :c, required: false
    option :name,     aliases: :n, required: false
    option :place,    aliases: :p, required: false
    option :id,       aliases: :i, required: false
    def pay amount, genre_id = nil
      categories = Models::Category.all
      genres     = Models::Genre.all

      # genre id 決定さす
      genre =
        if genre_id.nil?
          self.category
          puts "Input category index"
          category = categories[STDIN.gets.strip]

          self.genre category["id"]
          puts "Input genre index"
          genres[STDIN.gets.strip]
        else
          genres.find_by_id genre_id.to_i
        end

      if genre.nil?
        warn 'genre not found'
        return
      end

      category = categories.find_by_id genre["category_id"]
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
      puts "#{category['name']} #{genre['name']}"
      p item.to_h

      puts 'sure? y/n'
      yes = STDIN.gets.strip

      if yes == 'n'
        return
      end

      puts item.save rescue warn "失敗した"
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
      table = ::Terminal::Table.new({
        headings: %w{index id name},
        rows: categories
          .select{|c|c["active"] != -1}
          .map {|c|[c["index"], c["id"], c["name"]]}
      })
      puts table
    end

    desc 'genre', 'show genre'
    def genre category_id = nil
      categories = Models::Category.all
      genres = Models::Genre.all

      if category_id.present?
        genres = genres.select {|g| g["category_id"] == category_id.to_i}
      end

      table = ::Terminal::Table.new({
        headings: %w{index category id name},
        rows: genres
          .select{|c|c["active"] != -1}
          .map {|c| [c["index"], categories.find_by_id(c["category_id"])["name"], c["id"], c["name"]]}
          .sort{|f, s| s[1] <=> f[1]}
      })
      puts table

    end

    desc 'account', 'show accounts'
    def account
      accounts = Models::Account.all
      table = ::Terminal::Table.new({
        headings: %w{index id name},
        rows: accounts.select{|c|c["active"] != -1}.map {|c| [ c["index"], c["id"], c["name"]]}
      })
      puts table
    end

  end
end
