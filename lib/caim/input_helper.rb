module Caim
  module InputHelper
    extend self

    def get_category_id_interactively attrs
      p attrs
      categories = Models::Category.all
      OutputHelper.category_table categories.select{|c|c['mode'] == 'payment'}
      print "Input category index:"
      categories[STDIN.gets.strip].try(:fetch, "local_id")
    end

    def get_genre_id_interactively attrs
      category_id = attrs[:category_id]
      categories = Models::Category.all
      genres = Models::Genre.all

      parent = categories.find {|c| c["local_id"] == category_id}

      OutputHelper.genre_table genres.select {|g|
        g['category_id'] == parent["id"]
      }

      print "Input genre index:"
      genres[STDIN.gets.strip].try(:fetch, "id")
    end

    def get_from_account_id_interactively attrs
      accounts = Models::Account.all
      OutputHelper.account_table accounts
      print "Input genre index:"
      accounts[STDIN.gets.strip].try(:fetch, "id")
    end

    def make_payment_attrs amount = 0, raw = {}

      genre = Models::Genre.all[raw[:genre]]
      if genre.nil?
        raise 'genre not found'
      end

      category = Models::Category.all[genre["category_id"]]
      if category.nil?
        raise 'category not found'
      end

      account = Models::Account.all[raw[:account]]

      {
        id:              raw[:id] || nil,
        amount:          amount,
        category_id:     category["local_id"],
        genre_id:        genre['id'],
        from_account_id: account.try(:fetch, "id"),
        date:            raw[:date] || Time.new.strftime('%Y-%m-%d'),
        comment:         raw[:comment] ,
        name:            raw[:name] ,
        place:           raw[:place] ,
      }
    end

    def make_payment_attrs_interactively amount, raw = {}
      attrs = raw.dup
      %w(
        amount
        category_id
        genre_id
        from_account_id
        date
        comment
        name
        place).each {|name|
          method = "get_#{name}_interactively"
          attrs[name.to_sym] =  if self.respond_to? method
            self.send method, attrs
          else
            print "Input #{name}:"
            STDIN.gets.strip
          end
        }

        attrs.transform_values(&:presence).compact.symbolize_keys
    end

    def confirm selection = %w(yes no)
      print "Are your sure? #{selection.join('/')}:"
      yes = STDIN.gets.strip
      yes[0]
    end
  end
end
