module Caim
  module Models
    class Genre < Model

      def local_id
        self[:local_id] || self[:parent_genre_id] || self[:id]
      end

      def <=> other
        self[:category_id] <=> other[:category_id]
      end
    end

    class Genres < Collection
      def model_class
        Genre
      end
    end

  end
end
