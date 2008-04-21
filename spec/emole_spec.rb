require File.join(File.dirname(__FILE__), "spec_helper" )
                   
require 'action_mailer'
ActionMailer::Base.delivery_method       = :sendmail
ActionMailer::Base.raise_delivery_errors = true                                       

# TODO Figure out how to auto check email was sent                       
describe Mole::EMole do                                      
  before( :each ) do      
    ::Mole.reset_configuration!
    ::Mole.initialize( :moleable         => true, 
                       :emole_from       => "MOleBeatch@liquidrail.com", 
                       :emole_recipients => ['fernand@liquidrail.com'] )
  end
  
  it "should send out a correct perf alert" do
    Mole::EMole.deliver_perf_alerts(
      self, 
      "fernand", 
      :feature      => "test", 
      :elapsed_time => 10 )
  end

  it "should send out a correct feature alert" do
    Mole::EMole.deliver_feature_alerts( 
      self,
      "fernand", 
      :feature      => "test", 
      :fred         => "blee" )
  end

  it "should send out a correct exception alert" do
    begin
      raise "Something craped out"
    rescue => boom
      Mole::EMole.deliver_exception_alerts( 
        self,
        "fernand", 
        :feature    => "test", 
        :boom       => boom )
    end
  end  
end
