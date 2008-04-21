require File.join(File.dirname(__FILE__), "spec_helper" )

require 'stringio'          
require File.join(File.dirname(__FILE__), %w[.. lib mole logger] )

describe Mole::Logger do
  it "raises an error if the email addresses passed in is empty" do
    lambda { Mole::Logger.new( { :email_alerts_to => [] } ) }.should raise_error( Mole::Logger::ConfigurationError )
  end

  it "configures an email appender if :email_alerts is set" do
    l = Mole::Logger.new( { :logger_name => "Test2", :email_alerts_to => "fernand@invalid.address", :email_alert_level => :off })
    l.email_appender.should_not == nil
  end

  it "does not configure an email appender if :email_alerts is not set" do
    l = Mole::Logger.new( { :logger_name => "Test3" })
    lambda { l.email_appender }.should raise_error( Mole::Logger::ConfigurationError )
  end

  it "raises an error if an invalid object is passed in for the :log_file" do
    lambda { l = Mole::Logger.new( { :log_file => Object.new } ) }.should raise_error( Mole::Logger::ConfigurationError )
  end

  it "logs to an IO stream if given" do
    io = StringIO.new
    l  = Mole::Logger.new( { :log_file => io, :logger_name => "Test4"  })
    l.info "This is a test io message"
    io.string.split("\n").should have(1).item
    io.string.should =~ /This is a test io message/
    io.string.should =~ /INFO/
  end

  it "logs to a file if given a file name to log to" do
    log_file = "/tmp/mole_logger_test.log"   
    FileUtils.rm( log_file ) if File.exists?( log_file )
    l = Mole::Logger.new({ :log_file => log_file, :logger_name => "Test5" })
    l.info "This is a test log file message"

    log_lines = IO.readlines(log_file)
                          
    log_lines.should have(1).items
    log_lines.first.should =~ /This is a test log file message/
    log_lines.first.should =~ /INFO/
  end

  it "creates a logger from another logger" do
    io = StringIO.new
    l  = Mole::Logger.new( { :log_file => io, :logger_name => ::Mole})
    child_l = l.for(Mole)
    
    child_l.info "This is a child log message"
    io.string.should =~ /This is a child log message/
    io.string.should =~ /INFO/
  end
end
