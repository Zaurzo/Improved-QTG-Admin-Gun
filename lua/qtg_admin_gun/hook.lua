local D1 = math.random(1,9999)
local A1 = math.random(1,9999)
local D2 = math.random(1,9999)
local A2 = math.random(1,9999)

if CLIENT then
	local vector_one = Vector(1, 1, 1)

	hook.Add('Think','QTG_AdminGunPlayerFixViewModel',function()
		local p = LocalPlayer()
		if !p:IsValid() then return end

		if p:GetActiveWeaponClass() == 'qtg_admin_gun' then
			if !p.hasqtggunequipped then
				p.hasqtggunequipped = true
			end
		else
			if p.hasqtggunequipped then
				p.hasqtggunequipped = nil

				local vm = p:GetViewModel()
				if !vm:IsValid() or !vm:GetBoneCount() then return end

				for i=0, vm:GetBoneCount() do
					vm:ManipulateBoneScale(i, vector_one)
					vm:ManipulateBoneAngles(i, angle_zero)
					vm:ManipulateBonePosition(i, vector_origin)
				end	
			end
		end
	end)
end

hook.Add('PlayerDeath','QTG_AdminGunPlayerDeath',function(p)
	if p:HasQTGInvisible() then
		p:QTGInvisible(false)
	end
end)

local isYellowColor = {
	[BLOOD_COLOR_ANTLION] = true,
	[BLOOD_COLOR_ANTLION_WORKER] = true,
	[BLOOD_COLOR_GREEN] = true,
	[BLOOD_COLOR_YELLOW] = true,
	[BLOOD_COLOR_ZOMBIE] = true
}

local IsDmgValid do
	local GetDamage = FindMetaTable('CTakeDamageInfo').GetDamage
	local pcall = pcall

	function IsDmgValid(dmginfo)
		return pcall(GetDamage, dmginfo) == true
	end
end

local type = debug.getupvalue(saverestore.WriteVar, 3)

if !isfunction(type) then
	type = _G.type
end

hook.Add('EntityTakeDamage','QTG_AdminGunSetDamage',function(e,d)
	if !IsDmgValid(d) then return end

	local a = d:GetAttacker()
	local inflictor = d:GetInflictor()
	local cbd = 1e9

	if inflictor:IsValid() and inflictor.IsQTGAdminGun then
		local o = inflictor:GetOwner()
		local valid = IsValid(o) and type(o) != 'userdata'
		local valid2 = IsValid(e) and type(e) != 'userdata'

		if inflictor:GetClass() == 'crossbow_bolt' then
			if a:IsValid() then
				local bp = ''
				local p = ents.Create('info_particle_system')

				if IsValid(p) then
					p:Fire('Kill','',0.1)
				end

				if (e:IsPlayer() or e:IsNPC() or type(e) == 'NextBot' or e:IsRagdoll()) then
					local bc = e:GetBloodColor()

					if isYellowColor[bc] then
						bp = 'blood_impact_yellow_01'
					elseif bc == BLOOD_COLOR_RED then
						bp = 'blood_impact_red_01'
					elseif bc == BLOOD_COLOR_MECH then
						bp = ''
					elseif e:GetClass() == 'npc_hunter' then
						bp = 'blood_impact_synth_01'
					elseif e:GetClass() == 'npc_turret' then
						bp = ''
					elseif e:GetClass() == 'npc_rollermine' then
						bp = ''
					elseif e:GetClass() == 'npc_clawscanner' then
						bp = ''
					elseif e:GetClass() == 'npc_cscanner' then
						bp = ''
					elseif e:GetClass() == 'npc_manhack' then
						bp = ''
					elseif e:GetModel() == 'models/props_c17/furnituremattress001a.mdl' then
						bp = ''	
					else
						bp = 'blood_impact_red_01'
					end
				end

				if bp != '' and IsValid(p) then
					p:SetKeyValue('effect_name',bp)
					p:SetKeyValue('start_active','1')
					p:Spawn()
					p:Activate()

					local pos = a:IsPlayer() and a:GetEyeTrace().HitPos or inflictor:GetPos()

					p:SetPos(pos)
				end
			end

			if o != e then
				d:SetAttacker(valid and o or inflictor)
				d:SetInflictor(valid and o or inflictor)
				d:SetDamage(cbd)

				if valid2 then
					e:SetHealth(0)

					if e:IsPlayer() or e:IsNPC() or type(e) == 'NextBot' then
						d:SetDamageForce(inflictor:GetForward()*cbd)
					elseif e:GetPhysicsObject():IsValid() then
						e:GetPhysicsObject():ApplyForceCenter(inflictor:GetForward()*cbd)
					end
				end
			else
				return true
			end
		else
			if o != e then
				local gun = inflictor.Gun

				if valid2 then
					e:SetHealth(0)
				end

				d:SetAttacker(valid and o or inflictor)
				d:SetInflictor(IsValid(gun) and gun or inflictor)
				d:SetDamage(cbd)
			else
				return true
			end
		end
	end

	if IsValid(e) then 
		if e.IsQTGAdminGun then
			return true
		end

		if e:IsPlayer() and e:GetActiveWeaponClass() == 'qtg_admin_gun' and SERVER then
			net.Start('QTG_miss')
			net.WriteEntity(e)
			net.WriteVector(e:EyePos())
			net.Broadcast()
			e:EmitSound('undertale/qtg_attack_miss.wav',75,100,1,CHAN_AUTO)
			return true
		end

		if IsValid(e.TimeStopENT) then
			local tb = {
			ent=e,
			inf=inflictor,
			atk=a,
			dmg=d:GetDamage(),
			pos=d:GetDamagePosition(),
			typ=d:GetDamageType(),
			amm=d:GetAmmoType(),
			frc=d:GetDamageForce(),
			bubble=e.TimeStopENT}
			if e.TimeStopENT.BarrierDamage and e != e.TimeStopENT.Owner then
				table.insert(e.TimeStopENT.BarrierDamage,tb)
				d:ScaleDamage(0)
			end
			return true
		end
	end
end)

