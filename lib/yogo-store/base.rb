require 'pathname'
require 'fileutils'
require 'git_store'
require 'grit'
require 'configatron'
require 'sequel'
require 'rufus/tokyo'

require 'yogo-store/inflector'
require 'yogo-store/handler/csv'

module Yogo
  module Store
    module Base
      module Setup
        def initialize(options={}, &block)
          @options = options
          setup
          super
        end
        
        def setup
        end
      end

      module Name
        include Setup
        def initialize(options={}, &block)
          @name ||= options[:name] if options[:name]
          super
        end
        
        def name
          @name
        end
      end
      
      module Paths
        include Setup
        include Name
        def initialize(options={}, &block)
          @path = options[:path]
          @name ||= path.basename(extname)
          super
        end
        
        def path
          Pathname(@path)
        end

        def extname
          '.yogo'
        end

        def repository_path
          path + "repo"
        end

        def database_path
          path + "db"
        end

        def config_path
          path + "config.git"
        end

        def setup
          super
          FileUtils.mkdir_p([path, repository_path, database_path])
        end
      end


      
      module Config
        include Setup
        include Paths

        def config(commit_message = "Changing store config...")
          load_config if @reload_config || !@config
          
          if block_given?
            config_store.transaction(commit_message) do
              load_config
              @config.send(:unlock!)
              @config.unprotect_all!
              
              yield @config

              config_store[config_file_name] = @config.to_hash
            end
          end
          @config.send(:lock!)
          @config.protect_all!
          @config
        end

        def reload_config
          @reload_config = true
          config
        end

        def setup
          super
          Grit::GitRuby::Repository.init(config_path, true)
        end
        
        private
        def config_store
          @config_store ||= GitStore.new(config_path.to_s, 'master', true)
        end
        
        def config_file_name
          'store_config.yml'
        end
        
        def load_config
          @reload_config = false
          config_store.refresh!
          config_hash = config_store[config_file_name] || {}
          @config ||= Configatron::Store.new
          @config.configure_from_hash(config_hash)
          @config
        end
      end

      module Repository
        include Name
        include Setup
        include Paths
        include Config

        def initialize(options={}, &branch)
          @branch = options[:branch] || 'master'
          super
        end

        def repository_name
          repo_name = Inflector.titleize(name).gsub(" ","")
          Inflector.underscore(repo_name)
        end
        
        def repository_path
          @repository_path ||= begin                       
                                 super + "#{repository_name}_data.git"
                               end
        end

        def repository
          @repo ||= create_store(branch)
        end

        def branch
          @branch
        end

        def checkout(branch_name)
          new_opts = @options
          new_opts[:branch] = branch_name
          self.class.new(new_opts)
        end

        def setup
          super
          Grit::GitRuby::Repository.init(repository_path, true)
        end

        private
        def create_store(branch)
          store = GitStore.new(repository_path.to_s, branch, true)
          store.handler['csv'] = Yogo::Store::Handler::CSVHandler.new
          store
        end
      end

      module Database
        module Base
          include Paths
          include Config
          include Repository
          

          def table(name)
            @tables ||= {}
            @tables[table_path(name).to_s] ||= create_table(table_path(name))
          end

          private
          def table_path(name)
            database_path + branch + "tree" + "#{name}"
          end

          def create_table(path)
            {}
          end
        end

        module TokyoTable
          include Database::Base

          private

          def table_path(name)
            path = Pathname(super.to_s + '.tct')
            
          end
          def create_table(path)
            FileUtils.mkdir_p(path.dirname.to_s)
            Rufus::Tokyo::Table.new(path.expand_path.to_s)
          end
        end
      end
      
    end
  end
end
