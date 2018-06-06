-- butterc | 3.06.2018
-- By daelvn
-- Preprocessor for shell scripts

--# Namespace #--
local butter = {}

--# Libraries #--
local getopt = require "lgetopt"

--# Getopt #--
local options = {
  name    = "butter",
  version = "v1.0",
  help    = "Preprocessor for shell scripts",
  options = {
    ["-i"]              = {help = "Input file",                             type = "string"},
    ["-o"]              = {help = "Output file",                            type = "string"},
    ["+i"]              = {help = "Source files",                           type = "table" },
    ["--no-print"]      = {help = "Disable all butter logging",             type = "boolean"},
    ["--verbose-print"] = {help = "Enable verbose butter logging",          type = "boolean"},
    ["--dry"]           = {help = "Print the output instead of writing it", type = "boolean"},
  },
  flags   = {
    ["v"]   = {help = "Be verbose",                                type = "boolean"},
    ["I"]   = {help = "Include butter helper functions in script", type = "boolean"},
  }
}

local args, err, idx = getopt (arg, options)
if err then print (err, idx) end
if args == "help" then return butter end

local cl = {
  i     = args.opt ["-i"]              or error "Input file is required",
  o     = args.opt ["-o"]              or args.opt ["-i"]:match "^(.-)%." .. ".sh",
  i2    = args.opt ["+i"]              or {},
  no_bl = args.opt ["--no-print"]      or false,
  vbl   = args.opt ["--verbose-print"] or false,
  dry   = args.opt ["--dry"]           or false,

  v     = args.opt ["v"]               or false,
  I     = args.opt ["I"]               or false,
}

--# Buffering #--
local ifileh  = assert (io.open (cl.i, "r"), "Could not open file: " .. cl.i)
local buffer  = {}
local nbuffer = {}
for line in ifileh:lines () do table.insert (buffer, line) end
ifileh:close ()

--# Init #--
if cl.I then
  nbuffer[1] = ". libbutter"
else
  cl.vbl    = false
  cl.no_bl  = true
end

--# Replacing #--
butter.state     = { fn = { close_posl = {}, open = false}, source = 1, leak = false, last = 0 }
butter.curprefix = ""
butter.curfn     = ""
-- *fld         => px_fld
-- px#fld       => px_fld
-- [*]          -> butter.curprefix = *
-- *:           -> butter.curfn = *
--              -> butter.state.fn.open = true
--              => * () { ... }
-- @n*          => "$n*"
-- #@v[iewk]: * => butter_log[iewk] "%butter.curprefix#%butter.curfn" "*" (if -I, !--bl, --vbl)
-- #@[iewk]: *  => butter_log[iewk] "%butter.curprefix#%butter.curfn" "*" (if -I, !--bl)
-- #@source      > Place sourcing in this location
-- #@@           > Stop processing
butter.replacers = {}
-- *fld
function butter.replacers.locals (line)
  if line:find "%*[a-zA-Z_-]+" then
    local mi,me       = line:find "%*[a-zA-Z_-]+"
    local bef,aft,mid = line:sub (1,mi-1), line:sub (me+1), line:sub (mi,me)
    return bef .. mid:gsub ("-", "_"):gsub ("%*([a-zA-Z_]+)", butter.curprefix .. "_%1") .. aft
  end
  return line
end
-- px#fld
function butter.replacers.fields (line)
  if line:find "[^# ]+#[^# ]+" then
    local mi,me       = line:find "[^# ]+#[^# ]+"
    local bef,aft,mid = line:sub (1,mi-1), line:sub (me+1), line:sub (mi,me)
    return bef .. mid:gsub ("-", "_"):gsub ("([^# ]+)#([^# ]+)", "%1_%2") .. aft
  end
  return line
end
-- [px]
function butter.replacers.prefix (line)
  if line:match "^%b[]" then
    local prefix = line:match "^%[(.-)%]":gsub("-","_")
    butter.curprefix = prefix ~= ":" and prefix or ""
    return "#@noprint"
  end
  return line
