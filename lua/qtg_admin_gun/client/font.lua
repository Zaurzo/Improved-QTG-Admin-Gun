function QTGAdminGun:AddFont(a,b,c,d)
	surface.CreateFont(a,{
		font = b,
		size = c,
		weight = d
	})
end
local FontList = {}
local FontList2 = {}

FontList['ModeFont'] = 100
FontList['Mode2Font'] = 25
FontList['Mode3Font'] = 30
FontList['Mode4Font'] = 22

FontList2['QM_Name'] = 40
FontList2['QM_Mode'] = 18
FontList2['QSM_Font'] = 18

for k,v in pairs(FontList) do
	QTGAdminGun:AddFont(k,'Roboto Bk',v,1000)
end
for k,v in pairs(FontList2) do
	QTGAdminGun:AddFont(k,'Roboto',v,500)
end