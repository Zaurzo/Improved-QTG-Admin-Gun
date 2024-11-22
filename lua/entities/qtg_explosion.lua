AddCSLuaFile()

ENT.Type 			= 'anim'
ENT.Base 			= 'base_anim'

ENT.Spawnable		= false
ENT.AdminOnly		= false

ENT.Radius 			= 200
ENT.Damage			= 1e9

local ReplaceList = {
	'prop_door_rotating',
	'prop_door',
	'func_door_rotating',
	'func_door'
}
local ReplaceList2 = {
	'func_physbox'
}

function ENT:Initialize()
	local o = self:GetOwner()
	if !o:IsValid() then return end
	local tr = o:GetEyeTrace()
	local Pos1 = tr.HitPos + tr.HitNormal
	local Pos2 = tr.HitPos - tr.HitNormal
	if SERVER then
		self:SetNoDraw(true)
		self:DrawShadow(false)
		util.BlastDamage(self,o,self:GetPos(),self.Radius,self.Damage)
		
		local lt = ents.Create('light_dynamic')

		if lt:IsValid() then
			lt:SetPos(tr.HitPos+(tr.HitNormal*3))
			lt:Spawn()
			lt:SetKeyValue('_light','255 100 0')
			lt:SetKeyValue('distance',500)
			lt:SetParent()
			lt:Fire('kill','',0.1)
		end

		for _,e in ipairs(ents.FindInSphere(self:GetPos(),self.Radius)) do
			for k, v in pairs(ReplaceList) do
				if e:IsValid() and e:GetClass() == v then
					local d = ents.Create('prop_physics')
					d:SetModel(e:GetModel())
					d:SetPos(e:GetPos())
					d:SetAngles(e:GetAngles())
					d:Spawn()
					d:Activate()
					if e:GetSkin() != nil then
						d:SetSkin(e:GetSkin())
					end
					d:SetMaterial(e:GetMaterial())
					e:Remove()
					timer.Simple(3,function()
						if d:IsValid() then
							d:SetCollisionGroup(1)
						end
					end)
					local phys = d:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(((d:GetPos()-self:GetPos())*500+(d:GetPos()+d:GetForward()*400-self:GetPos())+(d:GetPos()+d:GetUp()*200-self:GetPos())*140))
					end
				end
			end
			for k, v in pairs(ReplaceList2) do
				if e:IsValid() and e:GetClass() == v then
					local d = ents.Create('prop_physics')
					d:SetModel(e:GetModel())
					d:SetPos(e:GetPos())
					d:SetAngles(e:GetAngles())
					d:Spawn()
					d:Activate()
					if e:GetSkin() != nil then
						d:SetSkin(e:GetSkin())
					end
					d:SetMaterial(e:GetMaterial())
					e:Remove()
					local phys = d:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(((d:GetPos() -self:GetPos()) *500 +(d:GetPos() +d:GetForward() *400 -self:GetPos()) +(d:GetPos() +d:GetUp() *200 -self:GetPos()) *140))
					end
				end
			end
		end
		self:Remove()
	else
		local effectdata = EffectData()
		effectdata:SetStart(self:GetPos())
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(1)
		util.Effect('Explosion',effectdata)
		util.Decal('Scorch',Pos1,Pos2)
	end
end