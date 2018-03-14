require 'test/unit'
require 'deferral/toplevel'

require_relative 'resource'

using Deferral::TopLevel

class DeferralTopLevelTest < ::Test::Unit::TestCase
  class Consumer
    attr_reader :buf

    def initialize(resource)
      @buf = ""
      @r = resource
    end

    def yay
      @buf << "yay1;"
      defer{ @r.close; @buf << "closed;" }
      @buf << "yay2;"
      defer{ @buf << "deferred2;" }
      @buf << "yay3;"
    end

    def yay!
      defer{ @r.close; @buf << "closed;" }
      raise "boo"
    end
  end

  test 'release a resource in deferred way' do
    r = Resource.new
    c = Consumer.new(r)
    c.yay
    assert r.closed?
    assert_equal "yay1;yay2;yay3;deferred2;closed;", c.buf
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