hook.Add('PopulateToolMenu','QTG_AdminGunSettings',function()
	local function QTG_Admin_Gun_Options(p)
		function QTG_AdminGun_Language_r()
			if !p:IsValid() then return end
			p:ClearControls()
			QTG_Admin_Gun_Options(p)
		end
		p:Button(QAGL.SettingsOpenMenu,'QTG_AdminGun_OpenSettingMenu')
	end
	spawnmenu.AddToolMenuOption('Utilities','Neptune QTG','QTG_Admin_Gun','QTG Admin Gun','','',QTG_Admin_Gun_Options)
end)

hook.Add('PlayerFootstep','QTG_FootStep',function(p,po,f,s,v,r)
	if p:GetActiveWeaponClass() == 'qtg_admin_gun' and p:GetNWBool('AdminGun_Invisible') then
		return true
	end	
end)

hook.Add('GetFallDamage', 'QTG_DamageMiss', function(p,s)
	if p:GetActiveWeaponClass() == 'qtg_admin_gun' then
		return 0
	end
end)

hook.Add('PhysgunPickup', 'QTG_CantPickup', function(p,s)
	if p:GetActiveWeaponClass() == 'qtg_admin_gun' then
		return false
	end	
end)

hook.Add('PlayerSpawnedNPC', 'QTG_Player_Spawn_NPC', function(p,e)
	if !IsValid(p) or !IsValid(e) then return end

	if !p:IsAdmin() and e:IsNPC() and e:GetActiveWeaponClass() == 'qtg_admin_gun' then
		e:QTGRemove20()

		local lang = GetConVar('QTG_AdminGun_Language')

		if lang and lang:GetString() == 'zh-CN' then
			Text = p:Name()..' 你根本就不是管理员!请切换你的NPC武器!'
		else
			Text = p:Name()..' You are not an administrator at all! Please switch your NPC weapon!'
		end
		p:QTGAddNotify(Text,0,0)
	end
end)

if SERVER then
	local RemovedList = {
		['npc_windgrinbot'] = true,
		['npc_lubenweibot'] = true
	}

	hook.Add('EntityRemoved',A1..A1..A1..D1,function(e)
		if RemovedList[e:GetClass()] then
			return true
		end
	end)

	--[[
	hook.Add('OnEntityCreated',A1..D1..A2..D2,function(e)
		if RemovedList[e:GetClass()] then
			hook.Remove('ContextMenuOpen','windgrinno')
			return true
		end
	end)
	]]
end

local function QTG_RayIntersectSphere(src,dir,pos,radius)
	local distance = pos:Distance(src)
	local range = (pos-(src+dir*distance)):Length()
	if (pos-src):Length() <= radius or range <= radius then
		return src+dir*(distance-(110*math.sqrt(1-(range/radius)^2)))
	end
	return false
end

local function getRadius(e)
	local get = e.GetRadius

	if isfunction(get) then
		return get(e)
	end

	local radius = e.Radius

	if isnumber(radius) then
		return radius
	end

	return 120
