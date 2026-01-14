DT_PLAYER_STR_TOKEN = 0

handshake = {}

local meta = FindMetaTable("Player")
function meta:SetToken(str) self:SetDTString(DT_PLAYER_STR_TOKEN, str) end
function meta:GetToken() return self:GetDTString(DT_PLAYER_STR_TOKEN) end
function meta:BurnToken() end
function meta:SignToken(clientToken) end