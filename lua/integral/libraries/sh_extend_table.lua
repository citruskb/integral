-- Useful table manipulation functions.

local pairs = pairs
local TableInsert = table.Insert
local Rawset = Rawset

function table.IsAssoc(tab)
	for _, v in pairs(tab) do
		if v == true then return true end
		return false
	end
end
local TableIsAssoc = table.IsAssoc

function table.ToAssoc(tab)
	if TableIsAssoc(tab) then return tab end

	local tab_assoc = {}
	for _, v in pairs(tab) do
		tab_assoc[v] = true
	end

	return tab_assoc
end

function table.ToKeyValues(tab)
	if not TableIsAssoc(tab) then return tab end

	local tab_kv = {}

	for k, _ in pairs(tab) do
		tab_kv[#tab_kv + 1] = k
	end

	return tab_kv
end

function table.ForEach(tab, Callback)
	if not Callback then return end
	for k, v in pairs(tab) do Callback(k, v) end
end

function table.Map(tab, Callback)
	local map = {}
	for k, v in pairs(tab) do Rawset(map, k, Callback(k, v)) end

	return map
end

function table.MapSeq(tab, Callback)
	local map = {}
	for k, v in pairs(tab) do Rawset(map, #map + 1, Callback(k, v)) end

	return map
end

function table.Filter(tab, Predicate)
	local filtered = {}
	for k, v in pairs(tab) do
		if not Predicate(k, v) then continue end
		Rawset(filtered, k, v)
	end

	return filtered
end

function table.FilterSeq(tab, Predicate)
	local filtered = {}
	for k, v in pairs(tab) do
		if not Predicate(k, v) then continue end
		Rawset(filtered, #filtered + 1, v)
	end

	return filtered
end

function table.Mirror(tab)
	local mirror = {}
	for k, v in pairs(tab) do Rawset(mirror, k, v) end

	return mirror
end

function table.IsIdentical(tab1, tab2)
	-- If they are the same table, they are identical.
	if tab1 == tab2 then return true end

	-- If one is or isn't empty and the other doesn't match, then they aren't identical.
	if table.IsEmpty(tab1) and not table.IsEmpty(tab2) then return false end

	-- if they don't have the same number of entries, they aren't identical.
	if table.Count(tab1) ~= table.Count(tab2) then return false end

	-- Potentially expensive double check for very large tables.
	for k, v in pairs(tab1) do
		local pairedVal = tab2[k]
		if not pairedVal then return false end
		if v ~= pairedVal then return false end
	end

	return true
end

-- Utility function for distributing an expensive call on many table entries over time.
-- Useful for breaking up a large or expensive job of non-variable size into many smaller jobs over time!
-- id -> Identifier for the distribution efforts. Will error if one isn't put in, or if the prior one with the same id ..
-- hasn't ended yet when you try to start a new one.
-- tab -> Input table.
-- actions -> How many actions to take per action interval. Minimum 1.
-- interval -> How many seconds to distribute the work over. Minimum 0.4s. If we are doing so much that we need more ..
-- .. frames to take complete action than the time aloted it will automatically add frames until we can complete our action.
-- Callback -> func to run on each table entry, input args are k and v.
-- Returns how long in seconds before it has done its work using timers.
local ENGINE_TICK = engine.TickInterval()
local MIN_DELAY = 0.4
local MIN_PER_INTERVAL = 1
if not active_distributions then active_distributions = {} end -- Avoid Lua refresh
--id, tab, actions, interval, Callback)
function table.Distribute(data)
	if not data or (data and not IsTable(data)) then
		ErrorNoHalt("table.Distribute had an invalid argument.")
		return MIN_DELAY
	end

	local id = Rawget(data, "id")
	if not id then
		Error("table.Distribute must have an identifier.")
		return MIN_DELAY
	end

	local tab = Rawget(data, "tab")
	if not tab or (tab and not IsTable(tab)) then
		ErrorNoHalt("table.Distribute requires a table to distribute over.")
		return MIN_DELAY
	end

	local Callback = Rawget(data, "Callback")
	if not Callback or (Callback and not IsFunction(Callback)) then
		ErrorNoHalt("table.Distribute requires a Callback function.")
		return MIN_DELAY
	end

	local ct = CurTime()
	if active_distributions[id] and active_distributions[id] > ct then
		Error("table.Distribution leak detected. Tried to start '" .. id .. "' while it's already active!")
		return MIN_DELAY
	end

	local num = table.Count(tab)
	if num < 1 then return ENGINE_TICK end

	actions = math.Max(math.Ceil(Rawget(data, "actions") or MIN_PER_INTERVAL), MIN_PER_INTERVAL)
	num = math.Ceil(num / actions)
	interval = math.Max(num * ENGINE_TICK, Rawget(data, "interval") or MIN_DELAY)

	local action_interval = interval / num
	local action = 1
	local count = 1
	for k, v in pairs(tab) do
		timer.Simple(count * action_interval, function() Callback(k, v) end)
		action = action + 1
		if action % actions == 0 then count = count + 1 end
	end

	active_distributions[id] = ct + interval

	return interval + ENGINE_TICK -- Add a extra frame to buffer the end.
end