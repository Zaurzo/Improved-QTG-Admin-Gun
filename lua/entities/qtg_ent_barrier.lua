AddCSLuaFile()
ENT.Type 			= 'anim'
ENT.Base 			= 'base_anim'

ENT.Spawnable		= false
ENT.AdminOnly		= false

ENT.Radius 			= 150
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar('Int',0,'Radius')
end

function ENT:Initialize()
	self:DrawShadow(false)
	self.BarrierData = {}
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
	timer.Simple(0, function()
		if !self:IsValid() then return end
		local o = self:GetOwner()
		if o:IsValid() then
			if self:IsValid() then
				o:SetNWBool('AdminGun_BarrierSpawn',true)
			else
				o:SetNWBool('AdminGun_BarrierSpawn',false)
			end
		end
	end)
end

function ENT:QTGThink()
	local o = self:GetOwner()
	
	if o:IsValid() then
		o:SetNWBool('AdminGun_BarrierSpawn',true)
		local hitSource = o:GetPos()
		self:SetPos(hitSource)
		for _,e in pairs(ents.FindInSphere(hitSource,self.Radius)) do
			if o:GetNWBool('AdminGun_Defense') or (o:IsNPC() and e != o and e != o.Owner) then
				if e:IsValid() and e:IsPlayer() and e:GetActiveWeaponClass() != 'qtg_admin_gun' and e != o and e != o.Owner then
					local hitDirection = (e:GetPos() - hitSource):GetNormal()
					e:SetLocalVelocity(hitDirection * 500 + vector_up * 10)
				end
				self:TimeStop(e)
			end
		end
		if (o:GetNWBool('AdminGun_Defense') and o:Alive()) or (o:IsNPC() and o:Health() >= 0) then elseif SERVER then
			self:QTGRemove99()
		end
	elseif SERVER then
		self:QTGRemove98()
	end	
end

local Hl1Ent = {
	'grenade_hand',
	'rpg_rocket',
	'crossbow_bolt_hl1',
	'grenade_mp5',
	'monster_satchel'
}

function ENT:TimeStop(e)	
	if type(e) == 'NextBot' then
		e:QTGNextThink(CurTime()+21600)
		self.BarrierData[e] = {movetype = e:GetMoveType(),isnextbot = true,pos = e:GetPos(),ang = e:GetAngles()}
		e:SetMoveType(MOVETYPE_NONE)
	elseif e:IsNPC() then
		if e:GetActiveWeaponClass() != 'qtg_admin_gun' then
			e:QTGNextThink(CurTime()+21600)
			self.BarrierData[e] = {movetype = e:GetMoveType(),isnpc = true,pos = e:GetPos(),ang = e:GetAngles()}
			e:SetMoveType(MOVETYPE_NONE)
		end
		if e:GetClass() == 'npc_rollermine' or e:GetClass() == 'npc_manhack' or e:GetClass() == 'npc_clawscanner' or e:GetClass() == 'npc_cscanner' then
			local phy = e:GetPhysicsObject()
			if IsValid(phy) then
				phy:EnableMotion(false)
			end
		end
		if e:GetClass() == 'npc_turret_floor' then
			if e.turretstate == nil then e.turretstate = e:GetSaveTable().m_bEnabled end
			e:SetSaveValue('m_bEnabled',false)
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
	elseif e:GetClass() == 'func_rotating' and SERVER then
		self.BarrierData[e] = {isfrot = true}
		e:Fire('SetSpeed','0',0)
	elseif e:GetClass() == 'func_tracktrain' and SERVER then
		self.BarrierData[e] = {istrain = true}
		e:Fire('Stop')
	elseif e.Owner != self:GetOwner() then
		e:QTGNextThink(CurTime()+21600)
		if e:GetClass() == 'npc_grenade_frag' then
			if !e.savedtime then e.savedtime = e:GetSaveTable().m_flDetonateTime end
			e:SetSaveValue('m_flDetonateTime',e.savedtime)
		end
		
		if (e:GetClass() == 'rpg_missile' or e:GetClass() == 'crossbow_bolt') then
			if !self.BarrierData[e] then self.BarrierData[e] = { ang = e:GetAngles(), isrpgmissile = true } end
			e:SetMoveType(MOVETYPE_NONE)
			-- e:SetAngles(self.BarrierData[e].ang)
		end
		
		if e:GetClass() == 'prop_combine_ball' and !self.BarrierData[e] then
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
		
		if e:GetClass() == 'hunter_flechette' or e:GetClass() == 'grenade_ar2' or e:GetClass() == 'grenade_spit' then
			if !self.BarrierData[e] then self.BarrierData[e] = {isrpgmissile = true} end
			e:SetMoveType(MOVETYPE_NONE)
		end
		
		if e:GetClass() == 'grenade_helicopter' then
			local phy = e:GetPhysicsObject()
			
			self.BarrierData[e] = {phy = phy,health = e:Health(),vel = e:GetVelocity() } e:QTGNextThink(CurTime()+21600)

			if IsValid(phy) then
				phy:SetVelocity(Vector())
				phy:EnableMotion(false)
			end
		end
		
		for k, v in pairs(Hl1Ent) do
			if e:GetClass() == v then
				self.BarrierData[e] = {mv = e:GetMoveType(),ishlent = true}
				e:SetMoveType(MOVETYPE_NONE)
			end
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
			
			phy:SetVelocity( Vector() )
			if self.BarrierData[e].wasmotionenabled == nil then
				self.BarrierData[e].wasmotionenabled = phy:IsMotionEnabled()
			end
			
			phy:EnableMotion(false)
		end
		e:SetVelocity(Vector())
	end
