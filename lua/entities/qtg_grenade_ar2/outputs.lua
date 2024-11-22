
ENT.Sound				= {}
ENT.Sound.Explode		= "BaseGrenade.Explode"

function ENT:DoExplodeEffect()

	local info = EffectData()
	info:SetEntity( self )
	info:SetOrigin( self:GetPos() )

	util.Effect( "Explosion", info )

end

function ENT:OnExplode( pTrace )

	if ((pTrace.Entity != game.GetWorld()) || (pTrace.HitBox != 0)) then
		// non-world needs smaller decals
		if( pTrace.Entity && !pTrace.Entity:IsNPC() ) then
			util.Decal( "SmallScorch", pTrace.HitPos + pTrace.HitNormal, pTrace.HitPos - pTrace.HitNormal )
		end
	else
		util.Decal( "Scorch", pTrace.HitPos + pTrace.HitNormal, pTrace.HitPos - pTrace.HitNormal )
	end

end

function ENT:OnInitialize() end

function ENT:StartTouch( entity ) end

function ENT:EndTouch( entity ) end

function ENT:Touch( pOther )

	assert( pOther )
	if ( pOther:GetSolid() == SOLID_NONE ) then
		return
	end

	if (self.m_bIsLive) then
		self:Detonate()
	else
		local pBCC = pOther
		if (pBCC && self:GetOwner() != pBCC) then
			self.m_bIsLive = true
			self:Detonate()
		end
	end

end

function ENT:OnThink() end