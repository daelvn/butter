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

  it "generates empty functions #function_empty" (function ()
    assert.are.same (
      {
        "fn () {",
        "}"
      },
      butter.parse { "fn:" }
    )
  end)

  it "closes functions #function_close" (function ()
    assert.are.same (
      {
        "fn () {",
        "}",
        "fu () {",
        "}"
      },
      butter.parse {
        "fn:",
        "fu:"
      }
    )
  end)

  it "generates simple functions #function_simple" (function ()
    assert.are.same (
      {
        "fn () {",
        "  do",
        "}"
      },
      butter.parse {
        "fn:",
        "  do"
      }
    )
  end)

  it "generates complex functions #function_inline" (function ()
    assert.are.same (
      {
        "fn () { do",
        "}"
      },
      butter.parse { "fn: do" }
    )
  end)

  it "generates simple functions in namespaces #function_simple_namespace" (function ()
    assert.are.same (
      {
        "px_fn () {",
        "  do",
        "}"
      },
      butter.parse {
        "[px]",
        "fn:",
        "  do"
      }
    )

  end)

  it "generates complex functions in namespaces #function_inline_namespace" (function ()
    assert.are.same (
      {
        "px_fn () { do",
        "}"
      },
      butter.parse {
        "[px]",
        "fn: do"
      }
    )
 end)
end)
