require 'terminal-table'

module Caim
  module Helpers
    module AccountHelper
      extend self

      def table accounts
        ::Terminal::Table.new({
          headings: %w{index name},
          rows: accounts.map {|c| [ c[:index], c[:name]]}
        })
      end
    end
  end
end
