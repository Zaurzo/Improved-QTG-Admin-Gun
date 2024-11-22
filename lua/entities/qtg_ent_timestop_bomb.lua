AddCSLuaFile()
ENT.Editable 		= false
ENT.Type 			= 'anim'
ENT.Base 			= 'base_anim'

ENT.Spawnable		= false
ENT.AdminOnly		= false

ENT.Radius 			= 10
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

if SERVER then
	function ENT:Initialize()
		self:_QTGSetModel('models/props_combine/breenglobe.mdl',self:QTGGetKey())
		self:QTGIntPhy()
		self:DrawShadow(false)

		local phys = self:GetPhysicsObject()

		if phys:IsValid() then
			phys:EnableGravity(false)
		end
	end
	function ENT:QTGIntPhy()
		if self:IsValid() then
			self:_QTGPhysicsInit(SOLID_VPHYSICS,self:QTGGetKey())
		end
		self:_QTGSetMoveType(MOVETYPE_VPHYSICS,self:QTGGetKey())
		self:_QTGSetSolid(SOLID_BBOX,self:QTGGetKey())
		self:_QTGSetCollisionGroup(1,self:QTGGetKey())
	end
	function ENT:QTGThink()
		local ph = self:GetPhysicsObject()
		if ph:IsValid() then
			ph:SetVelocity(self:GetForward()*1e9)
		end
		local hitSource = self:GetPos()
		for _,e in pairs(ents.FindInSphere(hitSource,self.Radius)) do
			if e != self.Owner and e != self and e:Health() > 0 then
				hook.Remove('Tick',self)
				timer.Simple(0,function()
					if self:IsValid() then
						self:QTGRemove15(self:QTGGetKey())
					end
				end)
			end
		end
	end
	function ENT:PhysicsCollide(d,ph)
		hook.Remove('Tick',self)
		timer.Simple(0,function()
			if self:IsValid() then
				self:QTGRemove12()
			end
		end)
	end
	function ENT:OnRemove()
		local e = ents.Create('qtg_ent_timestop')
		e:SetPos(self:GetPos())
		e:SetOwner(self.Owner)
		e:Spawn()

		local owner = self:GetOwner()

		if owner:IsValid() and owner:IsPlayer() and owner:GetActiveWeaponClass() == 'qtg_admin_gun' then
			local t = owner.QTG_AdminGun_TimeStopBombs

			if !t then
				t = {}
				owner.QTG_AdminGun_TimeStopBombs = t
			end

			t[#t+1] = e
		end
	end
else
	local color = Color(255,255,0,20)
	function ENT:Draw()
		local owner = self
		local pos = self:GetPos()
		if owner:IsValid() then
			pos = owner:GetPos()+owner:OBBCenter()
		end
		render.SetColorMaterial()
		render.DrawSphere(pos,self.Radius,50,50,color)
	end
end