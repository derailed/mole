# Feature model - Tracks the various application features in the db.
class MoleFeature < ActiveRecord::Base
  has_many :mole_logs    
        
  class << self     
    # famous constants...  
    def all()         "ALL"        ; end
    def exception()   "Exception"  ; end
    def performance() "Performance"; end  
    
    # find performance feature
    def find_performance_feature( app_name )
      find_or_create_feature( performance, app_name )
    end
                                 
    # find exception feature
    def find_exception_feature( app_name )         
      find_or_create_feature( exception, app_name )
    end
       
    # Find the all feature ( wildcard feature for given app )
    def find_all_feature( app_name )
      find_or_create_feature( all, app_name )
    end
                     
    # Find all the MOled applications                                       
    def find_moled_application_names
      res = find( :all, 
                  :select => "distinct( app_name )", 
                  :order  => "name asc" )            
      res.map(&:app_name)             
    end
          
    # Finds all the features available for a given application
    def find_features( app_name )       
      # Creates the all feature if necessary    
      find_all_feature( app_name )
      find( :all, 
            :conditions => ["app_name = ?", app_name], 
            :select     => "id, name, context", 
            :order      => "name asc" )      
    end
      
    # locates an existing feature or create a new one if it does not exist.
    def find_or_create_feature( name, app_name, ctx_name=nil )
      if name.nil? or name.empty? 
        ::Mole.logger.error( "--- MOLE ERROR - Invalid feature. Empty or nil" ) 
        return nil
      end                          
      if ctx_name      
        res = find_by_name_and_context_and_app_name( name, ctx_name, app_name )
      else
        res = find_by_name_and_app_name( name, app_name )
      end
      res || create(:name => name,:context => ctx_name, :app_name => app_name )
    end   
  end
end               
