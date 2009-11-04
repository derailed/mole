require 'twitter'

# TODO Use template engine for twitts
module Mole
  class Twitt     
    include Singleton
                               
    def initialize #:nodoc:
      username, pwd = Mole.twitter_credentials
      raise "You must specify your twitter account credentials" unless username or pwd
      @twitter = ::Twitter::Client.new( :login => username, :password => pwd )
      @host    = `hostname`      
    end
       
    # send out feature alerts
    def feature_alerts( context, feature, user_id, options={} )
      # setup
      twitt_msg = "[#{Mole.application}:FEATURE] #{@host}:#{user_id} -- #{context.class}:#{feature}"
      @twitter.status( :post, twitt_msg )
    end                                  
    
    # send out mole performance alert
    def perf_alerts( context, feature, user_id, options={} )
      # setup
      twitt_msg = "[#{Mole.application}:PERFORMANCE] #{@host}:#{user_id} -- #{options[:elapsed_time]} -- #{context.class}##{options[:feature]}"
      @twitter.status( :post, twitt_msg )
    end           

    # send out mole exception alerts
    def exception_alerts( context, feature, user_id, options={} )
      # setup
      twitt_msg = "[#{Mole.application}:EXCEPTION] #{@host}:#{user_id} -- #{options[:boom]} -- #{context.class}##{options[:feature]}"
      @twitter.status( :post, twitt_msg )
    end
  end
end