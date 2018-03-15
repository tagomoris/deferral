require_relative "./deferred"

module Deferral
  class StackFrame
    attr_reader :type, :id

    def initialize(type)
      @type = type
      @releases = []
    end

    def root?
      @type == :root
    end

    def add(*args, **kwds, &release)
      @releases << Deferred.new(*args, **kwds, &release)
    end

    def release!
      return if @releases.empty?
      @releases.reverse.each do |d|
        d.call
      end
      nil
    end
  end
end
