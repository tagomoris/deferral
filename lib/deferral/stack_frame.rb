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

    def add(release)
      @releases << release
    end

    def release!
      return if @releases.empty?
      @releases.reverse.each do |r|
        begin
          r.call
        rescue Exception => e
          # ignore all exceptions ...
          # no way to add "suppressed" exceptions to the exception already thrown
        end
      end
      nil
    end
  end
end
