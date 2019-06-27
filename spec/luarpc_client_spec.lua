require("rpc")

function error_handler (message)
  io.write ("Err: " .. message .. "\n");
end

--
-- BEGIN TESTS
--

describe("Tests the client side of LuaRPC module", function()
  setup(function()
    if rpc.mode == "tcpip" then
      slave, err = rpc.connect ("localhost",12346);
    elseif rpc.mode == "serial" then
      slave, err = rpc.connect ("/dev/ttys0");
    end

    -- Local Dataset

    tab = {a=1, b=2};

    test_local = {1, 2, 3, 4, "234"}
    test_local.sval = 23

    function squareval(x) return x*x end
  end)

  it("should have connection exising", function()
    assert( slave, "connection failed" )
  end)
  
  it("reflects parameters off mirror", function()
    -- Sending 42
    assert.is_equal(42, slave.mirror(42), "integer return failed")
    -- Done 42
    --    print(slave.mirror("012345673901234")) -- why the heck does this fail for things of length 15 (16 w/ null)?
    --    slave.mirror("01234567890123456789012")
    assert.is_equal("The quick brown fox jumps over the lazy dog", slave.mirror("The quick brown fox jumps over the lazy dog"), "string return failed")
    --    print(slave.mirror(squareval))
    assert.is_true(slave.mirror(true), "function return failed")
  end)

  it("does basic remote call with returned data", function()
    assert.is_equal(456, slave.foo1 (123,56,"hello"), "basic call and return failed" )
  end)

  it("executes function remotely", function()
    assert.is_equal(64, slave.execfunc( string.dump(squareval), 8 ), "couldn't serialize and execute dumped function")
  end)

  it("gets remote table", function()
    assert.is.truthy(slave.test:get(), "couldn't get remote table")
  end)

  it("can get and set entry on remote table", function()
    assert.is_equal(test_local.sval, slave.test:get().sval, "table field not equivalent")

    slave.yarg.blurg = 23
    assert.is_equal(23, slave.yarg.blurg:get())
  end)

  it("can send function", function()
    slave.squareval = squareval
    assert.is_equal("userdata", type(slave.squareval), "function assigment failed")
  end)

  it("can execute of assigned (remote) function", function()
    assert.is_equal(slave.squareval(99), squareval(99), "remote setting and evaluation of function failed")
  end)
end)
