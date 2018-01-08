module Caim
  module InputHelper
    extend self

    def get_category_id_interactively attrs, mode
      categories = Models::Categories.new
      OutputHelper.category_table categories
        .select{|c|c[:mode] == mode.to_s}.sort
      print "Input category index:"
      categories[STDIN.gets.strip].local_id
    end

    def get_genre_id_interactively attrs, mode = nil
      category_id = attrs[:category_id]
      categories = Models::Categories.new
      genres = Models::Genres.new

      parent_category = categories.find {|c| c.local_id == category_id}

      OutputHelper.genre_table genres
        .select {|g| g[:category_id] == parent_category[:id]}
        .sort

      print "Input genre index:"
      index = STDIN.gets.strip
      genres[index].local_id
    end

    def get_account_id_interactively attrs, mode = nil
      accounts = Models::Accounts.new
      OutputHelper.account_table accounts
      print "Input account index:"
      accounts[STDIN.gets.strip].id
    end
    alias :get_from_account_id_interactively :get_account_id_interactively
    alias :get_to_account_id_interactively   :get_account_id_interactively

    def make_income_attrs raw = {}

      category = Models::Categories.new[raw[:category]]
      if category.nil?
        raise 'category not found'
      end

      account = Models::Accounts.new[raw[:account]]

      {
        id:            raw[:id] || nil,
        category_id:   category.id,
        amount:        raw[:amount],
        date:          raw[:date] || Time.new.strftime('%Y-%m-%d'),
        to_account_id: account.try(:id),
        comment:       raw[:memo],
        place:         raw[:place],
      }
    end

    def make_payment_attrs raw = {}

      genre = Models::Genres.new[raw[:genre]]
      if genre.nil?
        raise 'genre not found'
      end

      category = Models::Categories.new[genre[:category_id]]
      if category.nil?
        raise 'category not found'
      end

      account = Models::Accounts.new[raw[:account]]

      {
        id:              raw[:id] || nil,
        amount:          raw[:amount],
        category_id:     category.local_id,
        genre_id:        genre.local_id,
        from_account_id: account.id,
        date:            raw[:date] || Time.new.strftime('%Y-%m-%d'),
        comment:         raw[:memo] ,
        name:            raw[:name] ,
        place:           raw[:place] ,
      }
    end

    def make_income_attrs_interactively raw = {}
      make_attrs_interactively %w(
        amount
        category_id
        to_account_id
        comment
        place
        date), raw, :income
    end

    def make_payment_attrs_interactively raw = {}
      make_attrs_interactively %w(
        amount
        category_id
        genre_id
        from_account_id
        comment
        place
        date
        name
        ), raw, :payment
    end

    def make_transfer_attrs_interactively raw = {}
      make_attrs_interactively %w(
        amount
        from_account_id
        to_account_id
        comment
        date), raw, :income
    end

    def confirm selection = %w(yes no)
      print "Are your sure? #{selection.join('/')}:"
      yes = STDIN.gets.strip
      yes[0]
    end

    private
    def make_attrs_interactively attr_names, raw, mode
      attrs = raw.dup
      attr_names.each {|name|
        method = "get_#{name}_interactively"
        attrs[name.to_sym] =
          if self.respond_to? method
            self.send method, attrs, mode
          else
            print "Input #{name}:"
            STDIN.gets.strip
          end
      }
      attrs.transform_values(&:presence).compact.symbolize_keys
    end
  end
end
