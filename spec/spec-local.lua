-- butter | 07.06.2018
-- By daelvn
-- spec-local
-- luacheck: ignore

describe "local" (function ()
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

  it "creates a prefixed local #local" (function ()
    assert.are.same (
      { "px_fld" },
      butter.parse {
        "[px]",
        "*fld",
      }
    )
    assert.are.same (
      { "px_fld='value'" },
      butter.parse {
        "[px]",
        "*fld='value'"
      }
    )
    assert.are.same (
      { 'echo "$px_fld"' },
      butter.parse {
        "[px]",
        'echo "$*fld"'
      }
    )
  end)

  it "creates a global #global" (function ()
    assert.are.same (
      { "global" },
      butter.parse { "*global" }
    )
    assert.are.same (
      { "global='value'" },
      butter.parse { "*global='value'" }
    )
    assert.are.same (
      { 'echo "$fld"' },
      butter.parse { 'echo "$*fld"' }
    )
  end)
end)
