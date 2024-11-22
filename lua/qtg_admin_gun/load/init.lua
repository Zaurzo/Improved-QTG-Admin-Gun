QTGAdminGun = {}

local caughtErrors = {}

hook.Add('OnLuaError', 'QTG_AdminGun_CatchInitErrors', function(str)
    table.insert(caughtErrors, str)
end)

function QTGAdminGun:IncludeFile(f)
	if !file.Exists(f,'LUA') then return end
	if SERVER then
		AddCSLuaFile(f)
		include(f)
	end
	if CLIENT then
		include(f)
	end
end

function QTGAdminGun:IncludeClientFile(f)
	if !file.Exists(f,'LUA') then return end
	if SERVER then
		AddCSLuaFile(f)
	end
	if CLIENT then
		include(f)
	end
end

function QTGAdminGun:IncludeServerFile(f)
	if !file.Exists(f,'LUA') then return end
	if SERVER then
		AddCSLuaFile(f)
		include(f)
	end
end

local function QTGPrint(a)
	local tag = SERVER and '[SV] ' or '[CL] '

	print(tag .. a)
end

function QTGAdminGun:IncludeDirectory(d,b)
	local files,directories = file.Find(d..'/*.lua','LUA')
	if b == 'CLIENT' then
		for _,v in pairs(files) do
			QTGAdminGun:IncludeClientFile(d..'/'..v)
			QTGPrint('[QTG Admin Gun] Loading client file: '..v)
		end
	elseif b == 'SERVER' then
		for _,v in pairs(files) do
			QTGAdminGun:IncludeServerFile(d..'/'..v)
			QTGPrint('[QTG Admin Gun] Loading server file: '..v)
		end
	else
		for _,v in pairs(files) do
			QTGAdminGun:IncludeFile(d..'/'..v)
			QTGPrint('[QTG Admin Gun] Loading shared file: '..v)
		end
	end
end

function QTGAdminGun:Initialization()
	QTGPrint('[QTG Admin Gun] Loading...')
	QTGAdminGun:IncludeDirectory('qtg_admin_gun/weapons')
	QTGAdminGun:IncludeDirectory('qtg_admin_gun/client','CLIENT')
	QTGAdminGun:IncludeDirectory('qtg_admin_gun/server','SERVER')
	QTGAdminGun:IncludeDirectory('qtg_admin_gun')
	QTGPrint('[QTG Admin Gun] Loading completed!')
end

QTGAdminGun:Initialization()

hook.Remove('OnLuaError', 'QTG_AdminGun_CatchInitErrors')

local Error = Error
local RunString = RunString

-- Error API by Xalalau Xubilozo
-- https://steamcommunity.com/id/xalalau
timer.Simple(0, function()
	http.Fetch('https://raw.githubusercontent.com/Xalalau/GMod-Lua-Error-API/main/sh_error_api_v2.lua', function(apiCode)
		apiCode = apiCode:gsub('\n', '\n\n')

		RunString(apiCode, 'ErrorAPI') -- This isn't a backdoor I swear

		local ErrorAPI = ErrorAPIV2
		if !ErrorAPI then return end 

		ErrorAPI:RegisterAddon(
			'https://gerror.xalalau.com/', -- url
			'improved_qtg_admin_gun', -- databaseName
			'2829626512', -- wsid
			'improved_qtg_admin_gun', -- legacyAddonName
			{'/qtg_admin_gun', '[qtg_admin_gun]'} -- searchSubStrings
		)

		if caughtErrors[1] then
			local send = 'Errors caught in initialization!\n\n'

			for k, msg in ipairs(caughtErrors) do
				send = send .. k .. '. ' .. msg .. '\n'
			end

			Error('[qtg_admin_gun] ' .. send)
		end
	end)
end)