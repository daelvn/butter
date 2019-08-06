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

  it "declares a variable with mixed spacing #declare_mixed" (function ()
    assert.are.same (
      { "a=5", "bb=4", "ccc='d'", "eeee=1" },
      butter.parse {
        "#= a=  5",
        "#=bb    =4",
        "#= ccc='d'",
        "#=eeee =  1"
      }
    )
  end)

  it "declares a variable with aligned spacing #declare_aligned" (function ()
    assert.are.same (
      { "a=5", "bb=4", "ccc='d'", "eeee=1" },
      butter.parse {
        "#= a    =  5",
        "#= bb   =  4",
        "#= ccc  =  'd'",
        "#= eeee =  1"
      }
    )
  end)
end)
