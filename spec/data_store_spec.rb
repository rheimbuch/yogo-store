require 'spec_helper'

describe "Yogo::Store::DataStore" do
  before(:all) do
    @tmp_path = tmp_path('stores')
    FileUtils.mkdir_p @tmp_path.to_s
  end

  after(:all) do
    FileUtils.rm_rf(@tmp_path.to_s)
  end
  
  describe "initialization" do
    describe "path handling" do

      
      it "should create it's location if it doesn't exist" do
        name = "test-01-store.yogo"
        location = @tmp_path + name
        location.should_not exist

        store = Yogo::Store::DataStore.new(:path => location.to_s)
        
        location.should exist
      end

    end

    describe "directories" do
      before do
        @path = @tmp_path + "test-02-store.yogo"
        @store = Yogo::Store::DataStore.new(:path => @path)
      end

      it "should create a directory for repositories" do
        @store.repository_path.should == @path + "repo" + "#{@store.repository_name}_data.git"
        @store.repository_path.should exist
      end

      it "should create a directory for databases" do
        @store.database_path.should == @path + "db"
        @store.database_path.should exist
      end

      it "should create a directory for the config repo" do
        @store.config_path.should == @path + "config.git"
        @store.config_path.should exist
      end
    end
  end

end
