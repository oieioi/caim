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
    option :all,  aliases: :a, required: false, type: :boolean
    option :format,  aliases: :f, required: false
    def list month = Time.current.strftime("%Y-%m-%d")

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
    def pay amount
      genre, category = InputHelper.genre_interactive options[:genre]

      if genre.nil?
        warn 'genre not found'
        return
      end

      if category.nil?
        warn 'category not found'
        return
      end

      account_id = if options[:account].nil? and options[:interactive]
        InputHelper.account_interactive.try(:fetch, "id")
      else
        options[:account].to_i
      end

      money = Models::Money.new(:payment, {
        id:              options[:id] || nil,
        amount:          amount,
        category_id:     category["local_id"],
        genre_id:        genre['id'],
        from_account_id: account_id,
        date:            options[:date] || Time.new.strftime('%Y-%m-%d'),
        comment:         options[:comment] ,
        name:            options[:name] ,
        place:           options[:place] ,
      })

      puts 'You pay payment:'
      OutputHelper.pretty_money money, padding: "  "

      if options[:yes].blank?
        puts 'Are sure? (y/n)'
        yes = STDIN.gets.strip

        if ['n', 'no', 'none', 'false'].include? yes
          return
        end
      end

      puts money.save rescue warn "失敗した"
    end

    desc 'delete', 'delete money'
    option :force, aliases: :f, required: false, type: :boolean
    def delete money_id
      if options[:force].blank?
        puts "You should remove #{money_id}."
        print 'Are sure? (y/n): '
        yes = STDIN.gets.strip

        if ['n', 'no', 'none', 'false'].include? yes
          return
        end
      end

      puts Models::Money.new(:payment, {id: money_id.to_i}).destroy rescue warn '失敗した'
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
  end
end
