include('shared.lua')

function ENT:Initialize()
	timer.Simple(0.7, function()
		surface.PlaySound(Sound("ambient/explosions/explode_6.wav"))
	end)
	
	timer.Simple(8, function()
		surface.PlaySound(Sound("hl1/ambience/port_suckin1.wav"))
		
		timer.Simple(3, function()
			surface.PlaySound(Sound("hl1/ambience/port_suckin1.wav"))
			
			timer.Simple(5, function()
				surface.PlaySound(Sound("hl1/ambience/port_suckin1.wav"))
			end)
		end)
	end)
end