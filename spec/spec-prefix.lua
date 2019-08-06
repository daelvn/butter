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

  it "keeps track of the prefix #prefix" (function ()
    butter.parse { "[px]" }
    assert.are.equal ("px", butter.curprefix)
    butter.parse { "[pf]" }
    assert.are.equal ("pf", butter.curprefix)
    butter.parse { "[:]" }
    assert.are.equal ("", butter.curprefix)
  end)

  it "generates @noprint #prefix_noprint" (function ()
    assert.are.same (
      {},
      butter.parse { "[px]" }
    )
    assert.are.same (
      {},
      butter.parse { "[:]" }
    )
  end)
end)
