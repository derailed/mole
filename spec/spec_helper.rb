require 'rubygems'        
require 'active_record'  
             
require File.join( File.dirname(__FILE__), %w[.. lib mole] )

# Init the mole with defaults             
::Mole.initialize
         
# Connect to the database    
unless ActiveRecord::Base.connected?
  db_config = YAML.load_file( File.join( File.dirname(__FILE__), %w[.. config database.yml] ) )["test"]
  # ::ActiveRecord::Base.logger = ::Mole.logger 
  # ::ActiveRecord::Base.logger.level = :debug
  ::ActiveRecord::Base.establish_connection(db_config)
end

class CallStackChecker
  class << self
    def called
      @called = 1
    end
    
    def reset
      @called = 0
    end
    
    def called?
      @called == 1
    end    
  end
end
                  
gem 'rspec'
require 'spec'
                     
Spec::Runner.configure do |config|  
  config.before(:each) do
    # from fixtures.rb in rails
    begin
      ActiveRecord::Base.send :increment_open_transactions
      ActiveRecord::Base.connection.begin_db_transaction
    rescue
    end
  end

  config.after(:each) do      
    begin
      # from fixtures.rb in rails
      if Thread.current['open_transactions'] && Thread.current['open_transactions'] > 0
        Thread.current['open_transactions'].downto(1) do
          ActiveRecord::Base.connection.rollback_db_transaction if ActiveRecord::Base.connection
        end
        Thread.current['open_transactions'] = 0
      end
      ActiveRecord::Base.verify_active_connections!
    rescue
    end
  end
end      
                              
# Convenience to check mole_logs
def check_it( feature, user_id, args={} )
  log = MoleLog.find( :first, :conditions => ['mole_feature_id = ?', feature.id] )     
  log.should_not     be_nil
  log.user_id.should == user_id         
  log_args = YAML.load( log.params )
  check_args( log_args, args )
  log
end                           
def check_args( args, expected_args )
  args.should have(expected_args.size).items
  expected_args.keys.each do |k| 
    args[k].should_not be_nil
    args[k].should == expected_args[k]
  end
end                        
