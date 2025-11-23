-- Rewrite index functions to be more efficient.

local meta_ent = FindMetaTable("Entity")
local EGetTable = meta_ent.GetTable
local val, tab
function meta_ent:__index(key)
    val = meta_ent[key]
    if val ~= nil then return val end

    tab = EGetTable(self)
    if not tab then return end
    return tab[key]
end

local meta_pl = FindMetaTable("Player")
function meta_pl:__index(key)
    val = meta_pl[key] or meta_ent[key]
    if val ~= nil then return val end

    tab = EGetTable(self)
    if not tab then return end
    return tab[key]
end

local meta_wep = FindMetaTable("Weapon")
local EGetOwner = meta_ent.GetOwner
local DEPRECATED_OWNER_KEY = "Owner"
function meta_wep:__index(key)
    val = meta_wep[key] or meta_ent[key]
    if val ~= nil then return val end

    if key == DEPRECATED_OWNER_KEY then return EGetOwner(self) end

    tab = EGetTable(self)
    if not tab then return end
    return tab[key]
end