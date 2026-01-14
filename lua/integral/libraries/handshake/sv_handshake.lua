--[[
	"NEVER TRUST THE CLIENT"
	This is true, but in some cases it makes things way easier to be able to.
	How it works is the server can generate a token for a client. The server sets the token as a DTVar on that client.
	When the client requests something important from the server we can check if the tokens match. Then it's reset.
	Unused tokens expire after a minute.

	WARNING WARNING WARNING
	Do NOT use this system for anything critically important, such as admin rights, database access, RCON, etc.
	This system is not foolproof.. but should be a roadblock for the average joe.
]]

-- Any of these failures either means you didn't impliment the handshake system properly.. OR there is some funny business.
HANDSHAKE_FAILURE_DUPLICATE_TOKEN = 1		-- Tried to gen new token before old one was burned!
HANDSHAKE_FAILURE_BURNED_TOKEN = 2			-- Tried to handshake a burned token!
HANDSHAKE_FAILURE_MISMATCH = 3				-- Tried to handshake and SV token doesn't match CL token!

DT_PLAYER_STR_TOKEN = 0
__tokens = {}
BURNED_TOKEN = "__BURNEDTOKEN__"

handshake = {}

function handshake.NewToken(pl)
	local ct = CurTime()
	local steamid64 = pl:SteamID64()
	local str = ToString(steamid64) .. ToString(ct)
	local token = util.SHA256(str)

	pl:SetToken(token)

	table.Insert(__tokens, {token = token, creation = ct, steamid64 = steamid64})
end

function handshake.Failed(pl, code)
	hook.Run("HandshakeFailure", code)
end

local meta = FindMetaTable("Player")
function meta:SetToken(str)
	self:SetDTString(DT_PLAYER_STR_TOKEN, str)
end
function meta:GetToken() return self:GetDTString(DT_PLAYER_STR_TOKEN) end
function meta:BurnToken() self:SetToken(BURNED_TOKEN) end
