require File.join(File.dirname(__FILE__), "..", "spec_helper" )

describe Mole::Db::Migrate do     
  before( :all ) do        
    ::Mole.reset_configuration!
    ::Mole.initialize( :moleable => true )
    @config = ::File.expand_path( ::File.join(::File.dirname(__FILE__), %w[.. .. config database.yml] ) )
  end
                                 
  it "migrates down correctly" do
    mgt = Mole::Db::Migrate.new( OpenStruct.new( :direction => :down, :configuration => @config, :environment => 'test' ) )
    mgt.apply
  end

  it "migrates up correctly" do
    mgt = Mole::Db::Migrate.new( OpenStruct.new( :direction => :up, :configuration => @config, :environment => 'test' ) )
    mgt.apply
  end  
end