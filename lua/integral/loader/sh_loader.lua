--[[ INSTRUCTIONS (to use LoadLibrary in your gamemode or addon)

	1. Set the loader root in a shared file.
		For in a gamemode, call GamemodeLoaderRoot(GM) prior to calling IncludeLibrary(folderName)
			This will set your "root" loading folder to <yourgamemode>/gamemode
		For in an addon, call SetLoaderRoot(<LuaFolder>) prior to calling IncludeLibrary(folderName)
			This will set your "root" loading folder to lua/<LuaFolder>
	
	2. Use IncludeLibary(folderName) in a shared file to load the library, relative to the loader root.
		So if your root is <yourgamemode>/gamemode then IncludeLibrary("mylibrary") will load <yourgamemode>/gamemode/mylibrary

	For example implementation, see shared.lua

	DETAILS
	1. Files inside a library should start with "sh_", "sv_", or "cl_" to determine where it loads
		"sh_" - AddCSLuaFile'd and included serverside and clientside
		"sv_" - included serverside
		"cl_" - AddCSLuaFile'd and included clientside

	2. Files ending in "_load.lua" are loaded FIRST

	3. Files ending in "_register.lua" are loaded LAST

	4. All other files are loaded in alphabetical order

	5. Have a file named "sh_loader.lua" inside your library to bypass steps 3-5
		If this file is detected, the loader simply loads that file and nothing else
		Use this to define your own specific load order for more complex libraries
]]

local SERVERSIDE = 1
local SHARED = 2
local CLIENTSIDE = 3
local SKIP = 4

-- When we load this file, gm.FolderName returns nil. If we're loading a gamemode, it'll return the gamemode name
-- if we want to load files in other gamemodes we need to run this function there beforehand.
function SetLoaderRoot(str) loader_root = str end
function GamemodeLoaderRoot(g) SetLoaderRoot(g.FolderName .. "/gamemode/") end

local SERVERSIDE_PREFIX = "sv"
local CLIENTSIDE_PREFIX = "cl"
local SHARED_PREFIX = "sh"
local FILE_NAME_SPACER = "_"
local FIRST_INDEX = 1
local function GetFileDomain(file_name)
	local explode = string.Explode(FILE_NAME_SPACER, file_name)
	local prefix = explode[FIRST_INDEX]

	return 	prefix == SERVERSIDE_PREFIX and SERVERSIDE
			or prefix == CLIENTSIDE_PREFIX and CLIENTSIDE
			or prefix == SHARED_PREFIX and SHARED
			or SKIP
end

local function LoadServersideFile(file_loc)
	-- Serverside files get included Serverside.
	if CLIENT then return end
	include(file_loc)
end

local function LoadSharedFile(file_loc)
	-- Shared files need to be AddCSLuaFile'd Serverside, then included both Serverside and Clientside.
	if SERVER then AddCSLuaFile(file_loc) end
	include(file_loc)
end

local function LoadClientsideFile(file_loc)
	-- Clientside files need to be AddCSLuaFile'd Clientside, then included Clientside.
	if SERVER then AddCSLuaFile(file_loc) end
	if SERVER then return end
	include(file_loc)
end

local function SkipLoad(file_loc) end

local switch = {
	[SERVERSIDE] = LoadServersideFile,
	[SHARED] = LoadSharedFile,
	[CLIENTSIDE] = LoadClientsideFile,
	[SKIP] = SkipLoad,
}

local function LoadFile(file_name, file_loc)
	local LoadFunction = switch[GetFileDomain(file_name)]
	LoadFunction(file_loc)
end

local LUA_SUFFIX = "/*.lua"
local LUA_PATH = "LUA"
local function LoadFilesInFolder(folder_loc)
	local ftab, _ = file.Find(folder_loc .. LUA_SUFFIX, LUA_PATH)

	-- We want to make sure we load in this order.
	-- 1. shared
	-- 2. server
	-- 3. client
	-- We do this because I assume serverside and clientside may have shared dependencies.
	local shared, server, client = {}, {}, {}
	for _, file_name in ipairs(ftab) do
		-- If we find a loader file in a folder, stop everything. Just load that instead.
		--[[ TODO find out why this doesn't work.
		if file_name == "sh_loader.lua" then
			print("FOUND A LOAD OVERRIDE: ", folder_loc)
			LoadFile("sh_loader.lua", folder_loc .. "/" .. "sh_loader.lua")
			return true
		end
		]]

		local domain = GetFileDomain(file_name)
		if domain == SHARED then
			table.insert(shared, file_name)
		elseif domain == SERVERSIDE then
			table.insert(server, file_name)
		elseif domain == CLIENTSIDE then
			table.insert(client, file_name)
		end
	end

	local function PutLoadFirst(tab)
		if table.IsEmpty(tab) then return tab end
		local loader_idx
		for k, file_name in ipairs(tab) do
			if string.Find(file_name, "_load.") then loader_idx = k break end
		end

		if not loader_idx then return tab end

		local loader_file_name = tab[loader_idx]
		table.Remove(tab, loader_idx)
		table.Insert(tab, 1, loader_file_name)
		return tab
	end

	local function PutRegisterLast(tab)
		if table.IsEmpty(tab) then return tab end
		local register_idx
		for k, file_name in ipairs(tab) do
			if string.Find(file_name, "_register.") then register_idx = k break end
		end

		if not register_idx then return tab end

		local register_file_name = tab[register_idx]
		table.Remove(tab, register_idx)
		table.Insert(tab, register_file_name)
		return tab
	end

	local function Load(tab)
		if table.IsEmpty(tab) then return end

		-- Makes sure sh_loader.lua or sv_loader.lua or cl_loader.lua loads first of their respective domains.
		tab = PutLoadFirst(tab)

		-- Makes sure sh_register.lua or sv_register.lua or cl_register.lua loads last of their respective domains.
		tab = PutRegisterLast(tab)

		for _, file_name in ipairs(tab) do
			local file_loc = folder_loc .. "/" .. file_name
			LoadFile(file_name, file_loc)
		end
	end

	Load(shared)
	Load(server)
	Load(client)
end

local function LoadFilesInDirectory(dir)
	local endEarly = LoadFilesInFolder(dir)
	if endEarly then return end

	local _, dir_tab = file.Find(dir .. "/*", LUA_PATH)
	for _, folder in ipairs(dir_tab) do
		local new_dir = dir .. "/" .. folder
		LoadFilesInDirectory(new_dir)
	end
end

function IncludeLibrary(libraryName)
	LoadFilesInDirectory(loader_root .. libraryName)
end
