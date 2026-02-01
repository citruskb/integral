-- NOTE: Do not trust the client on this command. They can bypass it using a console alias.
concommand.Add("initpostentity", function(sender, command, arguments)
	if sender.ready then return end
	sender.ready = true
	hook.Run("PlayerReady", sender)

	timer.Simple(5, function()
		if not IsValid(sender) then return end
		if sender.disconnecting then return end

		hook.Run("PlayerReadyDelayed", sender)
	end)
end)