module ZaimCli
  module Models

    class Model
      include Enumerable
      def each
        @list.each {|item| yield item }
      end
      def size
        @list.size
      end
      def [] id
        self.find {|item| item["id"] == id }
      end
    end

    class Category < Model
      def initialize
        @api = API.new "/v2/home/category", :get
        @list = @api.request["categories"]
      end
      def income
        self.select {|category| category["mode"] == "income" }
      end

      def payment
        self.select {|category| category["mode"] == "payment"}
      end
    end

    class Genre < Model
      def initialize
        @api = API.new "/v2/home/genre", :get
        @list = @api.request["genres"]
      end
    end

    class Account < Model
      def initialize
        @api = API.new "/v2/home/account", :get
        @list = @api.request["accounts"]
      end
      def income
        self.select {|category| category["mode"] == "income" }
      end

      def payment
        self.select {|category| category["mode"] == "payment"}
      end
    end

    class Money < Model
      def initialize
        @api = API.new "/v2/home/money?start_date=2017-11-01&end_date=2017-11-30&page=1&limit=10", :get
        @list = @api.request["money"]
      end

    end
  end

end
