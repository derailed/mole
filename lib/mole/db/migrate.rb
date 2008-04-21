#!/usr/bin/env ruby

# -----------------------------------------------------------------------------
# Sets up the MOle persistent layer
# Two tables are involved: mole_features and mole_logs 
# -----------------------------------------------------------------------------
require 'rake'
require 'rake/tasklib'

module Mole
  module Db           
    class Migrate                     
      def initialize( opts )
        @direction = opts.direction
        @config    = opts.configuration
        @env       = opts.environment
      end
                                                      
      # Creates a MOle migration by creating or dropping the MOle related tables    
      def apply #:nodoc:
        setup
        @direction == :up ? migrate_up : migrate_down
      end
                                              
      # Setup database connection prior to applying migrations
      def setup #:nodoc:
        require 'rubygems'
        gem "activerecord"
        require 'active_record'  
        db_config = YAML.load_file( File.expand_path( @config ) )[@env]
        ::ActiveRecord::Base.establish_connection(db_config)
      end                                                   
                        
      # ---------------------------------------------------------------------
      # Create mole persistence tables ( 2 tables mole_features/mole_logs )
      def migrate_up
        # Create the mole_features table if it doesn't exist
        unless ActiveRecord::Schema.tables.include?('mole_features')
          ActiveRecord::Schema.create_table('mole_features') do |t|
            t.column :name,             :string     
            t.column :context,          :string
            t.column :app_name,         :string
            t.column :created_at,       :datetime
            t.column :updated_at,       :datetime
          end
          ActiveRecord::Schema.add_index( 'mole_features', 
                                          ['name', 'context', 'app_name'], 
                                          :name   => 'feature_idx')
        end
        # Create the mole_logs table if it doesn't exist
        unless ActiveRecord::Schema.tables.include?('mole_logs')
          ActiveRecord::Schema.create_table('mole_logs') do |t|
            t.column :mole_feature_id,  :integer
            t.column :user_id,          :integer
            t.column :params,           :string, :limit => 1024    
            t.column :ip_address,       :string
            t.column :browser_type,     :string  
            t.column :host_name,        :string
            t.column :created_at,       :datetime
            t.column :updated_at,       :datetime
          end     
          ActiveRecord::Schema.add_index( 'mole_logs', 
                                          ['mole_feature_id','user_id'], 
                                          :name   => "log_feature_idx" )
          ActiveRecord::Schema.add_index( 'mole_logs', 
                                          ['mole_feature_id','created_at'], 
                                          :name   => "log_date_idx",
                                          :unique => true )
        end
      end
                                                     
      # -------------------------------------------------------------------------
      # Destroys mole persistence tables
      def migrate_down
        # Delete the mole_feature table
        if ActiveRecord::Schema.tables.include?( 'mole_features' )                                                             
          ActiveRecord::Schema.remove_index( 'mole_features', :name => 'feature_idx' )              
          ActiveRecord::Schema.drop_table( 'mole_features' )
        end
    
        # Delete the mole_logs table
        if ActiveRecord::Schema.tables.include?( 'mole_logs' )
          ActiveRecord::Schema.remove_index( 'mole_logs', :name => 'log_feature_idx' )        
          ActiveRecord::Schema.remove_index( 'mole_logs', :name =>'log_date_idx' )              
          ActiveRecord::Schema.drop_table( 'mole_logs' )
        end
      end                                      
    end
  end
end