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
      include Base::Database

      def initialize(path)
        @path = path
        super
      end

      def name
        path.basename
      end
    end
  end
end
