AddCSLuaFile('qtg_admin_gun/load/init.lua')
include('qtg_admin_gun/load/init.lua')

list.Add('NPCUsableWeapons',{class='qtg_admin_gun',title='QTG Admin Gun'})

if SERVER then
	resource.AddWorkshop('1410750647')
end