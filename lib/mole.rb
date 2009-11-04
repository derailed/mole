# $Id$

# Equivalent to a header guard in C/C++
# Used to prevent the class/module from being loaded more than once
unless defined? Mole
  require 'activerecord'
  module Mole                 
    # :stopdoc:
    LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
    PATH    = ::File.dirname(LIBPATH) + ::File::SEPARATOR
    
    # :startdoc:  
    # The MOle can be ran in a couple of modes: Transient and Persistent         
    # Transient mode will log the output to the specified log file
    # Persistent mode will log the mole output to your db      
    # The default is :transient
    def self.run_modes #:nodoc:
      [:transient, :persistent]
    end
  
    # MOle Default settings 
    def self.defaults #:nodoc:
      @defaults ||= { 
        :moleable         => false, 
        :application      => "Default", 
        :perf_threshold   => 5,          
        :mode             => :transient,  
        :emole_from       => "MOleBeatch",  
        :emole_recipients => [],        
        :mole_config      => nil,      
        # logging options
        :log_file           => $stdout,
        :log_level          => :info,
        :email_alerts_to    => "MOleBeatch",
        :email_alert_level  => :error }      
    end                               
                                     
    # Reset the configuration to what it would be when the class is parsed
    # this is needed mainly for running specs.  This resets the class to the
    # state it was before initialize is called.  initialize MUST be called
    # after reset_configuration! is invoked
    def self.reset_configuration! #:nodoc:
      @logger.clear_appenders if @logger
      @logger = nil
      @config = nil
    end
            
    # Initialize the MOle 
    # Valid options are
    # <tt>moleable</tt>::         specify if this application is moleable.
    #                             Defaults to false.
    # <tt>application</tt>::      the name of the application to be moled.
    # <tt>perf_threshold</tt>::   the performance threshold over which a Mole condition will be issued.
    #                             Defaults to 5 seconds
    # <tt>mode</tt>::             the MOle logging mole. The mole can either log information to a db via
    #                             the :persistent option or to a log file via the :transient flag.
    #                             Defaults to transient
    # <tt>emole_from</tt>::       the EMole originator when sending eMOle alerts.
    # <tt>emole_recipients</tt>:: a collection of EMOle recipients
    # <tt>mole_config</tt>::      the location of the MOle configuration file where the interceptors will
    #                             be defined.
    # <tt>log_file</tt>::         The log file to be used to log MOle interceptions
    # <tt>log_level</tt>::        logging level ie :info, :debug, :error, :warn...
    # <tt>email_alerts_to</tt>::  log level email alert recipients.
    # <tt>email_alert_level</tt>:: specifies which log level will trigger email alerts to be sent   
    # <tt>twitter_login</tt>::    Twitter login either username or email address
    # <tt>twitter_pwd</tt>::      Twitter password
    def self.initialize( opts={} ) 
      @config = defaults.merge( opts )    
      @config[:email_alerts_to] = @config[:emole_recipients] if @config[:emole_recipients] and !@config[:emole_recipients].empty?
      # Add the mole/lib to the ruby path...
      $: << libpath
      Mole.require_all_libs_relative_to __FILE__                                       
    end
      
    # Loads the mole configuration file
    # You can either specify a directory containing mole config files or 
    # a single mole config file via the mole_config option.
    def self.load_mole_configuration
      return unless moleable?      
      raise "Unable to find the MOle configuration from `#{conf_file}" if conf_file and !File.exists? conf_file      
      unless @config_loaded
        @config_loader = true
        if File.directory? conf_file
          logger.debug "--- Loading MOle configs files from directory `#{conf_file}"          
          load_all_moles_relative_to( conf_file )
        else
          logger.debug "--- Loading single MOle config #{conf_file}"          
          load conf_file
        end
      end
      @config_loaded
    end
    
    # Fetch the MOle configuration file
    def self.conf_file #:nodoc:
      config[:mole_config]
    end
                 
    # EMole alert sender             
    def self.emole_from #:nodoc:
      config[:emole_from]
    end
                        
    # EMole alert recipients
    def self.emole_recipients  #:nodoc:
      config[:emole_recipients]
    end
             
    # Twitter account information return login, pwd
    def self.twitter_credentials
      return config[:twitter_login], config[:twitter_pwd]
    end
    
    # Fetch the MOle configuration
    def self.config  #:nodoc:
      @config
    end
  
    # Debug                        
    def self.dump #:nodoc:
      puts "" 
      puts "Mole Configuration Landscape"    
      config.keys.sort{ |a,b| a.to_s <=> b.to_s }.each do |k| 
        key   = k.to_s.rjust(20)
        value = config[k].to_s.rjust(97,".")
        puts "#{key} : #{value}"
      end
    end

    # get a hold of a logger.  This is the global logger for sentiment.
    def self.logger #:nodoc:   
      @logger ||= ::Mole::Logger.new( { :log_file          => config[:log_file], 
                                        :logger_name       => "MOle",
                                        :log_level         => config[:log_level],
                                        :email_alerts_to   => config[:email_alerts_to],
                                        :email_alert_level => config[:email_alert_level],
                                        :additive          => false } )
    end
            
    # The name of the MOled application
    def self.application #:nodoc:
      config[:application]
    end                
                          
    # Is this application is MOleable
    def self.moleable? #:nodoc:
      config[:moleable]
    end                
                                         
    # Returns the MOle perf threshold. If any MOled features takes longer
    # than this time to complete, then an alarm will be triggered...
    def self.perf_threshold #:nodoc:
      config[:perf_threshold]
    end
        
    # Enable to toggle between different log modes ie :persistent/:transient
    def self.switch_mode( mode )
      config[:mode] = mode
    end
                      
    # Check if the MOle is running in persistent mode
    def self.persistent?
      config[:mode] == :persistent
    end
  
    # Returns the library path for the module. If any arguments are given,
    # they will be joined to the end of the libray path using
    # <tt>File.join</tt>.
    #
    def self.libpath( *args ) #:nodoc:
      args.empty? ? LIBPATH : ::File.join(LIBPATH, *args)
    end

    # Returns the lpath for the module. If any arguments are given,
    # they will be joined to the end of the path using
    # <tt>File.join</tt>.
    #
    def self.path( *args ) #:nodoc:
      args.empty? ? PATH : ::File.join(PATH, *args)
    end

    # Utility method used to require all files ending in .rb that lie in the
    # directory below this file that has the same name as the filename passed
    # in. Optionally, a specific _directory_ name can be passed in such that
    # the _filename_ does not have to be equivalent to the directory.
    #
    def self.require_all_libs_relative_to( fname, dir = nil ) #:nodoc:
      dir       ||= ::File.basename(fname, '.*')
      search_me   = ::File.expand_path( ::File.join(::File.dirname(fname), dir, '**', '*.rb'))
      Dir.glob(search_me).sort.each {|rb| require rb}
    end

    # Utility method used to load all MOle config files ending in .rb that lie in the
    # directory below this file that has the same name as the filename passed
    # in. Optionally, a specific _directory_ name can be passed in such that
    # the _filename_ does not have to be equivalent to the directory.
    #
    def self.load_all_moles_relative_to( mole_dir ) #:nodoc:
      search_me = ::File.join( mole_dir, '**', '*.rb')
      Dir.glob(search_me).sort.each {|rb| load rb}
    end
    
    # Stolen from inflector
    def self.camelize(lower_case_and_underscored_word)
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    end
    
    # Fetch all ruby files in the given directory and return a cltn of class names
    def self.find_controller_classes( dir )
      classes   = []
      search_me = ::File.expand_path( ::File.join(dir, '*.rb'))
      # BOZO !! This kind of sucks - need to exclude application controller for rails otherwise class loading error ??
      Dir.glob(search_me).sort.each {|rb| classes << camelize( File.basename( rb, ".rb") ) unless File.basename( rb, ".rb") == "application_controller" }
      classes
    end
    
    # Automatically setup on perf MOle on any classes within a given directory
    # NOTE: this call assumes the controller classes are in all in the path    
    def self.auto_perf( dir, &block )
      controller_classes = find_controller_classes( dir )
      controller_classes.each do |class_name|
        clazz    = Kernel.const_get( class_name )
        features = ::Mole::Utils::Frameworks.features_for( clazz )
        clazz.mole_perf( :features => features, &block )
      end
    end
    
    # Automatically setup MOle untrapped exception on any classes within a given directory
    # NOTE: this call assumes the controller classes are in all in the path
    def self.auto_unchecked( dir, &block )
      controller_classes = find_controller_classes( dir )
      controller_classes.each do |class_name|
        clazz    = Kernel.const_get( class_name )
        features = ::Mole::Utils::Frameworks.features_for( clazz )
        clazz.mole_unchecked( :features => features, &block )
      end
    end

    # Automatically setup MOle after filter on any classes within a given directory
    # NOTE: this call assumes the controller classes are in all in the path    
    def self.auto_after( dir, &block )
      controller_classes = find_controller_classes( dir )
      controller_classes.each do |class_name|
        clazz = Kernel.const_get( class_name )
        features = ::Mole::Utils::Frameworks.features_for( clazz )
        features.each do |feature|
          clazz.mole_after( :feature => feature, &block )
        end
      end
    end

    # Automatically setup MOle after filter on any classes within a given directory
    # NOTE: this call assumes the controller classes are in all in the path    
    def self.auto_before( dir, &block )
      controller_classes = find_controller_classes( dir )
      controller_classes.each do |class_name|
        clazz = Kernel.const_get( class_name )
        features = ::Mole::Utils::Frameworks.features_for( clazz )
        features.each do |feature|
          clazz.mole_before( :feature => feature, &block )
        end
      end
    end
    
  end
end