# Add your own ruby code here for app specific stuff. This file gets loaded
# after the framework is loaded.
puts "Started merb_init.rb ..."

# Your app's dependencies, including your database layer (if any) are defined
# in config/dependencies.rb
require File.join(Merb.root, 'config', 'dependencies')

# Here's where your controllers, helpers, and models, etc. get loaded.  If you
# need to change the order of things, just move the call to 'load_application'
# around this file.
puts "Loading Application..."
Merb::BootLoader.load_application

# Load environment-specific configuration
environment_config = File.join(Merb.root, 'config', 'environments', Merb.environment + '.rb')
require environment_config if File.exist?(environment_config)

# Initialize the MOle and load the mole configuration file from config/mole_config.rb
require 'mole'
::Mole.initialize( :moleable       => true, 
                   :application    => "MerbApp",
                   :perf_threshold => 2,
                   :mole_config    => File.join( Merb.root, %w[config mole_config.rb]) )
::Mole.dump
::Mole.load_mole_configuration