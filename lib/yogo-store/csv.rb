require "csv"
module Yogo
  module Store
    if ::CSV.const_defined?(:Reader)
      require 'faster_csv'
      CSV = FasterCSV
    else
      CSV = ::CSV
    end
  end
end
