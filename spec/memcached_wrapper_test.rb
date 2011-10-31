require 'test_helper'
require 'memcache'

class MemcachedWrapperTest < ActiveSupport::TestCase

  context "with single memcached server" do

    setup do
      @wrapper = MemcachedWrapper.new("127.0.0.1:11211", {:namespace => "wrapper", :show_backtraces => true, :support_cas => true})
      @memcache = MemCache.new("127.0.0.1:11211", {:namespace => "memcache"})
      @wrapper.flush_all
      @memcache.flush_all
    end

    teardown do
      @wrapper.close
      @memcache.reset
    end

    should "add" do
      assert_equal(@wrapper.add("blah/toe", "blah"),  @memcache.add("blah/toe", "blah"))
      assert_equal(@wrapper.get("blah/toe"),          @memcache.get("blah/toe"))
      assert_equal(@wrapper.add("blah/toe", "blah2"), @memcache.add("blah/toe", "blah2"))
      assert_equal(@wrapper.get("blah/toe"),          @memcache.get("blah/toe"))
    end

    should "replace" do
      assert_equal(@wrapper.replace("blah/toe", "blah"),  @memcache.replace("blah/toe", "blah"))
      assert_equal(@wrapper.add("blah/toe", "blah"),      @memcache.add("blah/toe", "blah"))
      assert_equal(@wrapper.replace("blah/toe", "blah2"), @memcache.replace("blah/toe", "blah2"))
      assert_equal(@wrapper.get("blah/toe"),              @memcache.get("blah/toe"))
    end

    should "get" do
      assert_equal(@wrapper.add("blah/toe", "blah"), @memcache.add("blah/toe", "blah"))
      assert_equal(@wrapper.get("blah/toe"),         @memcache.get("blah/toe"))
    end

    should "fetch" do
      assert_equal(@wrapper.fetch("blah/toe") { "blah" },  @memcache.fetch("blah/toe") { "blah" })
      assert_equal(@wrapper.fetch("blah/toe") { "blah2" }, @memcache.fetch("blah/toe") { "blah2" })
    end

    should "compare and swap" do
      assert_equal(@wrapper.cas("blah/toe") { "blah" },  @memcache.cas("blah/toe") { "blah" })
      assert_equal(@wrapper.add("blah/toe", "blah"),     @memcache.add("blah/toe", "blah"))
      assert_equal(@wrapper.cas("blah/toe") { "blah2" }, @memcache.cas("blah/toe") { "blah2" })
      assert_equal(@wrapper.get("blah/toe"),             @memcache.get("blah/toe"))
    end

    should "get multiple" do
      assert_equal(@wrapper.add("blah/toe", "blah"),     @memcache.add("blah/toe", "blah"))
      assert_equal(@wrapper.add("blah/finger", "blah2"), @memcache.add("blah/finger", "blah2"))
      assert_equal(@wrapper.get_multi(["blah/toe", "blah/finger"]), @memcache.get_multi(["blah/toe", "blah/finger"]))
    end

    should "set" do
      assert_equal(@wrapper.set("blah/toe", "blah"), @memcache.set("blah/toe", "blah"))
      assert_equal(@wrapper.get("blah/toe"),         @memcache.get("blah/toe"))
    end

    should "append" do
      assert_equal(@wrapper.append("blah/toe", "blah"), @memcache.append("blah/toe", "blah"))
      assert_equal(@wrapper.get("blah/toe"),            @memcache.get("blah/toe"))

      assert_equal(@wrapper.set("blah/toe", "blah", 0, true), @memcache.set("blah/toe", "blah", 0, true))
      assert_equal(@wrapper.get("blah/toe", true),            @memcache.get("blah/toe", true))
      assert_equal(@wrapper.append("blah/toe", "blah2"),      @memcache.append("blah/toe", "blah2"))
      assert_equal(@wrapper.get("blah/toe", true),            @memcache.get("blah/toe", true))
    end

    should "prepend" do
      assert_equal(@wrapper.prepend("blah/toe", "blah"), @memcache.prepend("blah/toe", "blah"))
      assert_equal(@wrapper.get("blah/toe"),             @memcache.get("blah/toe"))

      assert_equal(@wrapper.set("blah/toe", "blah", 0, true), @memcache.set("blah/toe", "blah", 0, true))
      assert_equal(@wrapper.prepend("blah/toe", "blah2"),     @memcache.prepend("blah/toe", "blah2"))
      assert_equal(@wrapper.get("blah/toe", true),            @memcache.get("blah/toe", true))
    end

    should "delete" do
      assert_equal(@wrapper.delete("blah/toe"),      @memcache.delete("blah/toe"))
      assert_equal(@wrapper.set("blah/toe", "blah"), @memcache.set("blah/toe", "blah"))
      assert_equal(@wrapper.delete("blah/toe"),      @memcache.delete("blah/toe"))
    end

    should "increment" do
      assert_equal(@wrapper.incr("blah/count"),            @memcache.incr("blah/count"))
      assert_equal(@wrapper.set("blah/count", 0, 0, true), @memcache.set("blah/count", 0, 0, true))
      assert_equal(@wrapper.incr("blah/count"),            @memcache.incr("blah/count"))
    end

    should "decrement" do
      assert_equal(@wrapper.decr("blah/count"),            @memcache.decr("blah/count"))
      assert_equal(@wrapper.set("blah/count", 2, 0, true), @memcache.set("blah/count", 2, 0, true))
      assert_equal(@wrapper.decr("blah/count"),            @memcache.decr("blah/count"))
    end

    # should "stats" do
    #   assert_equal(@wrapper.stats(), @memcache.stats())
    # end

  end

  # context "with two memcached servers" do
  #
  #   setup do
  #     @wrapper = MemcachedWrapper.new(["127.0.0.1:11211", "127.0.0.1:1111"], {:show_backtraces => true, :support_cas => true})
  #     # @wrapper = MemCache.new(["127.0.0.1:11211", "127.0.0.1:1111"], {:show_backtraces => true, :support_cas => true})
  #     @wrapper.flush_all
  #   end
  #
  #   teardown do
  #     # @wrapper.close
  #   end
  #
  #   should "add value" do
  #     assert_stored(@wrapper.add("blah/toe", "blah"))
  #     assert_equal( "blah", @wrapper.get("blah/toe"))
  #     assert_not_stored(@wrapper.add("blah/toe", "blah2"))
  #     assert_equal( "blah", @wrapper.get("blah/toe"))
  #   end
  #
  #   should "get value" do
  #     assert_stored(@wrapper.add("blah/toe", "blah"))
  #     assert_equal( "blah", @wrapper.get("blah/toe"))
  #   end
  #
  #   should "fetch value" do
  #     assert_equal( "blah", @wrapper.fetch("blah/toe") { "blah" })
  #     assert_equal( "blah", @wrapper.fetch("blah/toe") { "blah2" })
  #   end
  #
  #   should "check and set value" do
  #     assert_nil(   @wrapper.cas("blah/toe") { "blah" })
  #     assert_stored(@wrapper.add("blah/toe", "blah"))
  #     assert_stored(@wrapper.cas("blah/toe") { "blah2" })
  #     assert_equal( "blah2", @wrapper.get("blah/toe"))
  #   end
  #
  #   should "get multiple values" do
  #     assert_stored(@wrapper.add("blah/toe", "blah"))
  #     assert_stored(@wrapper.add("blah/finger", "blah2"))
  #     assert_equal( {'blah/toe'=>'blah','blah/finger'=>'blah2'}, @wrapper.get_multi(["blah/toe", "blah/finger"]))
  #   end
  #
  #   should "set value" do
  #     assert_stored(@wrapper.set("blah/toe", "blah"))
  #     assert_equal( "blah", @wrapper.get("blah/toe"))
  #   end
  #
  #   should "append value" do
  #     assert_not_stored( @wrapper.append("blah/toe", "blah"))
  #     assert_nil( @wrapper.get("blah/toe"))
  #
  #     assert_stored( @wrapper.set("blah/toe", "blah", 0, true))
  #     assert_equal(  "blah", @wrapper.get("blah/toe", true))
  #     assert_stored( @wrapper.append("blah/toe", "blah2"))
  #     assert_equal(  "blahblah2", @wrapper.get("blah/toe", true))
  #   end
  #
  #   should "prepend value" do
  #     assert_not_stored(@wrapper.prepend("blah/toe", "blah"))
  #     assert_nil( @wrapper.get("blah/toe"))
  #
  #     assert_stored( @wrapper.set("blah/toe", "blah", 0, true))
  #     assert_stored( @wrapper.prepend("blah/toe", "blah2"))
  #     assert_equal(  "blah2blah", @wrapper.get("blah/toe", true))
  #   end
  #
  #   should "delete value" do
  #     assert_not_found( @wrapper.delete("blah/toe"))
  #     assert_stored(    @wrapper.set("blah/toe", "blah"))
  #     assert_deleted(   @wrapper.delete("blah/toe"))
  #   end
  #
  #   should "increment value" do
  #     assert_nil(   @wrapper.incr("blah/count"))
  #     assert_stored(@wrapper.set("blah/count", 0, 0, true))
  #     assert_equal( 1, @wrapper.incr("blah/count"))
  #   end
  #
  #   should "decrement value" do
  #     assert_nil(   @wrapper.decr("blah/count"))
  #     assert_stored(@wrapper.set("blah/count", 2, 0, true))
  #     assert_equal( 1, @wrapper.decr("blah/count"))
  #   end
  #
  # end

private

  def assert_stored(val)
    assert_equal("STORED\r\n", val)
  end

  def assert_deleted(val)
    assert_equal("DELETED\r\n", val)
  end

  def assert_not_stored(val)
    assert_equal("NOT_STORED\r\n", val)
  end

  def assert_not_found(val)
    assert_equal("NOT_FOUND\r\n", val)
  end

end
