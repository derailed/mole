require File.join(File.dirname(__FILE__), "..", "spec_helper" )
require 'ostruct'
           
describe MoleLog do                           
  before( :each ) do    
    ::Mole.reset_configuration!
    ::Mole.initialize( :mode => :persistent, :log_level => :info, :moleable => true )
    @args = { :blee => "Hello", :duh => "World" }
  end
                      
  it "should log unchecked exceptions correctly" do
     args = @args 
     feature = MoleFeature.find_exception_feature( ::Mole.application )
     feature.should_not be_nil      
     begin
       raise "Something crapped out"
     rescue => boom     
       args[:boom] = Mole::Moler.dump_stack( boom )
       MoleLog.log_it( self, feature, 100, args )
     end
     check_it( feature, 100, @args )   
  end
      
  it "should log perf exception correctly" do                       
     feature = MoleFeature.find_performance_feature( ::Mole.application )
     feature.should_not be_nil         
     MoleLog.log_it( self, feature, 200, @args )
     check_it( feature, 200, @args )
  end

  it "should mole a feature correctly" do
     feature = MoleFeature.find_or_create_feature( "fred", ::Mole.application, "Test".class.name )
     feature.should_not be_nil         
     MoleLog.log_it( "Test", feature, 300, @args )
     check_it( feature, 300, @args )
  end

  it "should log request info correctly" do
     ctrl    = Moled::Controller.new
     feature = MoleFeature.find_or_create_feature( "fred", ::Mole.application, ctrl.class.name )
     feature.should_not be_nil          
     MoleLog.log_it( ctrl, feature, 400, @args )
     log = check_it( feature, 400, @args )
     log.ip_address.should    == "1.1.1.1"
     log.browser_type.should  == "GodZilla"
  end      
    
  # Test Controller...
  module Moled
    class Controller
      class Request
        def env
          {'REMOTE_ADDR' => "1.1.1.1", 'HTTP_USER_AGENT' => 'GodZilla' }
        end
      end
    
      def request
        Request.new
      end
    end
   end
end