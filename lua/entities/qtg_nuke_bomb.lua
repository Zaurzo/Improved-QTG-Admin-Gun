AddCSLuaFile()
ENT.Type 			= 'anim'
ENT.Base 			= 'base_anim'

ENT.Spawnable		= false
ENT.AdminOnly		= false

function ENT:Initialize()
	if CLIENT then return end
	self:SetModel('models/Combine_Helicopter/helicopter_bomb01.mdl')
	self:RebuildPhysics()
	timer.Create('QTG_Nuke_Time',3,1,function()
		self:QTGRemove8()
	end)
end

function ENT:RebuildPhysics()
	self.ConstraintSystem = nil
	self:PhysicsInitSphere(15,'metal_bouncy')
	self:SetCollisionBounds(Vector(100,100,100),Vector(100,100,100))
	self:PhysWake()
end

local BounceSound = Sound('garrysmod/balloon_pop_cute.wav')

function ENT:PhysicsCollide(d,p)	
	if !p:IsValid() then return end

	if (d.Speed > 60 && d.DeltaTime > 0.2) then
		local pitch = 32 + 128 - 30
		sound.Play(BounceSound,self:GetPos(),75,math.random(pitch-10,pitch+10),math.Clamp(d.Speed/150,0,1))
	end

	local LastSpeed = math.max(d.OurOldVelocity:Length(),d.Speed)
	local NewVelocity = p:GetVelocity()

	NewVelocity:Normalize()

	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

	local TargetVelocity = NewVelocity * LastSpeed * 0.9
	
	p:SetVelocity(TargetVelocity)
	p:AddAngleVelocity(TargetVelocity)
end

function ENT:OnTakeDamage(d) return end

function ENT:OnRemove()
	timer.Stop('QTG_Nuke_Time')
	if SERVER then
		local e = ents.Create('qtg_nuke_explosion')
		e:SetPos(self:GetPos())
		e:SetOwner(self.Owner)
		e:Spawn()
		self:QTGRemove9()
	end
end