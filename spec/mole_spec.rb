require File.join(File.dirname(__FILE__), "spec_helper" )

describe Mole do     
  before( :all ) do        
    ::Mole.reset_configuration!
    ::Mole.initialize( :moleable => true )
    @root = ::File.expand_path( ::File.join(::File.dirname(__FILE__), ".." ) )
  end
                                 
  it "is versioned" do
    ::Mole::Version.version.should =~ /\d+\.\d+\.\d+/
  end
  
  it "should have the right defaults" do
    Mole.should                be_moleable
    Mole.logger.should_not     be_nil
    Mole.perf_threshold.should == 5
    Mole.should_not            be_persistent  
    Mole.application.should    == "Default"
  end         
  
  it "generates a correct path relative to root" do
    Mole.path( "mole.rb" ).should == ::File.join(@root, "mole.rb" )
  end
  
  it "generates a correct path relative to lib" do
    Mole.libpath(%w[ mole db_mole.rb]).should == ::File.join(@root, "lib", "mole", "db_mole.rb")
  end       
  
  it "should define the correct run modes" do
    Mole.run_modes.should == [:transient,:persistent]
  end       
  
  it "should dump config info to console" do
    Mole.dump
  end
  
  describe "load_mole_configuration" do
    before( :each ) do
      ::Mole.reset_configuration!
    end
    
    it "should load single file correctly" do
      ::Mole.initialize( :moleable => true, :mole_config => File.join( File.dirname(__FILE__), %w[config mole_config.rb] ) )
      ::Mole.load_mole_configuration
      require( File.join( File.dirname(__FILE__), %w[config mole_config.rb] ) ).should == []
    end
    
    it "should load config for directory correctly" do
      ::Mole.initialize( :moleable => true, :mole_config => File.join( File.dirname(__FILE__), %w[config moles] ) )
      ::Mole.load_mole_configuration
      require( File.join( File.dirname(__FILE__), %w[config moles fred_config.rb] ) ).should == []      
    end
    
    it "should raise an error if the configuration file does not exist" do
      ::Mole.initialize( :moleable => true, :mole_config => File.join( File.dirname(__FILE__), %w[config fred_mole.rb] ) )
      lambda{ ::Mole.load_mole_configuration }.should raise_error( "Unable to find the MOle configuration from `./spec/config/fred_mole.rb" )       
    end
    
    it "should raise an error if the config directory does not exist" do
      ::Mole.initialize( :moleable => true, :mole_config => File.join( File.dirname(__FILE__), %w[config freds] ) )
      lambda{ ::Mole.load_mole_configuration }.should raise_error( "Unable to find the MOle configuration from `./spec/config/freds" )       
    end
  end
  
end
