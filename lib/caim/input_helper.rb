module Caim
  module InputHelper
    extend self

    def genre_interactive genre_index
      categories = Models::Category.all
      genres     = Models::Genre.all

      genre = if genre_index.nil?
        OutputHelper.category_table categories.select{|c|c['mode'] == 'payment'}
        print "Input category index:"
        category = categories[STDIN.gets.strip]

        OutputHelper.genre_table genres
          .select {|g| g['category_id'] == category['id']}
        print "Input genre index:"
        genres[STDIN.gets.strip]
      else
        genres[genre_index]
      end

      category = categories.find_by_id genre["category_id"]

      [genre, category]
    end

    def account_interactive
      accounts = Models::Account.all
      OutputHelper.account_table accounts
      print "Input genre index:"
      accounts[STDIN.gets.strip]
    end
  end
end
