-- butterc | 7.06.2018
-- By daelvn
-- Command line wrapper for butter

--# Libraries #--
local getopt = require "lgetopt"
local butter = require "butter"

--# Getopt #--
local options = {
  name    = "butter",
  version = "v1.3",
  help    = "Preprocessor for shell scripts",
  options = {
    ["-i"]              = {help = "Input file",                             type = "string" },
    ["-o"]              = {help = "Output file",                            type = "string" },
    ["+i"]              = {help = "Source files",                           type = "table"  },
    ["+I"]              = {help = "Source butter.lib files",                type = "table"  },
    ["--silent"]        = {help = "Disable all butter logging",             type = "boolean"},
    ["--verbose-print"] = {help = "Enable verbose butter logging",          type = "boolean"},
    ["--version"]       = {help = "Show the program version",               type = "boolean"},
    ["--dry"]           = {help = "Print the output instead of writing it", type = "boolean"},
    ["--no-comments"]   = {help = "Disables comment printing",              type = "boolean"},
  },
  flags   = {
    ["v"] = {help = "Be verbose",                                type = "boolean"},
    ["e"] = {help = "Execute file after generating it",          type = "boolean"},
  }
}

local args, err, idx = getopt (arg, options)
if err then print (err,idx) end
if args == "help" then return butter end

local cl = {}
cl.i      = args.opt ["-i"]
            or "butter: An input file is required"
cl.o      = args.opt ["-o"]
            or (args.opt ["-i"] and cl.i:match "^(.-)%."..".sh")
            or "butter: An output file is required"
cl.i2     = args.opt ["+i"]              or {}
cl.incl   = args.opt ["+I"]              or {}
cl.no_com = args.opt ["--no-comments"]   or false
cl.no_bl  = args.opt ["--silent"]        or false
cl.vbl    = args.opt ["--verbose-print"] or false
cl.dry    = args.opt ["--dry"]           or false
cl.v      = args.opt.v or false
cl.e      = args.opt.e or false

if not args.opt ["-i"] then print (cl.i); return false end

--# Buffering #--
local ifileh  = assert (io.open (cl.i, "r"), "Could not open file: " .. cl.i)
local buffer  = {}
local nbuffer
for line in ifileh:lines () do table.insert (buffer, line) end
ifileh:close ()

--# Executing #--
nbuffer = butter.parse (buffer, cl)

--# Printing #--
if cl.dry then for k,v in pairs (nbuffer) do print (v) end
else
  local ofileh = assert (io.open (cl.o, "w"), "Could not open file: " .. cl.o)
  for k,v in pairs(nbuffer) do ofileh:write (v.."\n") end
  ofileh:close ()
end
-- cl.e
if cl.e then os.execute ("./" .. cl.o) end

--# Returning #--
return true
