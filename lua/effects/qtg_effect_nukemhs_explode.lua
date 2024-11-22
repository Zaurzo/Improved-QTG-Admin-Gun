AddCSLuaFile()

local glow1 = CreateMaterial("glow1", "UnlitGeneric", {["$basetexture"] = "sprites/light_glow02", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
local glow2 = CreateMaterial("glow2", "UnlitGeneric", {["$basetexture"] = "sprites/yellowflare", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
local glow3 = CreateMaterial("glow3", "UnlitGeneric", {["$basetexture"] = "sprites/redglow2", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})

function EFFECT:Init(data)
	self.start = data:GetOrigin()
	self.lifetime = CurTime() + 70
	
	self.radius = 600
	
	self.glowsalpha = 255
	self.mainglowsalpha = 255
	self.glows = 120000
	self.redalpha = 255
	self.mushroom = {}
	
	self.Emitter = ParticleEmitter(self.start)

	for i = 1, 360 do //main dust
		local p = self.Emitter:Add("particle/particle_smokegrenade", self.start)
		p:SetDieTime(math.Rand(10, 15))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(2100)
		p:SetEndSize(1000)
		p:SetRoll(math.Rand(-10, 10))
		p:SetRollDelta(math.Rand(-10, 10))
				
		local vec = VectorRand()
		vec.z = 0
		local pos = (self.start + vec * 2)
					
		p:SetVelocity((pos - self.start):GetNormal() * 10000)
		p:SetColor(100, 100, 100)
	end
		
	for i = 1, 250 do
		local vec = VectorRand()
		vec.z = 0
		
		local p = self.Emitter:Add("particles/smokey", self.start + vec * 1500)
		p:SetDieTime(math.Rand(8, 12))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(math.Rand(1900, 2100)^math.Rand(0.7, 1.1))
		p:SetEndSize(800)
		p:SetRoll(math.Rand(-10, 10))
		p:SetRollDelta(math.Rand(-10, 10))
				
		local vec = VectorRand()
		vec.z = 0
		local pos = (self.start + vec * 2)
					
		p:SetVelocity((pos - self.start):GetNormal() * math.random(7000, 10000))
		p:SetColor(100, 100, 100)
	end
	
	for i = 1, 360 do //main up dust
		local p = self.Emitter:Add("particle/particle_smokegrenade", self.start + Vector(0, 0, 5000))
		p:SetDieTime(math.Rand(10, 15))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(math.Rand(1000, 1500))
		p:SetEndSize(1000)
		p:SetRoll(math.Rand(-10, 10))
		p:SetRollDelta(math.Rand(-10, 10))
				
		local vec = VectorRand()
		vec.z = 0
		local pos = (self.start + vec * 2)
					
		p:SetVelocity((pos - self.start):GetNormal() * 8000)
		p:SetColor(100, 100, 100)
	end
	
	for i = 1, 200 do //big stuff first
		local p = self.Emitter:Add("effects/fleck_cement" .. math.random(1, 2), self.start + Vector(0, 0, 5000))
		p:SetDieTime(math.Rand(15, 20))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(math.Rand(100, 300))
		p:SetEndSize(200)
		p:SetRoll(math.Rand(-10, 10))
		p:SetRollDelta(math.Rand(-10, 10))
				
		local vec = VectorRand()
		vec.z = 0
		local pos = (self.start + vec * 2)
		
		p:SetVelocity((Vector(0, 0, math.random(500, 1000)) + vec * math.random(1500, 6000)) + (pos - self.start):GetNormal() * math.random(1000, 7000))
		p:SetGravity(Vector(0, 0, math.random(-150, -90)))
		p:SetColor(80, 80, 80)
	end
	
	/*for i = 1, 360 do
		local p = self.Emitter:Add("particle/particle_smokegrenade", self.start)
		p:SetDieTime(math.Rand(10, 15))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(math.Rand(600, 2000))
		p:SetEndSize(1000)
		p:SetRoll(math.Rand(-10, 10))
		p:SetRollDelta(math.Rand(-10, 10))
				
		local vec = VectorRand()
		vec.z = 0
		local pos = (self.start + vec * 2)
					
		p:SetVelocity((pos - self.start):GetNormal() * math.random(1500, 5000))
		p:SetColor(100, 100, 100)
	end*/

	for i = 1, 280 do //big stuff
		local p = self.Emitter:Add("effects/fleck_cement" .. math.random(1, 2), self.start)
		p:SetDieTime(math.Rand(15, 20))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(math.Rand(100, 300))
		p:SetEndSize(200)
		p:SetRoll(math.Rand(-10, 10))
		p:SetRollDelta(math.Rand(-10, 10))
				
		local vec = VectorRand()
		vec.z = 0
		local pos = (self.start + vec * 2)
		
		p:SetVelocity((Vector(0, 0, math.random(500, 1000)) + vec * math.random(500, 6000)) + (pos - self.start):GetNormal() * math.random(200, 5000))
		p:SetGravity(Vector(0, 0, math.random(-120, -50)))
		p:SetColor(80, 80, 80)
	end

	for i = 1, 280 do //small stuff
		local p = self.Emitter:Add("effects/fleck_cement" .. math.random(1, 2), self.start)
		p:SetDieTime(math.Rand(15, 20))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(math.Rand(50, 200))
		p:SetEndSize(200)
		p:SetRoll(math.Rand(-10, 10))
		p:SetRollDelta(math.Rand(-10, 10))
				
		local vec = VectorRand()
		vec.z = 0
		local pos = (self.start + vec * 2)
		
		p:SetVelocity((Vector(0, 0, math.random(600, 1000)) + vec * math.random(400, 4000)) + (pos - self.start):GetNormal() * math.random(100, 3000))
		p:SetGravity(Vector(0, 0, math.random(-120, -50)))
		p:SetColor(80, 80, 80)
	end
	
	for i = 1, 255 do //ideal things
		local p = self.Emitter:Add("sprites/heatwave", self.start)
		p:SetDieTime(math.Rand(10, 15))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(math.Rand(4000, 8000))
		p:SetEndSize(5000)
		p:SetRoll(math.Rand(-5, 5))
		p:SetRollDelta(math.Rand(-5, 5))
				
		local vec = VectorRand()
		vec.z = 0
		local pos = (self.start + vec * 2)
					
		p:SetVelocity((pos - self.start):GetNormal() * math.random(3500, 9000))
		p:SetColor(100, 100, 100)
	end
	
	///////////////////
	//here is mushroom #region mushroom lol :D
	///////////////////
	
	for i = 1, 260 do
		local vec = VectorRand()
		vec.z = 0
		local pos = (self.start + vec * 2)
		
		local rand = math.random(-400, 400)
		local rand2 = math.random(-400, 400)
		
		local p = self.Emitter:Add("particles/flamelet" .. math.random(1, 5), self.start + Vector(rand, rand2, 0))
		p:SetDieTime(math.Rand(15, 25))
		p:SetStartAlpha(200)
		p:SetEndAlpha(0)
		p:SetStartSize(math.random(400, 800))
		p:SetEndSize(300)
		p:SetRoll(math.Rand(-10, 10))
		p:SetRollDelta(math.Rand(-10, 10))			
		p:SetVelocity(((pos - self.start):GetNormal() * math.random(-40, 40)) + Vector(0, 0, 2500))
		
		timer.Create("stopshit" .. math.random(-1337, 1337) .. i, i / 70, 1, function()
			p:SetVelocity(Vector(0, 0, 0))
		end)
		
		rand = math.random(-1900, 1900)
		rand2 = math.random(-1900, 1900)
			
		local p = self.Emitter:Add("particles/smokey", self.start + Vector(rand, rand2, 200))
		p:SetDieTime(math.Rand(35, 50))
		p:SetStartAlpha(150)
		p:SetEndAlpha(0)
		p:SetStartSize(0)
		p:SetEndSize(math.random(600, 1200))
		p:SetRoll(math.Rand(-5, 5))
		p:SetRollDelta(math.Rand(-5, 5))						
		p:SetVelocity(((pos - self.start):GetNormal() * math.random(-30, 30)) + Vector(0, 0, math.random(-10, 10)))
		p:SetColor(80, 80, 80)
		
		self:createMush("particles/flamelet" .. math.random(1, 5), Vector(rand, rand2, 200), ((pos - self.start):GetNormal() * math.random(-50, 50)) + Vector(0, 0, math.random(-10, 10)), false)
	end
	
	timer.Simple(4, function()
		for i = 1, 380 do
			local vec = VectorRand()
			vec.z = 0
			local pos = (self.start + vec * 2)
			
			local rand = math.random(-400, 400)
			local rand2 = math.random(-400, 400)
			
			local p = self.Emitter:Add("particles/smokey", self.start + Vector(rand, rand2, i * 25))
			p:SetDieTime(math.Rand(35, 50))
			p:SetStartAlpha(150)
			p:SetEndAlpha(0)
			p:SetStartSize(20)
			p:SetEndSize(math.random(600, 1200))
			p:SetRoll(math.Rand(-5, 5))
			p:SetRollDelta(math.Rand(-5, 5))						
			p:SetVelocity((pos - self.start):GetNormal() * math.random(-10, 10))
			p:SetColor(80, 80, 80)
			
			rand = math.random(-2100, 2100)
			rand2 = math.random(-2100, 2100)
		
			local p = self.Emitter:Add("particles/smokey", self.start + Vector(math.random(-1500, 1500), math.random(-1500, 1500), 8000 + math.random(-1500, 1900)))
			p:SetDieTime(math.Rand(35, 50))
			p:SetStartAlpha(150)
			p:SetEndAlpha(0)
			p:SetStartSize(0)
			p:SetEndSize(math.random(600, 1200))
			p:SetRoll(math.Rand(-5, 5))
			p:SetRollDelta(math.Rand(-5, 5))					
			p:SetVelocity(((pos - self.start):GetNormal() * math.random(-20, 20)) + Vector(0, 0, math.random(-20, 20)))
			p:SetColor(80, 80, 80)
		
			self:createMush("particles/flamelet" .. math.random(1, 5), Vector(rand, rand2, 8000 + math.random(-1500, 1900)), ((pos - self.start):GetNormal() * math.random(-50, 50)) + Vector(0, 0, math.random(-30, 30)), false)
		end
		
		self.Emitter:Finish()
	end)
	
	//////mushroom end///////#endregion lol :D
end

function EFFECT:createMush(text, pos, vel, col)
	local p = self.Emitter:Add(text, self.start + pos)
	p:SetDieTime(math.Rand(20, 25))
	p:SetStartAlpha(255)
	p:SetEndAlpha(0)
	p:SetStartSize(math.random(500, 1000))
	p:SetEndSize(1000)
	p:SetRoll(math.Rand(-10, 10))
	p:SetRollDelta(math.Rand(-10, 10))
						
	p:SetVelocity(vel)
	
	if col then
		p:SetColor(80, 80, 80)
	end
end

function EFFECT:Think()
	if self.lifetime - CurTime() > 0 then
		if self.glowsalpha > 0 then self.glowsalpha = self.glowsalpha - 0.08 end
		if self.mainglowsalpha > 0 then self.mainglowsalpha = self.mainglowsalpha - 0.37 end
		if self.redalpha > 0 then self.redalpha = self.redalpha - 0.07 end
		
		return true
	else
		return false
	end
end

function EFFECT:Render()
	render.SetMaterial(glow1)
	render.DrawSprite(self.start, self.glows, self.glows, Color(255, 240, 220, 2 * self.glowsalpha))

	render.SetMaterial(glow2)
	render.DrawSprite(self.start, self.glows, self.glows, Color(255, 240, 220, 1.1 * self.mainglowsalpha))
	render.DrawSprite(self.start, self.glows, self.glows, Color(255, 240, 220, 0.74 * self.mainglowsalpha))
	
	render.SetMaterial(glow3)
	render.DrawSprite(self.start, 80000, 80000, Color(255, 240, 220, self.redalpha))
	
	render.SetMaterial(glow2)
	render.DrawSprite(self.start + Vector(0, 0, 6000), 19000, 2500, Color(255, 240, 220, 0.8 * self.redalpha))
	
	render.DrawSprite(self.start + Vector(0, 0, 7000), 3500, 21000, Color(255, 240, 220, 0.8 * self.redalpha))
	render.DrawSprite(self.start + Vector(0, 0, 7000), 21000, 3500, Color(255, 240, 220, 0.8 * self.redalpha))
end







