require 'action_mailer'

module Mole
  class EMole < ActionMailer::Base        
    self.template_root = File.join( File.dirname(__FILE__), %w[.. .. templates] )
                            
    def setup #:nodoc:
      recipients  ::Mole.emole_recipients
      from        ::Mole.emole_from             
      @host = `hostname`      
    end
       
    # Setup aspect
    %w[perf exception feature].each do |asp|
      module_eval "def #{asp}_alerts_with_setup( context, feature, user_name, opts={} ) setup; #{asp}_alerts_without_setup( context, feature, user_name, opts) end #:nodoc:"
    end
    
    # send out feature alerts
    def feature_alerts( context, feature, user_id, options={} )
      Mole.logger.debug "Sending feature email from #{::Mole.emole_from} -- to #{::Mole.emole_recipients}"                  
      subject     "[FEATURE] #{options[:feature]} -- #{@host} -- #{Mole.application} -- #{user_id}"        
      body        :application  => Mole.application,
                  :host_name    => @host,
                  :context      => context.class.name,
                  :feature      => feature.to_s,
                  :args         => dump_args( options )
    end                                  
    alias_method_chain :feature_alerts, :setup
    
    # send out mole performance alert
    def perf_alerts( context, feature, user_id, options={} )                                                                      
      Mole.logger.debug "Sending perf email from #{::Mole.emole_from} -- to #{::Mole.emole_recipients}"                  
      subject     "[PERF] #{@host} -- #{Mole.application} -- #{user_id}"        
      body        :application  => ::Mole.application,       
                  :host_name    => @host,      
                  :context      => context.class.name,
                  :feature      => feature.to_s,                          
                  :elapsed_time => options[:elapsed_time] ,
                  :args         => dump_args( options )
    end           
    alias_method_chain :perf_alerts, :setup

    # send out mole exception alerts
    def exception_alerts( context, feature, user_id, options={} )      
      Mole.logger.debug "Sending perf email from #{::Mole.emole_from} -- to #{::Mole.emole_recipients}"                  
      subject     "[EXCEPTION] #{@host} -- #{Mole.application} -- #{user_id}"        
      body        :application  => Mole.application,
                  :host_name    => @host,
                  :context      => context.class.name,
                  :feature      => feature.to_s,
                  :boom         => options[:boom],  
                  :trace        => options[:trace],
                  :args         => dump_args( options )                  
    end                                  
    alias_method_chain :exception_alerts, :setup
    
    # =========================================================================               
    private
                                                
      # dumps arguments
      def dump_args( args )
puts "ARGS !!!", args.inspect        
        return "N/A" unless args
        buff = []
        args.keys.sort { |a,b| a.to_s <=> b.to_s}.each do |k|
          key   = k.to_s.rjust(20)
          if args[k].instance_of? Hash
            buff << dump_hash( args[k] )
          else
            value = args[k].to_s.rjust(97,".")
            buff << "#{key} :  #{value}" 
          end
        end
        buff.join( "\r" )
      end
      
      def dump_hash( value )
puts "!!!!! VAL!!!", value.inspect        
        buff = []
        value.keys.sort { |a,b| a.to_s <=> b.to_s} .each do |k|  
          key = k.to_s.rjust(20)
          if value[k].instance_of? Hash
            buff << dump_hash( value[k] )
          else
            val = value[k].to_s.rjust(97,".")
            buff << "#{key} :  #{val}" 
          end
        end
        buff
      end
  end
end