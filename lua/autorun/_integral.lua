-- The name of this file is important. Gmod lua load order in autorun is done is alphabetical order.
-- See https://wiki.facepunch.com/gmod/Lua_Loading_Order

AddCSLuaFile()

Include = include

if SERVER then Include("integral/init.lua") end
if CLIENT then Include("integral/cl_init.lua") end