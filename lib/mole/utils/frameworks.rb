# -----------------------------------------------------------------------------
# Convenience for extracting actions out controller classes                    
# Currently supported frameworks : Rails and Merb, more in the future...
# -----------------------------------------------------------------------------
module Mole
   module Utils
     class Frameworks       
       class << self                                                    
         # Retrieves the collection of callable actions from a Merb controller.
         def merb_actions( controller_class )
           actions = []
           controller_class.send( :callable_actions ).keys.each { |action| actions << action } 
         end               
         
         # Retrieves the collection of callable actions from a Rails controller
         def rails_actions( controller_class )    
           controller_class.send( :action_methods )
         end
       end       
    end
  end
end