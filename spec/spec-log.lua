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
    butter.cl.incl  = {} 
    butter.cl.no_bl = false
  end)

  it "prints nothing for !-I #log_no_i" (function ()
    assert.are.same (
      {},
      butter.parse { "#@i: logi" }
    )
  end)

  it "prints nothing for --silent #log_silent" (function ()
    butter.cl.incl  = {"log"}
    butter.cl.no_bl = true
    assert.are.same (
      {". butter.lib/log.butter"},
      butter.parse { "#@i: logi" }
    )
  end)

  it "prints normally #log_normal" (function ()
    butter.cl.incl  = {"log"}
    assert.are.same (
      {
        ". butter.lib/log.butter",
        'libbutter_log_i "#" "logi"'
      },
      butter.parse { "#@i: logi" }
    )
  end)
end)
