require_relative "../deferral"

module Deferral::TopLevel
  refine Kernel do
    include Deferral::Mixin
  end
end
