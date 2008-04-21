require File.join(File.dirname(__FILE__), "spec_helper" )           
                   
require 'action_mailer'
ActionMailer::Base.delivery_method       = :sendmail
ActionMailer::Base.raise_delivery_errors = true                                       

describe Mole::Moler do     
  TEST_LOG = "/tmp/test.log"                    
  before( :each ) do                                          
    ::Mole.reset_configuration!
    @io = StringIO.new
    ::Mole.initialize( :mode             => :transient, 
                       :logger_name      => "Test", 
                       :log_file         => @io, 
                       :moleable         => true,
                       :emole_from       => "MOleBeatch@liquidrail.com", 
                       :emole_recipients => ['fernand@liquidrail.com'] )
    @args = { :blee => "Hello", :duh => "World" }
  end
                        
  it "should log unchecked to the db exceptions correctly" do
    ::Mole.switch_mode :persistent   
    begin
      raise "Something bad happened !"
    rescue => boom
      @args[:boom] = boom     
      ::Mole::Moler.check_it( self, 100, @args )
    end
    feature = MoleFeature.find_exception_feature( ::Mole.application )
    feature.should_not be_nil     
    check_it( feature, 100, @args )
  end
      
  it "should log perf exception to the db correctly" do             
    ::Mole.switch_mode :persistent
    ::Mole::Moler.perf_it( self, 100, @args )
    feature = MoleFeature.find_performance_feature( ::Mole.application )
    feature.should_not be_nil     
    check_it( feature, 100, @args )
  end

  it "should mole a feature to the db correctly" do                 
    ::Mole.switch_mode :persistent
    ::Mole::Moler.mole_it( "Test", "fred", 100, @args )
    feature = MoleFeature.find_or_create_feature( "fred", ::Mole.application, "Test".class.name )
    feature.should_not be_nil     
    check_it( feature, 100, @args )
  end

  it "should log a feature to the db and send an email correctly" do             
    ::Mole.switch_mode :persistent      
    @args[:email] = true
    ::Mole::Moler.mole_it( "Test", "fred", 100, @args )
    feature = MoleFeature.find_or_create_feature( "fred", ::Mole.application, "Test".class.name )
    feature.should_not be_nil     
    check_it( feature, 100, { :email => true, :blee => "Hello", :duh => "World" } )
  end
  
  it "should log unchecked exceptions to the logger correctly" do   
    ::Mole.switch_mode :transient
    ::Mole::Moler.check_it( self, 100, @args )
    @io.string[@io.string.index( "---" )..@io.string.size].should == "--- 100 -> blee=>Hello, duh=>World\n"
  end

  it "should log perf exception to the logger correctly" do             
    ::Mole.switch_mode :transient
    ::Mole::Moler.perf_it( self, 100, @args )                                  
    @io.string[@io.string.index( "---" )..@io.string.size].should == "--- 100 -> blee=>Hello, duh=>World\n"    
  end

  it "should mole a feature to the logger correctly" do             
    ::Mole.switch_mode :transient
    ::Mole::Moler.mole_it( "Test", "Fred", 100, @args )                                  
    @io.string[@io.string.index( "---" )..@io.string.size].should == "--- 100 -> blee=>Hello, duh=>World\n"    
  end
  
end