require 'mole/module'

class Blee  
  def self.blee_static
  end
  
  def crap_out
  end       
    
  def crap_out_too
  end
  
  def blee_no_args                 
    10
  end   
  
  # Try some ßpunctuations...
  def get_out?
    true
  end          
  
  def blee_args( a, b, c, d )
    # puts ">>> Blee Many Args #{[a,b,c,d].join( "--" )}"
    20
  end
  
  def blee_block( a, b, c, d, &block )
    # puts ">>> Blee Many Block #{[a,b,c,d,block].join( "--" )}"
    10
  end
  
  def blee_args_ret( a )
    "Hello #{a}"
  end  
           
  def blee_raise
    raise "Blee exception"
  end

  def blee_raise_too
    raise "Blee exception"
  end
          
  def blee_slow
    sleep( 1 )
  end

  def blee_slow_too
    sleep( 1 )
  end
  
  private
  
  def blee_private( arg )
    arg
  end
    
  protected
  
  def blee_protected( arg )
    arg
  end
    
end       
