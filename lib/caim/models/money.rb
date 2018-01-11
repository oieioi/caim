module Caim
  module Models
    class Money < Model

      def self.attrs
        raise 'not implemented'
      end

      def self.resource_name
        "money"
      end

      def initialize values, mode = nil
        @mode = mode
        super values
        if self[:mode].present?
          @mode = self[:mode]
        end
      end

      def path
        id.nil? ? "/v2/home/money/#{@mode.to_s}" : "/v2/home/money/#{@mode.to_s}/#{id}"
      end
    end

    class Moneys < Collection

      def model_class
        Money
      end

      def where param
        param = param.dup

        if param[:time].present?
           param[:start_date] = param[:time].beginning_of_month.strftime("%Y-%m-%d")
           param[:end_date] = param[:time].end_of_month.strftime("%Y-%m-%d")
           param.delete :time
        end

        fetch param.to_param
      end

      def fetch query = nil
        queried = path
        queried << "?#{query}" if query.present?
        result = API.get queried
        set_new_list result["money"]
        self
      end

      def summary
        sum_payment = payments.reduce(0) {|sum, val| sum + val[:amount].to_i}

        sum_income = incomes.reduce(0) {|sum, val| sum + val[:amount].to_i}

        {
          income: sum_income.to_s(:delimited),
          payment: sum_payment.to_s(:delimited),
          "income - payment": (sum_income - sum_payment).to_s(:delimited)
        }
      end

      def payments
        select{|m|m[:mode] == "payment"}
      end

      def incomes
        select{|m|m[:mode] == "income"}
      end

      def summary_by_category categories
        by_category = self.group_by {|e| e[:category_id]}

        summaried_by_category = by_category.map { |category_id, c_moneys|
          summary_category = c_moneys.reduce(0) {|s, v| s + v[:amount].to_i}
          category = categories[category_id]
          {id: category_id, category: category, summary: summary_category}
        }

        prettied = []
        summaried_by_category.each {|item|
          prettied << [
            item[:category].try(:[], 'mode') || 'transfered',
            item[:category].try(:[], 'name') || 'transfered',
            item[:summary]
          ]
        }

        prettied = prettied.sort {|a, b| (b[0] <=> a[0]).nonzero? || (b[2] <=> a[2]) }

        # 返り値が雑
        ::Terminal::Table.new({
          headings: %w{
            mode category summary
          },
            rows: prettied
        })
      end

      # TODO 汚い
      def summary_by_genre categories, genres
        by_category = self.group_by {|e| e[:category_id]}
        summaried_by_category = by_category.map { |category_id, c_moneys|
          summary_category = c_moneys.reduce(0) {|s, v| s + v[:amount].to_i}
          category = categories[category_id]

          by_genre = c_moneys.group_by{|m|m[:genre_id]}.map {|genre_id, g_moneys|
            genre = genres[genre_id]
            summary_genre = g_moneys.reduce(0) {|s, v| s + v[:amount].to_i}
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

          if item[:category].try(:[], 'mode') == 'payment'
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

        prettied = prettied.sort {|a, b| (b[0] <=> a[0]).nonzero? || (b[1] <=> a[1]).nonzero? || (b[3] <=> a[3]) }

        ::Terminal::Table.new({
          headings: %w{
            mode category genre summary
          },
            rows: prettied
        })


      end

    end
  end
end
