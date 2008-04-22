# Mole a feature called 'my_feature' on class Fred
RubyApp::Fred.mole_after( :feature => :my_feature ) { |context, feature, ret, block, *args|
  ::Mole::Moler.mole_it( 
    context                       , # Calling context => Fred instance
    feature                       , # Method called on Fred => my_feature
    "AppBreaker"                  , # If we had real user information we would put it here...
    :args     => args.join( ", " ), # The args passed into my_feature
    :returned => ret              ) # The value returned by my_feature call
 }

# Monitor perf on all instance methods defined on Fred
RubyApp::Fred.mole_perf do |context, feature, elapsed_time, ret, block, *args|
  ::Mole::Moler.perf_it( 
    context                                 , 
    "AppBreaker"                            , # User info
    :controller   => context.class.name     ,
    :feature      => feature                ,
    :args         => args                   ,
    :returned     => ret                    ,
    :elapsed_time => "%3.3f" % elapsed_time )
end

# Monitors unchecked exceptions raise in Fred
RubyApp::Fred.mole_unchecked do |context, feature, boom, ret, block, *args|
  ::Mole::Moler.check_it( 
    context                          , 
    "AppBreaker"                     , # User info
    :controller => context.class.name,
    :feature    => feature           ,
    :boom       => boom              )
end
