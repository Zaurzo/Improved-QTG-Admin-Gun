AddCSLuaFile()
ENT.Editable 		= false
ENT.Type 			= 'anim'
ENT.Base 			= 'base_anim'

ENT.Spawnable		= false
ENT.AdminOnly		= false

ENT.Radius 			= 120
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar('Int',0,'Radius')
	self:NetworkVar('Int',1,'GiveDamage')
end

function ENT:Initialize()
	self:DrawShadow(false)
	self.BarrierData = {}
	self.BarrierDamage = {}
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(99999)
		phys:EnableGravity(false)
	end
	if CLIENT then
		local bounds = Vector(self.Radius,self.Radius,self.Radius)*3
		self:SetRenderBounds(-bounds,bounds)
	end
	self:SetRadius(self.Radius)
	self:SetGiveDamage(0)
	self:SetNWInt('RemoveTime',CurTime()+8)
end

function ENT:QTGThink()
	if self.qtgtimestopisremove then return end
	
	local hitSource = self:GetPos()
	for _,e in ipairs(ents.FindInSphere(hitSource,self.Radius)) do
		self:TimeStop(e)
	end
	if self:GetNWInt('RemoveTime') < CurTime() and SERVER then
		self:QTGRemove8()
	end
end

local Hl1Ent = {
	['grenade_hand'] = true,
	['rpg_rocket'] = true,
	['crossbow_bolt_hl1'] = true,
	['grenade_mp5'] = true,
	['monster_satchel'] = true
}

function ENT:TimeStop(e)
	local classname = e:GetClass()

	if classname == 'qtg_ent_timestop_bomb' or e == self then return end

	if e:IsPlayer() and e != self.Owner and SERVER then
		self.BarrierData[e] = {isplayer=true}
		e:Lock()
		e:RemoveFlags(FL_GODMODE)
	elseif type(e) == 'NextBot' then
		e:QTGNextThink(CurTime()+21600)
		self.BarrierData[e] = {movetype = e:GetMoveType(),isnextbot = true,pos = e:GetPos(),ang = e:GetAngles()}
		e:SetMoveType(MOVETYPE_NONE)
	elseif e:IsNPC() then
		if e:GetActiveWeaponClass() != 'qtg_admin_gun' then
			e:QTGNextThink(CurTime()+21600)
			self.BarrierData[e] = {movetype = e:GetMoveType(),isnpc = true,pos = e:GetPos(),ang = e:GetAngles()}
			e:SetMoveType(MOVETYPE_NONE)
			if classname == 'npc_rollermine' or classname == 'npc_manhack' or classname == 'npc_clawscanner' or classname == 'npc_cscanner' then
				local phy = e:GetPhysicsObject()
				if IsValid(phy) then
					phy:EnableMotion(false)
				end
			end
			if classname == 'npc_turret_floor' then
				if e.turretstate == nil then e.turretstate = e:GetSaveTable().m_bEnabled end
				e:SetSaveValue('m_bEnabled',false)
			end
		end
	elseif e:IsRagdoll() and !self.BarrierData[e] then
		local storedVelocities = {}
		local storedTypes = {}
		for c = 0, e:GetPhysicsObjectCount() - 1 do
			local phy = e:GetPhysicsObjectNum( c )
			if IsValid( phy ) then
				storedVelocities[c] = phy:GetVelocity()
				if !storedTypes[c] then storedTypes[c] = phy:IsMotionEnabled() end
				phy:EnableMotion(false)
			end
		end
		if !self.BarrierData[e] then self.BarrierData[e] = {vel = storedVelocities, mv = storedTypes, isdoll = true} end
	elseif classname == 'func_rotating' and SERVER then
		self.BarrierData[e] = {isfrot = true}
		e:Fire('SetSpeed','0',0)
	elseif classname == 'func_tracktrain' and SERVER then
		self.BarrierData[e] = {istrain = true}
		e:Fire('Stop')
	else
		e:QTGNextThink(CurTime()+21600)
		if classname == 'npc_grenade_frag' then
			if !e.savedtime then e.savedtime = e:GetSaveTable().m_flDetonateTime end
			e:SetSaveValue('m_flDetonateTime',e.savedtime)
		end
		
		if (classname == 'rpg_missile' or classname == 'crossbow_bolt') then
			if !self.BarrierData[e] then self.BarrierData[e] = { ang = e:GetAngles(), isrpgmissile = true } end
			e:SetMoveType(MOVETYPE_NONE)
			-- e:SetAngles(self.BarrierData[e].ang)
		end
		
		if classname == 'prop_combine_ball' and !self.BarrierData[e] then
			if timer.Exists('cball_' .. tostring(e:EntIndex() ) .. '_explode') then
				timer.Remove('cball_' .. tostring(e:EntIndex() ) .. '_explode')
			end
			self.BarrierData[e] = {vel = e:GetVelocity(), iscball = true}
			e:SetMoveType(MOVETYPE_NONE)
			local phy = e:GetPhysicsObject()
			if IsValid(phy) then
				phy:EnableMotion(false)
			end
		end
		
		if classname == 'hunter_flechette' or classname == 'grenade_ar2' or classname == 'grenade_spit' then
			if !self.BarrierData[e] then self.BarrierData[e] = {isrpgmissile = true} end
			e:SetMoveType(MOVETYPE_NONE)
		end
		
		if classname == 'grenade_helicopter' then
			local phy = e:GetPhysicsObject()
			
			self.BarrierData[e] = {phy = phy,health = e:Health(),vel = e:GetVelocity() } e:QTGNextThink(CurTime()+21600)

			if IsValid(phy) then
				phy:SetVelocity(vector_origin)
				phy:EnableMotion(false)
			end
		end

		if Hl1Ent[classname] then
			self.BarrierData[e] = {mv = e:GetMoveType(),ishlent = true}
			e:SetMoveType(MOVETYPE_NONE)
		end
		
		local phy = e:GetPhysicsObject()
		local vel = e:GetVelocity()
		
		if !self.BarrierData[e] then
			self.BarrierData[e] = { phy = phy, health = e:Health(), vel = vel } e:QTGNextThink(CurTime()+21600)
		end
		
		if isfunction( e.SetHealth ) and self.BarrierData[e].health then e:SetHealth(self.BarrierData[e].health) end
		if IsValid(phy) then
			local avelocity = phy:GetAngleVelocity()
			if !self.BarrierData[e].avel then self.BarrierData[e].avel = avelocity end
			
			phy:SetVelocity(vector_origin)
			if self.BarrierData[e].wasmotionenabled == nil then
				self.BarrierData[e].wasmotionenabled = phy:IsMotionEnabled()
			end
			
			phy:EnableMotion(false)
		end
		e:SetVelocity(vector_origin)
	end
	e.TimeStopENT = self
