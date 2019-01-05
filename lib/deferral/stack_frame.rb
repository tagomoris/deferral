require_relative "./deferred"

module Deferral
  class StackFrame
    attr_reader :type

    def initialize(type)
      @type = type
      @releases = []
    end

    def root?
      @type == :root
    end

    def add(*args, **kwargs, &release)
      @releases << Deferred.new(*args, **kwargs, &release)
    end

    def release!
      @releases.reverse_each do |d|
        d.call
      end
      nil
    end
  end
end
