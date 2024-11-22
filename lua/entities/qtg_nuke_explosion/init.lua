AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local i = 500

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:PhysicsInitBox(Vector(-1, -1, 0), Vector(1, 1, 1))
	self:DrawShadow(false)
	
	self.Time = CurTime() + 4
	
	local phys = self:GetPhysicsObject()
			
	local ef = EffectData()
	ef:SetOrigin(self:GetPos())
	util.Effect("qtg_effect_nukemhs_explode", ef)
	
	for k, v in pairs(player.GetAll()) do v:ViewPunch(Angle(-8, 0, math.Rand(-7, 7))) end
	
	if IsValid(phys) then phys:EnableMotion(false) end
	
	timer.Simple(11, function()
		for k, v in pairs(player.GetAll()) do v:ViewPunch(Angle(0, 0, math.Rand(-15, 15))) end
		
		timer.Simple(5, function()
			for k, v in pairs(player.GetAll()) do v:ViewPunch(Angle(math.Rand(-7, 7), 0, math.Rand(-7, 7))) end
		end)
		
		timer.Simple(9, function()
			for k, v in pairs(player.GetAll()) do v:ViewPunch(Angle(0, 0, math.Rand(-7, 7))) end
		end)
	end)
	
	timer.Simple(20, function()
		if not IsValid(self) then return end
		self:QTGRemove11()
	end)
	
	timer.Create("shitthings" .. self:EntIndex(), 0.1, 20, function()
		if not IsValid(self) then return end
		
		local owner = self:GetOwner()
	
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 900)) do //very vaporize
			if not IsValid(owner) then owner = self end
		
			if v:IsNPC() then
				local ef = EffectData()
				ef:SetOrigin(v:GetPos())
				util.Effect("qtg_effect_vaporize_mhs", ef)
				
				v:QTGRemove12()
			end
		end
	end)
end

function ENT:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then owner = self end
		
	i = i + 500
		
	util.ScreenShake(self:GetPos(), 3, 3, 1, 9999999)
			
	for k, v in pairs(ents.FindInSphere(self:GetPos(), i)) do
		constraint.RemoveAll(v)
		
		if string.find(v:GetClass(), "prop") != nil then
			v:Fire("enablemotion", "", 0)
		end
			
		if CurTime() - self.Time > 0 then
			if v:GetClass() == "func_breakable" then v:Fire("break", "", i) end
			
			if IsValid(v) and v:IsPlayer() and v:GetActiveWeaponClass() != "qtg_admin_gun" then
				v:SetHealth(0)
				v:TakeDamage(999999999999, owner, self)
			end
			if IsValid(v) and v:IsNPC() or v:Health() > 0 then
				if !v:IsPlayer() then
					v:SetHealth(0)
					v:TakeDamage(999999999999, owner, self)
				end
			end
			if owner:IsPlayer() then
				if v:IsPlayer() and v:Alive() and v:GetActiveWeaponClass() != "qtg_admin_gun" then
					v:KillSilent()
					net.Start("PlayerKilledByPlayer")
						net.WriteEntity(v)
						net.WriteString(self.ClassName)
						net.WriteEntity(owner)
					net.Broadcast()
					MsgAll(owner:Nick().." killed "..v:Nick().." using "..self.ClassName.. "\n")
				end
				if IsValid(v) and (v:IsNPC() or v:Health() > 0) and !v:IsPlayer() then
					v:QTGRemove13()
					net.Start("PlayerKilledNPC")
						net.WriteString(v:GetClass())
						net.WriteString(self.ClassName)
						net.WriteEntity(owner)
					net.Broadcast()
				end
			end
			if IsValid(v) && (v:GetClass() == "prop_door_rotating" || v:GetClass() == "prop_door" || v:GetClass() == "func_door_rotating" || v:GetClass() == "func_door") && v:Visible(self) then
				local door = ents.Create("prop_physics")
				door:SetModel(v:GetModel() or '')
				door:SetPos(v:GetPos())
				door:SetAngles(v:GetAngles())
				door:Spawn()
				door:Activate()
				if v:GetSkin() != nil then
					door:SetSkin(v:GetSkin())
				end
				door:SetMaterial(v:GetMaterial() or '')
				v:QTGRemove14()
				timer.Simple(3,function()
					if IsValid(door) then
						door:SetCollisionGroup(1)
					end
				end)
				local phys = door:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocity(((door:GetPos() -self:GetPos()) *500 +(door:GetPos() +door:GetForward() *400 -self:GetPos()) +(door:GetPos() +door:GetUp() *200 -self:GetPos()) *140))
				end
			end
		end
			
		local phys = v:GetPhysicsObject()
			
		if v:GetMoveType() != 6 or not IsValid(phys) then
			if v:IsValid() then
				v:SetVelocity((v:GetPos() - self:GetPos()):GetNormal() * 700)
			end
		elseif phys:IsValid() then
			if v:GetClass() == "prop_ragdoll" then
				if math.random(1, 10) == 5 then 
					local ef = EffectData()
					ef:SetOrigin(v:GetPos())
					util.Effect("qtg_effect_vaporize_mhs", ef)			

					v:QTGRemove15() 
				end
				
				phys:ApplyForceCenter((v:GetPos() - self:GetPos()):GetNormal() * 10000 * i)
			else
				phys:ApplyForceOffset((v:GetPos() - self:GetPos()):GetNormal() * 90000 * i, v:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), math.random(20, 40)))
			end
		end
	end
end