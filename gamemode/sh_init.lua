--Gamemode information!
GM.Name = "TowerDefense"
GM.Author = "Pandaman09"
GM.Email = ""
GM.Website = "https://github.com/Pandaman09/TowerDefense"

-- loading system by bboudreaux00, thanks <3
-- additional reloading idea from Acecool

LOADER = LOADER or {}
LOADER.Systems = LOADER.Systems or {}
LOADER.loaded = false
LOADER.DIR = "towerdefense/gamemode/"
LOADER.Version = "1-31-15"
LOADER.Loaded = LOADER.Loaded or false
LOADER.Reload = false

--used to avoid autorefresh, we have our own that will work on all systems.
if !LOADER.Reload and LOADER.Loaded then
	MsgN("Avoiding Auto Refresh")
	return
end

--loads each folders basic 'loading' functions
function LOADER.SendSystems( template )
	if template then
		table.insert(LOADER.Systems, template)
		if SERVER then
			template.svLoadFunction()
		elseif CLIENT then
			template.clLoadFunction()
		end
		MsgN("System ["..template.NAME.."] load complete.")
	else
		MsgN("No System to load")
	end
end

--load core files
function LOADER.LoadCore()
	include(LOADER.DIR .. "core_systems/shared.lua");
	if SERVER then
		AddCSLuaFile( LOADER.DIR .. "core_systems/shared.lua" );
	end
end

local SystemDirs = {}
--Function for detecting directories.
--This will load all the system directories into the loader.
function LOADER.FindDirectories()
	local _, dir = file.Find(LOADER.DIR .. "*", "LUA")
	SystemDirs = dir
end

--Function for loading init file inside of listed directories.
function LOADER.LoadSystemInits( Dirs )
	if SystemDirs == nil then
		MsgN("System directories are empty!")
		return
	else
		for _,v in pairs(SystemDirs) do
			if v != "core_systems" then
				include(LOADER.DIR .. v .. "/shared.lua");
				if SERVER then
					AddCSLuaFile(LOADER.DIR .. v .. "/shared.lua");
				end
			end
		end
	end
end

function LOADER.RequestSystemsLoaded()
	return LOADER.Systems
end

if ( SERVER ) then
	-- Serverside Forced Auto-Refresh
	-- By Acecool
	concommand.Add( "reloadgm", function( p, cmd, args )
		if ( p != NULL and !p:IsSuperAdmin( ) ) then return end
		GM = GAMEMODE
		LOADER.LoadCore()
		LOADER.FindDirectories()
		LOADER.LoadSystemInits()
		hook.Call( "OnReloaded", GAMEMODE )
		-- Client-Side refresh
		BroadcastLua( "GM = GAMEMODE; LOADER.LoadCore(); LOADER.FindDirectories(); LOADER.LoadSystemInits(); hook.Call( \"OnReloaded\", GAMEMODE );" );
	end );
end

--Start loading the gamemode
LOADER.LoadCore()
LOADER.FindDirectories()
LOADER.LoadSystemInits()

LOADER.Loaded = true