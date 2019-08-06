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

  it "uses a field #field" (function ()
    assert.are.same (
      { "px_fld" },
      butter.parse { "px#fld" }
    )
    assert.are.same (
      { "p_x_f_ld" },
      butter.parse { "p-x#f-ld" }
    )
  end)

  it "uses multiple fields #field_multi" (function ()
    assert.are.same (
      { "px_pf_fld" },
      butter.parse { "px#pf#fld" }
    )
  end)
end)
