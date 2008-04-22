module Mole
  module Version
    MAJOR = 1
    MINOR = 0
    TINY  = 6
    
    # Returns the version string for the library.
    #
    def self.version
      [ MAJOR, MINOR, TINY].join( "." )
    end
  end
end