end
-- fld:
function butter.replacers.fn (line)
  if line:match "^([^@]-):" then
    butter.curfn         = line:match "^(.-):"
    butter.state.fn.open = true
    if butter.curprefix ~= "" then
      return butter.curprefix.."_"..butter.curfn:gsub("-","_").." () {"
    else
      return butter.curfn:gsub("-","_").." () {"
    end
  end
  return line
end
-- @fld
function butter.replacers.symbol (line) return line:gsub ("@([0-9*?@])", '"$%1"') end
-- #@source
function butter.replacers.source (line)
  if line:match "#@source" then butter.state.source = #nbuffer; return "#@noprint" end
  return line
end
-- #@@
function butter.replacers.leak (line) if line:match "#@@" then butter.state.leak = true; return true end end
-- #@v[iewk]
function butter.replacers.logv (line)
  if line:match "#@v[iewk]" then
    if cl.vbl and not cl.no_bl then
      if cl.v then
        print "dump-viewk"
        print (line:match "^%s*", line:match "#@v([iewk])", line:match "%:(.*)")
      end
      return line:match "^%s*"
          .. "libbutter_log_"
          .. (line:match "#@v([iewk])")
          .. ' "'
          .. butter.curprefix
          .. "#"
          .. butter.curfn
          .. '" "'
          .. (line:match "%:%s*(.*)")
          .. '"'
    else
      return "#@noprint"
    end
  end
  return line
end
-- #@[iewk]
function butter.replacers.log (line)
  if line:match "#@[iewk]" then
    if not cl.no_bl then
      if cl.v then
        print "dump-iewk"
        print (line:match "^%s*":gsub("%s","*"), line:match "#@([iewk])", line:match "%:%s*(.*)")
      end
      return (line:match "^%s+")
          .. "libbutter_log_"
          .. (line:match "#@([iewk])")
          .. ' "'
          .. butter.curprefix
          .. "#"
          .. butter.curfn
          .. '" "'
          .. (line:match "%:%s*(.*)")
          .. '"'
    else
      return "#@noprint"
    end
  end
  return line
end

--# Iterate #--
for lnum,line in pairs (buffer) do
  if cl.v then print "--------------------------" end
  -- Set last
  butter.state.last = lnum
  -- Verbose
  if cl.v then
    print ("print state", lnum, line)
    print (butter.state.fn.open, butter.state.last)
  end
  -- Autoclose functions
  if butter.state.fn.open and not line:match "^%s+" then
    butter.state.fn.open = false
    table.insert (nbuffer, "}")
  end
  -- Primary replaces
  -- #@@
  if butter.replacers.leak (line) then break end
  -- @?
  line = butter.replacers.symbol (line)
  -- Fields and locals
  line = butter.replacers.locals (line)
  line = butter.replacers.fields (line)

  -- Prefixes and functions
  line = butter.replacers.prefix (line)
  line = butter.replacers.fn     (line)

  -- Sources
  line = butter.replacers.source (line)
  -- Logging
  -- #@v?[iewk]
  line = butter.replacers.logv (line)
  line = butter.replacers.log  (line)
  -- Print
  if not line:match "^#@noprint" then table.insert (nbuffer, line) end
end
-- Autoclose functions
if butter.state.fn.open then table.insert (nbuffer, "}") end
-- Place sources
for _,src in pairs (cl.i2) do table.insert (nbuffer, butter.state.source, ". "..src) end
-- Leak?
if butter.state.leak then
  for i = butter.state.last, #buffer do
    table.insert (nbuffer, buffer[i])
  end
end

--# Printing #--
if cl.dry then for k,v in pairs (nbuffer) do print (v) end
else
  local ofileh = assert (io.open (cl.o, "w"), "Could not open file: " .. cl.o)
  for k,v in pairs (nbuffer) do ofileh:write (v .. "\n") end
  ofileh:close ()
end

--# Returning #--
return butter
