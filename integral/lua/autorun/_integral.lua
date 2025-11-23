-- The name of this file is important. Gmod lua load order in autorun is done is alphabetical order.
-- See https://wiki.facepunch.com/gmod/Lua_Loading_Order

AddCSLuaFile()

if SERVER then include("integral/init.lua") end
if CLIENT then include("integral/cl_init.lua") end