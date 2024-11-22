Time_Stop_Datatable = Time_Stop_Datatable or {}
Time_Stop_Enabled	= Time_Stop_Enabled or false

local TS_NPC 		= 1
local TS_PROP 		= 2
local TS_DOLL 		= 3
local TS_BALL		= 4
local TS_FRAG		= 5
local TS_FROT		= 6
local TS_TRAIN		= 7
local TS_BOT		= 8
local TS_PLY		= 9
local TS_RPG		= 10
local TS_HLENT		= 11

local Hl1Ent = {
	'grenade_hand',
	'rpg_rocket',
	'crossbow_bolt_hl1',
	'grenade_mp5',
	'monster_satchel'
}

function QTG_TimeStop(e,b)
	local index = e:EntIndex()
	if !index then return end

	e:QTGNextThink(CurTime()+21600)
	if type(e) == 'NextBot' then
		Time_Stop_Datatable[index] = { type = TS_BOT, mv = e:GetMoveType(), pos = e:GetPos(), ang = e:GetAngles() }
	elseif SERVER and e:IsNPC() and e:GetClass() != 'npc_turret_floor' then
		Time_Stop_Datatable[index] = { type = TS_NPC, mv = e:GetMoveType(), pos = e:GetPos(), ang = e:GetAngles() }
		e:QTGSetMoveType(MOVETYPE_NONE)
		if e:GetClass() == 'npc_rollermine' or e:GetClass() == 'npc_manhack' or e:GetClass() == 'npc_clawscanner' then
			if e:GetClass() != 'npc_turret_floor' then
				local phy = e:GetPhysicsObject()
				if IsValid(phy) then
					phy:EnableMotion(false)
				end
			end
		end
	elseif SERVER and e:IsPlayer() and e:GetNWInt('AdminGun_TimeStop') != 1 and e:GetActiveWeaponClass() != 'qtg_admin_gun' then
		table.insert(Time_Stop_Datatable,{ent=e,type=TS_PLY})
		e:Lock()
		e:RemoveFlags(FL_GODMODE)
	elseif e:GetClass() == 'prop_ragdoll' and SERVER || e:GetClass() == 'class C_ClientRagdoll' and CLIENT then
		local vels = {}
		local motion = {}
		local pos = {}
		local grav = {}
		local avels = {}
		for i = 0, e:GetPhysicsObjectCount() - 1 do
			local phy = e:GetPhysicsObjectNum(i)
			if phy:IsValid() then
				vels[i] = phy:GetVelocity()
				motion[i] = phy:IsMotionEnabled()
				pos[i] = phy:GetPos()
				grav[i] = phy:IsGravityEnabled()
				avels[i] = phy:GetAngleVelocity()
				phy:SetVelocity(Vector())
				phy:AddAngleVelocity(-phy:GetAngleVelocity())
				phy:EnableGravity(false)
			end
		end
		table.insert(Time_Stop_Datatable,{ent=e,type=TS_DOLL,vel=vels,mot=motion,pos=pos,grav=grav,avel=avels})
	elseif e:GetClass() == 'prop_combine_ball' then
		local phy = e:GetPhysicsObject()
		
		if IsValid( phy ) then
			local vel = phy:GetVelocity()
			e:SetMoveType(MOVETYPE_NONE)
			phy:EnableMotion(false)
			Time_Stop_Datatable[ index ] = { type = TS_BALL, vel = vel }
		end
	elseif e:GetClass() == 'func_rotating' and SERVER then
		Time_Stop_Datatable[index] = { type = TS_FROT }
		e:Fire('SetSpeed','0',0)
	elseif e:GetClass() == 'func_tracktrain' and SERVER then
		Time_Stop_Datatable[index] = { type = TS_TRAIN }
		e:Fire('Stop')
	else
		if e:GetClass() == 'npc_grenade_frag' then
			if !e.savedtime then e.savedtime = e:GetSaveTable().m_flDetonateTime end
			if !e.savedblip then e.savedblip = e:GetSaveTable().m_flNextBlipTime end
			e:SetSaveValue('m_flDetonateTime',e.savedtime)
		end
		if e:GetClass() == 'rpg_missile' or e:GetClass() == 'crossbow_bolt' then
			Time_Stop_Datatable[index] = { type = TS_RPG,ang = e:GetAngles()}
			e:SetMoveType(MOVETYPE_NONE)
			-- e:SetAngles(self.BarrierDate[e].ang)
		end
		if e:GetClass() == 'hunter_flechette' or e:GetClass() == 'grenade_ar2' or e:GetClass() == 'grenade_spit' then
			local phy = e:GetPhysicsObject()
			Time_Stop_Datatable[index] = {type = TS_RPG}
			e:SetMoveType(MOVETYPE_NONE)
		end
		for k, v in pairs(Hl1Ent) do
			if e:GetClass() == v then
				Time_Stop_Datatable[index] = {type = TS_HLENT}
				e:SetMoveType(MOVETYPE_NONE)
			end
		end
		local phy = e:GetPhysicsObject()
		local velocity = phy:IsValid() and phy:GetVelocity() or e:GetVelocity()
		local avelocity = phy:IsValid() and phy:GetAngleVelocity() or Vector()
		local mv = e:GetMoveType()
		local motion = true
		if phy:IsValid() then motion = phy:IsMotionEnabled() end
		
		local pos = e:GetPos()
		Time_Stop_Datatable[index] = { type = TS_PROP, vel = velocity, avel = avelocity, mot = motion, pos = pos, mv = mv }
		
		if IsValid( e.TimeBubbleENT ) then
			local bubble = e.TimeBubbleENT
			local data = bubble.StoredData[v]
			
			if data then
				Time_Stop_Datatable[index].vel = data.vel
				if data.avel then Time_Stop_Datatable[index].avel = data.avel end
				Time_Stop_Datatable[index].mot = data.wasmotionenabled
			end
		end
		
		if e:GetCollisionGroup() == COLLISION_GROUP_DEBRIS then
			Time_Stop_Datatable[index].wasmoved = true
		end
		
		if IsValid(phy) then
			Time_Stop_Datatable[index].grav = phy:IsGravityEnabled()
			phy:SetVelocity(Vector())
			phy:EnableGravity(false)
		end
	end
