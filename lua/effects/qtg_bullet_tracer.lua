-- Solution for the tracers being wonky for Shotgun Type 2

function EFFECT:Init(d)
    local ent = d:GetEntity()
    if not ent:IsValid() then return end

    if ent:IsPlayer() then
        ent = ent:ShouldDrawLocalPlayer() and ent:GetActiveWeapon() or ent:GetViewModel()
    elseif ent:IsNPC() then
        ent = ent:GetActiveWeapon()
    end

    if not ent:IsValid() then return end

    local att = ent:GetAttachment(ent:LookupAttachment('muzzle')) or ent:GetAttachment(ent:LookupAttachment('1'))

    if att then
        local ef = EffectData()

        ef:SetOrigin(d:GetOrigin())
        ef:SetStart(att.Pos)
        ef:SetEntity(ent)
        ef:SetAttachment(1)
        ef:SetScale(5000)

        local name = d:GetFlags() == 2 and 'AR2Tracer' or 'AirboatGunHeavyTracer'

        util.QTGEffect(name, ef)

        ef:SetScale(1)
    end
end

local function Kill()
    return false
end

EFFECT.Think = Kill
EFFECT.Render = Kill