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
-- !fld         => px_fld
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
butter.state     = { fn = { close_posl = {}, open = false}, source = 1, leak = false, last = 0 }
butter.curprefix = ""
butter.curfn     = ""
for lnum,line in pairs (buffer) do
  butter.state.last = lnum
  if cl.v then
    print ("print state", lnum)
    print (butter.state.fn.open, butter.state.last)
  end
  if butter.state.fn.open and not line:match "^%s+" then
    butter.state.fn.open = false
    table.insert (nbuffer, "}")
  end
  --- One-per-line
  -- [*]
  if line:match "^%b[]" then
    local prefix = line:match "^%[(.-)%]":gsub("-","_")
    butter.curprefix = prefix ~= ":" and prefix or ""

    line = "#@noprint"
  -- *:
  elseif line:match "^([^@]-):" then
    butter.curfn         = line:match "^(.-):"
    butter.state.fn.open = true
    if butter.curprefix ~= "" then
      line = butter.curprefix.."_"..butter.curfn:gsub("-","_").." () {"
    else
      line = butter.curfn:gsub("-","_").." () {"
    end
  end

  --- Free replaces
  -- #@v[iewk]
  if line:match "#@v[iewk]" then
    if cl.vbl and not cl.no_bl then
      if cl.v then
        print "dump"
        print (line)
        print (line:match "^%s*")
        print (line:match "#@v([iewk])")
        print (line:match "%:(.*)")
      end
      line = line:match "^%s*"
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
      line = "#@noprint"
    end
  end
  -- #@[iewk]
  if line:match "#@[iewk]" then
    if not cl.no_bl then
      line = line:match "^%s+".."libbutter_log_"..line:match "#@v([iewk])"
          .. ' "' .. butter.curprefix .. "#" .. butter.curfn .. '" "'
          .. (line:match ":(.+)" or "") .. '"'
    else
      line = "#@noprint"
    end
  end
  -- @n*
  line = line:gsub ("@(%d)", '"$%1"')
  -- %w#%w
  if line:find "[^# ]+#[^# ]+" then
    local mi,me       = line:find "[^# ]+#[^# ]+"
    local bef,aft,mid = line:sub (1,mi-1), line:sub (me+1), line:sub (mi,me)
    line              = bef .. mid:gsub ("-", "_"):gsub ("([^# ]+)#([^# ]+)", "%1_%2") .. aft
  end
  -- !%w+
  if line:find "%*[a-zA-Z_-]+" then
    local mi,me       = line:find "%*[a-zA-Z_-]+"
    local bef,aft,mid = line:sub (1,mi-1), line:sub (me+1), line:sub (mi,me)
    line              = bef .. mid:gsub ("-", "_"):gsub ("%*([a-zA-Z_]+)", butter.curprefix .. "_%1") .. aft
  end
  --- Sources
  if line:match "#@source" then butter.state.source = #nbuffer end

  --- Other
  if line:match "#@@" then butter.state.leak = true; break end
  if not line:match "^#@noprint" then table.insert (nbuffer, line) end
end
if butter.state.fn.open then table.insert (nbuffer, "}") end
for _,src in pairs (cl.i2) do table.insert (nbuffer, butter.state.source, ". "..src) end
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
