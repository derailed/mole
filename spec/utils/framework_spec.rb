require File.join(File.dirname(__FILE__), %w[.. spec_helper] )

describe Mole::Utils::Frameworks do     
  before( :all ) do        
    ::Mole.reset_configuration!
    ::Mole.initialize( :moleable => true )
  end
         
  describe ".features_for" do
    it "should find the correct features for a merb controller" do
      features = Mole::Utils::Frameworks.features_for( MerbController )
      features.sort.should == %w[blee fred]      
    end
    it "should find the correct features for a rails controller" do
      features = Mole::Utils::Frameworks.features_for( RailsController )
      features.sort.should == %w[blee fred]      
    end
    it "should find the correct features for a plain old ruby object" do
      features = Mole::Utils::Frameworks.features_for( Poro )
      features.sort.should == %w[blee duh]      
    end    
  end
           
  describe ".merb_actions" do                                 
    it "should retrieve Merb controller actions correctly" do
      actions = Mole::Utils::Frameworks.merb_actions( MerbController )
      actions.sort.should == %w[blee fred]
    end
    it "should raise an exception if it is not a merb controller" do
      lambda { Mole::Utils::Frameworks.merb_actions( String ) }.should raise_error( "Invalid Merb Controller class `String" )
    end    
  end
  
  describe ".rails_actions" do
    it "should retrieve Rails controller actions correctly" do
      actions = Mole::Utils::Frameworks.rails_actions( RailsController )
      actions.sort.should == %w[blee fred]
    end
    
    it "should raise an exception if it is not a rails controller" do
      lambda { Mole::Utils::Frameworks.rails_actions( String ) }.should raise_error( "Invalid Rails Controller class `String" )
    end
  end
  
  class Poro
    def blee
    end
    
    def duh
    end
  end
  
  class MerbController
    def self.callable_actions
      { 'fred' => nil, 'blee' => nil }
    end
    
    def fred
    end
    
    def blee
    end
    
    private
    
    def duh
    end
  end      
  
  class RailsController 
    def self.action_methods
      %w[fred blee]
    end
    
    def fred
    end
    
    def blee
    end
    
    private
    
    def duh
    end
  end
end
