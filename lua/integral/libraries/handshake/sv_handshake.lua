--[[
	"NEVER TRUST THE CLIENT"
	This is true, but in some cases it makes things way easier to be able to.
	How it works is the server can generate a token for a client. The server sets the token as a DTVar on that client.
	When the client requests something important from the server we can check if the tokens match. Then it's reset.
	Unused tokens expire after a minute.

	WARNING WARNING WARNING
	Do NOT use this system for anything critically important, such as admin rights, database access, RCON, etc.
	This system is not foolproof.. but should be a roadblock for the average joe to exploit.
]]

-- Any of these failures either means you didn't impliment the handshake system properly.. OR there is some funny business.
HANDSHAKE_FAILURE_BURNED_TOKEN = 1			-- Tried to handshake a burned token!
HANDSHAKE_FAILURE_MISMATCH = 2				-- Tried to handshake and SV token doesn't match CL token!
HANDSHAKE_FAILURE_MALFORMED_TOKEN = 3		-- Clear sign of tampering. Token is in a nonstandard form!

HANDSHAKE_FAILURE_CODE_TO_TXT = {
	[HANDSHAKE_FAILURE_BURNED_TOKEN] = "Tried to sign a burned token.",
	[HANDSHAKE_FAILURE_MISMATCH] = "SV/CL token mismatch.",
	[HANDSHAKE_FAILURE_MALFORMED_TOKEN] = "Malformed token detected!",
}

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

function handshake.Failed(pl)
	local clientToken = pl:GetToken()
	local code

	-- Check if we were trying to sign a burned token.
	if clientToken == BURNED_TOKEN then code = HANDSHAKE_FAILURE_BURNED_TOKEN end

	-- Check if the token is malformed.
	if #clientToken ~= 64 or string.Lower(clientToken) ~= clientToken then code = code or HANDSHAKE_FAILURE_MALFORMED_TOKEN end

	-- Remove the letters a-f, if any other characters are left, it's a malformed token.
	if not code then
		local manipulate = clientToken
		local letters = {"a", "b", "c", "d", "e", "f"}
		for i = 1, #letters do string.Replace(manipulate, letters[i], "") end
		if not ToNumber(manipulate) then code = code or HANDSHAKE_FAILURE_MALFORMED_TOKEN end
	end

	-- If we haven't assigned a code already, it simply doesn't match.
	code = code or HANDSHAKE_FAILURE_MISMATCH

	hook.Run("HandshakeFailure", code)
end

hook.Add("HandshakeFailure", "HandshakeFailure.Integral", function(pl, code)
	print("[Integral] -- Handshake failure! Player: " .. pl:Nick() .. " (" .. pl:SteamID() .. ") | Issue: " .. HANDSHAKE_FAILURE_CODE_TO_TXT[code])
end)

function handshake.SignToken(pl, token)
	local success = pl:GetToken() == token
	if not success then handshake.Failed(pl, HANDSHAKE_FAILURE_MISMATCH) end

	pl:BurnToken()

	return success
end

local meta = FindMetaTable("Player")
function meta:SetToken(str)
	self:SetDTString(DT_PLAYER_STR_TOKEN, str)
end
function meta:GetToken() return self:GetDTString(DT_PLAYER_STR_TOKEN) end
function meta:BurnToken() self:SetToken(BURNED_TOKEN) end
function meta:SignToken(clientToken) return handshake.SignToken(self, clientToken) end

-- Make sure players have a burned token on connect.
hook.Add("PlayerReady", "PlayerReady.Integral.Handshake", function(pl) pl:BurnToken() end)
