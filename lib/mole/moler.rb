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
      # log an unchecked exception. Moler will look at the MOle
      # configuration to see if this event should be persisted to the db or
      # sent out to the logger.           
      def check_it( context, user_id, args )                                            
        return unless ::Mole.moleable?   
        # If exception is given record the first couple of frames
        if args[:boom]
          args[:trace] = dump_stack( args[:boom] )
          args[:boom]  = args[:boom].to_s
        end        
        if ::Mole.persistent?             
          MoleLog.log_it( context, MoleFeature::find_exception_feature( ::Mole.application ), user_id, args )             
        else                                                                            
          ::Mole.logger.log_it( context, "Exception", user_id, args ) 
        end          
        # Send out email notification if requested
        Mole::EMole.deliver_exception_alerts( context, user_id, args ) if args[:email] and args[:email] == true        
      end             
                                         
      # log performance occurence. 
      def perf_it( context, user_id, args )
        return unless ::Mole.moleable?        
        if ::Mole.persistent?
          MoleLog.log_it( context, MoleFeature::find_performance_feature( ::Mole.application ), user_id, args )
        else
          ::Mole.logger.log_it( context, "Performance", user_id, args )
        end
        # Send out email notification if requested
        Mole::EMole.deliver_perf_alerts( context, user_id, args ) if args[:email] and args[:email] == true                
      end
            
      # log a mole feature occurence.           
      def mole_it(context, feature, user_id, args)    
        return unless ::Mole.moleable?        
        if ::Mole.persistent?
          MoleLog.log_it( context, MoleFeature::find_or_create_feature( feature, ::Mole.application, context.class.name ), user_id, args )
        else
          ::Mole.logger.log_it( context, feature, user_id, args )
        end
        # Send out email notification if requested   
        if args[:email] and args[:email] == true 
          args[:feature] = feature
          Mole::EMole.deliver_feature_alerts( context, user_id, args )                         
        end
      end         
      
      # dumps partial stack
      def dump_stack( boom )      
        buff = boom.backtrace[0...3].join( "-" )
      end      
    end             
  end
end