local D1 		= math.random(1,9999)
local A1 		= math.random(1,9999)
local D2 		= math.random(1,9999)
local A2 		= math.random(1,9999)
local e 		= FindMetaTable('Entity')
local p 		= FindMetaTable('Player')
local w 		= FindMetaTable('Weapon')
local n 		= FindMetaTable('NPC')
local oer 		= e.Remove
local K = string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))..string.char(math.random(70,100))
NOTIFY_GENERIC	= 0
NOTIFY_ERROR	= 1
NOTIFY_UNDO		= 2
NOTIFY_HINT		= 3
NOTIFY_CLEANUP	= 4
SOUND_DEFAULT	= 0
SOUND_CLEANUP	= 1
PSOUND_DEFAULT 	= 0
PSOUND_FIREPROP = 1
PSOUND_RPG 		= 2
PSOUND_HUNTER 	= 3
PSOUND_MODE 	= 4
PSOUND_ON 		= 5
PSOUND_OFF 		= 6
PSOUND_ZOOM 	= 7
PSOUND_CLEANUP 	= 8

local Overridden = {}
local OverriddenTwe = {}
local OverriddenEnt = {
	'qtg_ent_barrier',
	'qtg_ent_bullet',
	'qtg_ent_timestop',
	'qtg_ent_timestop_bomb'
}

local isValid = IsValid
local function IsValid(e)
	if !isentity(e) then
		return false
	end

	return isValid(e)
end

local function qejc(e,b)
	if !IsValid(e) then return nil end
	if e:IsPlayer() and e:GetActiveWeaponClass() == 'qtg_admin_gun' and e:IsAdmin() then
		return true
	elseif e:IsNPC() and e:GetActiveWeaponClass() == 'qtg_admin_gun' then
		return true
	elseif e:IsWeapon() and e:GetClass() == 'qtg_admin_gun' and !b then
		return true
	elseif e == 'qtg_admin_gun' then
		return true
	end
	return false
end
local function qemc(e)
	if !IsValid(e) then return nil end
	if e:IsNPC() and e:GetActiveWeaponClass() == 'qtg_admin_gun' then
		return e:GetClass()
	elseif e:IsWeapon() and e:GetClass() == 'qtg_admin_gun' then
		return e:GetClass()
	end
	return nil
end
local function qoei(e)
	if !IsValid(e) then return nil end
	for i=1,#OverriddenEnt do
		if e:GetClass() == OverriddenEnt[i] then
			return true
		end
	end
	return false
end

