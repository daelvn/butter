-- butterc | 3.06.2018
-- By daelvn
-- Preprocessor for shell scripts

-- luacheck: no max line length

--# Namespace #--
local butter = {}

--# Utils #--
local function l (s) if butter.cl.v then print (s) end end

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
-- #@#           > Comments
--- Shell
-- #/ exit-on-error
-- #/ exit-on-unset
--- Arrays
-- #@new fld[]   > Numeric array
-- #@new fld{}   > Associative array
--- Declarations (Ignore whitespace)
-- #= fld = val => fld=val
-- #= fld[x]= v => fld[x]=v
butter.replacers = {}
-- *fld
function butter.replacers.locals (line)
  local ln = line
  if line:find "%*[a-zA-Z_-]+" then
    l "detected local"
    for m in line:gmatch "%*[a-zA-Z_-]+" do
      local mi,me       = ln:find (m)
      local bef,aft,mid = ln:sub (1,mi-1), ln:sub (me+1), ln:sub (mi+1,me)
      l (mi, me, m)
      ln = bef .. mid:gsub ("-", "_"):gsub (m:gsub ("-", "_"):match "[a-zA-Z_]", (butter.curprefix ~= "" and butter.curprefix .. "_" or "") .. "%1") ..aft
    end
  end
  return ln
end
-- px#fld
function butter.replacers.fields (line)
  local ln = line
  -- Return if no match
  if not ln:match "[a-zA-Z_-]+#" then return ln end
  -- Init loop
  -- luacheck: ignore ai
  local ai, ae = 1, 1
  for m in ln:gmatch "[a-zA-Z_-]+#" do
    ai, ae = ln:find (m,ae+1)
    ai, ae = ai or 1, ae or ln:len ()
    -- If recursive then
    if ln:match ("#[a-zA-Z_-]+#",ae-1) then
      l "detected recursive field"
      l (ai)
      repeat
        local _,me = ln:find ("[a-zA-Z_-]+#", ae)
        ae = ae + (me-ae)
      until not ln:match ("[a-zA-Z_-]+#", ae)
    -- Not recursive
    else l "detected field"; l (ai,ae,ai) end
    -- Common steps
    local pres    = (ln:sub (ai,ae) .. ln:match ("#([a-zA-Z_-]+)",ae)):gsub ("-", "_"):gsub ("#", "_")
    local ti,te   = 0, ae + string.len (ln:match ("#([a-zA-Z_-]+)",ae))
    local bef,aft = ln:sub (ti,ai-1), ln:sub (te+1)
    -- Return line
    ln = bef .. pres .. aft
  end
  -- Return
  return ln
end
-- [px]
function butter.replacers.prefix (line)
  if line:match "^%b[]" then
    l "detected prefix"
    local prefix = line:match "^%[(.-)%]":gsub ("-","_"):gsub ("#", "_")
    butter.curprefix = prefix ~= ":" and prefix or ""
    return "#@noprint"
  end
  return line
end
-- fld:
function butter.replacers.fn (line)
  if line:match "^([^@]-):" then
    l "detected function"
    butter.curfn         = line:match "^(.-):"
    butter.state.fn.open = true
    if butter.curprefix ~= "" then
      return butter.curprefix.."_"..butter.curfn:gsub ("-","_"):gsub ("#", "_").." () {"..line:match ":(.*)"
    else
      return butter.curfn:gsub ("-","_"):gsub ("#", "_").." () {"..line:match ":(.*)"
    end
  end
  return line
end
-- @fld
function butter.replacers.symbol (line)
  return line:gsub ("@([0-9*?@!])", '"$%1"')
end
-- #@source
function butter.replacers.source (line, nbuf)
  if line:match "#@source" then
    l "detected source"
    butter.state.source = #nbuf > 0 and #nbuf or 1
    return "#@noprint"
  end
  return line
end
-- #@@
function butter.replacers.leak (line) if line:match "#@@" then butter.state.leak = true; return true end end
-- #@v[iewk]
function butter.replacers.logv (line)
  if line:match "#@v[iewk]" then
    l "detected logv"
    if butter.cl.vbl and not butter.cl.no_bl then
      if butter.cl.v then
        print "dump-viewk"
        print (line:match "^%s*", line:match "#@v([iewk])", line:match "%:%s*(.*)")
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
    l "detected log"
    if not butter.cl.no_bl then
      if butter.cl.v then
        print "dump-iewk"
        print (line:match "^%s*":gsub("%s","*"), line:match "#@([iewk])", line:match "%:%s*(.*)")
      end
      return (line:match "^%s*")
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
-- #@#
function butter.replacers.comment (line)
  if butter.cl.no_com then return "#@noprint" end
  if line:find "#@#(.*)" then
    l "detected comment"
    local mi, me      = line:find "#@#(.*)"
    local bef,aft,mid = line:sub (1,mi-1), line:sub (me+1), line:sub (mi,me)
    if butter.cl.no_c then return bef..aft else return bef.. mid:gsub ("#@#", "#") .. aft end
  end
  return line
