module Caim
  module InputHelper
    extend self

    def genre_interactive genre_index
      categories = Models::Category.all
      genres     = Models::Genre.all

      genre = if genre_index.nil?
        OutputHelper.category_table categories
        puts "Input category index"
        category = categories[STDIN.gets.strip]

        OutputHelper.genre_table genres
          .select {|g| g['category_id'] == category['id']}
        puts "Input genre index"
        genres[STDIN.gets.strip]
      else
        genres[genre_index]
      end

      category = categories.find_by_id genre["category_id"]

      [genre, category]

    end
  end
end
