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
  
  it "should locate controller classes correctly" do
    classes = Mole.find_controller_classes( File.join(File.dirname(__FILE__), %w[data] ) )
    classes.should == %w[Blee]
  end
  
  describe ".auto_xxx" do
    before( :each ) do
      ::Mole.reset_configuration!
      ::Mole.initialize( :perf_threshold => 1, :log_level => :debug )
      require File.join( File.dirname(__FILE__),  %w[data blee] )
      Blee.send( :mole_clear! )
      CallStackChecker.reset! 
    end

    it "should auto perf a set of controllers correctly" do
      Mole.auto_perf( File.join(File.dirname(__FILE__), %w[data] ) ) do |context, feature, elapsed_time, ret_val, block, *args|  
        context.class.should == Blee
        block.should         be_nil      
        args.size.should     == 0      
        elapsed_time.should  > 1      
        CallStackChecker.called
      end         
      Blee.new.blee_slow      
      CallStackChecker.should be_called    
      CallStackChecker.reset!
      Blee.new.blee_slow_too  
      CallStackChecker.should be_called          
    end
    
    it "should auto check a set of controllers correctly" do
      Mole.auto_unchecked( File.join(File.dirname(__FILE__), %w[data] ) ) do |context, feature, elapsed_time, block, *args|  
        context.class.should == Blee
        feature.should       == "blee_raise"      
        block.should         be_nil      
        args.size.should     == 0      
        CallStackChecker.called
      end   
      Blee.new.blee_raise rescue nil
      CallStackChecker.should be_called    
    end

    it "should auto before a set of controllers correctly" do
      Mole.auto_before( File.join(File.dirname(__FILE__), %w[data] ) ) do |context, feature, block, *args|  
        context.class.should == Blee
        feature.should       == "blee_no_args"      
        block.should         be_nil      
        args.size.should     == 0      
        CallStackChecker.called
      end   
      Blee.new.blee_no_args
      CallStackChecker.should be_called    
    end

    it "should auto after a set of controllers correctly" do
      Mole.auto_after( File.join(File.dirname(__FILE__), %w[data] ) ) do |context, feature, ret_val, block, *args|  
        context.class.should == Blee
        feature.should       == "blee_no_args"      
        ret_val.should       == 10
        block.should         be_nil      
        args.size.should     == 0      
        CallStackChecker.called
      end   
      Blee.mole_dump( "After" )
      Blee.new.blee_no_args
      CallStackChecker.should be_called    
    end
    
  end
    
  describe ".load_mole_configuration" do
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
