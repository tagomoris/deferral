require "deferral/version"
require "deferral/stack_frame"
require "digest"

module Deferral
  ### Can't add "suppressed" information, because TracePoint doesn't provide
  ### an exception was rescued or not after it was raised.
  # module ErrorExt
  #   def suppressed
  #     @suppressed ||= []
  #   end
  # end

  module Mixin
    def defer(&block)
      raise ArgumentError, "release block is not specified" unless block

      store = (Thread.current[:deferral_store] ||= {})
      if !store.empty? && !store[:stack].empty?
        store[:stack].last.add(block)
        return
      end

      stack = store[:stack] = [StackFrame.new(:root)] # root stack frame as first "caller" position of this method
      first_return = true

      trace = TracePoint.new(:call, :return, :b_call, :b_return) do |tp|
        if tp.event == :return && first_return # return from this method
          first_return = false
          next
        end

        case tp.event
        when :call, :b_call
          if tp.defined_class == Deferral::Mixin && tp.method_id == :defer
            # invocation of "defer" itself - ignore it
            next
          end

          stack << StackFrame.new(tp.event)
        when :return, :b_return
          if tp.defined_class == Deferral::Mixin && tp.method_id == :defer
            # invocation of "defer" itself - ignore it
            next
          end

          frame = stack.pop
          frame.release!
          if frame.root?
            trace.disable
          end
        else
          raise "unexpected TracePoint event:#{tp.event}"
        end
      end
      stack.last.add(block)
      trace.enable
    end
  end

  extend Mixin
end
