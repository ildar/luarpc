require("rpc")

function error_handler (message)
  io.write ("Err: " .. message .. "\n");
end

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

--
-- BEGIN TESTS
--

describe("Tests the client side of LuaRPC module", function()
  it("should have connection exising", function()
    assert( slave, "connection failed" )
  end)
  
  it("reflects parameters off mirror", function()
    -- Sending 42
    assert(slave.mirror(42) == 42, "integer return failed")
    -- Done 42
    --    print(slave.mirror("012345673901234")) -- why the heck does this fail for things of length 15 (16 w/ null)?
    --    slave.mirror("01234567890123456789012")
    assert(slave.mirror("The quick brown fox jumps over the lazy dog") == "The quick brown fox jumps over the lazy dog", "string return failed")
    --    print(slave.mirror(squareval))
    assert(slave.mirror(true) == true, "function return failed")
  end)

  it("does basic remote call with returned data", function()
    assert( slave.foo1 (123,56,"hello") == 456, "basic call and return failed" )
  end)

  it("executes function remotely", function()
    assert(slave.execfunc( string.dump(squareval), 8 ) == 64, "couldn't serialize and execute dumped function")
  end)

  it("gets remote table", function()
    assert(slave.test:get(), "couldn't get remote table")
  end)

  it("can get and set entry on remote table", function()
    assert(test_local.sval == slave.test:get().sval, "table field not equivalent")

    slave.yarg.blurg = 23
    assert(slave.yarg.blurg:get() == 23, "not equal")
  end)

  it("can send function", function()
    slave.squareval = squareval
    assert(type(slave.squareval) == "userdata", "function assigment failed")
  end)

  it("can execute of assigned (remote) function", function()
    assert(slave.squareval(99) == squareval(99), "remote setting and evaluation of function failed")
  end)
end)