end

local function QTG_EntTimeStart(self)
	for i, v in pairs(self.BarrierData) do
		if IsValid(i) then
			i:QTGNextThink(CurTime())
			if v.onfire then
				i:Ignite(6)
			end
			-- if v.isplayer then
				-- i:SetMoveType(v.mv)
				-- i:Freeze(false)
				-- i:SetVelocity(v.vel)
			if v.isnextbot then
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
					if IsValid(i) and mt != nil and pos != nil and ang != nil then
						i:SetPos(pos)
						i:SetAngles(ang)
						i:SetMoveType(mt)
						
						if i:GetClass() == 'npc_rollermine' or i:GetClass() == 'npc_manhack' or i:GetClass() == 'npc_clawscanner' or i:GetClass() == 'npc_cscanner' then
							local phy = i:GetPhysicsObject()
							if IsValid(phy) then
								phy:EnableMotion(true)
							end
						end
					end
				end )
					
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
				end )
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
				end )
			end
		end
	end
end

function ENT:OnRemove()
	QTG_EntTimeStart(self)

	local o = self:GetOwner()

	if o:IsValid() then
		o:SetNWBool('AdminGun_BarrierSpawn',false)
	end
end

if CLIENT then
	local colorfallback = Color(0, 255, 255, 15)
	local isfunction = isfunction

	local function getGun(self)
		local get = self.GetWeapon

		if isfunction(get) then
			local wep = get(self, 'qtg_admin_gun')

			return wep
		end
	end
	
	function ENT:DrawTranslucent()
		local owner = self:GetOwner()
		if !owner:IsValid() then return end

		local color = colorfallback

		if owner:IsPlayer() then
			local wep = getGun(owner)

			if IsValid(wep) then
				if wep:GetNWBool('LaserRainbow', false) then
					color = HSVToColor((CurTime() * 100) % 360, 1, 1)
					color.a = 15
				else
					local rgb = string.Split(wep:GetNWString('LaserColor', '255,0,0'), ',')
					color = Color(rgb[1], rgb[2], rgb[3], 15)
				end
			end
		end

		local pos = owner:GetPos()+owner:OBBCenter()

		render.SetColorMaterial()
		render.DrawSphere(pos,-self:GetRadius(),50,50,color)

		for i=0,5 do
			render.DrawSphere(pos,self:GetRadius()-i*10,50,50,color)
		end
	end
end