require 'thor'
require 'yaml'
require 'json'
require 'byebug'
require 'active_support'
require 'active_support/core_ext'
require 'terminal-table'

module Caim
  class CLI < Thor
    include ::Caim::Helpers

    desc "login", "login"
    def login
      OAuth.get_access_token
    end

    desc "ls", "list zaim"
    option :all,  aliases: :a, required: false, type: :boolean, desc: 'show all money'
    option :format,  aliases: :f, required: false, desc: ''
    def ls month = Time.current.strftime("%Y-%m-%d")

      moneys = Models::Moneys.new fetch: false
      if options[:all].present?
        moneys.fetch
      else
        month = Time.strptime("#{month}-01", "%Y-%m-%d") rescue Time.current
        moneys.where time: month
      end

      puts MoneyHelper.pretty_moneys moneys, format: options[:format]
    end

    desc "sum", "summary zaim"
    option :all, aliases: :a, required: false, type: :boolean
    option :category, aliases: :c, required: false, type: :boolean
    option :genre, aliases: :g, required: false, type: :boolean
    def sum month = Time.current.strftime("%Y-%m-%d")
      moneys = Models::Moneys.new fetch: false

      if options[:all].present?
        moneys.fetch
      else
        month = Time.strptime("#{month}-01", "%Y-%m-%d") rescue Time.current
        moneys.where time: month
      end

      puts moneys.summary

      if options['category']
        categories = Models::Categories.new
        puts moneys.summary_by_category categories
      end

      if options['genre']
        categories = Models::Categories.new
        genres = Models::Genres.new
        puts moneys.summary_by_genre categories, genres
      end
    end

    desc 'pay', 'add payment'
    option :genre,       aliases: :g, required: false
    option :account,     aliases: :a, required: false
    option :date,        aliases: :d, required: false
    option :memo,        aliases: :m, required: false
    option :name,        aliases: :n, required: false
    option :place,       aliases: :p, required: false
    option :yes,         aliases: :y, required: false, type: :boolean
    option :interactive, aliases: :i, required: false, type: :boolean
    def pay amount = nil
      create_money :payment, options.merge(amount: amount)
    end

    desc 'earn', 'add income'
    option :category,    aliases: :c, required: false
    option :account,     aliases: :a, required: false
    option :date,        aliases: :d, required: false
    option :memo,        aliases: :m, required: false
    option :place,       aliases: :p, required: false
    option :yes,         aliases: :y, required: false, type: :boolean
    option :interactive, aliases: :i, required: false, type: :boolean
    def earn amount = nil
      create_money :income, options.merge(amount: amount)
    end

    desc 'mv', 'transfer money'
    option :date,        aliases: :d, required: false
    option :'from-account',  aliases: :f, required: false
    option :'to-account',  aliases: :t, required: false
    option :memo,        aliases: :m, required: false
    option :yes,         aliases: :y, required: false, type: :boolean
    option :interactive, aliases: :i, required: false, type: :boolean
    def mv amount = nil
      create_money :transfer, options.merge(amount: amount)
    end

    desc 'rm', 'remove money'
    option :force, aliases: :f, required: false, type: :boolean
    def rm money_id
      if options[:force].blank?
        puts "You should remove #{money_id}."
        case InputHelper.confirm
        when 'n' then exit 0
        end
      end

      # Payment, Income 関係なくmoney_idあってればリクエスト通る
      puts Models::Payment.new(id: money_id.to_i).destroy
    end

    desc 'category', 'show categories'
    option :income , aliases: :i, type: :boolean
    option :payment, aliases: :p, type: :boolean
    def category sub_command = nil

      categories = Models::Categories.new

      if options[:income]
        categories = categories.select {|c| c[:mode] == "income" }
      end

      if options[:payment]
        categories = categories.select {|c| c[:mode] == "payment" }
      end

      categories.sort!

      puts CategoryHelper.table categories
    end

    desc 'genre', 'show genre'
    def genre category_id = nil
      genres = Models::Genres.new

      if category_id.present?
        genres = genres.select {|g| g[:category_id] == category_id.to_i}
      end

      genres = genres.sort
      puts GenreHelper.table genres
    end

    desc 'account', 'show accounts'
    def account
      accounts = Models::Accounts.new
      puts AccountHelper.table accounts
    end

    private

    def create_money mode, options
      attrs  = options[:interactive] ?
        InputHelper.send("make_#{mode}_attrs_interactively", options) :
        InputHelper.send("make_#{mode}_attrs", options)

      money = Models.module_eval(mode.to_s.classify).new(attrs)

      puts "You should create #{mode}:"
      puts MoneyHelper.pretty_money money, padding: "    "

      if options[:yes].blank?
        case InputHelper.confirm %w{yes no edit}
        when 'n' then return
        when 'e' then raise 'not implmented!'
        end
      end

      id = money.save
      puts "success! #{id}"
    end
  end
end
