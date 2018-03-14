module Deferral
  class Deferred
    def self.get_local_variables(block)
      vars = {}
      block.binding.local_variables.each do |name|
        vars[name] = block.binding.local_variable_get(name)
      end
      vars
    end

    def self.set_local_variables(block, vars)
      vars.each_pair do |name, val|
        block.binding.local_variable_set(name, val)
      end
      nil
    end

    def initialize(block)
      @block = block
      @local_variables = Deferred.get_local_variables(block)
    end

    def call
      current_vars = Deferred.get_local_variables(@block)
      begin
        Deferred.set_local_variables(@block, @local_variables)
        @block.call
      rescue Exception
        # ignore all exceptions ...
        # no way to add "suppressed" exceptions to the exception already thrown
      ensure
        Deferred.set_local_variables(@block, current_vars)
      end
    end
  end
end

