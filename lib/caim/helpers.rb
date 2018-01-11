Dir[File.expand_path('../helpers', __FILE__) << '/*.rb'].each do |file|
  require_relative file
end

module Caim
  module Helpers
  end
end
