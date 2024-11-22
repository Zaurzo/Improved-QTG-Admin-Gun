AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
include( 'outputs.lua' )


FRAG_GRENADE_BLIP_FREQUENCY			= 1.0
FRAG_GRENADE_BLIP_FAST_FREQUENCY	= 0.3

FRAG_GRENADE_GRACE_TIME_AFTER_PICKUP = 1.5
FRAG_GRENADE_WARN_TIME = 1.5

GRENADE_COEFFICIENT_OF_RESTITUTION = 0.2

local sk_npc_dmg_fraggrenade	= GetConVarNumber( "sk_npc_dmg_fraggrenade","0" )
local sk_fraggrenade_radius		= GetConVarNumber( "sk_fraggrenade_radius", "0" )

GRENADE_MODEL = "models/Weapons/w_grenade.mdl"
GRENADE_TIMER = 1


function		ENT:GetShakeAmplitude() return 25.0 end
function		ENT:GetShakeRadius() return 750.0 end

-- Damage accessors.
function ENT:GetDamage()
	return self.m_flDamage
end
function ENT:GetDamageRadius()
	return self.m_DmgRadius
end

function ENT:SetDamage(flDamage)
	self.m_flDamage = flDamage
end

function ENT:SetDamageRadius(flDamageRadius)
	self.m_DmgRadius = flDamageRadius
end

-- Bounce sound accessors.
function ENT:SetBounceSound( pszBounceSound )
	self.m_iszBounceSound = tostring( pszBounceSound )
end

function	ENT:BlipSound() self:EmitSound( self.Sound.Blip ) end

-- UNDONE: temporary scorching for PreAlpha - find a less sleazy permenant solution.
function ENT:Explode( pTrace, bitsDamageType )

if !( CLIENT ) then

	self:SetModel( "" )--invisible
	self:SetColor( color_transparent )
	self:SetSolid( SOLID_NONE )

	self.m_takedamage = DAMAGE_NO

	local vecAbsOrigin = self:GetPos()
	local contents = util.PointContents ( vecAbsOrigin )

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	if ( pTrace.Fraction != 1.0 ) then
		local vecNormal = pTrace.HitNormal
		local pdata = pTrace.MatType

		util.BlastDamage( self, -- don't apply cl_interp delay
			owner,
			self:GetPos(),
			500,
			1e9 )
	else
		util.BlastDamage( self, -- don't apply cl_interp delay
			owner,
			self:GetPos(),
			500,
			1e9 )
	end

	self:DoExplodeEffect()

	self:OnExplode( pTrace )

	self:EmitSound( self.Sound.Explode )

	self.Touch = function( ... ) return end
	self:SetSolid( SOLID_NONE )

	-- Because the grenade is zipped out of the world instantly, the EXPLOSION sound that it makes for
	-- the AI is also immediately destroyed. For this reason, we now make the grenade entity inert and
	-- throw it away in 1/10th of a second instead of right away. Removing the grenade instantly causes
	-- intermittent bugs with env_microphones who are listening for explosions. They will 'randomly' not
	-- hear explosion sounds when the grenade is removed and the SoundEnt thinks (and removes the sound)
	-- before the env_microphone thinks and hears the sound.
	SafeRemoveEntityDelayed( self, 0.1 )

end

end

function ENT:Detonate()

	local		tr
	local		vecSpot-- trace starts here!

	self.Think = function( ... ) return end

	vecSpot = self:GetPos() + Vector ( 0 , 0 , 8 )
	tr = {}
	tr.start = vecSpot
	tr.endpos = vecSpot + Vector ( 0, 0, -32 )
	tr.mask = MASK_SHOT_HULL
	tr.filter = self
	tr.collision = COLLISION_GROUP_NONE
	tr = util.TraceLine ( tr)

	if( tr.StartSolid ) then
		-- Since we blindly moved the explosion origin vertically, we may have inadvertently moved the explosion into a solid,
		-- in which case nothing is going to be harmed by the grenade's explosion because all subsequent traces will startsolid.
		-- If this is the case, we do the downward trace again from the actual origin of the grenade. (sjb) 3/8/2007  (for ep2_outland_09)
		tr = {}
		tr.start = self:GetPos()
		tr.endpos = self:GetPos() + Vector( 0, 0, -32)
		tr.mask = MASK_SHOT_HULL
		tr.filter = self
		tr.collision = COLLISION_GROUP_NONE
		tr = util.TraceLine( tr )
	end

	tr = self:Explode( tr, DMG_BLAST )

	if ( self:GetShakeAmplitude() ) then
		util.ScreenShake( self:GetPos(), self:GetShakeAmplitude(), 150.0, 1.0, self:GetShakeRadius() )
	end

