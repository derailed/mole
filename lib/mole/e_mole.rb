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
      module_eval "def #{asp}_alerts_with_setup( context, user_name, opts={} ) setup; #{asp}_alerts_without_setup( context, user_name, opts) end #:nodoc:"
    end
    
    # send out feature alerts
    def feature_alerts( context, user_id, options={} )
      Mole.logger.debug "Sending feature email from #{::Mole.emole_from} -- to #{::Mole.emole_recipients}"                  
      subject     "[FEATURE] #{options[:feature]} -- #{@host} -- #{Mole.application} -- #{user_id}"        
      body        :application  => Mole.application,
                  :host_name    => @host,
                  :context      => context.class.name,
                  :feature      => options[:feature],
                  :args         => dump_args( options )
    end                                  
    alias_method_chain :feature_alerts, :setup
    
    # send out mole performance alert
    def perf_alerts( context, user_id, options={} )                                                                      
      Mole.logger.debug "Sending perf email from #{::Mole.emole_from} -- to #{::Mole.emole_recipients}"                  
      subject     "[PERF] #{@host} -- #{Mole.application} -- #{user_id}"        
      body        :application  => ::Mole.application,       
                  :host_name    => @host,      
                  :context      => context.class.name,
                  :feature      => options[:feature],                          
                  :elapsed_time => options[:elapsed_time] ,
                  :args         => dump_args( options )
    end           
    alias_method_chain :perf_alerts, :setup

    # send out mole exception alerts
    def exception_alerts( context, user_id, options={} )
      Mole.logger.debug "Sending perf email from #{::Mole.emole_from} -- to #{::Mole.emole_recipients}"                  
      subject     "[EXCEPTION] #{@host} -- #{Mole.application} -- #{user_id}"        
      body        :application  => Mole.application,
                  :host_name    => @host,
                  :context      => context.class.name,
                  :feature      => options[:feature],
                  :boom         => options[:boom],  
                  :trace        => dump_stack( options[:boom] ),
                  :args         => dump_args( options )                  
    end                                  
    alias_method_chain :exception_alerts, :setup
                   
    # dumps partial stack
    def dump_stack( boom )   
      return boom if boom.is_a? String         
      buff = boom.backtrace[0...3].join( "\r" )
    end
                                        
    # dumps arguments
    def dump_args( args )
      return "N/A" unless args
      buff = []
      args.keys.sort { |a,b| a.to_s <=> b.to_s}.each do |k|  
        key   = k.to_s.rjust(20)
        value = args[k].to_s.rjust(97,".")
        buff << "#{key} :  #{value}" 
      end
      buff.join( "\r" )
    end
  end
end