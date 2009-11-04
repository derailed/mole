# -----------------------------------------------------------------------------
# Manages different ways to log the Mole interceptors. Currently there are two
# allowed modes ie persistent and transient
# Persistent mode will log the interception to the database for easy viewing
# and reporting.
# Transient mode will log the interaction to the mole logger.
# -----------------------------------------------------------------------------
module Mole
  class Moler    
    class << self      
            
      # log a mole feature occurence.           
      def mole_it( context, feature, user_id, params )    
        return unless ::Mole.moleable?        
        
        if ::Mole.persistent?
          MoleLog.log_it( context, MoleFeature::find_or_create_feature( feature, ::Mole.application, context.class.name ), user_id, params )
        else
          ::Mole.logger.log_it( context, feature, user_id, params )
        end

        # Send out email notification if requested   
        Mole::EMole.deliver_feature_alerts( context, feature, user_id, params ) if email?( params )
        
        # Send out twitt if requested        
        Mole::Twitt.instance.feature_alerts( context, feature, user_id, params ) if twitt?( params )
      end         
      
      # log an unchecked exception. Moler will look at the MOle
      # configuration to see if this event should be persisted to the db or
      # sent out to the logger.           
      def check_it( context, user_id, params )                                            
        return unless ::Mole.moleable?   
        
        # If exception is given record the first couple of frames
        if params[:boom]
          params[:trace] = dump_stack( params[:boom] )
          params[:boom]  = truncate( params[:boom].to_s )
        end        
        
        feature = nil
        if ::Mole.persistent?             
          feature = MoleFeature::find_exception_feature( ::Mole.application )
          MoleLog.log_it( context, feature, user_id, params )             
        else         
          feature = "Exception"                                                                   
          ::Mole.logger.log_it( context, feature, user_id, params ) 
        end         
         
        # Send out email notification if requested
        Mole::EMole.deliver_exception_alerts( context, feature, user_id, params ) if email?( params )

        # Send out twitt if requested        
        Mole::Twitt.instance.exception_alerts( context, feature, user_id, params ) if twitt?( params )                
      end             
                                         
      # log performance occurence. 
      def perf_it( context, user_id, params )
        return unless ::Mole.moleable?
                
        feature = nil
        if ::Mole.persistent?
          feature = MoleFeature::find_performance_feature( ::Mole.application )
          MoleLog.log_it( context, feature, user_id, params )
        else
          feature = "Performance"
          ::Mole.logger.log_it( context, feature, user_id, params )
        end
        # Send out email notification if requested
        Mole::EMole.deliver_perf_alerts( context, feature, user_id, params ) if email?( params )

        # Send out twitt if requested        
        Mole::Twitt.instance.perf_alerts( context, feature, user_id, params ) if twitt?( params )        
      end
                        
      # =======================================================================
      # private
      
      # truncate exception
      def truncate(text, length = 200, truncate_string = "...")
        return "" if text.nil?
        l = length - truncate_string.mb_chars.length
        text.mb_chars.length > length ? (text.mb_chars[0...l] + truncate_string).to_s : text
      end
  
      # dumps partial stack
      def dump_stack( boom )
        return truncate( boom.backtrace[0] ) if boom.backtrace.size == 1
        buff = boom.backtrace[0...3].join( "-" )
      end  
    
      # check for twitter notification
      def twitt?( params )
        params[:twitt] == true
      end
      
      # check if need to send an email alert
      def email?( params )
        params[:email] == true
      end          
    end             
  end
end