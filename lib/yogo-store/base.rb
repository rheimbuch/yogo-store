require 'pathname'
require 'fileutils'
require 'git_store'
require 'grit'
require 'configatron'
require 'sequel'

require 'yogo-store/inflector'

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

        
        def repository_path
          @repository_path ||= begin
                                 repo_name = Inflector.titleize(name).gsub(" ","")
                                 repo_name = Inflector.underscore(repo_name)
                                 path + "#{repo_name}_data.git"
                               end
        end

        def repository(branch='master')
          @branches ||= {}
          @branches[branch] ||= GitStore.new(repository_path.to_s, branch, true)
        end

        def setup
          super
          Grit::GitRuby::Repository.init(repository_path, true)
        end
      end

      module Database
        include Paths
        include Config
        
        def database(ref='master', name='default')
          db_name = database_path + ref + "#{name}.db"
          FileUtils.mkdir_p(db_name.dirname)
          
          @databases ||= {}
          @databases[db_name.to_s] ||= Sequel.connect("sqlite://" + db_name.expand_path.to_s)
        end
      end
      
    end
  end
end
