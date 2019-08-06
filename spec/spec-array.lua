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

  it "creates a numeric array #array_numeric" (function ()
    assert.are.same (
      { "typeset -a arr" },
      butter.parse { "#@new arr[]" }
    )
  end)

  it "creates an associative array #array_associative" (function ()
    assert.are.same (
      { "typeset -A arr" },
      butter.parse { "#@new arr{}" }
    )
  end)

  it "creates a local numeric array #array_numeric_local" (function ()
    assert.are.same (
      { "typeset -a px_arr" },
      butter.parse {
        "[px]",
        "#@new *arr[]"
      }
    )
  end)

  it "creates a local associative array #array_associative_local" (function ()
    assert.are.same (
      { "typeset -A px_arr" },
      butter.parse {
        "[px]",
        "#@new *arr{}"
      }
    )
  end)
end)
