QAGL = {}
function QTGAdminGun:IncludelanguageFile(f)
	if file.Exists(f,'LUA') and CLIENT then
		include(f)
	else
		print('[QTG Admin Gun] language "'..f..'" File not found')
		GetConVar("QTG_AdminGun_Language"):SetString('en')
	end
end
function QTGAdminGun:AddlanguageDirectory(d)
	local files,directories = file.Find(d..'/*.lua','LUA')
	for _,v in pairs(files) do
		if string.find(v,'weapons') then return end
		if SERVER then
			AddCSLuaFile(d..'/'..v)
			print('[QTG Admin Gun] Loading language file: '..v)
		end
	end
end
QTGAdminGun:AddlanguageDirectory('qtg_admin_gun/language')
if CLIENT then
	function QAGL:Start()
		QTGAdminGun:IncludelanguageFile('qtg_admin_gun/language/'..GetConVar("QTG_AdminGun_Language"):GetString()..'.lua')
	end
	QAGL:Start()
	cvars.AddChangeCallback("QTG_AdminGun_Language",function(c,o,n)
		QAGL:Start()
		if QTG_AdminGun_Language_r then QTG_AdminGun_Language_r() end
	end)
end