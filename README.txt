The MOle
    by Fernand Galiana
    liquidrail.com

== DESCRIPTION:
                   
The MOle allows you to track user's interactions with your ruby application and closely monitors
how your customers are using your application. This is a must cheaper way than to hire a monitoring
service and produces much more detailed information on your application behavior and usage. To boot
your managers will love you !

Whether you are releasing a new application or improving on an old one, it is always a good thing 
to know if anyone is using your application and if they are, how they are using it. 
What features are your users most fond of and which features find their way into the abyss? 
Using the MOle you'll be able to rapidly assess whether or not your application is a hit and if
your coolest features are thought as such by your users. You will be able to elegantly record user
interactions and leverage these findings for the next iteration of your application. 
                
The MOle was initialy released as a Rails plugin, but we found the behavior usefull in other types
of projects such as Merb or straight up ruby applications, and decided to re-release it as a gem 
instead.

== PROJECT INFORMATION

* Developer:  Fernand Galiana [liquidrail.com]
* Forum:      http://groups.google.com/group/mole-plugin
* Home:       mole.rubyforge.org
* Svn:        svn://rubyforge.org/var/svn/mole/mole/trunk
* Snitch Svn: svn://rubyforge.org/var/svn/mole/snitch/trunk
* Examples:   svn://rubyforge.org/var/svn/mole/samples

== FEATURES:
                                                                                     
The MOle allows you to easily
  
* Trap method calls within your ruby application. You can use the MOle with either a straight ruby 
  application, Rails or Merb. The MOle allows you to inject aspects across various method calls.    
  You are in full control on how and where to trap the calls and the arguments you want to record. 
  'Moled' methods are not limited to controller's actions, you can also mole any third party or library methods. 

* Single configuration file. You won't have to sprinkle MOle code all over your application.
  The MOle instructions reside in a single file easy to manage and maintain. 

* Trap and surface uncaught exceptions in one easy call. The MOle will watch your execution stack
  and alert you when an unexpected exception is encountered

* Trap and surface performance bottle neck in your ruby application in one easy call. You can 
  specify a performance threshold within the MOle configuration file. Any methods taking longer
  than the specified threshold will trip an alert.
                                                  
* You can record users interaction by either using the MOle is a transient or persistent mode.
  In the persistent mode, users interactions will be recorded in your database. In the transient
  case, MOle events will be recorded in your application logs.

== INSTALL:

* sudo gem install mole   
  
== SYNOPSIS:

* The MOle can operate in 2 different modes: transient or persistent. The transient mode will
  simply record MOle interactions within your log file. If you opt to use the 
  persistent mode (recommanded!) which will allow to leverage the Snitch Application
  and also draw out MOle usage reports from you database, you will need to install the 2 MOle tables in your database.
  This is achived via the 'molify' command. In order to 'MOle' an application using the persistent
  mode, you will need to issue the following commands:
                                                     
   > cd my_non_moled_application
   > molify --up --config config/database.yml --env test
  
  This command will update your test database and create the MOle tables required when 
  the MOle is in a persistent mode. Namely, these tables are mole_features and mole_logs.
   
  You can use molify --help to see usage information. 
                                                                                             
* Mole initialization. This must be specified during your application initialization code.
  In a rails app, this can be set in you application controller class or environment.rb. In 
  a Merb app, this can be set in your merb_init.rb file.
        
   require 'mole'                    
   Mole.initialize( :moleable         => true,
                    :application      => "Smf",   
                    :emole_from       => "MoleBeatch@liquidrail.com",
                    :emole_recipients => ['fernand@liquidrail.com'],
                    :mode             => :persistent,
                    :log_file         => $stdout,
                    :log_level        => :debug,
                    :perf_threshold   => 2,
                    :mole_config      => File.join( File.dirname(__FILE__), %w[mole.rb] ) ) 
   # Load the MOle configuration file(s)
   ::Mole.load_configuration                  
                    
  NOTE: The mole_config can either be a single ruby file or a directory containing multiple MOle
  configuration files. Thanks to Ian Schreuder for the suggestion !
  
  NOTE: For rails applications you can either put the MOle initialization code in a custom initializer
  ie config/initializers/mole.rb or in your environment file (config/environments/production.rb). 
  You will need to make the load_configuration call in your application controller(application.rb) as follows:
  
    ::Mole.load_mole_configuration rescue nil 
    
  In dev env, the MOle will reload the configuration so you can tweak your app on the fly. In production
  env the MOle configuration will be loaded once.
                             
