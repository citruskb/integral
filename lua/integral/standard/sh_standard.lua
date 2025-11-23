--[[

Gmod does not have consistent coding standards.

Baseline global support for the following coding stardard:
#1 Functions and function properties use PascalStyleCasing
#2 Constants and constant properties use SCREAMING_SNAKE_STYLE_CASING
#3 Variables, variable properties, identifiers, filenames, and all else uses snake_style_casing

Deprecated funcs were skipped as they shouldn't be used anyways.

We also skip funcs which already follow our standard above, of course.

]]

---------
-- bit --
---------
bit.Arshift =					bit.arshift
bit.Band =						bit.band
bit.Bnot =						bit.bnot
bit.Bor =						bit.bor
bit.Bswap =						bit.bswap
bit.Bxor =						bit.bxor
bit.Lshift =					bit.lshift
bit.Rol =						bit.rol
bit.Ror =						bit.ror
bit.Rshift =					bit.rshift
bit.ToBit =						bit.tobit
bit.ToHex =						bit.tohex


---------------
-- coroutine --
---------------
coroutine.Create =				coroutine.create
coroutine.IsYieldable =			coroutine.isyieldable
coroutine.Resume =				coroutine.resume
coroutine.Running =				coroutine.running
coroutine.Status =				coroutine.status
coroutine.Wait =				coroutine.wait
coroutine.Wrap =				coroutine.wrap
coroutine.Yield =				coroutine.yield


-----------
-- debug --
-----------
debug.GetInfo =					debug.getinfo


---------
-- jit --
---------
jit.Arch =						jit.arch
jit.Os =						jit.os
jit.Version =					jit.version
jit.VersionNum =				jit.version_num
jit.Attach =					jit.attach
jit.Flush =						jit.flush
jit.Off =						jit.off
jit.On =						jit.on
jit.Status =					jit.status
jit.opt.Start =					jit.opt.start
jit.util.Funcbc =				jit.util.funcbc
jit.util.FuncInfo =				jit.util.funcinfo


----------
-- math --
----------
math.HUGE =						math.huge
math.PI =						math.pi
math.TAU =						math.tau
math.Abs =						math.abs
math.Acos =						math.acos
math.Asin =						math.asin
math.Atan =						math.atan
math.Atan2 =					math.atan2
math.CalcBSplineN =				math.calcBSplineN
math.Ceil =						math.ceil
math.Cos =						math.cos
math.Cosh =						math.cosh
math.Deg =						math.deg
math.Exp =						math.exp
math.Floor =					math.floor
math.Fmod =						math.fmod
math.Frexp =					math.frexp
math.Ldexp =					math.ldexp
math.Log =						math.log
math.Log10 =					math.log10
math.Max =						math.max
math.Min =						math.min
math.Modf =						math.modf
math.Pow =						math.pow
math.Rad =						math.rad
math.Random =					math.random
math.RandomSeed =				math.randomseed
math.Sin =						math.sin
math.Sinh =						math.sinh
math.Sqrt =						math.sqrt
math.Tan =						math.tan
math.Tanh =						math.tanh


--------
-- os --
--------
os.Clock =						os.clock
os.Date =						os.date
os.DiffTime =					os.difftime
os.Time =						os.time


-------------
-- package --
-------------
package.Loaded =				package.loaded
package.SeeAll =				package.seeall


------------
-- string --
------------
string.Byte =					string.byte
string.Char =					string.char
string.Dump =					string.dump
string.Find =					string.find
string.Format =					string.format
string.Gmatch =					string.gmatch
string.Gsub =					string.gsub
string.Len =					string.len
string.Lower =					string.lower
string.Match =					string.match
string.Rep =					string.rep
string.Reverse =				string.reverse
string.Sub =					string.sub
string.Upper =					string.upper


-----------
-- table --
-----------
table.Concat =					table.concat
table.Insert =					table.insert
table.Maxn =					table.maxn
table.Move =					table.move
table.Remove =					table.remove
table.Sort =					table.sort


----------
-- utf8 --
----------
utf8.CharPattern =				utf8.charpattern
utf8.Char =						utf8.char
utf8.CodePoint =				utf8.codepoint
utf8.Codes =					utf8.codes
utf8.Force =					utf8.force
utf8.Len =						utf8.len
utf8.Offset =					utf8.offset
utf8.Sub =						utf8.sub


-------------
-- Globals --
-------------
Assert =						assert
CollectGarbage =				collectgarbage
--DTVarReceiveProxyGL =			DTVar_ReceiveProxyGL -- Exception. Breaks otherwise.
Getfenv =						getfenv
Error =							error -- Error is an alias of ErrorNoHalt anyways. But could break some addons.. maybe?
Include =						include
--Ipairs =						ipairs -- Exception. Personal preference.
IsAngle =						isangle
IsBool =						isbool
IsEntity =						isentity
IsFunction =					isfunction
IsMatrix =						ismatrix
IsNumber =						isnumber
IsPanel =						ispanel
IsString =						isstring
IsTable =						istable
IsVector =						isvector
Module =						module
NewProxy =						newproxy
Next =							next
--Pairs =						pairs -- Exception. Personal preference.
Pcall =							pcall
--Print =						print -- Exception. Personal preference.
RawEqual =						rawequal
Rawget =						rawget
Rawset =						rawset
Require =						require
Select =						select
SetMetaTable =					setmetatable
GetMetaTable =					getmetatable
ToBool =						tobool
ToNumber =						tonumber
ToString =						tostring
Type =							type
Unpack =						unpack
Xpcall =						xpcall