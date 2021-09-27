--[[
	@Author: NuzzyFutts
	@Github: github.com/NuzzyFutts
	@File: getSteamGames
	@input: {table} argv - A list of inputs
	Order of inputs:
		1. {string} defaultSteamPath - The path of the default steam directory
		2. {string} userID - The user's steam ID
]]
 
function main(DEFAULT_STEAM_PATH,USER_ID)

		
	local function getIDsAndLastPlayed()
		local LOCAL_CONFIG_VDF_PATH = DEFAULT_STEAM_PATH.."userdata\\"..USER_ID.."\\config\\localconfig.vdf"
		local vdfFile = io.open(LOCAL_CONFIG_VDF_PATH,"r")
		local foundLevel = 0						--Used to keep track of how deep in entries we are AFTER we have found the right apps sectgion
		local currApp = {}							--used to keep track of data for current app
		local apps = {}								--used for storing data of all apps
									--used track number of apps
		
		if vdfFile then
			for line in vdfFile:lines() do

				
				line = string.lower(line)	-- we don't care about the capitalization of the data inside. Do this to reduce number of checks required

				if string.match(line,'%s*apps') then

					--increment/decrement level to check for closing of individual apps
					--entries and for checking when apps section has ended
					foundLevel = foundLevel + 1
						
				end

					
						
				-- Capture all remaining data and push it to return table
				if foundLevel == 1 then

					--individual game parameters capture
					local temp = string.match(line,'^%s*"(%d+)"')
					if temp ~= nil then
						local appID = temp
						currApp["appID"] = appID
						
					end

					local title = string.match(line,'^%s*"(%w*)"')
					--if title of current line is lastplayed, get timestamp data
					if title == "lastplayed" then
						currApp["lastPlayed"] = string.match(line,'.*"(%d*)"')
						table.insert(apps,currApp)
						currApp = {}
					end
					
						
					--sets start line for check of closing of apps section
					if title == "AppInfoChangeNumber" then
						foundLevel = 0
						break
					end
					
				end

				
			end
			vdfFile:close()
		end
		return apps
	end

	local function getAllDirectories()
		local LIBRARY_FOLDERS_VDF_PATH = DEFAULT_STEAM_PATH.."steamapps\\libraryfolders.vdf"
		local libVDFFile = io.open(LIBRARY_FOLDERS_VDF_PATH,"r")				--open libraryfolders.vdf
		local dirs = {DEFAULT_STEAM_PATH}										--initialize dirs table with default steam directory preinserted
		--local lines = {}

		--if vdf file exists
		if libVDFFile then

			--iterate through all the lines
			for line in libVDFFile:lines() do
				local dirline = string.match(line,'%u%:\\\\%a+%d?')			--match format for only lines with directories
				
				--if that format is on this line
				if dirline then
					local newdirline = string.gsub(dirline,'\\\\','\\')..'\\'
					table.insert(dirs,newdirline)								--insert that path into the table
					
				end
			end
			libVDFFile:close()
		end
		return dirs																--return table of directories
	end

	local function clearDirectoryDuplicates(direc)									--function to remove duplicates from directory table
    		local clean = {}
    		local t2 = {};  
    			for i,v in pairs(direc) do
        			t2[v] = i
    			end

    			for i,v in pairs(t2) do
        			table.insert(clean, i)
    			end
    		return clean
	end

	local function checkAppManifests(directories,appTable)
		local resultTable = {}
		local currTable = {}
		
		--iterate through all steam directories
		for i = 1, table.getn(directories) do

			--iterate through all app possibilities in each directory
			for curr = 1, table.getn(appTable) do
				local currManifest = directories[i].."steamapps\\appmanifest_"..appTable[curr].appID..".acf"		--generate filepath for app
				manifestFile = io.open(currManifest,"r")														--open file
				
				--check if file exists
				if manifestFile then

					--iterate through all lines
					for line in manifestFile:lines() do
						line = string.gsub(line,'[^%w%s%p]+',"")
						appName = string.match(line,'.*"name"%s*"(.*)"')										--obtain app name from file
						
						--if this line contains the name field
						if appName then
							currTable["appID"] = appTable[curr].appID
							currTable["lastPlayed"] = appTable[curr].lastPlayed
							currTable["appPath"] = "steam://rungameid/"..appTable[curr].appID
							currTable["bannerURL"] = "http://cdn.akamai.steamstatic.com/steam/apps/"..appTable[curr].appID.."/header.jpg"
							currTable["bannerName"] = appTable[curr].appID..".jpg"
							currTable["appName"] = appName														--set appName in appTable
							currTable["installed"] = true														--set installed var in appTable (only for consistency across launchers)
							currTable["hidden"] = false															--PLACEHOLDER/INITIAL ASSIGNMENT parameter for if game should be hidden
							currTable["launcher"] = "Steam"														--defines which launcher this game is from
							table.insert(resultTable,currTable)
							currTable = {}
							--break
						end
					end
					manifestFile:close()
				end
				
			end
			
		end
		return resultTable																						--return fully populated appTable
	end

	local dirs = getAllDirectories()
	local cleanDirs = clearDirectoryDuplicates(dirs)
	local ids = getIDsAndLastPlayed()
	local final = checkAppManifests(cleanDirs,ids)

	--=====================================================================================
	--                                        DEBUG
	--=====================================================================================
	--Debug code to log all found appNames, lastPlayed timestamps, and appIDs
	for a = 1, table.getn(final) do
		debug("App Name: "..final[a].appName.."","Last Played: "..final[a].lastPlayed.."","App ID: "..final[a].appID.."","")
	end
	debug("Total number of games found: ",table.getn(final))

	return final
end