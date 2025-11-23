local meta_emitter = FindMetaTable("CLuaEmitter")
local OldEmitterAdd = meta_emitter.Add

local meta_p = FindMetaTable("CLuaParticle")
local PaSetAirResistance =		meta_p.SetAirResistance
local PaSetAngles =				meta_p.SetAngles
local PaSetAngleVelocity =		meta_p.SetAngleVelocity
local PaSetBounce =				meta_p.SetBounce
local PaSetCollide =			meta_p.SetCollide
local PaSetCollideCallback =	meta_p.SetCollideCallback
local PaSetColor =				meta_p.SetColor
local PaSetDieTime =			meta_p.SetDieTime
local PaSetEndAlpha =			meta_p.SetEndAlpha
local PaSetEndSize =			meta_p.SetEndSize
local PaSetEndLength =			meta_p.SetEndLength
local PaSetGravity =			meta_p.SetGravity
local PaSetLifeTime =			meta_p.SetLifeTime
local PaSetLighting =			meta_p.SetLighting
--local PaSetMaterial =			meta_p.SetMaterial			-- Set on Emitter.Add call as separate arg.
local PaSetNextThink =			meta_p.SetNextThink			-- We need to call this before SetThinkFunction while passing CurTime() to make sure SetThinkFunction works.
--local PaSetPos =				meta_p.SetPos				-- Set on Emitter.Add call as separate arg.
local PaSetRoll =				meta_p.SetRoll
local PaSetRollDelta =			meta_p.SetRollDelta
local PaSetStartAlpha =			meta_p.SetStartAlpha
local PaSetStartLength =		meta_p.SetStartLength
local PaSetStartSize =			meta_p.SetStartSize
local PaSetThinkFunction =		meta_p.SetThinkFunction
local PaSetVelocity =			meta_p.SetVelocity
local PaSetVelocityScale =		meta_p.SetVelocityScale

local Rawget = Rawget
local CurTime = CurTime

local function NewEmitterAdd(emitter, mat, pos, data)
	local p = OldEmitterAdd(emitter, mat, pos)
	if not data or not p then return p end

	local air_res =			Rawget(data, "air_res")				if air_res then			PaSetAirResistance(p, air_res) end
	local ang =				Rawget(data, "ang")					if ang then				PaSetAngles(p, ang) end
	local ang_vel =			Rawget(data, "ang_vel")				if ang_vel then			PaSetAngleVelocity(p, ang_vel) end
	local bounce =			Rawget(data, "bounce")				if bounce then			PaSetBounce(p, bounce) end
	local collide =			Rawget(data, "collide")				if collide ~= nil then	PaSetCollide(p, collide) end
	local CollideCallback =	Rawget(data, "CollideCallback")		if CollideCallack then	PaSetCollideCallback(p, CollideCallback) end
	local col =				Rawget(data, "col")					if col then				PaSetColor(p, Rawget(col, "r"), Rawget(col, "g"), Rawget(col, "b")) end
	local die_time =		Rawget(data, "die_time")			if die_time then		PaSetDieTime(p, die_time) end
	local end_alpha =		Rawget(data, "end_alpha")			if end_alpha then		PaSetEndAlpha(p, end_alpha) end
	local end_size =		Rawget(data, "end_size")			if end_size then		PaSetEndSize(p, end_size) end
	local end_len =			Rawget(data, "end_len")				if end_len then			PaSetEndLength(p, end_len) end
	local gravity =			Rawget(data, "gravity")				if gravity then			PaSetGravity(p, gravity) end
	local life_time =		Rawget(data, "life_time")			if life_time then		PaSetLifeTime(p, life_time) end
	local lighting =		Rawget(data, "lighting")			if lighting then		PaSetLighting(p, lighting) end
	local roll =			Rawget(data, "roll")				if roll then			PaSetRoll(p, roll) end
	local roll_delta =		Rawget(data, "roll_delta")			if roll_delta then		PaSetRollDelta(p, roll) end
	local start_alpha =		Rawget(data, "start_alpha")			if start_alpha then		PaSetStartAlpha(p, start_alpha) end
	local start_len =		Rawget(data, "start_len")			if start_len then		PaSetStartLength(p, start_len) end
	local start_size =		Rawget(data, "start_size")			if start_size then		PaSetStartSize(p, start_size) end
	local vel =				Rawget(data, "vel")					if vel then				PaSetVelocity(p, vel) end
	local vel_scale =		Rawget(data, "vel_scale")			if vel_scale then		PaSetVelocityScale(p, vel_scale) end

	-- This one is uniquely complicated.
	-- We need to call PaSetNextThink before calling the think function.
	-- Then during the think function, we need to set the next think for it to call again.
	-- Let's handle this automatically, so all we need to do is pass an effect a function and it just does it.
	local ThinkFunction =	Rawget(data, "ThinkFunction")
	if ThinkFunction then
		PaSetNextThink(p, CurTime())

		local function _think(_p)
			ThinkFunction(_p)
			PaSetNextThink(_p, CurTime())
		end
		PaSetThinkFunction(p, _think)
	end

	return p
end
meta_emitter.Add = NewEmitterAdd