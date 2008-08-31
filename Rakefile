# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'mole'      
require 'mole/version'
                   
task :default => 'spec:run'

PROJ.name           = 'mole'
PROJ.authors        = 'Fernand Galiana'
PROJ.email          = 'fernand@liquidrail.com'
PROJ.url            = 'http://mole.rubyforge.org'
PROJ.rubyforge_name = 'mole'            
PROJ.description    = "A flexible way to track user's interactions within your ruby web applications"
PROJ.spec_opts      << '--color'
PROJ.rcov_dir       = ENV['CC_BUILD_ARTIFACTS']  ? "#{ENV['CC_BUILD_ARTIFACTS']}/test_coverage" : 'coverage'  
PROJ.rdoc_dir       = ENV['CC_BUILD_ARTIFACTS']  ? "#{ENV['CC_BUILD_ARTIFACTS']}/api_docs" : 'docs'  
PROJ.ruby_opts      = %w[-W0]
PROJ.version        = ::Mole::Version.version
PROJ.svn            = 'mole'
PROJ.rcov_threshold = 90.0
PROJ.executables    = ['molify']

PROJ.exclude        << %w[.DS_Store$ .swo$ .swp$]
PROJ.tests          = FileList['test/**/test_*.rb']   
PROJ.annotation_tags << 'BOZO'

desc "Clean up artifact directories"
task :clean do    
  rcov_artifacts = File.join( File.dirname( __FILE__ ), "coverage" )
  FileUtils.rm_rf rcov_artifacts if File.exists? rcov_artifacts
  rdoc_artifacts = File.join( File.dirname( __FILE__ ), "docs" )
  FileUtils.rm_rf rdoc_artifacts if File.exists? rdoc_artifacts  
  gem_artifacts = File.join( File.dirname( __FILE__ ), "pkg" )
  FileUtils.rm_rf gem_artifacts if File.exists? gem_artifacts    
end  

task 'gem:package' => 'manifest:assert'

                
depend_on "logging"     , "= 0.9.0"       
depend_on "activerecord", "= 2.0.2"
