(function ()
  exports = {}
  function setenv(k, ...)
    local keys = unstash({...})
    local _g6 = sub(keys, 0)
    if string63(k) then
      local frame = last(environment)
      local x = (frame[k] or {})
      local k1 = nil
      local _g7 = _g6
      for k1 in next, _g7 do
        if (not number63(k1)) then
          local v = _g7[k1]
          x[k1] = v
        end
      end
      x.module = current_module
      frame[k] = x
    end
  end
  function getenv(k)
    if string63(k) then
      return(find(function (e)
        return(e[k])
      end, reverse(environment)))
    end
  end
  local function macro_function(k)
    local b = getenv(k)
    return((b and b.macro))
  end
  local function macro63(k)
    return(is63(macro_function(k)))
  end
  function special63(k)
    local b = getenv(k)
    return((b and is63(b.special)))
  end
  function special_form63(form)
    return((list63(form) and special63(hd(form))))
  end
  local function symbol_expansion(k)
    local b = getenv(k)
    return((b and b.symbol))
  end
  local function symbol63(k)
    return(is63(symbol_expansion(k)))
  end
  local function variable63(k)
    local b = last(environment)[k]
    return((b and is63(b.variable)))
  end
  function bound63(x)
    return((macro63(x) or special63(x) or symbol63(x) or variable63(x)))
  end
  local function escape(str)
    local str1 = "\""
    local i = 0
    while (i < length(str)) do
      local c = char(str, i)
      local c1 = (function ()
        if (c == "\n") then
          return("\\n")
        elseif (c == "\"") then
          return("\\\"")
        elseif (c == "\\") then
          return("\\\\")
        else
          return(c)
        end
      end)()
      str1 = (str1 .. c1)
      i = (i + 1)
    end
    return((str1 .. "\""))
  end
  function quoted(form)
    if string63(form) then
      return(escape(form))
    elseif atom63(form) then
      return(form)
    else
      return(join({"list"}, map42(quoted, form)))
    end
  end
  function stash(args)
    if keys63(args) then
      local p = {_stash = true}
      local k = nil
      local _g59 = args
      for k in next, _g59 do
        if (not number63(k)) then
          local v = _g59[k]
          p[k] = v
        end
      end
      return(join(args, {p}))
    else
      return(args)
    end
  end
  function stash42(args)
    if keys63(args) then
      local l = {"%object", "_stash", true}
      local k = nil
      local _g60 = args
      for k in next, _g60 do
        if (not number63(k)) then
          local v = _g60[k]
          add(l, k)
          add(l, v)
        end
      end
      return(join(args, {l}))
    else
      return(args)
    end
  end
  function unstash(args)
    if empty63(args) then
      return({})
    else
      local l = last(args)
      if (table63(l) and l._stash) then
        local args1 = sub(args, 0, (length(args) - 1))
        local k = nil
        local _g61 = l
        for k in next, _g61 do
          if (not number63(k)) then
            local v = _g61[k]
            if (k ~= "_stash") then
              args1[k] = v
            end
          end
        end
        return(args1)
      else
        return(args)
      end
    end
  end
  function _37bind42(args, body)
    local args1 = {}
    local rest = function ()
      if (target == "js") then
        return({"unstash", {"sublist", "arguments", length(args1)}})
      else
        add(args1, "|...|")
        return({"unstash", {"list", "|...|"}})
      end
    end
    if atom63(args) then
      return({args1, {join({"let", {args, rest()}}, body)}})
    else
      local bs = {}
      local r = (args.rest or (keys63(args) and make_id()))
      local _g63 = 0
      local _g62 = args
      while (_g63 < length(_g62)) do
        local arg = _g62[(_g63 + 1)]
        if atom63(arg) then
          add(args1, arg)
        elseif (list63(arg) or keys63(arg)) then
          local v = make_id()
          add(args1, v)
          bs = join(bs, {arg, v})
        end
        _g63 = (_g63 + 1)
      end
      if r then
        bs = join(bs, {r, rest()})
      end
      if keys63(args) then
        bs = join(bs, {sub(args, length(args)), r})
      end
      if empty63(bs) then
        return({args1, body})
      else
        return({args1, {join({"let", bs}, body)}})
      end
    end
  end
  function _37bind(lh, rh)
    if (composite63(lh) and list63(rh)) then
      local id = make_id()
      return(join({{id, rh}}, _37bind(lh, id)))
    elseif atom63(lh) then
      return({{lh, rh}})
    else
      local bs = {}
      local r = lh.rest
      local i = 0
      local _g64 = lh
      while (i < length(_g64)) do
        local x = _g64[(i + 1)]
        bs = join(bs, _37bind(x, {"at", rh, i}))
        i = (i + 1)
      end
      if r then
        bs = join(bs, _37bind(r, {"sub", rh, length(lh)}))
      end
      local k = nil
      local _g65 = lh
      for k in next, _g65 do
        if (not number63(k)) then
          local v = _g65[k]
          if (v == true) then
            v = k
          end
          if (k ~= "rest") then
            bs = join(bs, _37bind(v, {"get", rh, {"quote", k}}))
          end
        end
      end
      return(bs)
    end
  end
  function _37message_handler(msg)
    local i = search(msg, ": ")
    return(sub(msg, (i + 2)))
  end
  local function quoting63(depth)
    return(number63(depth))
  end
  local function quasiquoting63(depth)
    return((quoting63(depth) and (depth > 0)))
  end
  local function can_unquote63(depth)
    return((quoting63(depth) and (depth == 1)))
  end
  local function quasisplice63(x, depth)
    return((list63(x) and can_unquote63(depth) and (hd(x) == "unquote-splicing")))
  end
  function macroexpand(form)
    if symbol63(form) then
      return(macroexpand(symbol_expansion(form)))
    elseif atom63(form) then
      return(form)
    else
      local x = hd(form)
      if (x == "%for") then
        local _g3 = form[1]
        local _g66 = form[2]
        local t = _g66[1]
        local k = _g66[2]
        local body = sub(form, 2)
        return(join({"%for", {macroexpand(t), macroexpand(k)}}, macroexpand(body)))
      elseif (x == "%function") then
        local _g4 = form[1]
        local args = form[2]
        local _g67 = sub(form, 2)
        add(environment, {})
        local _g69 = (function ()
          local _g71 = 0
          local _g70 = args
          while (_g71 < length(_g70)) do
            local _g68 = _g70[(_g71 + 1)]
            setenv(_g68, {_stash = true, variable = true})
            _g71 = (_g71 + 1)
          end
          return(join({"%function", map42(macroexpand, args)}, macroexpand(_g67)))
        end)()
        drop(environment)
        return(_g69)
      elseif ((x == "%local-function") or (x == "%global-function")) then
        local _g5 = form[1]
        local name = form[2]
        local _g72 = form[3]
        local _g73 = sub(form, 3)
        add(environment, {})
        local _g75 = (function ()
          local _g77 = 0
          local _g76 = _g72
          while (_g77 < length(_g76)) do
            local _g74 = _g76[(_g77 + 1)]
            setenv(_g74, {_stash = true, variable = true})
            _g77 = (_g77 + 1)
          end
          return(join({x, name, map42(macroexpand, _g72)}, macroexpand(_g73)))
        end)()
        drop(environment)
        return(_g75)
      elseif macro63(x) then
        return(macroexpand(apply(macro_function(x), tl(form))))
      else
        return(map42(macroexpand, form))
      end
    end
  end
  local function quasiquote_list(form, depth)
    local xs = {{"list"}}
    local k = nil
    local _g78 = form
    for k in next, _g78 do
      if (not number63(k)) then
        local v = _g78[k]
        local v = (function ()
          if quasisplice63(v, depth) then
            return(quasiexpand(v[2]))
          else
            return(quasiexpand(v, depth))
          end
        end)()
        last(xs)[k] = v
      end
    end
    local _g80 = 0
    local _g79 = form
    while (_g80 < length(_g79)) do
      local x = _g79[(_g80 + 1)]
      if quasisplice63(x, depth) then
        local x = quasiexpand(x[2])
        add(xs, x)
        add(xs, {"list"})
      else
        add(last(xs), quasiexpand(x, depth))
      end
      _g80 = (_g80 + 1)
    end
    if (length(xs) == 1) then
      return(hd(xs))
    else
      return(reduce(function (a, b)
        return({"join", a, b})
      end, keep(function (x)
        return(((length(x) > 1) or (not (hd(x) == "list")) or keys63(x)))
      end, xs)))
    end
  end
  function quasiexpand(form, depth)
    if quasiquoting63(depth) then
      if atom63(form) then
        return({"quote", form})
      elseif (can_unquote63(depth) and (hd(form) == "unquote")) then
        return(quasiexpand(form[2]))
      elseif ((hd(form) == "unquote") or (hd(form) == "unquote-splicing")) then
        return(quasiquote_list(form, (depth - 1)))
      elseif (hd(form) == "quasiquote") then
        return(quasiquote_list(form, (depth + 1)))
      else
        return(quasiquote_list(form, depth))
      end
    elseif atom63(form) then
      return(form)
    elseif (hd(form) == "quote") then
      return(form)
    elseif (hd(form) == "quasiquote") then
      return(quasiexpand(form[2], 1))
    else
      return(map42(function (x)
        return(quasiexpand(x, depth))
      end, form))
    end
  end
  target = "lua"
  function length(x)
    return(#x)
  end
  function empty63(x)
    return((length(x) == 0))
  end
  function substring(str, from, upto)
    return((string.sub)(str, (from + 1), upto))
  end
  function sublist(l, from, upto)
    local i = (from or 0)
    local j = 0
    local _g81 = (upto or length(l))
    local l2 = {}
    while (i < _g81) do
      l2[(j + 1)] = l[(i + 1)]
      i = (i + 1)
      j = (j + 1)
    end
    return(l2)
  end
  function sub(x, from, upto)
    local _g82 = (from or 0)
    if string63(x) then
      return(substring(x, _g82, upto))
    else
      local l = sublist(x, _g82, upto)
      local k = nil
      local _g83 = x
      for k in next, _g83 do
        if (not number63(k)) then
          local v = _g83[k]
          l[k] = v
        end
      end
      return(l)
    end
  end
  function inner(x)
    return(sub(x, 1, (length(x) - 1)))
  end
  function hd(l)
    return(l[1])
  end
  function tl(l)
    return(sub(l, 1))
  end
  function add(l, x)
    return((table.insert)(l, x))
  end
  function drop(l)
    return((table.remove)(l))
  end
  function last(l)
    return(l[((length(l) - 1) + 1)])
  end
  function reverse(l)
    local l1 = {}
    local i = (length(l) - 1)
    while (i >= 0) do
      add(l1, l[(i + 1)])
      i = (i - 1)
    end
    return(l1)
  end
  function join(l1, l2)
    if nil63(l1) then
      return(l2)
    elseif nil63(l2) then
      return(l1)
    else
      local l = {}
      local skip63 = false
      if (not skip63) then
        local i = 0
        local len = length(l1)
        while (i < len) do
          l[(i + 1)] = l1[(i + 1)]
          i = (i + 1)
        end
        while (i < (len + length(l2))) do
          l[(i + 1)] = l2[((i - len) + 1)]
          i = (i + 1)
        end
      end
      local k = nil
      local _g84 = l1
      for k in next, _g84 do
        if (not number63(k)) then
          local v = _g84[k]
          l[k] = v
        end
      end
      local _g86 = nil
      local _g85 = l2
      for _g86 in next, _g85 do
        if (not number63(_g86)) then
          local v = _g85[_g86]
          l[_g86] = v
        end
      end
      return(l)
    end
  end
  function reduce(f, x)
    if empty63(x) then
      return(x)
    elseif (length(x) == 1) then
      return(hd(x))
    else
      return(f(hd(x), reduce(f, tl(x))))
    end
  end
  function keep(f, l)
    local l1 = {}
    local _g88 = 0
    local _g87 = l
    while (_g88 < length(_g87)) do
      local x = _g87[(_g88 + 1)]
      if f(x) then
        add(l1, x)
      end
      _g88 = (_g88 + 1)
    end
    return(l1)
  end
  function find(f, l)
    local _g90 = 0
    local _g89 = l
    while (_g90 < length(_g89)) do
      local x = _g89[(_g90 + 1)]
      local x = f(x)
      if x then
        return(x)
      end
      _g90 = (_g90 + 1)
    end
  end
  function pairwise(l)
    local i = 0
    local l1 = {}
    while (i < length(l)) do
      add(l1, {l[(i + 1)], l[((i + 1) + 1)]})
      i = (i + 2)
    end
    return(l1)
  end
  function iterate(f, count)
    local i = 0
    while (i < count) do
      f(i)
      i = (i + 1)
    end
  end
  function replicate(n, x)
    local l = {}
    iterate(function ()
      return(add(l, x))
    end, n)
    return(l)
  end
  function splice(x)
    return({_splice = x})
  end
  local function splice63(x)
    if table63(x) then
      return(x._splice)
    end
  end
  function map(f, l)
    local l1 = {}
    local _g100 = 0
    local _g99 = l
    while (_g100 < length(_g99)) do
      local x = _g99[(_g100 + 1)]
      local x1 = f(x)
      local s = splice63(x1)
      if list63(s) then
        l1 = join(l1, s)
      elseif is63(s) then
        add(l1, s)
      elseif is63(x1) then
        add(l1, x1)
      end
      _g100 = (_g100 + 1)
    end
    return(l1)
  end
  function map42(f, t)
    local l = map(f, t)
    local k = nil
    local _g101 = t
    for k in next, _g101 do
      if (not number63(k)) then
        local v = _g101[k]
        local x = f(v)
        if is63(x) then
          l[k] = x
        end
      end
    end
    return(l)
  end
  function mapt(f, t)
    local t1 = {}
    local k = nil
    local _g102 = t
    for k in next, _g102 do
      if (not number63(k)) then
        local v = _g102[k]
        local x = f(k, v)
        if is63(x) then
          t1[k] = x
        end
      end
    end
    return(t1)
  end
  function mapo(f, t)
    local o = {}
    local k = nil
    local _g103 = t
    for k in next, _g103 do
      if (not number63(k)) then
        local v = _g103[k]
        local x = f(k, v)
        if is63(x) then
          add(o, k)
          add(o, x)
        end
      end
    end
    return(o)
  end
  function keys63(t)
    local k63 = false
    local k = nil
    local _g104 = t
    for k in next, _g104 do
      if (not number63(k)) then
        local v = _g104[k]
        k63 = true
        break
      end
    end
    return(k63)
  end
  function extend(t, ...)
    local xs = unstash({...})
    local _g105 = sub(xs, 0)
    return(join(t, _g105))
  end
  function exclude(t, ...)
    local keys = unstash({...})
    local _g106 = sub(keys, 0)
    local t1 = sublist(t)
    local k = nil
    local _g107 = t
    for k in next, _g107 do
      if (not number63(k)) then
        local v = _g107[k]
        if (not _g106[k]) then
          t1[k] = v
        end
      end
    end
    return(t1)
  end
  function char(str, n)
    return(sub(str, n, (n + 1)))
  end
  function code(str, n)
    return((string.byte)(str, (function ()
      if n then
        return((n + 1))
      end
    end)()))
  end
  function search(str, pattern, start)
    local _g108 = (function ()
      if start then
        return((start + 1))
      end
    end)()
    local i = (string.find)(str, pattern, start, true)
    return((i and (i - 1)))
  end
  function split(str, sep)
    if ((str == "") or (sep == "")) then
      return({})
    else
      local strs = {}
      while true do
        local i = search(str, sep)
        if nil63(i) then
          break
        else
          add(strs, sub(str, 0, i))
          str = sub(str, (i + 1))
        end
      end
      add(strs, str)
      return(strs)
    end
  end
  function cat(...)
    local xs = unstash({...})
    local _g109 = sub(xs, 0)
    if empty63(_g109) then
      return("")
    else
      return(reduce(function (a, b)
        return((a .. b))
      end, _g109))
    end
  end
  function _43(...)
    local xs = unstash({...})
    local _g112 = sub(xs, 0)
    return(reduce(function (a, b)
      return((a + b))
    end, _g112))
  end
  function _(...)
    local xs = unstash({...})
    local _g113 = sub(xs, 0)
    return(reduce(function (a, b)
      return((b - a))
    end, reverse(_g113)))
  end
  function _42(...)
    local xs = unstash({...})
    local _g114 = sub(xs, 0)
    return(reduce(function (a, b)
      return((a * b))
    end, _g114))
  end
  function _47(...)
    local xs = unstash({...})
    local _g115 = sub(xs, 0)
    return(reduce(function (a, b)
      return((b / a))
    end, reverse(_g115)))
  end
  function _37(...)
    local xs = unstash({...})
    local _g116 = sub(xs, 0)
    return(reduce(function (a, b)
      return((b % a))
    end, reverse(_g116)))
  end
  function _62(a, b)
    return((a > b))
  end
  function _60(a, b)
    return((a < b))
  end
  function _61(a, b)
    return((a == b))
  end
  function _6261(a, b)
    return((a >= b))
  end
  function _6061(a, b)
    return((a <= b))
  end
  function read_file(path)
    local f = (io.open)(path)
    return((f.read)(f, "*a"))
  end
  function write_file(path, data)
    local f = (io.open)(path, "w")
    return((f.write)(f, data))
  end
  function write(x)
    return((io.write)(x))
  end
  function exit(code)
    return((os.exit)(code))
  end
  function nil63(x)
    return((x == nil))
  end
  function is63(x)
    return((not nil63(x)))
  end
  function string63(x)
    return((type(x) == "string"))
  end
  function string_literal63(x)
    return((string63(x) and (char(x, 0) == "\"")))
  end
  function id_literal63(x)
    return((string63(x) and (char(x, 0) == "|")))
  end
  function number63(x)
    return((type(x) == "number"))
  end
  function boolean63(x)
    return((type(x) == "boolean"))
  end
  function function63(x)
    return((type(x) == "function"))
  end
  function composite63(x)
    return((type(x) == "table"))
  end
  function atom63(x)
    return((not composite63(x)))
  end
  function table63(x)
    return((composite63(x) and nil63(hd(x))))
  end
  function list63(x)
    return((composite63(x) and is63(hd(x))))
  end
  function parse_number(str)
    return(tonumber(str))
  end
  function to_string(x)
    if nil63(x) then
      return("nil")
    elseif boolean63(x) then
      if x then
        return("true")
      else
        return("false")
      end
    elseif function63(x) then
      return("#<function>")
    elseif atom63(x) then
      return((x .. ""))
    else
      local str = "("
      local x1 = sub(x)
      local k = nil
      local _g117 = x
      for k in next, _g117 do
        if (not number63(k)) then
          local v = _g117[k]
          add(x1, (k .. ":"))
          add(x1, v)
        end
      end
      local i = 0
      local _g118 = x1
      while (i < length(_g118)) do
        local y = _g118[(i + 1)]
        str = (str .. to_string(y))
        if (i < (length(x1) - 1)) then
          str = (str .. " ")
        end
        i = (i + 1)
      end
      return((str .. ")"))
    end
  end
  function apply(f, args)
    local _g119 = stash(args)
    return(f(unpack(_g119)))
  end
  local id_count = 0
  function make_id()
    id_count = (id_count + 1)
    return(("_g" .. id_count))
  end
  _g121 = {}
  exports.lib = _g121
  _g121.sub = sub
  _g121.extend = extend
  _g121.apply = apply
  _g121["special?"] = special63
  _g121["%bind"] = _37bind
  _g121.splice = splice
  _g121["string?"] = string63
  _g121["make-id"] = make_id
  _g121.unstash = unstash
  _g121.exclude = exclude
  _g121.reverse = reverse
  _g121["bound?"] = bound63
  _g121["function?"] = function63
  _g121.pairwise = pairwise
  _g121["<="] = _6061
  _g121["read-file"] = read_file
  _g121[">="] = _6261
  _g121.iterate = iterate
  _g121.getenv = getenv
  _g121["is?"] = is63
  _g121.replicate = replicate
  _g121.drop = drop
  _g121.search = search
  _g121.last = last
  _g121["nil?"] = nil63
  _g121.keep = keep
  _g121["%message-handler"] = _37message_handler
  _g121.tl = tl
  _g121["cat"] = cat
  _g121["+"] = _43
  _g121["empty?"] = empty63
  _g121["-"] = _
  _g121.substring = substring
  _g121["map*"] = map42
  _g121.inner = inner
  _g121.setenv = setenv
  _g121["*"] = _42
  _g121["parse-number"] = parse_number
  _g121.length = length
  _g121.sublist = sublist
  _g121["/"] = _47
  _g121.mapo = mapo
  _g121.code = code
  _g121.char = char
  _g121["<"] = _60
  _g121["="] = _61
  _g121[">"] = _62
  _g121["atom?"] = atom63
  _g121.quoted = quoted
  _g121.add = add
  _g121["write-file"] = write_file
  _g121.map = map
  _g121.quasiexpand = quasiexpand
  _g121["keys?"] = keys63
  _g121.write = write
  _g121["stash*"] = stash42
  _g121["to-string"] = to_string
  _g121.print = print
  _g121.target = target
  _g121["string-literal?"] = string_literal63
  _g121["list?"] = list63
  _g121.exit = exit
  _g121["table?"] = table63
  _g121["number?"] = number63
  _g121["composite?"] = composite63
  _g121.macroexpand = macroexpand
  _g121["special-form?"] = special_form63
  _g121.hd = hd
  _g121["%bind*"] = _37bind42
  _g121["boolean?"] = boolean63
  _g121.join = join
  _g121.split = split
  _g121["id-literal?"] = id_literal63
  _g121.reduce = reduce
  _g121.type = type
  _g121["%"] = _37
  _g121.mapt = mapt
  _g121.find = find
end)();
(function ()
  local delimiters = {["("] = true, [")"] = true, [";"] = true, ["\n"] = true}
  local whitespace = {[" "] = true, ["\t"] = true, ["\n"] = true}
  function make_stream(str)
    return({pos = 0, string = str, len = length(str)})
  end
  local function peek_char(s)
    if (s.pos < s.len) then
      return(char(s.string, s.pos))
    end
  end
  local function read_char(s)
    local c = peek_char(s)
    if c then
      s.pos = (s.pos + 1)
      return(c)
    end
  end
  local function skip_non_code(s)
    while true do
      local c = peek_char(s)
      if nil63(c) then
        break
      elseif whitespace[c] then
        read_char(s)
      elseif (c == ";") then
        while (c and (not (c == "\n"))) do
          c = read_char(s)
        end
        skip_non_code(s)
      else
        break
      end
    end
  end
  read_table = {}
  local eof = {}
  local function key63(atom)
    return((string63(atom) and (length(atom) > 1) and (char(atom, (length(atom) - 1)) == ":")))
  end
  local function flag63(atom)
    return((string63(atom) and (length(atom) > 1) and (char(atom, 0) == ":")))
  end
  read_table[""] = function (s)
    local str = ""
    local dot63 = false
    while true do
      local c = peek_char(s)
      if (c and ((not whitespace[c]) and (not delimiters[c]))) then
        if (c == ".") then
          dot63 = true
        end
        str = (str .. c)
        read_char(s)
      else
        break
      end
    end
    local n = parse_number(str)
    if is63(n) then
      return(n)
    elseif (str == "true") then
      return(true)
    elseif (str == "false") then
      return(false)
    elseif (str == "_") then
      return(make_id())
    elseif dot63 then
      return(reduce(function (a, b)
        return({"get", b, {"quote", a}})
      end, reverse(split(str, "."))))
    else
      return(str)
    end
  end
  read_table["("] = function (s)
    read_char(s)
    local l = {}
    while true do
      skip_non_code(s)
      local c = peek_char(s)
      if (c and (not (c == ")"))) then
        local x = read(s)
        if key63(x) then
          local k = sub(x, 0, (length(x) - 1))
          local v = read(s)
          l[k] = v
        elseif flag63(x) then
          l[sub(x, 1)] = true
        else
          add(l, x)
        end
      elseif c then
        read_char(s)
        break
      else
        error(("Expected ) at " .. s.pos))
      end
    end
    return(l)
  end
  read_table[")"] = function (s)
    error(("Unexpected ) at " .. s.pos))
  end
  read_table["\""] = function (s)
    read_char(s)
    local str = "\""
    while true do
      local c = peek_char(s)
      if (c and (not (c == "\""))) then
        if (c == "\\") then
          str = (str .. read_char(s))
        end
        str = (str .. read_char(s))
      elseif c then
        read_char(s)
        break
      else
        error(("Expected \" at " .. s.pos))
      end
    end
    return((str .. "\""))
  end
  read_table["|"] = function (s)
    read_char(s)
    local str = "|"
    while true do
      local c = peek_char(s)
      if (c and (not (c == "|"))) then
        str = (str .. read_char(s))
      elseif c then
        read_char(s)
        break
      else
        error(("Expected | at " .. s.pos))
      end
    end
    return((str .. "|"))
  end
  read_table["'"] = function (s)
    read_char(s)
    return({"quote", read(s)})
  end
  read_table["`"] = function (s)
    read_char(s)
    return({"quasiquote", read(s)})
  end
  read_table[","] = function (s)
    read_char(s)
    if (peek_char(s) == "@") then
      read_char(s)
      return({"unquote-splicing", read(s)})
    else
      return({"unquote", read(s)})
    end
  end
  function read(s)
    skip_non_code(s)
    local c = peek_char(s)
    if is63(c) then
      return(((read_table[c] or read_table[""]))(s))
    else
      return(eof)
    end
  end
  function read_all(s)
    local l = {}
    while true do
      local form = read(s)
      if (form == eof) then
        break
      end
      add(l, form)
    end
    return(l)
  end
  function read_from_string(str)
    return(read(make_stream(str)))
  end
  _g125 = {}
  exports.reader = _g125
  _g125["make-stream"] = make_stream
  _g125["read-table"] = read_table
  _g125.read = read
  _g125["read-all"] = read_all
  _g125["read-from-string"] = read_from_string
end)();
(function ()
  local infix = {common = {["+"] = true, ["-"] = true, ["%"] = true, ["*"] = true, ["/"] = true, ["<"] = true, [">"] = true, ["<="] = true, [">="] = true}, js = {["="] = "===", ["~="] = "!=", ["and"] = "&&", ["or"] = "||", ["cat"] = "+"}, lua = {["="] = "==", ["cat"] = "..", ["~="] = true, ["and"] = true, ["or"] = true}}
  local function getop(op)
    local op1 = (infix.common[op] or infix[target][op])
    if (op1 == true) then
      return(op)
    else
      return(op1)
    end
  end
  local function infix63(form)
    return((list63(form) and is63(getop(hd(form)))))
  end
  local function numeric63(n)
    return(((n > 47) and (n < 58)))
  end
  local function valid_char63(n)
    return((numeric63(n) or ((n > 64) and (n < 91)) or ((n > 96) and (n < 123)) or (n == 95)))
  end
  function valid_id63(id)
    if empty63(id) then
      return(false)
    elseif special63(id) then
      return(false)
    elseif getop(id) then
      return(false)
    else
      local i = 0
      while (i < length(id)) do
        local n = code(id, i)
        local valid63 = valid_char63(n)
        if ((not valid63) or ((i == 0) and numeric63(n))) then
          return(false)
        end
        i = (i + 1)
      end
      return(true)
    end
  end
  local function compile_id(id)
    local id1 = ""
    local i = 0
    while (i < length(id)) do
      local c = char(id, i)
      local n = code(c)
      local c1 = (function ()
        if (c == "-") then
          return("_")
        elseif valid_char63(n) then
          return(c)
        elseif (i == 0) then
          return(("_" .. n))
        else
          return(n)
        end
      end)()
      id1 = (id1 .. c1)
      i = (i + 1)
    end
    return(id1)
  end
  local function compile_args(args)
    local str = "("
    local i = 0
    local _g126 = args
    while (i < length(_g126)) do
      local arg = _g126[(i + 1)]
      str = (str .. compile(arg))
      if (i < (length(args) - 1)) then
        str = (str .. ", ")
      end
      i = (i + 1)
    end
    return((str .. ")"))
  end
  local function compile_atom(x)
    if ((x == "nil") and (target == "lua")) then
      return(x)
    elseif (x == "nil") then
      return("undefined")
    elseif id_literal63(x) then
      return(inner(x))
    elseif string_literal63(x) then
      return(x)
    elseif string63(x) then
      return(compile_id(x))
    elseif boolean63(x) then
      if x then
        return("true")
      else
        return("false")
      end
    elseif number63(x) then
      return((x .. ""))
    else
      error("Unrecognized atom")
    end
  end
  function compile_body(forms, ...)
    local _g127 = unstash({...})
    local tail63 = _g127["tail?"]
    local str = ""
    local i = 0
    local _g128 = forms
    while (i < length(_g128)) do
      local x = _g128[(i + 1)]
      local t63 = (tail63 and (i == (length(forms) - 1)))
      str = (str .. compile(x, {_stash = true, ["stmt?"] = true, ["tail?"] = t63}))
      i = (i + 1)
    end
    return(str)
  end
  function compile_call(form)
    if empty63(form) then
      return(compile_special({"%array"}))
    else
      local f = hd(form)
      local f1 = compile(f)
      local args = compile_args(stash42(tl(form)))
      if list63(f) then
        return(("(" .. f1 .. ")" .. args))
      elseif string63(f) then
        return((f1 .. args))
      else
        error("Invalid function call")
      end
    end
  end
  local function compile_infix(_g129)
    local op = _g129[1]
    local args = sub(_g129, 1)
    local str = "("
    local op = getop(op)
    local i = 0
    local _g130 = args
    while (i < length(_g130)) do
      local arg = _g130[(i + 1)]
      if ((op == "-") and (length(args) == 1)) then
        str = (str .. op .. compile(arg))
      else
        str = (str .. compile(arg))
        if (i < (length(args) - 1)) then
          str = (str .. " " .. op .. " ")
        end
      end
      i = (i + 1)
    end
    return((str .. ")"))
  end
  function compile_branch(condition, body, first63, last63, tail63)
    local cond1 = compile(condition)
    local _g131 = (function ()
      indent_level = (indent_level + 1)
      local _g132 = compile(body, {_stash = true, ["stmt?"] = true, ["tail?"] = tail63})
      indent_level = (indent_level - 1)
      return(_g132)
    end)()
    local ind = indentation()
    local tr = (function ()
      if (last63 and (target == "lua")) then
        return((ind .. "end\n"))
      elseif last63 then
        return("\n")
      else
        return("")
      end
    end)()
    if (first63 and (target == "js")) then
      return((ind .. "if (" .. cond1 .. ") {\n" .. _g131 .. ind .. "}" .. tr))
    elseif first63 then
      return((ind .. "if " .. cond1 .. " then\n" .. _g131 .. tr))
    elseif (nil63(condition) and (target == "js")) then
      return((" else {\n" .. _g131 .. ind .. "}\n"))
    elseif nil63(condition) then
      return((ind .. "else\n" .. _g131 .. tr))
    elseif (target == "js") then
      return((" else if (" .. cond1 .. ") {\n" .. _g131 .. ind .. "}" .. tr))
    else
      return((ind .. "elseif " .. cond1 .. " then\n" .. _g131 .. tr))
    end
  end
  function compile_function(args, body, ...)
    local _g133 = unstash({...})
    local name = _g133.name
    local prefix = _g133.prefix
    local id = (function ()
      if name then
        return(compile(name))
      else
        return("")
      end
    end)()
    local prefix = (prefix or "")
    local args = compile_args(args)
    local body = (function ()
      indent_level = (indent_level + 1)
      local _g134 = compile_body(body, {_stash = true, ["tail?"] = true})
      indent_level = (indent_level - 1)
      return(_g134)
    end)()
    local ind = indentation()
    local tr = (function ()
      if name then
        return("end\n")
      else
        return("end")
      end
    end)()
    if (target == "js") then
      return(("function " .. id .. args .. " {\n" .. body .. ind .. "}"))
    else
      return((prefix .. "function " .. id .. args .. "\n" .. body .. ind .. tr))
    end
  end
  local function terminator(stmt63)
    if (not stmt63) then
      return("")
    elseif (target == "js") then
      return(";\n")
    else
      return("\n")
    end
  end
  function compile_special(form, stmt63, tail63)
    local _g135 = getenv(hd(form))
    local special = _g135.special
    local stmt = _g135.stmt
    local self_tr63 = _g135.tr
    if ((not stmt63) and stmt) then
      return(compile({{"%function", {}, form}}, {_stash = true, ["tail?"] = tail63}))
    else
      local tr = terminator((stmt63 and (not self_tr63)))
      return((special(tl(form), tail63) .. tr))
    end
  end
  local function can_return63(form)
    return(((not special_form63(form)) or (not getenv(hd(form)).stmt)))
  end
  function compile(form, ...)
    local _g136 = unstash({...})
    local stmt63 = _g136["stmt?"]
    local tail63 = _g136["tail?"]
    if (tail63 and can_return63(form)) then
      form = {"return", form}
    end
    if nil63(form) then
      return("")
    elseif special_form63(form) then
      return(compile_special(form, stmt63, tail63))
    else
      local tr = terminator(stmt63)
      local ind = (function ()
        if stmt63 then
          return(indentation())
        else
          return("")
        end
      end)()
      local form = (function ()
        if atom63(form) then
          return(compile_atom(form))
        elseif infix63(form) then
          return(compile_infix(form))
        else
          return(compile_call(form))
        end
      end)()
      return((ind .. form .. tr))
    end
  end
  function compile_toplevel(form)
    return(compile(macroexpand(form), {_stash = true, ["stmt?"] = true}))
  end
  local function encapsulate(body)
    local form = join({"do"}, join(body, {{"%export"}}))
    return({{"%function", {}, macroexpand(form)}})
  end
  function compile_file(file)
    local str = read_file(file)
    local body = read_all(make_stream(str))
    local form = encapsulate(body)
    return((compile(form) .. ";\n"))
  end
  local compiler_output = nil
  local compilation_level = nil
  _37result = nil
  local function run(x)
    local f = load((compile("%result") .. "=" .. x))
    if f then
      f()
      return(_37result)
    else
      local f,e = load(x)
      if f then
        return(f())
      else
        error((e .. " in " .. x))
      end
    end
  end
  function eval(form)
    local previous = target
    target = "lua"
    local str = compile(macroexpand(form))
    target = previous
    return(run(str))
  end
  current_module = nil
  function module_key(spec)
    if atom63(spec) then
      return(to_string(spec))
    else
      error("Unsupported module specification")
    end
  end
  local function module(spec)
    return(modules[module_key(spec)])
  end
  local function module_path(spec)
    return((module_key(spec) .. ".l"))
  end
  function compile_module(spec)
    compilation_level = 0
    compiler_output = ""
    load_module(spec)
    return(compiler_output)
  end
  local function _37compile_module(spec)
    local path = module_path(spec)
    local mod0 = current_module
    local env0 = environment
    local k = module_key(spec)
    if number63(compilation_level) then
      compilation_level = (compilation_level + 1)
    end
    current_module = spec
    environment = initial_environment()
    local compiled = compile_file(path)
    local m = module(spec)
    local toplevel = hd(environment)
    current_module = mod0
    environment = env0
    local name = nil
    local _g144 = toplevel
    for name in next, _g144 do
      if (not number63(name)) then
        local binding = _g144[name]
        if (binding.export and (binding.module == k)) then
          m.export[name] = binding
        end
      end
    end
    if number63(compilation_level) then
      compilation_level = (compilation_level - 1)
      compiler_output = (compiler_output .. compiled)
    else
      return(run(compiled))
    end
  end
  function load_module(spec)
    if (nil63(module(spec)) or (compilation_level == 1)) then
      _37compile_module(spec)
    end
    return(open_module(spec))
  end
  function open_module(spec)
    local m = module(spec)
    local frame = last(environment)
    local k = nil
    local _g145 = m.export
    for k in next, _g145 do
      if (not number63(k)) then
        local v = _g145[k]
        frame[k] = v
      end
    end
  end
  function in_module(spec)
    load_module(spec)
    local m = module(spec)
    return(map(open_module, m.import))
  end
  _g146 = {}
  exports.compiler = _g146
  _g146["valid-id?"] = valid_id63
  _g146["compile-body"] = compile_body
  _g146["compile-call"] = compile_call
  _g146["compile-branch"] = compile_branch
  _g146["compile-function"] = compile_function
  _g146["compile-special"] = compile_special
  _g146.compile = compile
  _g146["compile-toplevel"] = compile_toplevel
  _g146["compiler-output"] = compiler_output
  _g146.eval = eval
  _g146["module-key"] = module_key
  _g146["compile-module"] = compile_module
  _g146["load-module"] = load_module
  _g146["open-module"] = open_module
  _g146["in-module"] = in_module
end)();
(function ()
  indent_level = 0
  function indentation()
    return(apply(cat, replicate(indent_level, "  ")))
  end
  local function quote_binding(b)
    b = extend(b, {_stash = true, module = {"quote", b.module}})
    if is63(b.symbol) then
      return(extend(b, {_stash = true, symbol = {"quote", b.symbol}}))
    elseif (b.macro and b.form) then
      return(exclude(extend(b, {_stash = true, macro = b.form}), {_stash = true, form = true}))
    elseif (b.special and b.form) then
      return(exclude(extend(b, {_stash = true, special = b.form}), {_stash = true, form = true}))
    elseif is63(b.variable) then
      return(b)
    end
  end
  local function quote_frame(t)
    return(join({"%object"}, mapo(function (_g147, b)
      return(join({"table"}, quote_binding(b)))
    end, t)))
  end
  function quote_environment(env)
    return(join({"list"}, map(quote_frame, env)))
  end
  local function quote_module(m)
    local _g148 = {"table"}
    _g148.import = quoted(m.import)
    _g148.export = quote_frame(m.export)
    return(_g148)
  end
  function quote_modules()
    return(join({"table"}, map42(quote_module, modules)))
  end
  function initial_environment()
    return({{["define-module"] = getenv("define-module")}})
  end
  _g149 = {}
  exports.utilities = _g149
  _g149["indent-level"] = indent_level
  _g149.indentation = indentation
  _g149["quote-environment"] = quote_environment
  _g149["quote-modules"] = quote_modules
  _g149["initial-environment"] = initial_environment
end)();
(function ()
  _g194 = {}
  exports.special = _g194
end)();
(function ()
  modules = {utilities = {export = {["indent-level"] = {export = true, module = "utilities", variable = true}, indentation = {export = true, module = "utilities", variable = true}, ["with-indent"] = {export = true, module = "utilities", macro = function (form)
    local result = make_id()
    return({"do", {"inc", "indent-level"}, {"let", {result, form}, {"dec", "indent-level"}, result}})
  end}, ["quote-environment"] = {export = true, module = "utilities", variable = true}, ["quote-modules"] = {export = true, module = "utilities", variable = true}, ["initial-environment"] = {export = true, module = "utilities", variable = true}}, import = {"lib", "special"}}, reader = {export = {["make-stream"] = {export = true, module = "reader", variable = true}, ["read-table"] = {export = true, module = "reader", variable = true}, ["define-reader"] = {export = true, module = "reader", macro = function (_g195, ...)
    local char = _g195[1]
    local stream = _g195[2]
    local body = unstash({...})
    local _g196 = sub(body, 0)
    return({"set", {"get", "read-table", char}, join({"fn", {stream}}, _g196)})
  end}, read = {export = true, module = "reader", variable = true}, ["read-all"] = {export = true, module = "reader", variable = true}, ["read-from-string"] = {export = true, module = "reader", variable = true}}, import = {"lib", "special"}}, special = {export = {["%function"] = {export = true, special = function (_g197)
    local args = _g197[1]
    local body = sub(_g197, 1)
    return(compile_function(args, body))
  end, module = "special"}, ["while"] = {export = true, stmt = true, special = function (_g198)
    local condition = _g198[1]
    local body = sub(_g198, 1)
    local condition = compile(condition)
    local body = (function ()
      indent_level = (indent_level + 1)
      local _g199 = compile_body(body)
      indent_level = (indent_level - 1)
      return(_g199)
    end)()
    local ind = indentation()
    if (target == "js") then
      return((ind .. "while (" .. condition .. ") {\n" .. body .. ind .. "}\n"))
    else
      return((ind .. "while " .. condition .. " do\n" .. body .. ind .. "end\n"))
    end
  end, tr = true, module = "special"}, ["if"] = {export = true, stmt = true, special = function (form, tail63)
    local str = ""
    local i = 0
    local _g200 = form
    while (i < length(_g200)) do
      local condition = _g200[(i + 1)]
      local last63 = (i >= (length(form) - 2))
      local else63 = (i == (length(form) - 1))
      local first63 = (i == 0)
      local body = form[((i + 1) + 1)]
      if else63 then
        body = condition
        condition = nil
      end
      str = (str .. compile_branch(condition, body, first63, last63, tail63))
      i = (i + 1)
      i = (i + 1)
    end
    return(str)
  end, tr = true, module = "special"}, ["return"] = {export = true, module = "special", special = function (_g201)
    local x = _g201[1]
    local x = (function ()
      if nil63(x) then
        return("return")
      else
        return(compile_call({"return", x}))
      end
    end)()
    return((indentation() .. x))
  end, stmt = true}, ["%for"] = {export = true, stmt = true, special = function (_g202)
    local _g203 = _g202[1]
    local t = _g203[1]
    local k = _g203[2]
    local body = sub(_g202, 1)
    local t = compile(t)
    local ind = indentation()
    local body = (function ()
      indent_level = (indent_level + 1)
      local _g204 = compile_body(body)
      indent_level = (indent_level - 1)
      return(_g204)
    end)()
    if (target == "lua") then
      return((ind .. "for " .. k .. " in next, " .. t .. " do\n" .. body .. ind .. "end\n"))
    else
      return((ind .. "for (" .. k .. " in " .. t .. ") {\n" .. body .. ind .. "}\n"))
    end
  end, tr = true, module = "special"}, ["%try"] = {export = true, stmt = true, special = function (forms)
    local ind = indentation()
    local body = (function ()
      indent_level = (indent_level + 1)
      local _g205 = compile_body(forms, {_stash = true, ["tail?"] = true})
      indent_level = (indent_level - 1)
      return(_g205)
    end)()
    local e = make_id()
    local handler = {"return", {"%array", false, e}}
    local h = (function ()
      indent_level = (indent_level + 1)
      local _g206 = compile(handler, {_stash = true, ["stmt?"] = true})
      indent_level = (indent_level - 1)
      return(_g206)
    end)()
    return((ind .. "try {\n" .. body .. ind .. "}\n" .. ind .. "catch (" .. e .. ") {\n" .. h .. ind .. "}\n"))
  end, tr = true, module = "special"}, ["set"] = {export = true, module = "special", special = function (_g207)
    local lh = _g207[1]
    local rh = _g207[2]
    if nil63(rh) then
      error("Missing right-hand side in assignment")
    end
    return((indentation() .. compile(lh) .. " = " .. compile(rh)))
  end, stmt = true}, ["%global-function"] = {export = true, stmt = true, special = function (_g208)
    local name = _g208[1]
    local args = _g208[2]
    local body = sub(_g208, 2)
    if (target == "lua") then
      local x = compile_function(args, body, {_stash = true, name = name})
      return((indentation() .. x))
    else
      return(compile({"set", name, join({"%function", args}, body)}, {_stash = true, ["stmt?"] = true}))
    end
  end, tr = true, module = "special"}, ["break"] = {export = true, module = "special", special = function (_g150)
    return((indentation() .. "break"))
  end, stmt = true}, ["error"] = {export = true, module = "special", special = function (_g209)
    local x = _g209[1]
    local e = (function ()
      if (target == "js") then
        return(("throw " .. compile(x)))
      else
        return(compile_call({"error", x}))
      end
    end)()
    return((indentation() .. e))
  end, stmt = true}, ["%local"] = {export = true, module = "special", special = function (_g210)
    local name = _g210[1]
    local value = _g210[2]
    local id = compile(name)
    local value = compile(value)
    local keyword = (function ()
      if (target == "js") then
        return("var ")
      else
        return("local ")
      end
    end)()
    local ind = indentation()
    return((ind .. keyword .. id .. " = " .. value))
  end, stmt = true}, ["get"] = {export = true, special = function (_g211)
    local t = _g211[1]
    local k = _g211[2]
    local t = compile(t)
    local k1 = compile(k)
    if ((target == "lua") and (char(t, 0) == "{")) then
      t = ("(" .. t .. ")")
    end
    if (string_literal63(k) and valid_id63(inner(k))) then
      return((t .. "." .. inner(k)))
    else
      return((t .. "[" .. k1 .. "]"))
    end
  end, module = "special"}, ["%local-function"] = {export = true, stmt = true, special = function (_g212)
    local name = _g212[1]
    local args = _g212[2]
    local body = sub(_g212, 2)
    local x = compile_function(args, body, {_stash = true, name = name, prefix = "local "})
    return((indentation() .. x))
  end, tr = true, module = "special"}, ["do"] = {export = true, stmt = true, special = function (forms, tail63)
    return(compile_body(forms, {_stash = true, ["tail?"] = tail63}))
  end, tr = true, module = "special"}, ["%object"] = {export = true, special = function (forms)
    local str = "{"
    local sep = (function ()
      if (target == "lua") then
        return(" = ")
      else
        return(": ")
      end
    end)()
    local pairs = pairwise(forms)
    local i = 0
    local _g213 = pairs
    while (i < length(_g213)) do
      local _g214 = _g213[(i + 1)]
      local k = _g214[1]
      local v = _g214[2]
      if (not string63(k)) then
        error(("Illegal key: " .. to_string(k)))
      end
      local v = compile(v)
      local k = (function ()
        if valid_id63(k) then
          return(k)
        elseif ((target == "js") and string_literal63(k)) then
          return(k)
        elseif (target == "js") then
          return(quoted(k))
        elseif string_literal63(k) then
          return(("[" .. k .. "]"))
        else
          return(("[" .. quoted(k) .. "]"))
        end
      end)()
      str = (str .. k .. sep .. v)
      if (i < (length(pairs) - 1)) then
        str = (str .. ", ")
      end
      i = (i + 1)
    end
    return((str .. "}"))
  end, module = "special"}, ["not"] = {export = true, special = function (_g215)
    local x = _g215[1]
    local x = compile(x)
    local open = (function ()
      if (target == "js") then
        return("!(")
      else
        return("(not ")
      end
    end)()
    return((open .. x .. ")"))
  end, module = "special"}, ["%array"] = {export = true, special = function (forms)
    local open = (function ()
      if (target == "lua") then
        return("{")
      else
        return("[")
      end
    end)()
    local close = (function ()
      if (target == "lua") then
        return("}")
      else
        return("]")
      end
    end)()
    local str = ""
    local i = 0
    local _g216 = forms
    while (i < length(_g216)) do
      local x = _g216[(i + 1)]
      str = (str .. compile(x))
      if (i < (length(forms) - 1)) then
        str = (str .. ", ")
      end
      i = (i + 1)
    end
    return((open .. str .. close))
  end, module = "special"}}, import = {"lib", "compiler", "special", "utilities"}}, lib = {export = {table = {export = true, macro = function (...)
    local body = unstash({...})
    return(join({"%object"}, mapo(function (_g2, x)
      return(x)
    end, body)))
  end, module = "lib"}, sub = {export = true, variable = true, module = "lib"}, extend = {export = true, variable = true, module = "lib"}, apply = {export = true, variable = true, module = "lib"}, ["special?"] = {export = true, variable = true, module = "lib"}, ["define-global"] = {export = true, macro = function (name, x, ...)
    local body = unstash({...})
    local _g217 = sub(body, 0)
    setenv(name, {_stash = true, variable = true})
    if (not empty63(_g217)) then
      local _g218 = _37bind42(x, _g217)
      local args = _g218[1]
      local _g219 = _g218[2]
      return(join({"%global-function", name, args}, _g219))
    else
      return({"set", name, x})
    end
  end, module = "lib"}, ["%bind"] = {export = true, variable = true, module = "lib"}, splice = {export = true, variable = true, module = "lib"}, quote = {export = true, macro = function (form)
    return(quoted(form))
  end, module = "lib"}, ["string?"] = {export = true, variable = true, module = "lib"}, ["make-id"] = {export = true, variable = true, module = "lib"}, language = {export = true, macro = function ()
    return({"quote", target})
  end, module = "lib"}, quasiquote = {export = true, macro = function (form)
    return(quasiexpand(form, 1))
  end, module = "lib"}, let = {export = true, macro = function (bindings, ...)
    local body = unstash({...})
    local _g220 = sub(body, 0)
    local i = 0
    local renames = {}
    local locals = {}
    map(function (_g221)
      local lh = _g221[1]
      local rh = _g221[2]
      local _g223 = 0
      local _g222 = _37bind(lh, rh)
      while (_g223 < length(_g222)) do
        local _g224 = _g222[(_g223 + 1)]
        local id = _g224[1]
        local val = _g224[2]
        if bound63(id) then
          local rename = make_id()
          add(renames, id)
          add(renames, rename)
          id = rename
        else
          setenv(id, {_stash = true, variable = true})
        end
        add(locals, {"%local", id, val})
        _g223 = (_g223 + 1)
      end
    end, pairwise(bindings))
    return(join({"do"}, join(locals, {join({"let-symbol", renames}, _g220)})))
  end, module = "lib"}, unstash = {export = true, variable = true, module = "lib"}, exclude = {export = true, variable = true, module = "lib"}, ["set-of"] = {export = true, macro = function (...)
    local elements = unstash({...})
    local l = {}
    local _g226 = 0
    local _g225 = elements
    while (_g226 < length(_g225)) do
      local e = _g225[(_g226 + 1)]
      l[e] = true
      _g226 = (_g226 + 1)
    end
    return(join({"table"}, l))
  end, module = "lib"}, reverse = {export = true, variable = true, module = "lib"}, ["bound?"] = {export = true, variable = true, module = "lib"}, list = {export = true, macro = function (...)
    local body = unstash({...})
    local l = join({"%array"}, body)
    if (not keys63(body)) then
      return(l)
    else
      local id = make_id()
      local init = {}
      local k = nil
      local _g227 = body
      for k in next, _g227 do
        if (not number63(k)) then
          local v = _g227[k]
          add(init, {"set", {"get", id, {"quote", k}}, v})
        end
      end
      return(join({"let", {id, l}}, join(init, {id})))
    end
  end, module = "lib"}, at = {export = true, macro = function (l, i)
    if ((target == "lua") and number63(i)) then
      i = (i + 1)
    elseif (target == "lua") then
      i = {"+", i, 1}
    end
    return({"get", l, i})
  end, module = "lib"}, ["list*"] = {export = true, macro = function (...)
    local xs = unstash({...})
    if empty63(xs) then
      return({})
    else
      local l = {}
      local i = 0
      local _g228 = xs
      while (i < length(_g228)) do
        local x = _g228[(i + 1)]
        if (i == (length(xs) - 1)) then
          l = {"join", join({"list"}, l), x}
        else
          add(l, x)
        end
        i = (i + 1)
      end
      return(l)
    end
  end, module = "lib"}, dec = {export = true, macro = function (n, by)
    return({"set", n, {"-", n, (by or 1)}})
  end, module = "lib"}, ["function?"] = {export = true, variable = true, module = "lib"}, pairwise = {export = true, variable = true, module = "lib"}, ["<="] = {export = true, variable = true, module = "lib"}, ["read-file"] = {export = true, variable = true, module = "lib"}, [">="] = {export = true, variable = true, module = "lib"}, ["define-local"] = {export = true, macro = function (name, x, ...)
    local body = unstash({...})
    local _g229 = sub(body, 0)
    setenv(name, {_stash = true, variable = true})
    if (not empty63(_g229)) then
      local _g230 = _37bind42(x, _g229)
      local args = _g230[1]
      local _g231 = _g230[2]
      return(join({"%local-function", name, args}, _g231))
    else
      return({"%local", name, x})
    end
  end, module = "lib"}, iterate = {export = true, variable = true, module = "lib"}, getenv = {export = true, variable = true, module = "lib"}, ["is?"] = {export = true, variable = true, module = "lib"}, ["let-symbol"] = {export = true, macro = function (expansions, ...)
    local body = unstash({...})
    local _g232 = sub(body, 0)
    add(environment, {})
    local _g233 = (function ()
      map(function (_g234)
        local name = _g234[1]
        local exp = _g234[2]
        return(macroexpand({"define-symbol", name, exp}))
      end, pairwise(expansions))
      return(join({"do"}, macroexpand(_g232)))
    end)()
    drop(environment)
    return(_g233)
  end, module = "lib"}, ["with-frame"] = {export = true, macro = function (...)
    local body = unstash({...})
    local x = make_id()
    return({"do", {"add", "environment", {"table"}}, {"let", {x, join({"do"}, body)}, {"drop", "environment"}, x}})
  end, module = "lib"}, replicate = {export = true, variable = true, module = "lib"}, drop = {export = true, variable = true, module = "lib"}, search = {export = true, variable = true, module = "lib"}, last = {export = true, variable = true, module = "lib"}, ["nil?"] = {export = true, variable = true, module = "lib"}, ["cat!"] = {export = true, macro = function (a, ...)
    local bs = unstash({...})
    local _g235 = sub(bs, 0)
    return({"set", a, join({"cat", a}, _g235)})
  end, module = "lib"}, keep = {export = true, variable = true, module = "lib"}, ["%message-handler"] = {export = true, variable = true, module = "lib"}, tl = {export = true, variable = true, module = "lib"}, ["cat"] = {export = true, variable = true, module = "lib"}, ["+"] = {export = true, variable = true, module = "lib"}, ["empty?"] = {export = true, variable = true, module = "lib"}, ["-"] = {export = true, variable = true, module = "lib"}, substring = {export = true, variable = true, module = "lib"}, ["map*"] = {export = true, variable = true, module = "lib"}, inner = {export = true, variable = true, module = "lib"}, setenv = {export = true, variable = true, module = "lib"}, ["*"] = {export = true, variable = true, module = "lib"}, inc = {export = true, macro = function (n, by)
    return({"set", n, {"+", n, (by or 1)}})
  end, module = "lib"}, ["parse-number"] = {export = true, variable = true, module = "lib"}, length = {export = true, variable = true, module = "lib"}, sublist = {export = true, variable = true, module = "lib"}, ["/"] = {export = true, variable = true, module = "lib"}, across = {export = true, macro = function (_g236, ...)
    local l = _g236[1]
    local v = _g236[2]
    local i = _g236[3]
    local start = _g236[4]
    local body = unstash({...})
    local _g237 = sub(body, 0)
    local l1 = make_id()
    i = (i or make_id())
    start = (start or 0)
    return({"let", {i, start, l1, l}, {"while", {"<", i, {"length", l1}}, join({"let", {v, {"at", l1, i}}}, join(_g237, {{"inc", i}}))}})
  end, module = "lib"}, mapo = {export = true, variable = true, module = "lib"}, code = {export = true, variable = true, module = "lib"}, char = {export = true, variable = true, module = "lib"}, ["<"] = {export = true, variable = true, module = "lib"}, ["="] = {export = true, variable = true, module = "lib"}, [">"] = {export = true, variable = true, module = "lib"}, ["atom?"] = {export = true, variable = true, module = "lib"}, quoted = {export = true, variable = true, module = "lib"}, add = {export = true, variable = true, module = "lib"}, ["define-macro"] = {export = true, macro = function (name, args, ...)
    local body = unstash({...})
    local _g238 = sub(body, 0)
    local form = join({"fn", args}, _g238)
    eval((function ()
      local _g239 = {"setenv", {"quote", name}}
      _g239.macro = form
      _g239.form = {"quote", form}
      return(_g239)
    end)())
    return(nil)
  end, module = "lib"}, ["write-file"] = {export = true, variable = true, module = "lib"}, map = {export = true, variable = true, module = "lib"}, quasiexpand = {export = true, variable = true, module = "lib"}, ["let-macro"] = {export = true, macro = function (definitions, ...)
    local body = unstash({...})
    local _g240 = sub(body, 0)
    add(environment, {})
    local _g241 = (function ()
      map(function (m)
        return(macroexpand(join({"define-macro"}, m)))
      end, definitions)
      return(join({"do"}, macroexpand(_g240)))
    end)()
    drop(environment)
    return(_g241)
  end, module = "lib"}, ["%export"] = {export = true, macro = function ()
    local toplevel = hd(environment)
    local m = make_id()
    local k = module_key(current_module)
    local form = {"do", {"define", m, {"table"}}, {"set", {"get", "exports", {"quote", k}}, m}}
    local k = nil
    local _g242 = toplevel
    for k in next, _g242 do
      if (not number63(k)) then
        local v = _g242[k]
        if (v.variable and v.export and (v.module == current_module)) then
          add(form, {"set", {"get", m, {"quote", k}}, k})
        end
      end
    end
    return(form)
  end, module = "lib"}, ["keys?"] = {export = true, variable = true, module = "lib"}, write = {export = true, variable = true, module = "lib"}, ["stash*"] = {export = true, variable = true, module = "lib"}, ["to-string"] = {export = true, variable = true, module = "lib"}, print = {export = true, variable = true, module = "lib"}, target = {export = true, macro = function (...)
    local clauses = unstash({...})
    return(clauses[target])
  end, module = "lib", variable = true}, each = {export = true, macro = function (_g243, ...)
    local t = _g243[1]
    local k = _g243[2]
    local v = _g243[3]
    local body = unstash({...})
    local _g244 = sub(body, 0)
    local t1 = make_id()
    return({"let", {k, "nil", t1, t}, {"%for", {t1, k}, {"if", (function ()
      local _g245 = {"target"}
      _g245.js = {"isNaN", {"parseInt", k}}
      _g245.lua = {"not", {"number?", k}}
      return(_g245)
    end)(), join({"let", {v, {"get", t1, k}}}, _g244)}}})
  end, module = "lib"}, ["string-literal?"] = {export = true, variable = true, module = "lib"}, ["list?"] = {export = true, variable = true, module = "lib"}, exit = {export = true, variable = true, module = "lib"}, ["table?"] = {export = true, variable = true, module = "lib"}, ["number?"] = {export = true, variable = true, module = "lib"}, ["with-bindings"] = {export = true, macro = function (_g246, ...)
    local names = _g246[1]
    local body = unstash({...})
    local _g247 = sub(body, 0)
    local x = make_id()
    return(join({"with-frame", {"across", {names, x}, (function ()
      local _g248 = {"setenv", x}
      _g248.variable = true
      return(_g248)
    end)()}}, _g247))
  end, module = "lib"}, ["composite?"] = {export = true, variable = true, module = "lib"}, macroexpand = {export = true, variable = true, module = "lib"}, ["special-form?"] = {export = true, variable = true, module = "lib"}, guard = {export = true, macro = function (expr)
    if (target == "js") then
      return({{"fn", {}, {"%try", {"list", true, expr}}}})
    else
      local e = make_id()
      local x = make_id()
      local ex = ("|" .. e .. "," .. x .. "|")
      return({"let", {ex, {"xpcall", {"fn", {}, expr}, "%message-handler"}}, {"list", e, x}})
    end
  end, module = "lib"}, fn = {export = true, macro = function (args, ...)
    local body = unstash({...})
    local _g249 = sub(body, 0)
    local _g250 = _37bind42(args, _g249)
    local args = _g250[1]
    local _g251 = _g250[2]
    return(join({"%function", args}, _g251))
  end, module = "lib"}, hd = {export = true, variable = true, module = "lib"}, ["%bind*"] = {export = true, variable = true, module = "lib"}, ["boolean?"] = {export = true, variable = true, module = "lib"}, join = {export = true, variable = true, module = "lib"}, split = {export = true, variable = true, module = "lib"}, ["define-symbol"] = {export = true, macro = function (name, expansion)
    setenv(name, {_stash = true, symbol = expansion})
    return(nil)
  end, module = "lib"}, ["id-literal?"] = {export = true, variable = true, module = "lib"}, reduce = {export = true, variable = true, module = "lib"}, pr = {export = true, macro = function (...)
    local xs = unstash({...})
    local xs = map(function (x)
      return(splice({{"to-string", x}, "\" \""}))
    end, xs)
    return({"print", join({"cat"}, xs)})
  end, module = "lib"}, type = {export = true, variable = true, module = "lib"}, ["join!"] = {export = true, macro = function (a, ...)
    local bs = unstash({...})
    local _g252 = sub(bs, 0)
    return({"set", a, join({"join*", a}, _g252)})
  end, module = "lib"}, ["%"] = {export = true, variable = true, module = "lib"}, ["join*"] = {export = true, macro = function (...)
    local xs = unstash({...})
    return(reduce(function (a, b)
      return({"join", a, b})
    end, xs))
  end, module = "lib"}, define = {export = true, macro = function (name, x, ...)
    local body = unstash({...})
    local _g253 = sub(body, 0)
    setenv(name, {_stash = true, variable = true})
    return(join({"define-global", name, x}, _g253))
  end, module = "lib"}, mapt = {export = true, variable = true, module = "lib"}, ["define-special"] = {export = true, macro = function (name, args, ...)
    local body = unstash({...})
    local _g254 = sub(body, 0)
    local form = join({"fn", args}, _g254)
    local keys = sub(_g254, length(_g254))
    eval(join((function ()
      local _g255 = {"setenv", {"quote", name}}
      _g255.special = form
      _g255.form = {"quote", form}
      return(_g255)
    end)(), keys))
    return(nil)
  end, module = "lib"}, find = {export = true, variable = true, module = "lib"}}, import = {"lib", "special"}}, boot = {export = {}, import = {"lib", "special", "utilities"}}, compiler = {export = {["define-module"] = {export = true, macro = function (spec, ...)
    local body = unstash({...})
    local _g256 = sub(body, 0)
    local imp = _g256.import
    local exp = _g256.export
    map(load_module, imp)
    modules[module_key(spec)] = {import = imp, export = {}}
    local _g258 = 0
    local _g257 = (exp or {})
    while (_g258 < length(_g257)) do
      local k = _g257[(_g258 + 1)]
      setenv(k, {_stash = true, export = true})
      _g258 = (_g258 + 1)
    end
  end, module = "compiler"}, ["valid-id?"] = {export = true, module = "compiler", variable = true}, ["compile-body"] = {export = true, module = "compiler", variable = true}, ["compile-call"] = {export = true, module = "compiler", variable = true}, ["compile-branch"] = {export = true, module = "compiler", variable = true}, ["compile-function"] = {export = true, module = "compiler", variable = true}, ["compile-special"] = {export = true, module = "compiler", variable = true}, compile = {export = true, module = "compiler", variable = true}, ["compile-toplevel"] = {export = true, module = "compiler", variable = true}, ["compiler-output"] = {export = true, module = "compiler", variable = true}, eval = {export = true, module = "compiler", variable = true}, ["module-key"] = {export = true, module = "compiler", variable = true}, ["compile-module"] = {export = true, module = "compiler", variable = true}, ["load-module"] = {export = true, module = "compiler", variable = true}, ["open-module"] = {export = true, module = "compiler", variable = true}, ["in-module"] = {export = true, module = "compiler", variable = true}}, import = {"reader", "lib", "utilities", "special"}}}
  environment = {{["define-module"] = {export = true, macro = function (spec, ...)
    local body = unstash({...})
    local _g259 = sub(body, 0)
    local imp = _g259.import
    local exp = _g259.export
    map(load_module, imp)
    modules[module_key(spec)] = {import = imp, export = {}}
    local _g261 = 0
    local _g260 = (exp or {})
    while (_g261 < length(_g260)) do
      local k = _g260[(_g261 + 1)]
      setenv(k, {_stash = true, export = true})
      _g261 = (_g261 + 1)
    end
  end, module = "compiler"}}}
  _g262 = {}
  exports.boot = _g262
  _g262.environment = environment
  _g262.modules = modules
end)();
(function ()
  local function rep(str)
    local _g263 = (function ()
      local _g264,_g265 = xpcall(function ()
        return(eval(read_from_string(str)))
      end, _37message_handler)
      return({_g264, _g265})
    end)()
    local _g1 = _g263[1]
    local x = _g263[2]
    if is63(x) then
      return(print((to_string(x) .. " ")))
    end
  end
  local function repl()
    local step = function (str)
      rep(str)
      return(write("> "))
    end
    write("> ")
    while true do
      local str = (io.read)()
      if str then
        step(str)
      else
        break
      end
    end
  end
  local function usage()
    print((to_string("usage: lumen [options] <module>") .. " "))
    print((to_string("options:") .. " "))
    print((to_string("  -o <output>\tOutput file") .. " "))
    print((to_string("  -t <target>\tTarget language (default: lua)") .. " "))
    print((to_string("  -e <expr>\tExpression to evaluate") .. " "))
    return(exit())
  end
  local function main()
    local args = arg
    if ((hd(args) == "-h") or (hd(args) == "--help")) then
      usage()
    end
    local spec = nil
    local output = nil
    local target1 = nil
    local expr = nil
    local i = 0
    local _g266 = args
    while (i < length(_g266)) do
      local arg = _g266[(i + 1)]
      if ((arg == "-o") or (arg == "-t") or (arg == "-e")) then
        if (i == (length(args) - 1)) then
          print((to_string("missing argument for") .. " " .. to_string(arg) .. " "))
        else
          i = (i + 1)
          local val = args[(i + 1)]
          if (arg == "-o") then
            output = val
          elseif (arg == "-t") then
            target1 = val
          elseif (arg == "-e") then
            expr = val
          end
        end
      elseif (nil63(spec) and ("-" ~= char(arg, 0))) then
        spec = arg
      end
      i = (i + 1)
    end
    if output then
      if target1 then
        target = target1
      end
      return(write_file(output, compile_module(spec)))
    else
      local spec = (spec or "main")
      in_module(spec)
      if expr then
        return(rep(expr))
      else
        return(repl())
      end
    end
  end
  main()
  _g267 = {}
  exports.main = _g267
end)();
