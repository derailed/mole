# Log Model - Tracks and record user interactions with various features
# This will make it easy to write an app on top on the MOle to track a 
# particular application utilization.                     
class MoleLog < ActiveRecord::Base                                             
  belongs_to :mole_feature  
    
  class << self                                               
    # mole the bastard - create db entry into mole logs
    def log_it( context, feature, user_id, args )
      args    ||= "no args"                           
      user_id ||= "N/A"             
      ip_addr, browser_type = log_details( context )      
      MoleLog.create( :mole_feature => feature, 
                      :user_id      => user_id, 
                      :host_name    => `hostname`,
                      :params       => args.to_yaml,
                      :ip_address   => ip_addr, 
                      :browser_type => browser_type )
    end               
    
    # extract orginating ip address and browser type                                               
    def log_details( context ) #:nodoc:
      ip_addr, browser_type = nil
      if context.respond_to? :request                                                                     
        ip_addr, browser_type = context.request.env['REMOTE_ADDR'], context.request.env['HTTP_USER_AGENT'] 
      end
      return ip_addr, browser_type
    end            
  end          
  
end