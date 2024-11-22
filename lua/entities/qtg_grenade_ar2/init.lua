
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
include( 'outputs.lua' )


MAX_AR2_NO_COLLIDE_TIME = 0.2

AR2_GRENADE_MAX_DANGER_RADIUS	= 300

// Moved to HL2_SharedGameRules because these are referenced by shared AmmoDef functions
local    sk_plr_dmg_smg1_grenade	= GetConVarNumber( "sk_plr_dmg_smg1_grenade", 100 )
local    sk_npc_dmg_smg1_grenade	= GetConVarNumber( "sk_npc_dmg_smg1_grenade", 50 )
local    sk_max_smg1_grenade		= GetConVarNumber( "sk_max_smg1_grenade", 3 )

local	  sk_smg1_grenade_radius		= GetConVarNumber( "sk_smg1_grenade_radius","250")

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self:Precache( )
	self:SetModel( "models/Items/AR2_Grenade.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE )

	self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )

	self:SetCollisionBounds(Vector(-3, -3, -3), Vector(3, 3, 3))

	self:NextThink( CurTime() + 0.1 )

	self.m_takedamage	= DAMAGE_YES
	self.m_bIsLive		= true
	self.m_iHealth		= 1

	self:SetGravity( 1e9 )	// use a lower gravity for grenades to make them easier to see
	self:SetFriction( 0.8 )
	self:SetSequence( 0 )

	self.m_fSpawnTime = CurTime()

	self:OnInitialize()

end

function ENT:GetSpawnTime()
	local spawnTime = self.m_fSpawnTime

	if not spawnTime then
		spawnTime = CurTime()
		self.m_fSpawnTime = spawnTime
	end

	return spawnTime
end

function ENT:Think()
	if (!self.m_bIsLive) then
		if (self:GetSpawnTime() + MAX_AR2_NO_COLLIDE_TIME < CurTime()) then
			self.m_bIsLive  = true
		end
	end
	
	if (self.m_bIsLive) then
		if (self:GetVelocity():Length() == 0.0 ||
			self:GetGroundEntity() != NULL ) then
			// self:Detonate()
		end
	end
end

function ENT:PhysicsCollide( data, physobj )

	self:Touch( data.HitEntity )
	self.PhysicsCollide = function( ... ) return end

end

function ENT:Detonate()
	if !IsValid(self) then return end

	if (!self.m_bIsLive) then
		return
	end
	self.m_bIsLive		= false
	self.m_takedamage	= DAMAGE_NO

	if(self.m_hSmokeTrail) then
		self.m_hSmokeTrail:Remove()
		self.m_hSmokeTrail = NULL
	end

	self:DoExplodeEffect()

	local vecForward = self:GetVelocity()
	local		tr
	tr = {}
	tr.start = self:GetPos()
	tr.endpos = self:GetPos() + 60*vecForward
	tr.mask = MASK_SHOT
	tr.filter = self
	tr.collision = COLLISION_GROUP_NONE
	tr = util.TraceLine ( tr)


	self:OnExplode( tr )
	self:EmitSound( self.Sound.Explode )
	util.ScreenShake( self:GetPos(), 25.0, 150.0, 1.0, 750, SHAKE_START )

	local owner = self:GetOwner()

	util.BlastDamage( self, owner:IsValid() and owner or self, self:GetPos(), 250, 1e9 )

	timer.Simple(0,function()
		if self:IsValid() then
			self:Remove()
		end
	end)
end

function ENT:Precache()

	util.PrecacheModel("models/Items/AR2_Grenade.mdl")

end



