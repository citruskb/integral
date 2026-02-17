local CSS_SPRAY_PATH = table.ToAssoc({
	"materials/vgui/logos/spray_bullseye.vtf",
	"materials/vgui/logos/spray_crosshairs.vtf",
	"materials/vgui/logos/spray_crybaby.vtf",
	"materials/vgui/logos/spray_elited.vtf",
	"materials/vgui/logos/spray_flashbanged.vtf",
	"materials/vgui/logos/spray_grenaded.vtf",
	"materials/vgui/logos/spray_headshot.vtf",
	"materials/vgui/logos/spray_insights.vtf",
	"materials/vgui/logos/spray_kamikazi.vtf",
	"materials/vgui/logos/spray_kilroy.vtf",
	"materials/vgui/logos/spray_knifed.vtf",
	"materials/vgui/logos/spray_nobombs.vtf",
	"materials/vgui/logos/spray_nosmoking.vtf",
	"materials/vgui/logos/spray_nowar.vtf",
	"materials/vgui/logos/spray_touchdown.vtf",
})

-- Save info on active sprays.
if not sprayexInfo then sprayexInfo = {} end

local sprayex = {}

function sprayex:GetSprayPath()
	return GetConVar("cl_logofile"):GetString()
end

local sprayexPath = ""
local sprayexData = ""
local sprayexHex = ""

function sprayex:GetFlags()
	-- VTF Flags offset
	local f = file.Open(sprayex:GetSprayPath(), "rb", "MOD")
	f:Seek(0x14)
	local flags = f:ReadULong() or 0
	f:Close()

	return flags
end

function sprayex:ValidData()
	local flags = self:GetFlags()

	-- mask out malicious flags
	-- Normal Map  | Render Target | Depth Render Target |  No Depth Buffer | SSBump
	local mask = 0x0080 + 0x8000 + 0x10000 + 0x800000 + 0x8000000 + 0x0800
	local maskedFlags = bit.band(mask, flags)

	if maskedFlags > 0 then return false end

	return true
end

-- Watch for when we press our spray key.
hook.Add("PlayerBindPress", "PlayerBindPress.sprayex", function(ply, bind)
	if not string.find(bind, "impulse 201") then return end

	if sprayexPath ~= sprayex:GetSprayPath() then
		sprayexPath = sprayex:GetSprayPath()
		sprayexData = file.Read(sprayex:GetSprayPath(), "MOD") or ""
		sprayexHex = scrc32.GetHex(sprayexData)
	end

	-- Hard stop if it's a default spray.
	-- Would allow, but can't figure out how to get at the raw default spray files with file.Read
	-- I could rip them and add it in a content pack just to point to it.. but nah, that's a bit too annoying.
	if CSS_SPRAY_PATH[sprayexPath] then return end

	net.Start("sprayex_try")
		net.WriteString(sprayexHex)
	net.SendToServer()
end)

net.Receive("sprayex_evaluate", function(len)
	local validity = sprayex:ValidData()

	-- Not a valid filetype.
	if string.Right(sprayexPath, 3) ~= "vtf" then
		validity = false
	end

	-- Exceeds spray limit.
	if #sprayexData > 2 * 1020 * 1024 then
		validity = false
	end

	net.Start("sprayex_deliver")
		net.WriteString(MySelf:GetToken())
		net.WriteBool(validity)
		net.WriteString(sprayexHex)
	net.SendToServer()
end)

net.Receive("sprayex_updateinfo", function(len)
	local tab = net.ReadTable()
	local pl = Entity(tab.idx)
	if not IsValidPlayer(pl) then return end

	-- Check if we have this spray loaded already. If not, make a material for it.
	-- Useful for say, a spray previewer/viewer.
	local sameValidSpray
	if sprayexInfo[tab.idx] then
		sameValidSpray = sprayexInfo[tab.idx].hex == tab.hex and not sprayexInfo[tab.idx].mat:IsError()
	end

	if sameValidSpray then
		tab.mat = sprayexInfo[tab.idx].mat
	else
		tab.mat = CreateMaterial("spray_" .. tab.hex .. ToString(os.time()), "UnlitGeneric", {
			["$basetexture"] = string.Format("../materials/temp/%s.vtf", tab.hex),
			["$translucent"] = 1,
			["$vertexalpha"] = 1,
			["$vertexcolor"] = 1,
			["$decalscale"] = 1,
			["Proxies"] = {
				["AnimatedTexture"] = {
					["animatedTextureVar"] = "$basetexture",
					["animatedTextureFrameNumVar"] = "$frame",
					["animatedTextureFrameRate"] = ToString(12),
				}
			}
		})
	end

	sprayexInfo[tab.idx] = tab
end)