end

local function QTG_TimeStopThink()
	if Time_Stop_Enabled then
		for i, v in pairs(Time_Stop_Datatable) do
			local ent = Entity(i)
			if v.ent then ent = v.ent end
			if !IsValid( ent ) then Time_Stop_Datatable[ i ] = nil continue end
			if v.type == TS_PROP then
				local phy = ent:GetPhysicsObject()
				if IsValid( phy ) then				
					if phy:GetVelocity():Length() > 0.01 then
						Time_Stop_Datatable[i].wasmoved = true
						if Time_Stop_Datatable[i].vel:Length() - 50 < phy:GetVelocity():Length() then
							Time_Stop_Datatable[i].vel = ent:GetVelocity()
						end
						Time_Stop_Datatable[i].pos = ent:GetPos()
						phy:SetVelocity( phy:GetVelocity() * 0.9 )
					end
					if phy:GetAngleVelocity():Length() > 0 then
						Time_Stop_Datatable[ i ].wasmoved = true
						if Time_Stop_Datatable[ i ].avel:Length() < phy:GetAngleVelocity():Length() then
							Time_Stop_Datatable[ i ].avel = phy:GetAngleVelocity()
						end
						phy:AddAngleVelocity( -phy:GetAngleVelocity() * 0.9999999999999999 )
					end
					if ent:GetClass() == 'npc_grenade_frag' and ent.savedtime then
						ent:SetSaveValue('m_flNextBlipTime',CurTime()+5)
						ent:SetSaveValue('m_flDetonateTime',5)
					end
				end
			elseif v.type == TS_DOLL then
				for c = 0, ent:GetPhysicsObjectCount() - 1 do
					local phy = ent:GetPhysicsObjectNum( c )
					if phy:GetVelocity():Length() > 0 then
						if Time_Stop_Datatable[ i ].vel[ c ]:Length() - 50 < phy:GetVelocity():Length() then
							Time_Stop_Datatable[ i ].vel[ c ] = phy:GetVelocity()
						end
						Time_Stop_Datatable[i].pos[c] = phy:GetPos()
						phy:SetVelocity(phy:GetVelocity()*0.9)
					end
					if phy:GetAngleVelocity():Length() > 0 then
						if Time_Stop_Datatable[i].avel[c]:Length() < phy:GetAngleVelocity():Length() then
							Time_Stop_Datatable[i].avel[c] = phy:GetAngleVelocity()
						end
						phy:AddAngleVelocity(-phy:GetAngleVelocity()*0.9999999999999999)
					end
				end
			end
		end
	end
