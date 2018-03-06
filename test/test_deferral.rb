require 'test/unit'
require 'deferral'

require_relative 'resource'

class DeferralTest < ::Test::Unit::TestCase
  class Consumer
    def initialize(resource)
      @r = resource
    end

    def yay
      Deferral.defer{ @r.close }
      "do domething"
    end

    def yay!
      Deferral.defer{ @r.close }
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

  class Consumer2
    attr_reader :released

    def initialize(r1, r2)
      @released = []
      @r1 = r1
      @r2 = r2
    end

    def yay
      Deferral.defer{ @r1.close; @released << :r1 }
      Deferral.defer{ @r2.close; @released << :r2 }
      "do something"
    end
  end

  test 'multiple resources should be released in reverse order' do
    r1 = Resource.new
    r2 = Resource.new
    c = Consumer2.new(r1, r2)
    c.yay
    assert r1.closed?
    assert r2.closed?
    assert_equal([:r2, :r1], c.released)
  end

  $DEFERRAL_LABEL = ""
  class TrueResource
    def initialize(name)
      @name = name
    end
    def close
      $DEFERRAL_LABEL << @name
    end
  end

  def test_method_to_use_counter
    r1 = TrueResource.new("r1")
    Deferral.defer{ r1.close }
    r2 = TrueResource.new("r2")
    Deferral.defer{ r2.close }
    "yaaaaaaaaaaay"
  end

  test 'confirm instant resources are successfully released' do
    assert_equal "", $DEFERRAL_LABEL
    test_method_to_use_counter
    assert_equal "r2r1", $DEFERRAL_LABEL
  end
end
