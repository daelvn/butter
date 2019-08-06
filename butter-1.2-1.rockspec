package = "butter"
version = "1.2-1"

source = {
  url = "git://github.com/daelvn/butter",
  tag = "v1.2"
}

description = {
  summary  = "Preprocessor for shell files",
  detailed = [[
    butter is a preprocessor for shell files, with features like sourcing, namespaces,
    indent-based function declaration and others.
  ]],
  homepage = "http://me.daelvn.ga/butter",
  license  = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lgetopt >= 1.2.8"
}

build = {
  type    = "none",
  install = {
    bin   = {
      butter   = "butterc.lua",
      libbutter = "libbutter.sh"
    },
    lua   = { butter = "butter.lua" }
  }
}
