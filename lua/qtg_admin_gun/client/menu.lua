local QMENU = {}
local QSMENU = {}
local AddButton = {}

local ft = CreateClientConVar('QTG_AdminGun_FireType','0',true)

function QMENU:Init()
	self._buttons = {}
	
	self.OffMenuTime = CurTime()+0.8
	local p = LocalPlayer()
	self:SetSize(300,730)
	self:Center()
	self:CFrame()
	self:SetTitle('')
    self:SetDraggable(true)
    self:ShowCloseButton(false)
	local label_choose = self:Add('DLabel')
	label_choose:SetFont('QM_Name')
	label_choose:SetText(QAGL.MenuName)
	label_choose:SizeToContents()	
	label_choose:SetTextColor(Color(255,255,255))
	label_choose:SetPos(0,13)
	label_choose:CenterHorizontal()
	local CloseButton = self:Add('DButton')
	CloseButton:SetPos(279, 2)
	CloseButton:SetFont('marlett')
	CloseButton:SetText('r')
	CloseButton.Paint = function(self,w,h)
		if CloseButton:IsHovered() then
			surface.SetDrawColor(80,0,200)
		else
			surface.SetDrawColor(60,60,60)
		end
		surface.DrawRect(0,0,w,h)
	end
	CloseButton:SetColor(Color(255, 255, 255))
	CloseButton:SetSize(20, 20)
	CloseButton.DoClick = function()
		self:Remove()
	end
	local SButton = self:Add('DImageButton')
	SButton:SetPos(5,5)			
	SButton:SetImage('icon16/wrench.png')
	SButton:SizeToContents()			
	SButton.DoClick = function()
		RunConsoleCommand('QTG_AdminGun_OpenSettingMenu')
	end

	local searchbar = self:Add("DTextEntry")
	local parent = self

    searchbar:SetSize(275,25)
    searchbar:SetUpdateOnType(true)
    searchbar:SetPaintBackground(false)
    searchbar:SetFont("QM_Mode")
    searchbar:SetPos(5,62)

	searchbar.Placeholder = 'Search...'

	searchbar.HighlightColor = Color(150, 150, 150, 150)
	searchbar.PlaceholderColor = Color(100, 100, 100, 200)

	function searchbar:OnGetFocus()
		self.allowtime = CurTime() + 0.1

		parent:SetKeyboardInputEnabled(true)
	end

	function searchbar:OnLoseFocus()
		parent:SetKeyboardInputEnabled(false)
	end

	-- Prevent the user spamming keys being held down (e.g. w/s/a/d) when you select it
	function searchbar:AllowInput()
		if self.allowtime > CurTime() then
			self.allowtime = CurTime() + 0.1

			return true
		end
	end

	local cw = 275
	local vbar = self.Scroll:GetVBar()

	function searchbar:Paint(w, h)
		if cw != 290 then 
			if !vbar:IsVisible() then
				cw = 290

				self:SetSize(cw, 25)
			end
		else
			if vbar:IsVisible() then
				cw = 275

				self:SetSize(cw, 25)
			end
		end

		surface.SetDrawColor(40, 40, 40)
		surface.DrawRect(0, 0, w, h)
		
		self:DrawTextEntryText(color_white, self.HighlightColor, color_white)

        if not (self:HasFocus() or self:GetValue() != "") then
       		draw.SimpleText(self.Placeholder, 'QM_Mode', 5, h * 0.15, self.PlaceholderColor, TEXT_ALIGN_LEFT)
		end
    end

	self:Firemode_Menu()

	function searchbar:OnValueChange(value)
		value = string.lower(value)

		for k, v in ipairs(parent._buttons) do
			v:Remove()
		end

		table.Empty(parent._buttons)

		for k, v in pairs(parent._defaults) do
			local name = string.lower(v)

			if string.find(name, value, 1, true) then
				parent:AddOption(k, v)
			end
		end
    end
	
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

