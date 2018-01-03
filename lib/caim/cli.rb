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
    option :'category-summary',  aliases: :c, required: false, type: :boolean
    option :'genre-summary',  aliases: :g, required: false, type: :boolean
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
        puts JSON.dump moneys.list
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
        puts "payment: #{sum_payment.to_s :delimited}, income: #{sum_income.to_s :delimited}, sum: #{(sum_income - sum_payment).to_s :delimited}"
      end

      if options['category-summary'] || options['genre-summary']
        categories = Models::Category.all
        genres = Models::Genre.all

        by_category = moneys.group_by {|e| e['category_id']}

        summaried_by_category = by_category.map { |category_id, c_moneys|
          summary_category = c_moneys.reduce(0) {|s, v| s + v["amount"].to_i}
          category = categories.find_by_id(category_id)

          by_genre = c_moneys.group_by{|m|m['genre_id']}.map {|genre_id, g_moneys|
            genre = genres.find_by_id(genre_id)
            summary_genre = g_moneys.reduce(0) {|s, v| s + v["amount"].to_i}
            {genre: genre, sum: summary_genre}
          }

          {id: category_id, category: category, summary: summary_category, genres: by_genre}
        }

        prettied = []
        summaried_by_category.each {|item|
          prettied << [
            item[:category].try(:[], 'mode') || 'transfered',
            item[:category].try(:[], 'name') || 'transfered',
            'summary',
            item[:summary]
          ]

          if options['genre-summary'] && item[:category].try(:[], 'mode') == 'payment'
            item[:genres].each {|genre|
              prettied << [
                item[:category].try(:[], 'mode') || 'transfered',
                item[:category].try(:[], 'name') || 'transfered',
                genre[:genre].try(:[], 'name'),
                genre[:sum]
              ]
            }
          end

        }
        if options['category-summary']
          prettied = prettied.sort {|a, b| (b[0] <=> a[0]).nonzero? || (b[3] <=> a[3]) }
        elsif options['genre-summary']
          prettied = prettied.sort {|a, b| (b[0] <=> a[0]).nonzero? || (b[1] <=> a[1]).nonzero? || (b[3] <=> a[3]) }
        end

        puts ::Terminal::Table.new({
          headings: %w{
            mode category genre summary
          },
            rows: prettied
        })

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

      categories = if sub_command == 'update'
        Models::Category.all update: true
      else
        Models::Category.all
      end

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
