-- butter | 07.06.2018
-- By daelvn
-- spec-local
-- luacheck: ignore

describe "" (function ()
  local butter

  setup (function ()
    butter    = require "butter"
    butter.cl = { v = os.getenv "BUTTER_V" or false }
  end)

  teardown (function ()
    butter = nil
  end)

  before_each (function ()
    butter.parse { "[:]" }
    butter.cl.I     = {}
    butter.cl.no_bl = false
    butter.cl.vbl   = false
  end)

  it "prints nothing for !-I #logv_no_i" (function ()
    assert.are.same (
      {},
      butter.parse { "#@vi: logvi" }
    )
  end)

  it "prints nothing for --silent #logv_silent" (function ()
    butter.cl.incl  = {"log"}
    butter.cl.no_bl = true
    assert.are.same (
      {". butter.lib/log.butter"},
      butter.parse { "#@vi: logvi" }
    )
  end)

  it "prints nothing normally #logv_normal" (function ()
    butter.cl.I = {"log"}
    assert.are.same (
      {". butter.lib/log.butter"},
      butter.parse { "#@vi: logvi" }
    )
  end)

  it "prints for --verbose-print #logv" (function ()
    butter.cl.incl = {"log"}
    butter.cl.vbl  = true
    assert.are.same (
      {
        ". butter.lib/log.butter",
        'libbutter_log_i "#" "logvi"'
      },
      butter.parse { "#@vi: logvi" }
    )
  end)
end)