function QMENU:CFrame()
	local frame = self:Add('DPanel')
	frame:SetSize(290,620)
	frame:Center()
	frame:CenterVertical(0.55)
	frame:SetPos(frame:GetX(), frame:GetY() + 5)
	frame.Paint = function(self,w,h)
		surface.SetDrawColor(60,60,60)
		surface.DrawRect(0,0,w,h)
	end
	self.Scroll = frame:Add('DScrollPanel')
	self.Scroll:Dock(FILL)
	local sbar = self.Scroll:GetVBar()
	local sbar2 = self.Scroll
	function sbar:Paint(w,h)
		draw.RoundedBox(3,5,0,w-5,h,Color(60,60,60))
	end
	function sbar.btnUp:Paint(w,h)
		draw.RoundedBox(3,5,0,w-5,h-5,Color(40,40,40))
	end
	function sbar.btnDown:Paint(w,h)
		draw.RoundedBox(3,5,5,w-5,h-5,Color(40,40,40))
	end
	function sbar.btnGrip:Paint(w,h)
		draw.RoundedBox(3,5,0,w-5,h,Color(40,40,40))
		if self.Hovered then
			draw.RoundedBox(3,5,0,w-5,h,Color(80,0,200))
		end
		if self.Depressed then
			draw.RoundedBox(3,5,0,w-5,h,Color(60,0,100))
		end
	end
end

function QMENU:Paint(w,h)
	surface.SetDrawColor(60,60,60)
	surface.DrawRect(0,0,w,h)
end

function QMENU:AddOption(b,t)
	local db = self.Scroll:Add('DButton')
	db:SetSize(290,30)
	db:SetText('')
	db:Dock(TOP)
	db:DockMargin(0,0,0,5)
	db.DoClick = function()
		self:Remove()
		net.Start('QTG_SetServer')
			net.WriteFloat(b)
		net.SendToServer()
		ft:SetInt(b)
	end
	db.Paint = function(self,w,h)
		if db:IsHovered() then
			surface.SetDrawColor(80,0,200)
		else
			local p = LocalPlayer()

			if p:IsValid() and p:GetNWInt('AdminGun_FireMode') == b then
				surface.SetDrawColor(120, 120, 120)
			else
				surface.SetDrawColor(40,40,40)
			end
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetFont('QM_Mode')
		local str = string.upper(t[1]) .. string.sub(t,2)
		local TextW, TextH = surface.GetTextSize(str)
		surface.SetTextColor(200, 200, 200)
		surface.SetTextPos(w/2-TextW/2,h/2-TextH/2)
		surface.DrawText(str)
	end
	table.insert(self._buttons,db)
end

function QMENU:CanFireNukeBomb()
	local Nuke = table.Count(ents.FindByClass('qtg_nuke_bomb'))
	local Nuke2 = table.Count(ents.FindByClass('qtg_nuke_explosion'))
	if Nuke >= 1 or Nuke2 >= 1 then
		return false
	end
	return true
end

local function MovingSpeedI(a)
	if a == 0 then
		return QAGL.MovingSpeedOff
	elseif a == 1 then
		return QAGL.MovingSpeedX2
	elseif a == 2 then
		return QAGL.MovingSpeedX4
	elseif a == 3 then
		return QAGL.MovingSpeedX6
	elseif a == 4 then
		return QAGL.MovingSpeedX8
	elseif a == 5 then
		return QAGL.MovingSpeedX10
	end
end

