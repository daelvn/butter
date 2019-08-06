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

  it "parses a symbol #symbol" (function ()
    assert.are.same (
      { '"$0"' },
      butter.parse { "@0" }
    )
    assert.are.same (
      { '"$*"' },
      butter.parse { "@*" }
    )
  end)
end)
