# -----------------------------------------------------------------------------
# Convenience for extracting actions out controller classes                    
# Currently supported frameworks : Rails and Merb, more in the future...
# -----------------------------------------------------------------------------
module Mole
   module Utils
     class Frameworks
       class << self
         
         # find moleable features for a given class
         def features_for( controller_class )
           # Try rails first
           return rails_actions( controller_class ) rescue nil
           # Try merb
           return merb_actions( controller_class ) rescue nil
           # Otherwise returns instance methods
           moleable_features( controller_class )
         end
                  
         # Find moleable features on a given class ie non moled instance methods
         def moleable_features( clazz )
           features = clazz.public_instance_methods( false )
           features.select { |f| f unless f.index( /_(with|without)_mole/) }
         end
         
         # retrieves the collection of callable actions from a Merb controller.
         def merb_actions( controller_class )
           begin
             actions = []
             controller_class.send( :callable_actions ).keys.each { |action| actions << action } 
           rescue
             raise "Invalid Merb Controller class `#{controller_class}"
           end
         end               
         
         # retrieves the collection of callable actions from a Rails controller
         def rails_actions( controller_class )    
           begin
             controller_class.send( :action_methods )
           rescue
             raise "Invalid Rails Controller class `#{controller_class}"
           end
         end
       end       
    end
  end
end