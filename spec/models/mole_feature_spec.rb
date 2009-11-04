require File.join(File.dirname(__FILE__), "..", "spec_helper" )
                
describe MoleFeature do                         
  before( :each ) do                                                                    
    ::Mole.reset_configuration!
    ::Mole.initialize( :application => "Test", 
                       :mode        => :persistent, 
                       :log_level   => :debug, 
                       :moleable    => true )
  end
          
  it "should find moled application names correctly" do
    MoleFeature.find_moled_application_names.should be_empty
    %w[ all performance exception].each do |f|
      feature = MoleFeature.send( "find_#{f}_feature".to_sym, ::Mole.application )
    end
    MoleFeature.find_moled_application_names.should == ["Test"]
  end
                      
  it "should find or create known features correctly" do
    %w[ all performance exception].each do |f|
      feature = MoleFeature.send( "find_#{f}_feature".to_sym, ::Mole.application )
      feature.should_not           be_nil    
      feature.name.downcase.should == f
    end
  end     
  
  it "should create a new feature" do
    feature = MoleFeature.find_or_create_feature( "Fred", ::Mole.application, self.class.name )
    feature.should_not     be_nil
    feature.name.should    == "Fred"
    feature.context.should == self.class.name
  end  
  
  it "should not create a feature with no name" do
    feature = MoleFeature.find_or_create_feature( "", ::Mole.application, self.class.name )
    feature.should be_nil
  end    
  
  it "should find all features for a given application correctly" do
    %w[ all performance exception].each do |f|
      MoleFeature.send( "find_#{f}_feature".to_sym, ::Mole.application )
    end                                                                              
    MoleFeature.find_or_create_feature( "Fred", ::Mole.application, self.class.name )
    features = MoleFeature.find_features( ::Mole.application )
    features.should have(4).mole_features
  end       
end
