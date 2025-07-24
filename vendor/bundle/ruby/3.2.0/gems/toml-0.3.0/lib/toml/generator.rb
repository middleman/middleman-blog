
module TOML  
  class Generator
    attr_reader :body, :doc

    def initialize(doc)
      # Ensure all the to_toml methods are injected into the base Ruby classes
      # used by TOML.
      self.class.inject!
      
      @doc = doc
      @body = doc.to_toml
      
      return @body
    end
    
    # Whether or not the injections have already been done.
    @@injected = false
    # Inject to_toml methods into the Ruby classes used by TOML (booleans,
    # String, Numeric, Array). You can add to_toml methods to your own classes
    # to allow them to be easily serialized by the generator (and it will shout
    # if something doesn't have a to_toml method).
    def self.inject!
      return if @@injected
      require 'toml/monkey_patch'
      @@injected = true
    end
  end#Generator
end#TOML
