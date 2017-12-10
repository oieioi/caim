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

    desc "ls", "list zaim"
    option :all,  aliases: :a, required: false, type: :boolean
    option :format,  aliases: :f, required: false
    option :summary,  aliases: :s, required: false, type: :boolean

    def ls month = Time.current.strftime("%Y-%m-%d")

      month = Time.strptime("#{month}-01", "%Y-%m-%d") rescue Time.current
      if options[:all].present?
        moneys = Models::Money.all
      else
        moneys = Models::Money.where time: month
      end

      if options[:format] == 'raw'
        p moneys
      elsif options[:format] == 'json'
        #p JSON.dump moneys
      else
        OutputHelper.money_table moneys
      end

      if options[:summary]
        sum_payment = moneys
          .select{|m|m["mode"] == "payment"}
          .reduce(0) {|sum, val| sum + val["amount"].to_i}
        sum_income = moneys
          .select{|m|m["mode"] == "income"}
          .reduce(0) {|sum, val| sum + val["amount"].to_i}
        puts "payment: #{sum_payment}, income: #{sum_income}, sum: #{sum_income - sum_payment}"
      end

    end

    desc 'pay', 'add payment'
    option :genre,       aliases: :g, required: false
    option :account,     aliases: :a, required: false
    option :date,        aliases: :d, required: false
    option :comment,     aliases: :c, required: false
    option :name,        aliases: :n, required: false
    option :place,       aliases: :p, required: false
    option :yes,         aliases: :y, required: false, type: :boolean
    option :interactive, aliases: :i, required: false, type: :boolean
    def pay amount = nil
      create_money :payment, options.merge(amount: amount)
    end

    desc 'earn', 'add income'
    option :category,    aliases: :ca, required: false
    option :account,     aliases: :a, required: false
    option :date,        aliases: :d, required: false
    option :comment,     aliases: :co, required: false
    option :place,       aliases: :p, required: false
    option :yes,         aliases: :y, required: false, type: :boolean
    option :interactive, aliases: :i, required: false, type: :boolean
    def earn amount = nil
      create_money :income, options.merge(amount: amount)
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

      puts Models::Payment.new(id: money_id.to_i).destroy
    end

    desc 'category', 'show categories'
    option :income , aliases: :i, type: :boolean
    option :payment, aliases: :p, type: :boolean
    def category
      categories = Models::Category.all

      if options[:income]
        categories = categories.select {|c| c["mode"] == "income" }
      end
      if options[:payment]
        categories = categories.select {|c| c["mode"] == "payment" }
      end

      activated = categories.select{|c|c["active"] != -1}

      OutputHelper.category_table activated
    end

    desc 'genre', 'show genre'
    def genre category_id = nil
      genres = Models::Genre.all

      if category_id.present?
        genres = genres.select {|g| g["category_id"] == category_id.to_i}
      end

      activated = genres
        .select{|c|c["active"] != -1}
        .sort{|f, s| s[1] <=> f[1]}

      OutputHelper.genre_table activated
    end

    desc 'account', 'show accounts'
    def account
      OutputHelper.account_table Models::Account.all
    end

    private

    def create_money mode, options
      attrs  = options[:interactive] ?
        InputHelper.send("make_#{mode}_attrs_interactively", options) :
        InputHelper.send("make_#{mode}_attrs", options)

      money = Models.module_eval(mode.to_s.classify).new(attrs)

      puts "You should create #{mode}:"
      OutputHelper.pretty_money money, padding: "    "

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
