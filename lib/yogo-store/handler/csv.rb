require 'yogo-store/csv'

module Yogo
  module Store
    module Handler
      class CSVHandler
        def read(data)
          Yogo::Store::CSV.parse(data)
        end

        def write(data)
          data.to_csv
        end
      end
    end
  end
end
