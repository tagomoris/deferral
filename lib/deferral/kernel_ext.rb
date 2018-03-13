require_relative "../deferral"

module Kernel
  def defer(&block)
    Deferral.defer(&block)
  end
end