end
hook.Add('Think','QTG_TimeStopThink',QTG_TimeStopThink)

function QTG_TimeStart()
	Time_Stop_Enabled = false
	for i,e in pairs(Time_Stop_Datatable) do
		local ent = Entity(i)
		if e.ent then ent = e.ent end
		if !IsValid(ent) then continue end
		ent:QTGNextThink(CurTime())
		if e.onfire then
			ent:Ignite(6)
		end
		if e.type == TS_BOT then
			local mt = e.mv
			local pos, ang = e.pos, e.ang
			timer.Simple( FrameTime(), function()
				if IsValid(ent) and mt != nil and pos != nil and ang != nil then
					ent:SetPos(pos)
					ent:SetMoveType(mt)
					ent:SetAngles(ang)			
					local phy = ent:GetPhysicsObject()
					if IsValid(phy) then
						phy:EnableMotion(true)
					end
				end
			end)
		elseif e.type == TS_NPC then
			local mt = e.mv
			local pos, ang = e.pos, e.ang
			timer.Simple( FrameTime(), function()
				if IsValid(ent) and mt != nil and pos != nil and ang != nil then
					ent:QTGSetMoveType(mt)
					local phy = ent:GetPhysicsObject()
					if IsValid(phy) then
						phy:EnableMotion(true)
					end
				end
			end)
			if ent:GetClass() == 'npc_turret_floor' then
				ent:SetSaveValue('m_bEnabled',true)
			end
		elseif e.type == TS_PLY then
			ent:UnLock()
		elseif e.type == TS_PROP then
			local phy = ent:GetPhysicsObject()
			if IsValid(phy) then
				phy:EnableGravity(true)
				phy:EnableMotion(e.mot)
				if (SERVER and ent:CreatedByMap()) then
					if !phy:IsAsleep() || e.wasmoved || e.vel:Length() > 0 then
						phy:Wake()
						phy:SetVelocity(e.vel)
						phy:AddAngleVelocity( e.avel or Vector() )
					end
				else
					phy:Wake()
					phy:SetVelocity( e.vel )
					phy:AddAngleVelocity( e.avel or Vector() )
				end
			end
			if e.mv then
				ent:SetMoveType(e.mv)
			end
			if ent:GetClass() == 'npc_grenade_frag' and ent.savedtime then
				ent:SetSaveValue('m_flNextBlipTime',ent.savedblip or 0)
				ent:SetSaveValue('m_flDetonateTime',ent.savedtime)
			end
		elseif e.type == TS_DOLL then
			local size = table.Count( e.vel )
			for i = 0, size - 1 do
				local phy = ent:GetPhysicsObjectNum( i )
				if IsValid( phy ) then
					phy:SetPos( e.pos[ i ] )
					phy:EnableGravity( true )
					phy:SetVelocity( e.vel[ i ] )
					phy:AddAngleVelocity( e.avel[ i ] )
				end
			end
		elseif e.type == TS_BALL then
			local phy = ent:GetPhysicsObject()
			if IsValid( phy ) then
				ent:SetMoveType( MOVETYPE_VPHYSICS )
				phy:EnableMotion(true)
				phy:SetVelocity(e.vel)
			end
			local spawner = ent:GetSaveTable()['m_hSpawner']
			if !IsValid( spawner ) || spawner:GetClass() != 'func_combine_ball_spawner' then
				timer.Create( 'cball_' .. tostring( ent:EntIndex() ) .. '_explode', 3, 1, function()
					if IsValid(ent) then
						ent:Fire('Explode')
					end
				end )
			end
		elseif e.type == TS_FROT then
			ent:Fire('SetSpeed','1',0)
		elseif e.type == TS_TRAIN then
			ent:Fire('Resume')
		elseif e.type == TS_RPG then
			ent:SetMoveType(MOVETYPE_FLYGRAVITY)
		elseif e.type == TS_HLENT then
			ent:SetMoveType(MOVETYPE_FLYGRAVITY)
		end
		Time_Stop_Datatable = {}
	end
end

hook.Add('OnEntityCreated','QTG_TimeStop',function(ent)
	timer.Simple(0,function()
		if Time_Stop_Enabled and IsValid(ent) then
			QTG_TimeStop(ent)
		end
	end)
end)	