class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '59d52cb64b5c2ba2a4810a865fecf933'
  
  # Load the MOle configuration. Don't crap out if the MOle has not
  # been initialized for the given environment. In dev env this
  # file will be reloaded, allowing you to tweak the MOle configuration
  # to your liking.
  Mole.load_mole_configuration
end