* Now you'll need to create a mole.rb specification file to specify the various aspects you'll want
  to inject. This file is specified in the initialize call via the :mole_config tag.
  
  To trap a feature before or after it occurs you can use the mole_before/mole_after 
  interceptors. The following will mole the "Posts" class after the "show" method is called. 
  The context argument hands you an execution context. In a rails/merb environment
  this will be your controller object. You can handle this interaction any way
  you want. The MOle provides a convenience class to record this interaction via
  the database or the MOle logger in the guise of Mole::Moler. But you can also log it to 
  any media you'll find suitable. In a rails/merb context, you'll be able to extract session/params information
  as in this case.
    
      Posts.mole_after( :feature => :show ) { |context, feature, ret, block, *args|
        # Records the interaction to the database
        Mole::Moler.mole_it( context, feature, 
          context.session[:user_id],                           # Retrieves which user performed this action
          :post_id=> context.params[:post_id],                 # Records request parameter post id
          :url    => context.instance_variable_get( "@url" ) ) # Retrieves controller state 
        end
      }

  To record performance issues, you will need to provide a collection of
  methods that must be watched on a given class. In the case of rails or merb you can easily fetch the list
  of actions from the controller api and pass it to the MOle. The MOle provides convenience
  classes to log the perf issues to your database and send out alerts when a perf condition is met. 
  Upon invocation, you will be handed a calling context, that comprises the feature (method) being
  called, the actual time it took to complete the call and any args/block that was passed into
  the feature that causes the performance threshold to be triggered. Setting the :email option
  to true will also send out an email alert.           
     
      Posts.mole_perf( :features => merb_actions ) do |context, feature, elapsed_time, ret, block, *args|
        user    = context.instance_variable_get( "@user" )
        key     = context.params[:key], "N/A"                                                                     
        request = context.request.nil? ? "N/A" : context.request.remote_ip,
        Mole::Moler.perf_it( context, user.id,
          :controller   => context.class.name,
          :feature      => feature,
          :key          => key,
          :request      => request,
          :user         => user.user_name,
          :elapsed_time => "%3.3f" % elapsed_time,
          :email        => true )
      end

  The unchecked exception trap works very similarly to the mole_perf trap. It will pass in
  the context of the method that triggered the exception.
    
        Posts.mole_unchecked( :features => merb_actions ) do |context, action, boom, block, *args|
          sub     = context.instance_variable_get("@sub")
          user_id = "N/A"  
          user_id = sub.user.id if sub and sub.user    
          Mole::Moler.check_it( context, user_id,
            :controller => context.class.name,
            :action     => action,
            :boom       => boom,
            :email      => true )                               
        end     
          
== Snitch

To view MOle interaction simply, we've created the "Snitch" a rails console application that
allows you to see the results of your MOled application. The Snitch is a Rails 2.0 application.
It is available at http://mole.rubyforge.org/svn/snitch/trunk/. 

In order to start using the Snitch you will have to perform the following steps:

* Download the Snitch
   svn co http://mole.rubyforge.org/svn/snitch/trunk/
   
* The Snitch needs to access your user table to provide user related log information. So 
  you will need to run the following rake task and provide your users table description.
  
  > rake setup
  
* Edit the Snitch database.yml to point to your application database.

* Out of the box the Snitch will monitor and application named "Default". You will want
  to match the application name that you've used in the Mole.initialize call. So you
  should now be able to specify the following commands:
  
   > script/server
   
  Then in your browser
  
  http://localhost:3000?app_name=my_moled_application_name
  
* NOTE: You will keep enhancing the Snitch to provide capistrano deployment scripts,
  auto application name detection and many other enhancements...
                      
== LICENSE:

MIT Copyright (c) 2008

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.