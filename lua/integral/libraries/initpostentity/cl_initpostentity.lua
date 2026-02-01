-- Define "MySelf" global reference to LocalPlayer()
MySelf = MySelf or NULL

hook.Add("InitPostEntity", "GetLocal", function()
	MySelf = LocalPlayer()
	hook.Run("MySelfValid", MySelf)

	hook.Add("HUDPaint", "FirstDraw", function()
		hook.Remove("HUDPaint", "FirstDraw")
		RunConsoleCommand("initpostentity")
	end)
end)