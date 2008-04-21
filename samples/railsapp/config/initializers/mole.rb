# Initialize the MOle gem. Although we recommend you initialize the
# MOle here. You can also just init the MOle for a given environment only, in
# which case put this code in environments/xxx_env.rb to only load the MOle
# in environment xxx.
require 'mole'
::Mole.initialize( :moleable       => true, 
                   :application    => "RailsApp",
                   :perf_threshold => 2,
                   :mole_config    => File.join( RAILS_ROOT, %w[config moles]) )
::Mole.dump