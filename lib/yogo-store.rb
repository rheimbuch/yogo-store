require 'yogo-store/base'

module Yogo
  module Store
    def self.open(path)
    end

    class BasicStore
      include Base::Setup
      include Base::Paths
      include Base::Config
      include Base::Repository
      include Base::Database::Base
    end

    class DataStore < BasicStore
      include Base::Database::TokyoTable
    end
  end
end
