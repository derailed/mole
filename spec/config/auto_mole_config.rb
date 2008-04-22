::Mole.auto_perf( File.join( File.dirname(__FILE__), %w[.. data] ) ) do |context, feature, elapsed_time, ret_val, block, *args|
  ::Mole::Moler.perf_it( 
    context                            , 
    "AppBreaker"                       ,
    :controller   => context.class.name,
    :feature      => feature           ,
    :args         => args              ,
    :elapsed_time => "%3.3f" % elapsed_time )
end

::Mole.auto_check( File.join( File.dirname(__FILE__), %w[.. data] ) ) do |context, feature, boom, ret_val, block, *args|
  ::Mole::Moler.check_it( 
    context                          , 
    "AppBreaker"                     ,
    :controller => context.class.name,
    :feature    => feature           ,
    :boom       => boom )
end  
  
::Mole.auto_mole( File.join( File.dirname(__FILE__), %w[.. data] ) ) do |context, feature, ret, block, *args|
  ::Mole::Moler.mole_it( 
    context     , 
    feature     ,
    "AppBreaker",
    :args        => context.params[:id] )
end