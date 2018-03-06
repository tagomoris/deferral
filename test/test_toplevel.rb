require 'test/unit'
require 'deferral/toplevel'

require_relative 'resource'

using Deferral::TopLevel

class DeferralTopLevelTest < ::Test::Unit::TestCase
  class Consumer
    def initialize(resource)
      @r = resource
    end

    def yay
      defer{ @r.close }
      "do something"
    end

    def yay!
      defer{ @r.close }
      raise "boo"
    end
  end

  test 'release a resource in deferred way' do
    r = Resource.new
    c = Consumer.new(r)
    c.yay
    assert r.closed?
  end

  test 'release a resource in deferred way even for error situation' do
    r = Resource.new
    c = Consumer.new(r)
    err = nil
    begin
      c.yay!
    rescue => e
      err = e
    end
    assert err
    assert_equal "boo", err.message
    assert r.closed?
  end
end