end

hook.Add('EntityFireBullets','QTG_Ent_Timestop_Barrier',function(e,b)
	for k,v in ipairs(ents.FindByClass('qtg_ent_timestop')) do
		local hitPos = QTG_RayIntersectSphere(b.Src,b.Dir,v:GetPos(),getRadius(v))
		if hitPos then
			if e != v:GetOwner() then
				b.Distance = b.Src:Distance(hitPos)
			end
			b.Callback = function(a,t,d) end
			return true
		end
	end
	for k,v in ipairs(ents.FindByClass('qtg_ent_barrier')) do
		local hitPos = QTG_RayIntersectSphere(b.Src,b.Dir,v:GetPos(),getRadius(v))
		
		if hitPos then
			local o = v:GetOwner()

			if o:IsValid() and (o:GetNWBool('AdminGun_Defense') or o:IsNPC()) and e != o then
				b.Distance = b.Src:Distance(hitPos)
				return true
			end
		end
	end
	if e:IsPlayer() and e:GetActiveWeaponClass() == 'qtg_admin_gun' then
		return true
	end
end)

hook.Add('InitPostEntity',D1..A2..D2..A1,function()
	local t = scripted_ents.GetList()

	for k,v in pairs(t) do
		local tb = v.t
		if tb then
			local f = tb.QTGThink

			if f and string.find(k,'qtg_ent_') then
				local old = tb.Initialize

				if old then
					function tb:Initialize()
						old(self)

						local n = tostring(self)..math.random(1,9999)*math.random(1,9999)

						hook.Add('Tick',n,function()
							if !self:IsValid() then
								return hook.Remove('Tick',n)
							end

							f(self)
						end)
					end
				end
			end
		end
	end
end)

do
	local pickuphooks = {
		['PlayerCanPickupWeapon'] = true,
		['PlayerSpawnedSWEP'] = true,
		['PlayerSpawnSWEP'] = true,
		['PlayerGiveSWEP'] = true
	}

	local old = hook.Add
	local GetClass = FindMetaTable('Entity').GetClass

	local isentity = isentity
	local isfunction = isfunction

	local type = type

	local function isactivewepqtg(p)
		if type(p) != 'Player' then return end

		local get = p.GetActiveWeapon
		if !get then return false end

		local w = get(p)

		return w and w:IsValid() and w:GetClass() == 'qtg_admin_gun'
	end

	function hook.Add(n,i,f,...)
		if isfunction(f) then
			local old = f

			if pickuphooks[n] then
				f = function(p,w,...)
					if w == 'qtg_admin_gun' or (isentity(w) and GetClass(w) == 'qtg_admin_gun') then
						return true
					end

					return old(p,w,...)
				end
			elseif CLIENT and n == 'CalcView' then
				f = function(p,...)
					if !isactivewepqtg(p) then
						return old(p,...)
					end
				end
			end
		end

		return old(n,i,f,...)
	end
end

hook.Add('Move','QTG_Move',function(p,m)
	if !p:IsAdmin() then return end
	local w = p:GetActiveWeapon()
	if !w:IsValid() then return end

	if w:GetClass() == 'qtg_admin_gun' and p:GetNWBool('AdminGun_FlyMode') and !p:OnGround() then
		if w.qtgjuststartedfly then
			m:SetVelocity(vector_origin) 
			w.qtgjuststartedfly = nil
			return true
		end
		
		local speed = 0.0005 * FrameTime()
		local updown = Vector(0,0,0)
		if m:KeyDown(IN_SPEED) then speed = 0.005 * FrameTime() end
		if m:KeyDown(IN_JUMP) then updown = Vector(0,0,20) end
		if m:KeyDown(IN_DUCK) then updown = Vector(0,0,-20) end
		local ang = m:GetMoveAngles()
		local pos = m:GetOrigin()
		local vel = m:GetVelocity()
		vel = vel + ang:Forward() * m:GetForwardSpeed() * speed
		vel = vel + ang:Right() * m:GetSideSpeed() * speed
		vel = vel + ang:Up() * m:GetUpSpeed() * speed
		if math.abs(m:GetForwardSpeed()) + math.abs(m:GetSideSpeed()) + math.abs(m:GetUpSpeed()) < 0.1 then
			vel = vel * 0.90
		else
			vel = vel * 0.99
		end

		pos = pos+vel+updown
		
		m:SetVelocity(vel)
		m:SetOrigin(pos)

		return true
	end
end)