end

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.m_hThrower			= NULL
	self.m_hOriginalThrower	= NULL
	self.m_bIsLive			= false
	self.m_DmgRadius		= 100
	self.m_flDetonateTime	= CurTime() + GRENADE_TIMER
	self.m_flWarnAITime		= CurTime() + GRENADE_TIMER - FRAG_GRENADE_WARN_TIME
	self.m_bHasWarnedAI		= false

	self:Precache( )

	self:SetModel( GRENADE_MODEL )

	self.m_takedamage	= DAMAGE_YES
	self.m_iHealth		= 1

	self:SetCollisionBounds( -Vector(4,4,4), Vector(4,4,4) )
	self:CreateVPhysics()

	self:BlipSound()
	self.m_flNextBlipTime = CurTime() + FRAG_GRENADE_BLIP_FREQUENCY

	self.m_combineSpawned	= false
	self.m_punted			= false

	self:CreateEffects()

	self:OnInitialize()
	self.BaseClass:Initialize()

end

-------------------------------------------------------------------------------
-- Purpose:
-------------------------------------------------------------------------------
function ENT:OnRestore()

	-- If we were primed and ready to detonate, put FX on us.
	if (self.m_flDetonateTime > 0) then
		self:CreateEffects()
	end

	self.BaseClass:OnRestore()

end

-------------------------------------------------------------------------------
-- Purpose:
-------------------------------------------------------------------------------
function ENT:CreateEffects()

	local	nAttachment = self:LookupAttachment( "fuse" )

	-- Start up the eye trail
	self.m_pGlowTrail	= util.SpriteTrail( self, nAttachment, self.Trail.Color, true, self.Trail.StartWidth, self.Trail.EndWidth, self.Trail.LifeTime, 1 / ( self.Trail.StartWidth + self.Trail.EndWidth ) * 0.5, self.Trail.Material )

end

function ENT:CreateVPhysics()

	self:PhysicsInit( SOLID_VPHYSICS )

	local Phys = self:GetPhysicsObject()

	if ( Phys and Phys:IsValid() ) then

		Phys:SetMaterial( "grenade" )

	end

	return true

end

function ENT:Precache()

	util.PrecacheModel( GRENADE_MODEL )

	util.PrecacheSound( self.Sound.Blip )

	util.PrecacheModel( "sprites/redglow1.vmt" )
	util.PrecacheModel( self.Trail.Material )

	util.PrecacheSound( self.Sound.Explode )

end

function ENT:SetTimer( detonateDelay, warnDelay )

	self.m_flDetonateTime = CurTime() + detonateDelay
	self.m_flWarnAITime = CurTime() + warnDelay
	self:NextThink( CurTime() )

	self:CreateEffects()

end

function ENT:Think()

	self:OnThink()

	local detTime = self.m_flDetonateTime

	if( detTime and CurTime() > detTime ) then
		self:Detonate()
		return
	end

	local warnAiTime = self.m_flWarnAITime

	if( !self.m_bHasWarnedAI && (!warnAiTime or CurTime() >= self.m_flWarnAITime )) then
		self.m_bHasWarnedAI = true
	end

	local bliptime = self.m_flNextBlipTime or 0

	if( CurTime() > bliptime ) then
		self:BlipSound()

		if( self.m_bHasWarnedAI ) then
			self.m_flNextBlipTime = CurTime() + FRAG_GRENADE_BLIP_FAST_FREQUENCY
		else
			self.m_flNextBlipTime = CurTime() + FRAG_GRENADE_BLIP_FREQUENCY
		end
	end

	self:NextThink( CurTime() + 0.1 )

end

function ENT:SetVelocity( velocity, angVelocity )

	local pPhysicsObject = self:GetPhysicsObject()
	if ( pPhysicsObject ) then
		pPhysicsObject:AddVelocity( velocity )
		pPhysicsObject:AddAngleVelocity( angVelocity )
	end

end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	-- Manually apply vphysics because BaseCombatCharacter takedamage doesn't call back to CBaseEntity OnTakeDamage
	self:TakePhysicsDamage( dmginfo )

	-- Grenades only suffer blast damage and burn damage.
	if( !(dmginfo:GetDamageType() == bit.bor( DMG_BLAST, DMG_BURN) ) ) then
		return 0
	end

	return self.BaseClass:OnTakeDamage( dmginfo )

end



