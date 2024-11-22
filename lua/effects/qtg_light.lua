function EFFECT:Init(data)
	self.Origin = data:GetOrigin()
	local dlight = DynamicLight(self:EntIndex())
	if ( dlight ) then
		local r, g, b, a = self:GetColor()
		dlight.Pos = self:GetPos()
		dlight.r = 10
		dlight.g = 235
		dlight.b = 255
		dlight.Brightness = 0.9
		dlight.Size = 200
		dlight.Decay = 1000
		dlight.DieTime = CurTime() + 2
        dlight.Style = 0
	end
end
function EFFECT:Think() end
function EFFECT:Render() end