function QMENU:Firemode_Menu()
	local p = LocalPlayer()
	local TimeStop = p:GetNWBool('AdminGun_TimeStop')
	local Invisible = p:GetNWBool('AdminGun_Invisible')
	local WallHack = p:GetNWBool('AdminGun_WallHack')
	local MovingSpeed = p:GetNWInt('AdminGun_MovingSpeed')
	local FlyMode = p:GetNWBool('AdminGun_FlyMode')
	local SlowTime = p:GetNWBool('AdminGun_SlowTime')
	local SpeedTime = p:GetNWBool('AdminGun_SpeedTime')
	local Defense = p:GetNWBool('AdminGun_Defense')
	local SPH = p:GetNWInt('QTG_AdminGun_SetPlyHealth')
	local AllPly = 0
	local AllNpc = 0
	local Alle2 = 0
	local Allwire = 0
	for k, v in pairs(ents.GetAll()) do
		if IsValid(v) and v:IsNPC() or (v:Health() > 0 and v:IsScripted()) then
			AllNpc = AllNpc + 1
		elseif v:GetClass() == 'gmod_wire_*' or v:GetClass() == 'wire*' then
			Allwire = Allwire + 1
		elseif v:IsPlayer() and v != p and v:Alive() and v:GetActiveWeaponClass() != 'qtg_admin_gun' then
			AllPly = AllPly + 1						
		elseif v:GetClass() == 'gmod_wire_expression2' then
			Alle2 = Alle2 + 1
		end	
	end

	AddButton[0] = QAGL.Default
	AddButton[1] = QAGL.Explosion
	AddButton[2] = QAGL.Fire
	AddButton[3] = QAGL.Crossbow
	AddButton[4] = QAGL.CombineBall
	AddButton[5] = QAGL.Grenade
	AddButton[6] = QAGL.RPG
	AddButton[15] = QAGL.UniversalKill
	AddButton[16] = QAGL.FragGrenade
	AddButton[18] = QAGL.Flechette
	AddButton[20] = self:CanFireNukeBomb() and QAGL.NukeBombReady or QAGL.NukeBombNotReady
	AddButton[21] = QAGL.HelicopterBomb
	AddButton[24] = QAGL.Teleport
	AddButton[26] = QAGL.PhysicalBullet
	AddButton[27] = QAGL.TimeStopBomb
	AddButton[7] = TimeStop and QAGL.TimeStopOn or QAGL.TimeStopOff
	AddButton[8] = AllPly != 0 and QAGL.KillAllPLY..'('..AllPly..')' or QAGL.KillAllPLY
	AddButton[9] = AllNpc != 0 and QAGL.KillAllNPC..'('..AllNpc..')' or QAGL.KillAllNPC
	AddButton[10] = Invisible and QAGL.InvisibleOn or QAGL.InvisibleOff
	AddButton[11] = QAGL.SetAllPlayerHeath..'('..SPH..')'
	AddButton[12] = Alle2 != 0 and QAGL.RemoveAllWireE2..'('..Alle2..')' or QAGL.RemoveAllWireE2
	AddButton[13] = Allwire != 0 and QAGL.RemoveAllWire..'('..Allwire..')' or QAGL.RemoveAllWire
	AddButton[14] = WallHack and QAGL.WallHackOn or QAGL.WallHackOff
	AddButton[17] = MovingSpeedI(MovingSpeed)
	AddButton[19] = FlyMode and QAGL.FlyOn or QAGL.FlyOff
	AddButton[22] = SlowTime and QAGL.SlowTimeOn or QAGL.SlowTimeOff
	AddButton[23] = SpeedTime and QAGL.SpeedTimeOn or QAGL.SpeedTimeOff
	AddButton[25] = Defense and QAGL.DefenseOn or QAGL.DefenseOff

	for k,v in pairs(AddButton) do
		self:AddOption(k,v)
	end

	self._defaults = AddButton
end

function QMENU:OnRemove()
	AddButton = {}
end

function QSMENU:Init()
	local p = LocalPlayer()
	self:SetSize(ScrW(),ScrH())
	self:Center()
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
	local frame = self:Add('DFrame')
	frame:SetTitle('')
	frame:SetSize(500,560)
	frame:Center()
	frame:ShowCloseButton(false)
	frame.Paint = function(self,w,h)
		surface.SetDrawColor(60,60,60)
		surface.DrawRect(0,0,w,h)
	end
	local label_choose = frame:Add('DLabel')
	label_choose:SetFont('QSM_Font')
	label_choose:SetText(QAGL.SettingsMenu)
	label_choose:SetSize(480,20)
	label_choose:SetTextColor(Color(255,255,255))
	label_choose:SetPos(0,5)
	label_choose:CenterHorizontal()
	local CloseButton = frame:Add('DButton')
	CloseButton:SetPos(479,2)
	CloseButton:SetFont('marlett')
	CloseButton:SetText('r')
	CloseButton.Paint = function(self,w,h)
		if CloseButton:IsHovered() then
			surface.SetDrawColor(80,0,200)
			surface.DrawRect(0,0,w,h)
		end
	end
	CloseButton:SetColor(Color(255, 255, 255))
	CloseButton:SetSize(20, 20)
	CloseButton.DoClick = function()
		self:Remove()
	end
	local frame2 = frame:Add('DPanel')
	frame2:SetSize(480,520)
	frame2:Center()
	frame2:CenterVertical(0.52)
	frame2.Paint = function(self,w,h)
		surface.SetDrawColor(60,60,60)
		surface.DrawRect(0,0,w,h)
	end
	local Scroll = frame2:Add('DScrollPanel')
	Scroll:Dock(FILL)
	local sbar = Scroll:GetVBar()
	local sbar2 = Scroll
	function sbar:Paint(w,h)
		draw.RoundedBox(3,5,0,w-5,h,Color(60,60,60))
	end
	function sbar.btnUp:Paint(w,h)
		draw.RoundedBox(3,5,0,w-5,h-5,Color(40,40,40))
	end
	function sbar.btnDown:Paint(w,h)
		draw.RoundedBox(3,5,5,w-5,h-5,Color(40,40,40))
	end
	function sbar.btnGrip:Paint(w,h)
		draw.RoundedBox(3,5,0,w-5,h,Color(40,40,40))
		if self.Hovered then
			draw.RoundedBox(3,5,0,w-5,h,Color(80,0,200))
		end
		if self.Depressed then
			draw.RoundedBox(3,5,0,w-5,h,Color(60,0,100))
		end
	end
	self.mframe = frame
	self.frame = Scroll:Add('EditablePanel')
	self.frame:SetSize(480,520)
	self.frame:SetPos(0,0)
	self.frame.Paint = function(self,w,h)
		surface.SetDrawColor(150,150,150)
		surface.DrawRect(0,0,w,h)
	end
	self:SettingMenu()
