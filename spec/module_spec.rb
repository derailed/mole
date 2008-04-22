require File.join(File.dirname(__FILE__), "spec_helper" )


describe Module do     
  before( :all ) do
    ::Mole.initialize( :perf_threshold => 1, :log_level => :info )
    require File.join( File.dirname(__FILE__),  %w[data blee] )                          
  end
                    
  before( :each ) do
    @blee = Blee.new    
    CallStackChecker.reset!                                                                 
  end                    

  it "should trap mole before handler exceptions" do
    Blee.mole_before( :feature => :crap_out ) { |context, feature, *args| 
      raise "LEGIT !! - Before - Something did crap out"
      CallStackChecker.called
    }              
    @blee.crap_out                      
    CallStackChecker.should_not be_called
  end

  it "should trap mole after handler exceptions" do
    Blee.mole_after( :feature => :crap_out ) { |context, feature, *args| 
      raise "LEGIT !! - After - Something did crap out"
      CallStackChecker.called
    }              
    @blee.crap_out                      
    CallStackChecker.should_not be_called
  end

  it "should trap mole handler exceptions" do
    Blee.mole_unchecked( :features => [:blee_raise_too] ) { |context, feature, *args| 
      raise "-- LEGIT !! - Unchecked - Something did crap out"
      CallStackChecker.called
    }                           
    @blee.blee_raise_too rescue nil                    
    CallStackChecker.should_not be_called
  end

  it "should trap a perf handler exception" do
    Blee.mole_perf( :features => [:blee_slow_too] ) do |context, feature, elapsed_time, args, block|
      raise "---LEGIT !! - Perf - Something did crap out"      
      CallStackChecker.called
    end         
    @blee.blee_slow_too
    CallStackChecker.should_not be_called    
  end 
  
  # it "should trap mole handler exceptions" do
  #   Blee.mole_before( :feature => :crap_out ) { |context, feature, *args| 
  #     raise "Something did crap out"
  #     CallStackChecker.called
  #   }              
  #   @blee.crap_out                      
  #   CallStackChecker.should_not be_called
  # end
  
  it "should correctly setup a before call" do
    Blee.mole_before( :feature => :blee_no_args ) { |context, feature, block, *args| 
      context.class.should == Blee
      feature.should       == "blee_no_args"
      block.should         be_nil
      args.should          have(0).items
      CallStackChecker.called
    }              
    @blee.blee_no_args                         
    CallStackChecker.should be_called
  end
  
  it "should correctly setup an after call" do
    Blee.mole_after( :feature => :blee_no_args ) { |context, feature, ret_val, block, *args| 
      context.class.should == Blee
      feature.should       == "blee_no_args"
      args.should          have(0).items      
      CallStackChecker.called
    }              
    @blee.blee_no_args                         
    CallStackChecker.should be_called
  end
  
  it "should correctly trap an exception" do
    Blee.mole_unchecked( :features => [:blee_raise] ) do |context, feature, boom, args, block|  
      context.class.should == Blee
      feature.should       == "blee_raise"
      boom.to_s.should     == "Blee exception"
      CallStackChecker.called
    end         
    @blee.blee_raise rescue nil                          
    CallStackChecker.should be_called    
  end     
  
  it "should not trap a before call" do     
    @blee.blee_args( "Hello", "World", "Good", "Day" )
    CallStackChecker.should_not be_called
  end  
  
  it "should correctly trap the before call arguments" do
    Blee.mole_before( :feature => :blee_args ) { |context, feature, block, *args| 
      context.class.should == Blee
      feature.should       == "blee_args"      
      args.should          have(4).items
      args[0].should       == "Hello"
      args[1].should       == "World"
      args[2].should       == "Good"
      args[3].should       == "Day"                  
      CallStackChecker.called
    }              
    @blee.blee_args( "Hello", "World", "Good", "Day" )                         
    CallStackChecker.should be_called    
  end    

  it "should correctly trap a before call with a block" do
    Blee.mole_before( :feature => :blee_block ) do |context, feature, block, *args|
      context.class.should == Blee
      feature.should       == "blee_block"      
      block.should_not     be_nil
      block.call.should    == "Do it already!!"
      args.size.should     == 4
      args[0].should       == "Hello"
      args[1].should       == "World"
      args[2].should       == "Good"
      args[3].should       == "Day"            
      CallStackChecker.called
    end         
    @blee.blee_block( "Hello", "World", "Good", "Day" ) { "Do it already!!" }
    CallStackChecker.should be_called    
  end 
  
  it "should correctly trap the after call with many arguments" do
    Blee.mole_after( :feature => :blee_args ) { |context, feature, ret_val, block, *args| 
      context.class.should == Blee
      feature.should       == "blee_args"            
      ret_val.should       == 20
      args.size.should     == 4
      args[0].should       == "Hello"
      args[1].should       == "World"
      args[2].should       == "Good"
      args[3].should       == "Day"      
      CallStackChecker.called
    }              
    @blee.blee_args( "Hello", "World", "Good", "Day" )                         
    CallStackChecker.should be_called    
  end    

  it "should correctly trap the after call with a block" do
    Blee.mole_after( :feature => :blee_block ) do |context, feature, ret_val, block, *args|
      context.class.should == Blee
      feature.should       == "blee_block"      
      block.should_not     be_nil
      block.call.should    == "Do it already!!"
      ret_val.should       == 10
      args.size.should     == 4
      args[0].should       == "Hello"
      args[1].should       == "World"
      args[2].should       == "Good"
      args[3].should       == "Day"            
      CallStackChecker.called
    end         
    @blee.blee_block( "Hello", "World", "Good", "Day" ) { "Do it already!!" }
    CallStackChecker.should be_called    
  end 
  
  it "should correctly trap a slow call" do
    Blee.mole_perf( :features => [:blee_slow] ) do |context, feature, elapsed_time, ret_val, block, *args|
      context.class.should == Blee
      feature.should       == "blee_slow"      
      ret_val.should       == 1
      block.should         be_nil      
      args.size.should     == 0      
      elapsed_time.should  > 1      
      CallStackChecker.called
    end         
    @blee.blee_slow
    CallStackChecker.should be_called    
  end 
  
  it "should trap a private method correctly" do  
    Blee.mole_after( :feature => :blee_private ) { |context, feature, ret_val, block, *args| 
      context.class.should == Blee
      feature.should       == "blee_private"            
      ret_val.should       == "Hello"
      block.should         be_nil      
      args.size.should     == 1
      args[0].should       == "Hello"
      CallStackChecker.called
    }              
    @blee.send( :blee_private, "Hello" )
    CallStackChecker.should be_called        
  end
  
  it "should trap a protected method correctly" do
    Blee.mole_after( :feature => :blee_protected ) { |context, feature, ret_val, block, *args| 
      context.class.should == Blee
      feature.should       == "blee_protected"            
      ret_val.should       == "Hello"
      block.should         be_nil
      args.size.should     == 1
      args[0].should       == "Hello"
      CallStackChecker.called
    }              
    @blee.send( :blee_protected, "Hello" )
    CallStackChecker.should be_called        
  end      
                 
  it "should mole a static method correctly" do
    pending do
      Blee.mole_after( :feature => :blee_static ) { |context, feature, ret_val, block, *args| 
        context.class.should == Blee
        feature.should       == "blee_static"            
        ret_val.should       be_nil
        block.should         be_nil
        args.size.should     == 0
        CallStackChecker.called
      }              
      Blee.blee_static
      CallStackChecker.should be_called            
    end
  end
end