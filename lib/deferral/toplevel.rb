require_relative "../deferral"

module Deferral::TopLevel
  refine Kernel do
    def defer(&block)
      Deferral.defer(&block)
    end
  end
end