end

function QSMENU:SettingMenu()
	local NumSlider = self.frame:Add('DNumSlider')
	NumSlider:SetPos(5,5)
	NumSlider:SetSize(460,20)
	NumSlider:SetText(QAGL.SettingsMyHeath)
	NumSlider:SetMin(0)
	NumSlider:SetMax(1e9)
	NumSlider:SetDecimals(0)
	NumSlider:SetConVar('QTG_ADMINGUN_SetMyHealth')
	local Label = self.frame:Add('DLabel')
	Label:SetPos(5,25)
	Label:SetTextColor(Color(0,255,255))
	Label:SetText(QAGL.SettingsHelp2)
	Label:SizeToContents()
	local NumSlider = self.frame:Add('DNumSlider')
	NumSlider:SetPos(5,50)
	NumSlider:SetSize(460,20)
	NumSlider:SetText(QAGL.SettingsPlyHeath)
	NumSlider:SetMin(0)
	NumSlider:SetMax(1e9)
	NumSlider:SetDecimals(0)
	NumSlider:SetConVar('QTG_ADMINGUN_SetPlyHealth')
	local Label = self.frame:Add('DLabel')
	Label:SetPos(5,75)
	Label:SetTextColor(Color(0,255,255))
	Label:SetText(QAGL.SettingsHelp3)
	Label:SizeToContents()
	local Checkbox = self.frame:Add('DCheckBoxLabel')
	Checkbox:SetPos(5,100)
	Checkbox:SetText(QAGL.SettingsGunText)
	Checkbox:SetConVar('QTG_AdminGun_GunText')	
	Checkbox:SizeToContents()

	local Label = self.frame:Add('DLabel')
	Label:SetPos(5,125)
	Label:SetTextColor(Color(0,255,255))
	Label:SetText(QAGL.SettingsHelp4)
	Label:SizeToContents()

	local y = 125

	local function addCheckbox(name,desc,convar)
		y = y + 25

		local cbHealth = self.frame:Add('DCheckBoxLabel')
		cbHealth:SetPos(5,y)
		cbHealth:SetText(name)
		cbHealth:SetConVar(convar)	
		cbHealth:SizeToContents()

		local lHealth = self.frame:Add('DLabel')
		lHealth:SetPos(5,y+25)
		lHealth:SetTextColor(Color(0,255,255))
		lHealth:SetText(desc)
		lHealth:SizeToContents()

		y = y + 25
	end

	addCheckbox('Return original health on holster?', 'Your health before you deployed the gun', 'QTG_AdminGun_GunHealth')
	addCheckbox('Enable extra effects', 'Extra effects the gun creates. Might cause lag', 'QTG_AdminGun_GunEffects')
	addCheckbox('Destruction sphere', 'The gun breaks doors and removes prop_brushes that are near you when it\'s deployed', 'QTG_AdminGun_GunDestroy')
	addCheckbox('RGB Player', 'If the player has the weapon and has a playermodel that supports shirt color, it will be rainbow.', 'QTG_AdminGun_GunMakePlayerRainbow')

	addCheckbox = nil

	local lasercolorCvar = GetConVar('QTG_AdminGun_GunLaserColor')
	local lasercolor

	if !lasercolorCvar then
		lasercolor = Color(255, 0, 0)
	else
		local str = lasercolorCvar:GetString() or ''
		local rgb = string.Split(str, ',')

		if rgb[1] == nil then
			lasercolor = Color(255, 0, 0)
		else
			lasercolor = Color(rgb[1], rgb[2] or 0, rgb[3] or 0)
		end
	end

	y = y + 10

	local lclabel = self.frame:Add('DLabel')
	lclabel:SetPos(5,y+40)
	lclabel:SetTextColor(Color(0,255,255))
	lclabel:SetText('Color')
	lclabel:SizeToContents()

	local lcmixer = self.frame:Add("DColorMixer")
	--lcmixer:Dock(FILL)
	lcmixer:SetPalette(false)
	lcmixer:SetAlphaBar(false)
	lcmixer:SetWangs(true)
	lcmixer:SetColor(lasercolor)
	lcmixer:SetSize(self.frame:GetWide()-50,80)
	lcmixer:SetPos(5,y+65)

	local lcpanel = self.frame:Add('DPanel')
	lcpanel:SetSize(lcmixer:GetWide()/1.25,30)
	lcpanel:SetPos(5,lcmixer:GetY()+85)

	function lcpanel:Paint(w, h)
		draw.RoundedBox(10,0,0,w,h,lcmixer:GetColor())
	end

	local lcapply = self.frame:Add('DButton')
	lcapply:SetSize(self.frame:GetWide()-lcpanel:GetWide()-15,lcpanel:GetTall())
	lcapply:SetPos(lcpanel:GetWide()+10,lcpanel:GetY())
	lcapply:SetText('Apply')

	function lcapply:DoClick()
		local color = lcmixer:GetColor()

		lasercolorCvar:SetString(('%s,%s,%s'):format(color.r,color.g,color.b))
	end

	local lcRainbow = self.frame:Add('DCheckBoxLabel')
	lcRainbow:SetPos(lclabel:GetX()+30,lclabel:GetY())
	lcRainbow:SetText('Rainbow')
	lcRainbow:SetConVar('QTG_AdminGun_GunRainbowLaser')	
	lcRainbow:SizeToContents()
	
	local LButton = self.mframe:Add('DImageButton')
	local posX = self.mframe:GetWide()-45

	LButton:SetPos(posX,7)			
	LButton:SetImage('resource/localization/'..GetConVar('QTG_AdminGun_Language'):GetString()..'.png')
	LButton:SizeToContents()
	LButton.ClickN = false
	LButton.DoClick = function()
		local switch = !self.ClickN
		self.ClickN = switch
		if switch then
			local files,directories = file.Find('qtg_admin_gun/language/*.lua','LUA')
			local a = -15
			self.Container = self:Add('DBubbleContainer')
			self.Container:SetBackgroundColor(Color(60,60,60))

			local Paint = self.Container.Paint
			local mframe = self.mframe

			function self.Container:Paint(...)
				if IsValid(mframe) then
					self:OpenForPos(mframe:GetX()+posX,mframe:GetY()+7,280,150)
				end

				return Paint(self, ...)
			end

			for _,v in pairs(files) do
				a = a+20
				local vs,ve = string.find(v:lower(),'.lua')
				v = string.sub(v,1,vs-1)
				local LButton = self.Container:Add('DImageButton')
				LButton:SetPos(a,5)
				LButton:SetImage('resource/localization/'..v..'.png')
				LButton:SizeToContents()
				LButton.ClickN = false
				LButton.DoClick = function()
					RunConsoleCommand('QTG_AdminGun_Language',v)
					self:Remove()
					timer.Simple(0,function()
						QTGAdminGun:OpenSettingMenu()
					end)
				end
			end
		else
			self.Container:Remove()
		end
	end
end

vgui.Register('QTGAdminGunMenu',QMENU,'DFrame')
vgui.Register('QTGAdminGunSettingMenu',QSMENU)

function QTGAdminGun:OpenMenu()
	if IsValid(qmenu) then
		if !qmenu:IsVisible() then
			qmenu:Show()
		end
	else
		qmenu = vgui.Create('QTGAdminGunMenu')
	end
end

function QTGAdminGun:OpenSettingMenu()
	if IsValid(qsmenu) then
		if !qsmenu:IsVisible() then
			qsmenu:Show()
		end
	else
		qsmenu = vgui.Create('QTGAdminGunSettingMenu')
	end
end

concommand.Add('QTG_AdminGun_OpenSettingMenu',function(p,c,a)
	QTGAdminGun:OpenSettingMenu()
end)
net.Receive('QTG_OpenMenu', function()
	QTGAdminGun:OpenMenu()
end)

list.Set('DesktopWindows','QTG_AdminGun_SettingMenu',{
	title = 'QTG Admin Gun',
	icon = 'neptune_qtg/icon64/qtg_admin_gun.png',
	init = function(i,w)
		RunConsoleCommand('QTG_AdminGun_OpenSettingMenu')
	end
})