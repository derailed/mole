# MOle configuration can be either loaded as a single file or as a directory containing
# several MOle configuration for large applications. Idea contributed by Ian Schreuder !!

# The MOle configuration file tells the MOle which actions in your application you want
# to monitor. You can do whatever you want in the interceptors. The MOle comes bundled
# with a utility 'Mole::Moler' that allows you to log the interaction using either a 
# log file, the console or the database. You can scrape your logs for Mole information, but
# we've found that logging to the db is a good approach if you need to generate reports
# based on this information.
# require 'application'

# Watch my_action calls on the Moled Controller
MoledController.mole_after( :feature => :my_action ) do |context, feature, ret, block, *args|
  ::Mole::Moler.mole_it( 
    context               , 
    feature               ,
    context.session[:user],
    :state => context.instance_variable_get( "@state" ),
    :args  => context.params[:id] )
end

# Use the Mole provided convenience util to pick up all rails actions on the MoledController Class 
def all_actions() Mole::Utils::Frameworks.rails_actions( MoledController ) end

# Watch action performance on the MoledController
MoledController.mole_perf( :features => all_actions ) do |context, feature, elapsed_time, ret_val, block, *args|
  ::Mole::Moler.perf_it( 
    context                            , 
    context.session[:user]             ,
    :controller   => context.class.name,
    :feature      => feature           ,
    :args         => args              ,
    :elapsed_time => "%3.3f" % elapsed_time )
end

# Watch for exceptions raise in the MoledController
MoledController.mole_unchecked( :features => all_actions ) do |context, feature, boom, ret_val, block, *args|
  ::Mole::Moler.check_it( 
    context                          , 
    context.session[:user]           ,
    :controller => context.class.name,
    :feature    => feature           ,
    :boom       => boom )
end
