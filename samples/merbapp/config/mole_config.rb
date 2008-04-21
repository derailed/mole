# Watch my_action calls on the Moled Controller
Moled.mole_after( :feature => :my_action ) { |context, feature, ret, block, *args|
  ::Mole::Moler.mole_it( 
    context                                              , 
    feature                                              ,
    context.session[:user]                               ,
    :state   => context.instance_variable_get( "@state" ),
    :args    => args.join( ", " )                        )
}

# Use the Mole provided convenience util to pick up all actions on the Moled Controller Class 
def all_actions() Mole::Utils::Frameworks.merb_actions( Moled ) end

# Watch action performance on the Moled Controller
Moled.mole_perf( :features => all_actions ) do |context, feature, elapsed_time, ret, block, *args|
  ::Mole::Moler.perf_it( 
    context                                 , 
    context.session[:user]                  ,
    :controller   => context.class.name     ,
    :feature      => feature                ,
    :args         => args                   ,
    :elapsed_time => "%3.3f" % elapsed_time )
end

# Watch unchecked exceptions on the Moled Controller
Moled.mole_unchecked( :features => all_actions ) do |context, feature, boom, ret, block, *args|
  ::Mole::Moler.check_it( 
    context                          , 
    context.session[:user]           ,
    :controller => context.class.name,
    :feature    => feature           ,
    :boom       => boom )
end
