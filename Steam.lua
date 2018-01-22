--[[
	@Author: NuzzyFutts
	@Github: github.com/NuzzyFutts
	@File: Steam
	@input: {string} DEFAULT_STEAM_PATH - The path of the default steam directory
			{string} USER_ID - The user's steam ID
]]

function main(DEFAULT_STEAM_PATH, USER_ID)		-- For use in game drawer
	--function main(args)								-- For internal testing
	
		local DEFAULT_STEAM_PATH = args[1]
		local USER_ID = args[2]
	
		local function getIDsAndLastPlayed()
			local LOCAL_CONFIG_VDF_PATH = DEFAULT_STEAM_PATH.."userdata\\"..USER_ID.."\\config\\localconfig.vdf"
			local vdfFile = io.open(LOCAL_CONFIG_VDF_PATH,"r")
			local count = 0								--used to keep track of lines
			local found = false							--used for easier check of if we are in the apps section
			local level = 0								--used to keep track how deep in entries we currently are
			local currApp = {}							--used to keep track of data for current app
			local apps = {}								--used for storing data of all apps
			local previousLine = ""
	
			if vdfFile then
				for line in io.lines(LOCAL_CONFIG_VDF_PATH) do
	
					count = count + 1
					line = string.lower(line)
					if found or string.match(line,'%s*apps') then
	
						--=====================================================================================
						--                                        DEBUG
						--=====================================================================================
						--This line is used for debugging
						--It will print every line in terminal, as well as log it in
						--rainmeter log to assist debugging
						--debug(line)
	
						--increment/decrement level to check for closing of individual apps
						--entries and for checking when apps section has ended
						if string.match(line,"^%s*{") then				--if on a line where an app entry is beginning
							level = level + 1
							previousLine = "open"
						end
	
						--if on a line where an app entry is ending or line before is entry and this line is an entry
						if string.match(line,"^%s*}") or (previousLine == "id" and string.match(line,'^%s*"(%d+)"') ~= nil) then
	
							--only decrement level if only first case is satisfied and second case is false
							if string.match(line,"^%s*}") then
								level = level - 1
							end
							if level == 1 then
								currApp["appID"] = appID
								table.insert(apps,currApp)
	
								--if the game has never been played
								if currApp.lastPlayed == nil then
									currApp.lastPlayed = 0				--set lastplayed timestamp to 0
								end
								
								--=====================================================================================
								--                                        DEBUG
								--=====================================================================================
								--commented debug code to print all appIDs and lastPlayed timestamps
								--debug("appID: "..currApp.appID,"Last Played: "..currApp.lastPlayed)
	
								currApp = {}
								previousLine = "close"
							end
						end
						
						--individual game parameters capture
						local temp = string.match(line,'^%s*"(%d+)"')
						if temp ~= nil then
							appID = temp
							previousLine = "id"
						end
						
						--if currently in an app entry
						if level == 2 then
							local title = string.match(line,'^%s*"(%w*)"')
	
							--if title of current line is lastplayed, get timestamp data
							if title == "lastplayed" then
								currApp["lastPlayed"] = string.match(line,'.*"(%d*)"')
							end
							previousLine = "dataEntry"
						end
	
						--sets start line for check of closing of apps section
						if not found then
							previousLine = "begin"
							found = true
							start = count
						end
	
						--checks to stop reading file if apps section has ended
						if level == 0  and start ~= count then
							break
						end
					end
				end
		else
			--VDF file not found... Return nil for check further on in the script
			return nil
		end
			return apps
		end
	
		local function getAllDirectories()
			local LIBRARY_FOLDERS_VDF_PATH = DEFAULT_STEAM_PATH.."steamapps\\libraryfolders.vdf"
			local libVDFFile = io.open(LIBRARY_FOLDERS_VDF_PATH,"r")				--open libraryfolders.vdf
			local dirs = {DEFAULT_STEAM_PATH}										--initialize dirs table with default steam directory preinserted
	
			--if vdf file exists
			if libVDFFile then
	
				--iterate through all the lines
				for line in io.lines(LIBRARY_FOLDERS_VDF_PATH) do
					local dirline = string.match(line,'^%s*"%d+"%s*"(.*)"')			--match format for only lines with directories
					
					--if that format is on this line
					if dirline then
						newdirline = string.gsub(dirline,'\\\\','\\').."\\"
						table.insert(dirs,newdirline)								--insert that path into the table
					end
				end
			end
			return dirs																--return table of directories
		end
	
		local function checkAppManifests(directories,appTable)
			local resultTable = {}
			local currTable = {}
	
			--iterate through all steam directories
			for i=1,table.getn(directories) do
	
				--iterate through all app possibilities in each directory
				for curr = 1, table.getn(appTable) do
					local currManifest = directories[i].."steamapps/appmanifest_"..appTable[curr].appID..".acf"		--generate filepath for app
					manifestFile = io.open(currManifest,"r")														--open file
					
					--check if file exists
					if manifestFile then
	
						--iterate through all lines
						for line in io.lines(currManifest) do
							line = string.gsub(line,'[^%w%s%p]+',"")
							appName = string.match(line,'.*"name"%s*"(.*)"')										--obtain app name from file
							
							--if this line contains the name field
							if appName then
								currTable["appID"] = appTable[curr].appID
								currTable["lastPlayed"] = appTable[curr].lastPlayed
								currTable["appName"] = appName														--set appName in appTable
								currTable["installed"] = true														--set installed var in appTable (only for consistency across launchers)
								currTable["hidden"] = false															--PLACEHOLDER/INITIAL ASSIGNMENT parameter for if game should be hidden
								currTable["appPath"] = "steam://rungameid/"..appTable[curr].appID
								currTable["bannerURL"] = "http://cdn.akamai.steamstatic.com/steam/apps/"..appTable[curr].appID.."/header.jpg"
								currTable["bannerName"] = appTable[curr].appID..".jpg"
								currTable["launcher"] = "steam"														--defines which launcher this game is from
								table.insert(resultTable,currTable)
								currTable = {}
								break
							end
						end
					end
				end
			end
			return resultTable																						--return fully populated appTable
		end
	
		local dirs = getAllDirectories()
		local ids = getIDsAndLastPlayed()
		if ids == nil then
			local final = nil
			debug("VDF file not found... Stopping search")
		else
			local final = checkAppManifests(dirs,ids)
		end
		--=====================================================================================
		--                                        DEBUG
		--=====================================================================================
		--Debug code to log all found appNames, lastPlayed timestamps, and appIDs
		--[[for a = 1, table.getn(final) do
			debug(final[a].appName.."",final[a].lastPlayed.."",final[a].appID.."","")
		end
		debug("Total number of games found: ",table.getn(final))]]
	
		return final
	end
	
	--test command for debugging on my machine with my tools
	--steam "C:\Program Files (x86)\Steam\" 75154095