end

local function QTG_EntTimeStart(self)
	self.qtgtimestopisremove = true

	for i, v in pairs(self.BarrierData) do
		if i:IsValid() then
			i:QTGNextThink(CurTime())
			if v.onfire then
				i:Ignite(6)
			end
			if v.isplayer and SERVER then
				i:UnLock()
			elseif v.isnextbot then
				i:QTGNextThink(CurTime())
				local mt = v.movetype
				local pos, ang = v.pos, v.ang
				if IsValid(i) and mt != nil and pos != nil and ang != nil then
					i:SetPos(pos)
					i:SetAngles(ang)
					i:SetMoveType(mt)
				end
			elseif v.isnpc then
				i:QTGNextThink(CurTime())
				i.NextAllowedFreeze = CurTime() + 0.11
				local mt = v.movetype
				local pos, ang = v.pos, v.ang
				timer.Simple( FrameTime() * 2, function()
					if i:IsValid() and mt != nil and pos != nil and ang != nil then
						i:SetPos(pos)
						i:SetAngles(ang)
						i:SetMoveType(mt)
						if i:GetClass() == 'npc_rollermine' or i:GetClass() == 'npc_manhack' or i:GetClass() == 'npc_clawscanner' or i:GetClass() == 'npc_cscanner' then
							local phy = i:GetPhysicsObject()
							if phy:IsValid() then
								phy:EnableMotion(true)
							end
						end
					end
				end)
				if i:GetClass() == 'npc_turret_floor' then
					i:SetSaveValue('m_bEnabled',true)
				end
			elseif v.isrpgmissile then
				i:SetMoveType(MOVETYPE_FLYGRAVITY)
			elseif v.iscball then
				i:SetMoveType(MOVETYPE_VPHYSICS)
				local phy = i:GetPhysicsObject()
				if IsValid( phy ) then
					phy:EnableMotion( true )
					phy:SetVelocity( v.vel )
				end
				timer.Create( 'cball_' .. tostring( i:EntIndex() ) .. '_explode', 3, 1, function()
					if IsValid(i) and SERVER then
						i:Fire('Explode')
					end
				end)
			elseif v.isdoll then
				for c = 0, i:GetPhysicsObjectCount() - 1 do
					local phy = i:GetPhysicsObjectNum( c )
					if IsValid( phy ) then
						if v.mv and v.mv[ c ] then
							phy:EnableMotion( v.mv[ c ] )
							phy:Wake()
						end
						if v.vel and v.vel[ c ] then
							phy:SetVelocity( v.vel[ c ] )
						end
					end
				end
			elseif v.ishlent then
				i:SetMoveType(MOVETYPE_FLYGRAVITY)
			elseif v.isfrot and SERVER then
				i:Fire('SetSpeed','1',0)
			elseif v.istrain and SERVER then
				i:Fire('Resume')
			else
				timer.Simple( 0.07, function()
					if IsValid( i ) then
						i:SetHealth( v.health )
						if IsValid( v.phy ) then
							v.phy:EnableMotion( v.wasmotionenabled )
							
							if v.vel then v.phy:SetVelocity( v.vel ) end
							if v.avel then v.phy:AddAngleVelocity( v.avel ) end
						end
						if v.vel and !i:IsPlayer() then
							i:SetVelocity( v.vel )
						end
					end
				end)
			end
		end
	end
	local damageReplica = table.Copy(self.BarrierDamage)
	timer.Simple(0,function()
		for i, v in pairs(damageReplica) do
			if IsValid(v.ent) and v.bubble == self then
				local dmg = DamageInfo()
				if IsValid(v.inf) then dmg:SetInflictor(v.inf) end
				if IsValid(v.atk) then dmg:SetAttacker(v.atk) end
				dmg:SetDamage(v.dmg)
				dmg:SetDamagePosition(v.pos)
				dmg:SetDamageType(v.typ)
				dmg:SetAmmoType(v.amm)
				dmg:SetDamageForce(v.frc)
				v.ent:TakeDamageInfo(dmg)
			end
		end
	end)
end

function ENT:OnRemove()
	QTG_EntTimeStart(self)
end

if CLIENT then
	local color = Color(255,255,0,5)
	function ENT:Draw()
		local owner = self
		local pos = self:GetPos()
		if owner:IsValid() then
			pos = owner:GetPos()+owner:OBBCenter()
		end
		render.SetColorMaterial()
		render.DrawSphere(pos,-self:GetRadius(),50,50,color)
		for i=0,5 do
			render.DrawSphere(pos,self:GetRadius()-i*10,50,50,color)
		end
	end
end