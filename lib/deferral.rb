require "deferral/version"
require "securerandom"

module Deferral
  module ErrorExt
    def suppressed
      @suppressed ||= []
    end
  end

  def self.defer(&block)
    first_return = true
    stack_machine = []

    trace = TracePoint.new(:call, :return, :b_call, :b_return) do |tp|
      if tp.event == :return && first_return
        first_return = false
      elsif tp.event == :return && stack_machine.empty?
        trace.disable
        begin
          block.call
        rescue Exception
          # ignore all
        end
      elsif tp.event == :call || tp.event == :b_call
        stack_machine.push(tp.event)
      else
        stack_machine.pop
      end
    end
    trace.enable
  end
end
