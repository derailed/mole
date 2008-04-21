require File.join(File.dirname(__FILE__), %w[.. spec_helper] )
require 'merb'
require 'action_controller'

describe Mole::Utils::Frameworks do     
  before( :all ) do        
    ::Mole.reset_configuration!
    ::Mole.initialize( :moleable => true )
  end
                                 
  it "should retrieve Merb controller actions correctly" do
    actions = Mole::Utils::Frameworks.merb_actions( MerbController )
    actions.sort.should == %w[blee fred]
  end

  it "should retrieve Rails controller actions correctly" do
    actions = Mole::Utils::Frameworks.rails_actions( RailsController )
    actions.sort.should == %w[blee fred]
  end
  
  class MerbController < Merb::Controller  
    def fred
    end
    
    def blee
    end
    
    private
    
    def duh
    end
  end      
  
  class RailsController < ActionController::Base
    def fred
    end
    
    def blee
    end
    
    private
    
    def duh
    end
  end
end
