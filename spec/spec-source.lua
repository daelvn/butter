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
  end)

  it "places a source #source" (function ()
    butter.cl.i2 = {"filea"}
    assert.are.same (
      { ". filea" },
      butter.parse { "#@source" }
    )
  end)

  it "places multiple sources #source_multiple" (function ()
    butter.cl.i2 = {"filea", "fileb"}
    assert.are.same (
      {
        ". filea",
        ". fileb"
      },
      butter.parse { "#@source" }
    )
  end)
end)
