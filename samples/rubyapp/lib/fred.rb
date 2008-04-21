# Sample ruby class that is used in our ruby applications
# We will MOle this class and capture the essence of the interactions
module RubyApp
  class Fred
    
    # Pure feature
    def my_feature( arg1, arg2, arg3, &block )
      "#{arg1}--#{arg2}--#{arg3}"
    end
    
    # Slow feature
    def my_slow_feature( arg1 )
      sleep( 2 )
      "slow returned #{arg1}"
    end
    
    # Hose feature
    def my_hosed_feature( arg1 )
      raise "This will hose your app"
    end
  end
end