-- butter | 07.06.2018
-- By daelvn
-- spec-local
-- luacheck: ignore

describe "" (function ()
  local butter

  setup (function ()
    butter    = require "butter"
    butter.cl = { v = false }
  end)

  teardown (function ()
    butter = nil
  end)

  before_each (function ()
    butter.parse { "[:]" }
  end)

  it "exits on errors #shell_eoe" (function ()
    assert.are.same (
      { "set -e" },
      butter.parse { "#/ exit-on-error" }
    )
  end)

  it "exits on unset #shell_eou" (function ()
    assert.are.same (
      { "set -u" },
      butter.parse { "#/ exit-on-unset" }
    )
  end)
end)