end
-- #@new fld[] / #@new fld{}
function butter.replacers.array (line)
  if line:match "#@new %*?[a-zA-Z_-]-%s*[%[%{][%]%}]" then
    l "detected array"
    local flag = "A"
    if line:match ("#@new %*?[a-zA-Z_-]-%s*[%[%{][%]%}]"):match ("%b[]") then flag = "a" end
    local pres        = line:gsub ("#@new %*?([a-zA-Z_-]-)%s*[%[%{][%]%}]", "typeset -"..flag.." #@!%1")
    local mi, me      = pres:find "#@![a-zA-Z_-]+"
    local bef,aft,mid = pres:sub (0,mi-1), pres:sub (me+1), pres:sub (mi,me)
    return bef .. mid:gsub ("-", "_"):gsub ("#@!", "") .. aft
  end
  return line
end
-- #= fld = val
function butter.replacers.declare (line)
  if line:match "#=%s*[a-zA-Z_-]+%s*=%s*(.+)" then
    l "detected declaration"
    local pres        = line:gsub ("#=%s*([a-zA-Z_-]+)%s*=%s*(.+)", "#@!%1=%2")
    local mi, me      = pres:find "#@![a-zA-Z_-]"
    local bef,aft,mid = pres:sub (0,mi-1), pres:sub (me+1), pres:sub (mi,me)
    return bef .. mid:gsub ("-", "_"):gsub ("#@!", "") .. aft
  end
  return line
end
-- #/
function butter.replacers.shell (line)
  if line:match "#/%s*(.+)" then
    l "detected shell"
    local option = line:match "#/%s*(.+)"
    if     option == "exit-on-error" then return line:match "^%s*" .. "set -e"
    elseif option == "exit-on-unset" then return line:match "^%s*" .. "set -u"
    else   return line
    end
  end
  return line
end

--# Parse #--
function butter.parse (buf,cl)
  butter.cl    = butter.cl or cl or {
    i2 = {},
    v  = false
  }
  butter.cl.i2 = butter.cl.i2 or {}

  -- Init
  local nbuf     = {}
  local included = {}
  butter.cl.incl    = butter.cl.incl or {}
  for _,include in pairs (butter.cl.incl) do
    table.insert (nbuf, ". butter.lib/" .. include .. ".butter")
    included [include] = true
  end
  if not included.log then
    butter.cl.vbl    = false
    butter.cl.no_bl  = true
  end
  -- Iterate
  for lnum,line in pairs (buf) do
    if butter.cl.v then print "--------------------------" end
    -- Set last
    butter.state.last = lnum
    -- Verbose
    if butter.cl.v then
      print ("print state", lnum, line)
      print (butter.state.fn.open, butter.state.last)
    end
    -- Autoclose functions
    if butter.state.fn.open and not line:match "^%s+" then
      butter.state.fn.open = false
      table.insert (nbuf, "}")
    end
    -- Primary replaces
    -- Shell
    line = butter.replacers.shell (line)
    -- #@@
    if butter.replacers.leak (line) then break end
    -- @?
    line = butter.replacers.symbol  (line)
    -- Fields and locals
    line = butter.replacers.locals  (line)
    line = butter.replacers.fields  (line)
    -- Declaration
    line = butter.replacers.declare (line)
    line = butter.replacers.array   (line)
    -- Prefixes and functions
    line = butter.replacers.prefix  (line)
    line = butter.replacers.fn      (line)
    -- Sources
    line = butter.replacers.source  (line, nbuf)
    -- Comments
    line = butter.replacers.comment (line)
    -- Logging
    -- #@v?[iewk]
    line = butter.replacers.logv    (line)
    line = butter.replacers.log     (line)
    -- Print
    if not line:match "^#@noprint" then table.insert (nbuf, line) end
  end
  -- Autoclose functions
  if butter.state.fn.open then table.insert (nbuf, "}") end
  -- Place sources
  for i = #butter.cl.i2, 1, -1 do table.insert (nbuf, butter.state.source, ". "..butter.cl.i2 [i]) end
  -- Leak?
  if butter.state.leak then
    for i = butter.state.last, #buf do
      table.insert (nbuf, buf[i])
    end
  end
  -- Return nbuf
  return nbuf
end

--# Returning #--
return butter
