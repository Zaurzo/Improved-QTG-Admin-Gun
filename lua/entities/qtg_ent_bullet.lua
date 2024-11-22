AddCSLuaFile()
ENT.Type 			= 'anim'
ENT.Base 			= 'base_anim'

ENT.Spawnable		= false
ENT.AdminOnly		= false

local function GiveEntDamage(self,e)
	local d = DamageInfo()
	local owner = self:GetOwner()

	if owner:IsValid() then
		d:SetAttacker(owner)
	end

	d:SetInflictor(self)
	d:SetDamageType(bit.bor(DMG_AIRBOAT,DMG_BLAST))
	d:SetDamage(1e9)
	if e:IsPlayer() or e:IsNPC() or type(e) == 'NextBot' then
		d:SetDamageForce(self:GetForward()*10000)
	elseif e:GetPhysicsObject():IsValid() then
		e:GetPhysicsObject():ApplyForceCenter(self:GetForward()*100)
	end
	e:TakeDamageInfo(d)
end
	
if SERVER then
	function ENT:Initialize()
		self:_QTGSetModel('models/Items/AR2_Grenade.mdl',self:QTGGetKey())
		self:SetMaterial('models/debug/debugwhite')
		self:SetColor(Color(50,50,0))
		self:SetModelScale(self:GetModelScale()/2,0)
		self.ang = self:GetAngles()
		self:QTGIntPhy()
		self:DrawShadow(true)
		util.SpriteTrail(self,0,Color(255,100,0,255),true,2,0,0.06,0,'effects/beam_generic01')
		
		local phys = self:GetPhysicsObject()

		if phys:IsValid() then
			phys:EnableGravity(false)
		end
	end
	function ENT:QTGIntPhy()
		self:_QTGPhysicsInit(SOLID_VPHYSICS,self:QTGGetKey())
		self:_QTGSetMoveType(MOVETYPE_VPHYSICS,self:QTGGetKey())
		self:_QTGSetSolid(SOLID_BBOX,self:QTGGetKey())
		self:_QTGSetCollisionGroup(1,self:QTGGetKey())
	end
	function ENT:QTGThink()
		local ph = self:GetPhysicsObject()
		if ph:IsValid() then
			ph:SetVelocity(self:GetForward()*1e9)
			ph:SetAngles(self.ang)
		end
		local hitSource = self:GetPos()
		for _,e in pairs(ents.FindInSphere(hitSource,10)) do
			if e != self.Owner and e != self and e:Health() > 0 then
				hook.Remove('Tick',self)
				GiveEntDamage(self,e)
				timer.Simple(0,function()
					if self:IsValid() then
						self:QTGRemove12()
					end
				end)
			end
		end
		if self:WaterLevel()==3 then
			self:_QTGRemove(self:QTGGetKey())
		end
	end
else
	language.Add('qtg_ent_bullet','Physical Bullet')
end
function ENT:PhysicsCollide(d,ph)
	if d.HitEntity:GetClass() == self:GetClass() then return end
	hook.Remove('Tick',self)
	local e = d.HitEntity
	local bp = ''
	if e:IsValid() then
		GiveEntDamage(self,e)
	end
	timer.Simple(0,function()
		if self:IsValid() then
			self:QTGRemove12()
		end
	end)
	local b = {
		Num = 1,
		Src = self:GetPos(),
		Dir = self:GetForward()*1e9,
		Distance = 0.1,
		Spread = Vector(0,0,0),
		Tracer = 0,
		Force = 0,
		Damage = 0,
		AmmoType = 'none'
	}
	self:FireBullets(b)
end