AddCSLuaFile()

function EFFECT:Init(data)
	local startPos = data:GetOrigin()
	local emitter = ParticleEmitter(startPos)

	self.start = startPos

	if not emitter then return end

	for i = 1, 50 do
		local p = emitter:Add("effects/fleck_antlion"..math.random(1,2), startPos + Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(-32, 32)))
		p:SetVelocity(VectorRand() * 64)
		p:SetLifeTime(math.Rand(-0.3, 0.1))
		p:SetDieTime(math.Rand(0.7, 1))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(math.Rand(1.5, 1.7))
		p:SetEndSize(math.Rand(1.8, 2))
		p:SetRoll( math.Rand(360, 520))
		p:SetRollDelta( math.random(-2, 2 ))
		p:SetColor(30, 30, 30)	
	end
		
	for i = 1, 20 do
		local p = emitter:Add("particles/smokey", startPos + Vector(math.Rand(-8, 9), math.Rand(-8, 8), math.Rand(-32, 32)))
		p:SetVelocity(VectorRand() * 64)
		p:SetDieTime(math.Rand(0.4, 0.8))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(math.Rand(8, 12))
		p:SetEndSize(math.Rand(24, 32))
		p:SetRoll(math.Rand(360, 520 ))
		p:SetRollDelta(math.random(-2, 2))
		p:SetColor(20, 20, 20)	
	end

	emitter:Finish()

	self.Emitter = emitter
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end