module Caim
  module Models
    class Category < Model

      def local_id
        self[:local_id] || self[:parent_category_id] || self[:id]
      end

      def <=> other
        (self[:mode] <=> other[:mode]).nonzero? ||
        (self[:sort] <=> other[:sort])
      end
    end

    class Categories < Collection
      def model_class
        Category
      end
    end

  end
end
