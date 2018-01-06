module Caim
  module Models
    class Category < Model
      MODEL_KEY = :category
      def <=> other
        (self[:mode] <=> other[:mode]).nonzero? ||
        (self[:sort] <=> other[:sort])
      end
    end

    class Categories < Collection
      def model
        Category
      end
    end
 
  end
end
