class Resource
  attr_reader :state

  def initialize
    @state = :open
  end

  def closed?
    @state == :closed
  end

  def close
    @state = :closed
  end
end
