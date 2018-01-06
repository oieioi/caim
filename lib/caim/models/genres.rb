module Caim
  module Models
    class Genre < Model
      MODEL_KEY = :genre

      def <=> other
        self[:category_id] <=> other[:category_id]
      end
    end

    class Genres < Collection
      def model
        Genre
      end
    end
 
  end
end
