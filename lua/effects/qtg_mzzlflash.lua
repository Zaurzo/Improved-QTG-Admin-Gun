// Based on strider muzzle flash by Teta_Bonita(Tater_Bonanza)
local matBlueMuzzle	= Material("effects/strider_muzzle")
local matBlueMuzzle2	= Material("sprites/ar2_muzzle1")
matBlueMuzzle:SetInt("$spriterendermode",9)

function EFFECT:Init(data)
	self.Shooter = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.WeaponEnt = self.Shooter:GetActiveWeapon()
	self.KillTime = 0
	self.ShouldRender = false

	if GetViewEntity() == LocalPlayer() then 
		self.ViewModel = LocalPlayer():GetViewModel()
		self.SpriteSize = 30
		self.FlashSize = 48
		self.FlashSize2 = 110
	else
		self.ViewModel = self.WeaponEnt
		self.SpriteSize = 55
		self.FlashSize = 110
		self.FlashSize2 = 220
	end
	if not self.ViewModel:IsValid() then return end	
	local Muzzle = 	self.ViewModel:GetAttachment(self.Attachment)
	self:SetRenderBoundsWS(self.Owner:GetShootPos() + Vector()*self.SpriteSize,Muzzle.Pos - Vector()*self.SpriteSize)
	self.KillTime = CurTime() + 2
	self.ShouldRender = true
end

function EFFECT:Think()
	if CurTime() > self.KillTime then return false end
	if !self.Shooter then return false end
	if self.WeaponEnt ~= self.Shooter:GetActiveWeapon() then return false end
	if !self.ViewModel:IsValid() then return false end
	return true
end

function EFFECT:Render()
	if !self.ShouldRender then return end
	local Muzzle = self.ViewModel:GetAttachment(self.Attachment)
	if !Muzzle then return end
	local RenderPos = Muzzle.Pos
	self:SetRenderBoundsWS(RenderPos + Vector()*self.SpriteSize,RenderPos - Vector()*self.SpriteSize)	
	local invintrplt = (self.KillTime - CurTime())/2
	local intrplt = 1 - invintrplt
	local size
	if invintrplt > 0.8 then
		render.SetMaterial(matBlueMuzzle)
		size = 2*self.FlashSize*(invintrplt - 0.5)
		local alpha = 1275*(invintrplt - 0.8)
		render.DrawSprite(RenderPos,size,size,Color(255,255,255,alpha))
	end
	if invintrplt > 0.8 then
		render.SetMaterial(matBlueMuzzle2)
		size = 2*self.FlashSize2*(invintrplt - 0.5)
		local alpha = 1275*(invintrplt - 0.8)
		render.DrawSprite(RenderPos,size,size,Color(10,220,235,alpha))
	end
end
