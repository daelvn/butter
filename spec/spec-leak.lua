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

  it "leaks the code #leak" (function ()
    assert.are.same (
      {
        "#@@",
        "#@noprint comment"
      },
      butter.parse {
        "#@noprint comment",
        "#@@",
        "#@noprint comment"
      }
    )
  end)
end)
