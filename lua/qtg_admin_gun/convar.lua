local convarsToTransfer -- table

function QTGAdminGun:AddConvar(a,b,c)
	if SERVER then
		return CreateConVar(a,b,FCVAR_ARCHIVE+FCVAR_REPLICATED+FCVAR_SERVER_CAN_EXECUTE)
	else
		local cvar = CreateClientConVar(a,b,FCVAR_ARCHIVE)

		if c and cvar then
			convarsToTransfer[a] = cvar
	
			cvars.AddChangeCallback(a,function(n,old,new)
				net.Start('QTG_AdminGun_ConVar_Transfer')
				net.WriteString(a..'_Cvar')
				net.WriteString(new)
				net.SendToServer()
			end)
		end
	end
end

if SERVER then
	util.AddNetworkString('QTG_AdminGun_ConVar_Transfer')

	net.Receive('QTG_AdminGun_ConVar_Transfer', function(len, ply)
		if not ply:IsValid() then return end

		local name = net.ReadString()

		ply[name] = net.ReadString()
	end)
end

if CLIENT then
	convarsToTransfer = {}

	QTGAdminGun:AddConvar('QTG_AdminGun_GunText',1)
	QTGAdminGun:AddConvar('QTG_AdminGun_Language','en')
	QTGAdminGun:AddConvar('QTG_AdminGun_SetMyHealth',100)
	QTGAdminGun:AddConvar('QTG_AdminGun_SetPlyHealth',100)

	QTGAdminGun:AddConvar('QTG_AdminGun_GunHealth',0,true)
	QTGAdminGun:AddConvar('QTG_AdminGun_GunEffects',1,true)
	QTGAdminGun:AddConvar('QTG_AdminGun_GunDestroy',1,true)
	QTGAdminGun:AddConvar('QTG_AdminGun_GunLaserColor','255,0,0',true)
	QTGAdminGun:AddConvar('QTG_AdminGun_GunRainbowLaser',0,true)
	QTGAdminGun:AddConvar('QTG_AdminGun_GunMakePlayerRainbow',0,true)

	hook.Add('InitPostEntity','qtg_admin_gun_sendhealthconvar',function()
		hook.Remove('InitPostEntity','qtg_admin_gun_sendhealthconvar')
	
		timer.Simple(2.5,function()
			for k,v in pairs(convarsToTransfer) do
				net.Start('QTG_AdminGun_ConVar_Transfer')
				net.WriteString(k..'_Cvar')
				net.WriteString(v:GetString())
				net.SendToServer()
			end
		end)
	end)
end