# -----------------------------------------------------------------------------
# MOLE Related rake tasks
# Mole db setup upon installation
# -----------------------------------------------------------------------------
require 'ftools'

namespace :mole do        
  namespace :db do      
    task :environment do     
      require 'rubygems'

      gem "activerecord", "=2.0.2"
      require 'active_record'  

      environment = ENV['MOLE_ENV'] || "test"
      db_config = YAML.load_file( File.join( File.dirname(__FILE__), "..", "config", "test_database.yml") )[environment]
      ::ActiveRecord::Base.establish_connection(db_config)
    end                                                   
                                                     
    # ---------------------------------------------------------------------
    # Create mole persistence tables and pre-populate
    desc 'Create the database tables needed for the mole plugin.'
    task :migrate_up => :environment do
      # Create the mole_features table if it doesn't exist
      unless ActiveRecord::Schema.tables.include?('mole_features')
        ActiveRecord::Schema.create_table('mole_features') do |t|
          t.column :name,             :string     
          t.column :context,          :string
          t.column :app_name,         :string
          t.column :created_at,       :datetime
          t.column :updated_at,       :datetime
        end
        ActiveRecord::Schema.add_index( 'mole_features', 'name' )
        
        # Create some default features
        # MoleFeature.create :id => 0, :name => MoleFeature::ALL
        # MoleFeature.create :id => 1, :name => MoleFeature::EXCEPTION
        # MoleFeature.create :id => 2, :name => MoleFeature::PERFORMANCE
      end

      # Create the mole_logs table if it doesn't exist
      unless ActiveRecord::Schema.tables.include?('mole_logs')
        ActiveRecord::Schema.create_table('mole_logs') do |t|
          t.column :mole_feature_id,  :integer
          t.column :user_id,          :integer
          t.column :params,           :string     
          t.column :ip_address,       :string
          t.column :browser_type,     :string  
          t.column :host_name,        :string
          t.column :created_at,       :datetime
          t.column :updated_at,       :datetime
        end     
        ActiveRecord::Schema.add_index( 'mole_logs', ['mole_feature_id','user_id'] )
        ActiveRecord::Schema.add_index( 'mole_logs', ['mole_feature_id','created_at'] )
      end
    end
                                                     
    # -------------------------------------------------------------------------
    # Destroys mole persistence tables
    desc 'Drop the database tables needed for the mole plugin.'
    task :migrate_down => :environment do
      # Delete the mole_feature table
      if ActiveRecord::Schema.tables.include?('mole_features')
        ActiveRecord::Schema.drop_table('mole_features')
      end
      
      # Delete the mole_logs table
      if ActiveRecord::Schema.tables.include?('mole_logs')
        ActiveRecord::Schema.remove_index('mole_logs', ['mole_feature_id','user_id'] )        
        ActiveRecord::Schema.drop_table('mole_logs')
      end
    end
  end
                                      
  # ---------------------------------------------------------------------------
  # Installs the mole plugin
  desc 'The task that is run when you first install the plugin.'
  task :install => :setup do
    # Copy over the sample mole.conf file to the default location
    destination = @plugin_base + '/../../../config'
    File.makedirs(destination) unless File.exists?(destination)                   
    unless File.exists?(destination + '/mole.conf')
     File.copy(@plugin_base + '/lib/mole.conf.sample', destination + '/mole.conf') 
    end

    # Migrate the database
    Rake::Task["mole:migrate:up"].invoke
  end
                           
  # ---------------------------------------------------------------------------
  # Removes the mole plugin and cleanup artifacts
  desc 'The task that is run when you want to remove the plugin.'
  task :remove => :setup do
    # Remove the database tables
    Rake::Task["mole:migrate:down"].invoke

    # Delete the default mole.conf file
    File.delete( "#{RAILS_ROOT}/config/mole.conf" )
  end
       
  # ---------------------------------------------------------------------------  
  desc 'Setup plugin base dir'     
  task :setup do
    @plugin_base = File.dirname(__FILE__) + '/..'
  end                               
                                                                               
  # ---------------------------------------------------------------------------
  # Upgrade task from MOLE version 0.002
  # This task will setup the extra mole features columns and reset the indexes
  # on the mole_features table. 
  desc 'Ugrade the mole schema from version 0.002'
  task :upgrade do
    Rake::Task["mole:migrate:upgrade"].invoke
  end  
end