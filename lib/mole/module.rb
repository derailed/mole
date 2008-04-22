# =============================================================================
# Extends module to inject interceptors                                        
# =============================================================================
require 'benchmark'
require 'active_support'

class Module              
  # intercepts a collection of features and wrap performance check based on the
  # specified :perf_threshold. The trigger defaults to 5 secs if not explicitly set.
  #
  # Example:   
  #
  #   MyClass.mole_perf do |context, action, elapsed_time, ret, block, *args|                            
  #     Mole::DbMole.perf_it( context.session[:user_id], 
  #                           :controller   => context.class.name,
  #                           :action       => action,                           
  #                           :elapsed_time => "%3.3f" % elapsed_time )
  #   end  
  #
  # This will trap all public methods on the MyClass that takes more than 
  # :perf_threshold to complete. You can override this default by using the option
  # :features => [m1,m2,...]. This is handy for controller moling rails
  # and merb context.
  # 
  # If you elect not to use the block form of the call, you can pass in the
  # following arguments to the option hash:
  # <tt>:interceptor</tt>::   The class name of your interceptor class
  # <tt>:method</tt>::        The name of the method to callback the interceptor on
  #                           once a perf condition has been trapped.
  def mole_perf( opts={}, &interceptor )    
    opts[:interceptor] ||= interceptor
    opts[:method]      ||= :call             
    opts[:features]    ||= instance_methods( false )
    opts[:features].each do |feature|  
      wrap feature
      perf_mole_filters[feature.to_s] << [opts[:interceptor], opts[:method]]
    end    
  end
         
  # monitors a collections of features and wrap rescue logic to trap unchecked 
  # exceptions. You can handle to trap differently by either logging the event
  # in the db or sending out email/IM notification.
  #
  # Example:   
  #
  #   MyClass.mole_unchecked do |context, action, boom, block, *args|
  #     Mole::Moler.check_it( context.session[:user_id], 
  #                          :controller => context.class.name,  
  #                          :action     => action,
  #                          :boom       => boom )    
  #   end  
  #
  # This will wrap all public instance methods on MyClass. If any of these methods
  # raises an unchecked exception, the MOle will surface the condition. 
  # This call also takes in a :features option to specify a list of methods if the
  # default instance methods is not suitable, you can pass in a collection of methods
  # that you wish to mole. This is handy in the case of Rails/Merb where conveniences
  # are provided to gather controller actions
  # 
  # If you elect not to use the block form of the call, you can pass in the
  # following arguments to the option hash:
  # <tt>:interceptor</tt>::   The class name of your interceptor class
  # <tt>:method</tt>::        The name of the method to callback the interceptor on
  #                           once an exception condition has been trapped.   
  def mole_unchecked( opts={}, &interceptor )    
    opts[:interceptor] ||= interceptor
    opts[:method]      ||= :call             
    opts[:features]    ||= instance_methods( false )
    opts[:features].each do |feature|  
      wrap feature
      unchecked_mole_filters[feature.to_s] << [opts[:interceptor], opts[:method]]
    end
  end

  # intercepts a feature before the feature is called. During the callback
  # you will have access to the object ( context ) on which the call is intercepted,
  # as well as the arguments/block, the feature was issued with.
  #
  # Example:   
  #
  #   MyClass.mole_before( :feature => :blee ) do |context, feature, block, *args|
  #     Mole::Moler.mole_it( context, feature, context.session[:user_id], 
  #                         :args => args )
  #   end  
  #
  # This will wrap the method blee with a before interceptor. Before the blee call
  # is issued on MyClass, control will be handed to the before interceptor. 
  # 
  # Options:
  # <tt>:feature</tt>::       The name of the feature to be intercepted  
  # If you elect not to use the block form of the call, you can pass in the
  # following arguments to the option hash:  
  # <tt>:interceptor</tt>::   The class name of your interceptor class. If no interceptor block is specified
  # <tt>:method</tt>::        The name of the method to callback the interceptor on
  #                           once an exception condition has been trapped.     
  def mole_before(opts={}, &interceptor)  
    raise "Missing :feature option" if opts[:feature].nil? or opts[:feature].to_s.empty?
    opts[:interceptor] ||= interceptor
    opts[:method] ||= :call
    feature = opts[:feature].to_s
    if before_mole_filters[feature].empty?
      wrap feature 
      before_mole_filters[feature] << [opts[:interceptor], opts[:method]]
    end
  end

  # intercepts a feature after the feature is called. During the callback
  # you will have access to the object ( context ) on which the call is intercepted,
  # as well as the arguments/block and return values the feature was issued with.
  #
  # Example:   
  #
  #   MyClass.mole_after( :feature => :blee ) do |context, feature, ret_val, block, *args|
  #     Mole::Moler.mole_it( context, feature, context.session[:user_id], 
  #                         :args => args )
  #   end  
  #
  # This will wrap the method blee with an after interceptor. After the blee call
  # is issued on MyClass, control will be handed to the after interceptor. 
  # 
  # Options:
  # <tt>:feature</tt>::       The name of the feature to be intercepted  
  # <tt>:interceptor</tt>::   The class name of your interceptor class. If no interceptor block is specified
  # <tt>:method</tt>::        The name of the method to callback the interceptor on
  #                           once an exception condition has been trapped.     
  def mole_after(opts = {}, &interceptor)
    raise "Missing :feature option" if opts[:feature].nil? or opts[:feature].to_s.empty?    
    opts[:interceptor] ||= interceptor
    opts[:method] ||= :call
    feature = opts[:feature].to_s
    if after_mole_filters[feature].empty?
      wrap feature 
      after_mole_filters[feature] << [opts[:interceptor], opts[:method]]
    end
  end
   
  # ---------------------------------------------------------------------------
  # Dumps moled feature info       
  def mole_dump( msg=nil )
    puts "\n------------------------------------------------------------------"
    puts "From #{msg}" if msg
    puts "MOle Info for class <- #{self} ->"
    puts "\nBefore filters"
    before_mole_filters.keys.sort.each { |k| puts "\t#{k} --> #{before_mole_filters[k]}" }
    puts "\nAfter filters"
    after_mole_filters.keys.sort.each { |k| puts "\t#{k} --> #{after_mole_filters[k]}" }
    puts "\nUnchecked filters"
    unchecked_mole_filters.keys.sort.each { |k| puts "\t#{k} --> #{unchecked_mole_filters[k]}" }
    puts "\nPerf filters"
    perf_mole_filters.keys.sort.each { |k| puts "\t#{k} --> #{perf_mole_filters[k]}" }    
    puts "---------------------------------------------------------------------\n"    
  end
      
  # ===========================================================================
  private

    # Clear MOle state for this class # Used for testing only
    def mole_clear!
      @before_mole_filters = nil  
      @after_mole_filters = nil  
      @perf_mole_filters = nil  
      @unchecked_mole_filters = nil                    
    end  
    
  # ===========================================================================
  public
    
    # -------------------------------------------------------------------------
    # Holds before filters
    def before_mole_filters #:nodoc:    
      @before_mole_filters ||= Hash.new{ |h,k| h[k] = [] }
    end

    # -------------------------------------------------------------------------
    # Holds after filters
    def after_mole_filters #:nodoc:
      @after_mole_filters ||= Hash.new{ |h,k| h[k] = [] }
    end
  
    # -------------------------------------------------------------------------
    # Holds perf around filters   
    def perf_mole_filters #:nodoc:
      @perf_mole_filters ||= Hash.new{ |h,k| h[k] = []} 
    end

    # -------------------------------------------------------------------------
    # Holds unchecked exception filters   
    def unchecked_mole_filters #:nodoc:
      @unchecked_mole_filters ||= Hash.new{ |h,k| h[k] = []} 
    end
        
    # -------------------------------------------------------------------------        
    # Attempt to find singleton class method with given name 
    # TODO Figure out how to get method for static signature...
    # def find_public_class_method(method)                        
    #   singleton_methods.each { |name| puts "Looking for #{method}--#{method.class} -- #{name}#{name.class}";return name if name == method }
    #   nil
    # end
  
    # -------------------------------------------------------------------------
    # Wrap method call                                
    # TODO Add support for wrapping class methods ??
    def wrap( method ) #:nodoc:
      return if wrapped?( method )  
      begin
        between = instance_method( method )
      rescue
        # between = find_public_class_method( method )
        raise "Unable to find moled feature `#{method}" unless(between)
      end
      code = <<-code
        def #{method}_with_mole (*a, &b)
          key                 = '#{method}'
          klass               = self.class
          between             = klass.wrapped[key]
          ret_val             = nil
          klass.apply_before_filters( klass.before_mole_filters[key], self, key, *a, &b ) if klass.before_mole_filters[key]
          begin                                          
            elapsed = Benchmark::realtime do 
              ret_val = between.bind(self).call( *a, &b ) 
            end   
            klass.apply_perf_filters( elapsed, klass.perf_mole_filters[key], self, key, ret_val, *a, &b ) if klass.perf_mole_filters[key]
          rescue => boom   
            klass.apply_unchecked_filters( boom, klass.unchecked_mole_filters[key], self, key, *a, &b ) if klass.unchecked_mole_filters[key]
            raise boom            
          end                                                                 
          klass.apply_after_filters( klass.after_mole_filters[key], self, key, ret_val, *a, &b ) if klass.after_mole_filters[key]
          ret_val
        end
      code
   
      module_eval                code               
      alias_method_chain method, "mole" 
      wrapped[method.to_s]       = between
    end    
   
    def apply_before_filters( filters, clazz, key, *a, &b )          #:nodoc:              
      begin
        filters.each { |r,m| r.send( m, clazz, key, b, *a ) }
      rescue => ca_boom
        ::Mole.logger.error ">>> MOle Failure: Before-Filter -- " + ca_boom
        ca_boom.backtrace.each { |l| ::Mole.logger.error l }           
      end    
    end
                       
    def apply_after_filters( filters, clazz, key, ret_val, *a, &b )   #:nodoc:              
      begin  
        filters.each { |r,m| r.send( m, clazz, key, ret_val, b, *a ) }
      rescue => ca_boom    
        ::Mole.logger.error ">>> MOle Failure: After-Filter -- " + ca_boom
        ca_boom.backtrace.each { |l| ::Mole.logger.error l }           
      end    
    end
                       
    def apply_perf_filters( elapsed, filters, clazz, key, ret_val, *a, &b )       #:nodoc:
      begin
        if ( elapsed >= Mole.perf_threshold  )
          filters.each { |r,m| r.send( m, clazz, key, elapsed, ret_val, b, *a ) }            
        end
      rescue => ca_boom
        ::Mole.logger.error ">>> MOle Failure: Perf-Filter -- " + ca_boom
        ca_boom.backtrace.each { |l| ::Mole.logger.error l }             
      end    
    end
                       
    def apply_unchecked_filters( boom, filters, clazz, key, *a, &b ) #:nodoc:
      begin
        filters.each { |r,m| r.send( m, clazz, key, boom, b, *a ) }
      rescue => ca_boom                               
        ::Mole.logger.error ">>> MOle Failure: Unchecked-Filter -- " + ca_boom
        ca_boom.backtrace.each { |l| ::Mole.logger.error l }             
      end                                                                       
    end
                          
    # ---------------------------------------------------------------------------
    # Log wrapped class
    def wrapped #:nodoc:
      @wrapped ||= {}
    end

    # ---------------------------------------------------------------------------
    # Check if method has been wrapped
    def wrapped?(which) #:nodoc:
      wrapped.has_key?(which.to_s)
    end       
end