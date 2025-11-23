local HookAdd = hook.Add
local HookRemove = hook.Remove
local TimerRemove = timer.Remove
local TimerExists = timer.Exists

local function RemoveExpensiveHooks()
	-- Large amount of cycle usage, especially on the server.
	HookRemove("PlayerTick", "TickWidgets")

	if SERVER and TimerExists("CheckHookTimes") then TimerRemove("CheckHookTimes") end

	if CLIENT then
		-- These call on bloated convar getting methods and aren't used outside of sandbox.
		HookRemove("RenderScreenspaceEffects", "RenderColorModify")
		HookRemove("RenderScreenspaceEffects", "RenderBloom")
		HookRemove("RenderScreenspaceEffects", "RenderToyTown")
		HookRemove("RenderScreenspaceEffects", "RenderTexturize")
		HookRemove("RenderScreenspaceEffects", "RenderSunbeams")
		HookRemove("RenderScreenspaceEffects", "RenderSobel")
		HookRemove("RenderScreenspaceEffects", "RenderSharpen")
		HookRemove("RenderScreenspaceEffects", "RenderMaterialOverlay")
		HookRemove("RenderScreenspaceEffects", "RenderMotionBlur")
		HookRemove("RenderScene", "RenderStereoscopy")
		HookRemove("RenderScene", "RenderSuperDoF")
		HookRemove("GUIMousePressed", "SuperDOFMouseDown")
		HookRemove("GUIMouseReleased", "SuperDOFMouseUp")
		HookRemove("PreventScreenClicks", "SuperDOFPreventClicks")
		HookRemove("PostRender", "RenderFrameBlend")
		HookRemove("PreRender", "PreRenderFrameBlend")
		HookRemove("Think", "DOFThink")
		HookRemove("RenderScreenspaceEffects", "RenderBokeh")
		HookRemove("NeedsDepthPass", "NeedsDepthPass_Bokeh")

		-- Doesn't do anything since we disabled widgets above.
		HookRemove("PostDrawEffects", "RenderWidgets")

		-- Could screw with people's point shops but it's expensive.
		--HookRemove("PostDrawEffects", "RenderHalos")
	end
end
HookAdd("Initialize", "Initialize.RemoveExpensiveHooks", RemoveExpensiveHooks)