local function OverrideFunction(m,n,b,r,t)
	local oldFunc = m[n]
	t = t or Overridden

	if t[n] then return end
	if !oldFunc then return end

	m[n] = function(self,...)
		if qejc(self,b) then
			return r and unpack(r) or nil
		end

		return oldFunc(self,...)
	end

	m['_QTG' .. n] = function(self,...)
		local args = {...}

		if args[#args] == K then
			return oldFunc(self,...)
		end
	end

	t[n] = m[n]
end

local function OverrideFunctionEnt(m,n,r)
	OverrideFunction(m,n,nil,r,OverriddenTwe)
end

local function AddFunction(m,n,b,c)
	local oldFunc = m[n]
	local a = b and 0 or ''
	if !oldFunc then return end
	if !b then c = 1 end
	for i=1,c do
		if b then
			a=a+1
		end
		m['QTG'..n..a] = function(self,...)
			return oldFunc(self,...)
		end
	end
end

AddFunction(e,'NextThink')
AddFunction(e,'SetMoveType')
AddFunction(e,'GetTable')

OverrideFunction(p,'GodDisable')
OverrideFunction(p,'HasGodMode')
OverrideFunction(p,'Kill')
OverrideFunction(p,'KillSilent')
OverrideFunction(p,'StripWeapons')
OverrideFunction(p,'StripWeapon')
OverrideFunction(p,'Lock')
OverrideFunction(p,'Freeze')
OverrideFunction(p,'DropWeapon')
OverrideFunction(p,'DropNamedWeapon')
OverrideFunction(p,'Kick')
OverrideFunction(p,'EnterVehicle')
OverrideFunction(p,'SetEyeAngles')
OverrideFunction(p,'SetLaggedMovementValue')
OverrideFunction(p,'RemoveAllItems')
OverrideFunction(p,'SelectWeapon')
OverrideFunction(p,'SetActiveWeapon')
-- OverrideFunction(p,'SendLua')

OverrideFunction(e,'SetPos',true)
OverrideFunction(e,'SetLocalPos',true)
OverrideFunction(e,'SetLocalAngles')
OverrideFunction(e,'SetLocalAngularVelocity')
OverrideFunction(e,'SetVelocity')
OverrideFunction(e,'SetLocalVelocity')
OverrideFunction(e,'SetHealth')
OverrideFunction(e,'Remove')
OverrideFunction(e,'RemoveFlags')
OverrideFunction(e,'SetNoDraw')
OverrideFunction(e,'SetNoDraw')
OverrideFunction(e,'Ignite')
OverrideFunction(e,'SetMoveType')
OverrideFunction(e,'SetModel')
OverrideFunction(e,'SetSolid')
OverrideFunction(e,'SetNotSolid')
OverrideFunction(e,'SetCollisionGroup')
OverrideFunction(e,'DrawShadow')
OverrideFunction(e,'SetRenderMode')
OverrideFunction(e,'SetGravity')
OverrideFunction(e,'SetModelScale')
OverrideFunction(e,'SetMaterial')
OverrideFunction(e,'SetColor')
OverrideFunction(e,'ManipulateBonePosition')
OverrideFunction(e,'ManipulateBoneScale')
OverrideFunction(e,'ManipulateBoneJiggle')
OverrideFunction(e,'SetParent')
OverrideFunction(e,'SetFlexScale')
OverrideFunction(e,'SetSequence')
OverrideFunction(e,'SetCycle')
OverrideFunction(e,'SetOwner')
OverrideFunction(e,'SetModelName')
OverrideFunction(e,'AddCallback')
OverrideFunction(e,'AddEffects')
OverrideFunction(e,'AddFlags')
OverrideFunction(e,'AddGesture')
OverrideFunction(e,'AddGestureSequence')
OverrideFunction(e,'AddLayeredSequence')
OverrideFunction(e,'AddSolidFlags')
OverrideFunction(e,'AddToMotionController')
OverrideFunction(e,'AlignAngles')
OverrideFunction(e,'EnableConstraints')
OverrideFunction(e,'EnableCustomCollisions')
OverrideFunction(e,'Fire')
OverrideFunction(e,'FireBullets')
OverrideFunction(e,'NextThink')
OverrideFunction(e,'SetAbsVelocity')
OverrideFunction(e,'PhysicsInit')
OverrideFunction(e,'PhysicsDestroy')
OverrideFunction(e,'PhysicsFromMesh')
OverrideFunction(e,'PhysicsInitBox')
OverrideFunction(e,'PhysicsInitConvex')
OverrideFunction(e,'PhysicsInitMultiConvex')
OverrideFunction(e,'PhysicsInitShadow')
OverrideFunction(e,'PhysicsInitSphere')
OverrideFunction(e,'PhysicsInitStatic')
OverrideFunction(e,'RemoveFromMotionController')
OverrideFunction(e,'RemoveSolidFlags')
OverrideFunction(e,'Respawn')
OverrideFunction(e,'SetMoveCollide')
OverrideFunction(e,'SetMoveParent')
OverrideFunction(e,'AddEFlags')
OverrideFunction(e,'SetKeyValue')
OverrideFunction(e,'TakeDamage')
OverrideFunction(e,'TakeDamageInfo')

OverrideFunction(n,'SetNPCState')
OverrideFunction(n,'SetMovementActivity')
OverrideFunction(n,'SetCurrentWeaponProficiency')
OverrideFunction(n,'SetHullSizeNormal')
OverrideFunction(n,'SetHullType')
OverrideFunction(n,'UpdateEnemyMemory')
OverrideFunction(n,'SetSchedule')
OverrideFunction(n,'SetEnemy')
OverrideFunction(n,'CapabilitiesAdd')
OverrideFunction(n,'CapabilitiesClear')
OverrideFunction(n,'CapabilitiesRemove')
OverrideFunction(n,'Give')
OverrideFunction(n,'MaintainActivity')
OverrideFunction(n,'MarkEnemyAsEluded')
OverrideFunction(n,'MoveOrder')
OverrideFunction(n,'NavSetGoal')
OverrideFunction(n,'NavSetGoalTarget')
OverrideFunction(n,'NavSetRandomGoal')
OverrideFunction(n,'NavSetWanderGoal')
OverrideFunction(n,'SetArrivalActivity')
OverrideFunction(n,'SetArrivalDirection')
OverrideFunction(n,'SetArrivalDistance')
OverrideFunction(n,'SetArrivalSequence')
OverrideFunction(n,'SetArrivalSpeed')
OverrideFunction(n,'SetLastPosition')
OverrideFunction(n,'SetMaxRouteRebuildTime')
OverrideFunction(n,'UseActBusyBehavior')
OverrideFunction(n,'UseAssaultBehavior')
OverrideFunction(n,'UseFollowBehavior')
OverrideFunction(n,'UseFuncTankBehavior')
OverrideFunction(n,'UseLeadBehavior')
OverrideFunction(n,'UseNoBehavior')
OverrideFunction(n,'SetMovementSequence')
OverrideFunction(n,'SetCondition')
OverrideFunction(n,'AddEntityRelationship')
OverrideFunction(n,'ClearExpression')
OverrideFunction(n,'ClearEnemyMemory')
OverrideFunction(n,'ClearGoal')
OverrideFunction(n,'ClearSchedule')
OverrideFunction(n,'AlertSound')

OverrideFunctionEnt(e,'Remove')
OverrideFunctionEnt(e,'SetVelocity')
OverrideFunctionEnt(e,'SetMoveType')
OverrideFunctionEnt(e,'SetModel')
OverrideFunctionEnt(e,'SetSolid')
OverrideFunctionEnt(e,'SetNotSolid')
OverrideFunctionEnt(e,'SetCollisionGroup')
OverrideFunctionEnt(e,'PhysicsInit')
OverrideFunctionEnt(e,'EnableMotion')

local isfunction = isfunction

local isValid = e.IsValid
local GetClass = e.GetClass

function e:GetActiveWeaponClass()
	local get = self.GetActiveWeapon

	if isfunction(get) then
		local pass,w = pcall(get,self)

		if pass and isValid(w) then
			return GetClass(w)
		end
	end
end

local oet = util.Effect
function util.Effect(efName,ef,...)
	if ef and qejc(ef:GetEntity()) then
		return
	end
	return oet(efName,ef,...)
end
function util.QTGEffect(...)
	oet(...)
end
function p:QTGInvisible(b)
	if b then
		self:_QTGSetNoDraw(true,K)
		if self:GetActiveWeapon():IsValid() then self:GetActiveWeapon():_QTGSetNoDraw(true,K) end
		self:_QTGDrawShadow(false,K)
		self:_QTGAddFlags(FL_NOTARGET,K)
	else
		self:_QTGSetNoDraw(false,K)
		if self:GetActiveWeapon():IsValid() then self:GetActiveWeapon():_QTGSetNoDraw(false,K) end
		self:DrawShadow(true,K)
		self:RemoveFlags(FL_NOTARGET,K)
	end
end
function p:HasQTGInvisible()
	return self:GetNoDraw()
end
if SERVER then
	function p:QTGAddNotify(m,i,t,s)
		if m == nil then m = 'Notify' end
		if i == nil then i = 0 end
		if t == nil then t = 5 end
		if s == nil then s = ''
		elseif s == 0 then s = 'ambient/water/drip'..math.random(1,4)..'.wav'
		elseif s == 1 then s = 'buttons/button15.wav'
		end
		self:SendLua('notification.AddLegacy(\''..m..'\','..i..',\''..t..'\') surface.PlaySound(\''..s..'\')',K)
	end
	function p:QTGAddDeathNotice(an,at,ae,vn,vt)
		if an == nil then an = '' end
		if at == nil then at = '' end
		if ae == nil then ae = '' end
		if vn == nil then vn = '' end
		if vt == nil then vt = '' end
		self:SendLua('GAMEMODE:AddDeathNotice(\''..an..'\',\''..at..'\',\''..ae..'\',\''..vn..'\',\''..vt..'\')',K)
		MsgAll(an..' killed '..vn..' using '..ae..'\n')
	end
	function p:QTGSuperGODEnable()
		if qejc(self) then
			self:_QTGAddFlags(FL_DISSOLVING,K)
			self:_QTGAddFlags(FL_GODMODE,K)
			self:_QTGRemoveFlags(FL_FROZEN,K)
			if game.GetTimeScale() < 1 then
				self:_QTGSetLaggedMovementValue(1/game.GetTimeScale(),K)
			else
				self:_QTGSetLaggedMovementValue(1,K)
			end
			if self:IsValid() and self:GetMoveType() != MOVETYPE_NOCLIP and self:GetMoveType() != MOVETYPE_WALK and !self:GetNWBool('AdminGun_FlyMode') then
				self:_QTGSetMoveType(MOVETYPE_WALK,K)
			end
			self:_QTGSetHealth(self:GetNWInt('QTG_AdminGun_SetMyHealth'),K)
			self:SetNWInt('windgod',1)
		end
	end
	function p:QTGSuperGODDisable()
		if qejc(self) then
			self:_QTGRemoveFlags(FL_GODMODE,K)
			self:_QTGRemoveFlags(FL_DISSOLVING,K)
			self:_QTGSetLaggedMovementValue(1,K)
			self:SetNWInt('windgod',0)
		end
	end
end

local sl = {
	[0] = 'Airboat.FireGunRevDown',
	[1] = 'Weapon_SMG1.Double',
	[2] = 'Weapon_RPG.Single',
	[3] = 'NPC_Hunter.FlechetteShoot',
	[4] = 'Weapon_Alyx_Gun.Special2',
	[5] = 'garrysmod/ui_click.wav',
	[6] = 'common/warning.wav',
	[7] = 'Default.Zoom',
	[8] = 'buttons/button15.wav'
}

function e:QTGEmitSound(s)
	if !s then return end
	local sn = sl[s]
	if sn then
		self:EmitSound(sn)
	end
end

function e:QTGGetKey()
	if qejc(self) then 
		return K
	end

	for i=1,#OverriddenEnt do
		if self:GetClass() == OverriddenEnt[i] then
			return K
		end
	end
end

local opc = p.ConCommand
function p:ConCommand(b)
	if qejc(self) and b == 'kill' then
		return nil
	end
	return opc(self,b)
end

if !game.IsDedicated() then
	local ge = Entity

	if SERVER then
		local ogc = game.ConsoleCommand
		function game.ConsoleCommand(a,...)
			if a == 'kill\n' and qejc(ge(1)) then
				return MsgC(Color(255,90,90),'game.ConsoleCommand blocked! (kill)\n')
			end
			return ogc(a,...)
		end
	end

	local orc = RunConsoleCommand
	function RunConsoleCommand(a,...)
		if a == 'kill' and qejc(ge(1)) then return end
		return orc(a,...)
	end
end

local ocu = game.CleanUpMap
local MapDoNotClean = {
	'qtg_admin_gun',
	'qtg_nuke_explosion',
	'env_laserdot'
}
function game.CleanUpMap(send,filter,...)
	if !filter then filter = {} end
	for i=1,#MapDoNotClean do
		filter[#filter+1] = MapDoNotClean[i]
	end
	for i=1,#OverriddenEnt do
		filter[#filter+1] = OverriddenEnt[i]
	end
	return ocu(send,filter,...)
end
function p:UTF(b)
	if b then
		local omt = self:GetMoveType()
		self:Lock()
		self:RemoveFlags(FL_GODMODE)
		self:RemoveFlags(FL_FROZEN)
		self:SetMoveType(omt)
	else
		self:UnLock()
	end
end