function main(TEMP_DIR)

	function parseFileData()
		os.execute("REG QUERY \"HKLM\\SOFTWARE\\EA Games\" /s > "..TEMP_DIR.."msg.txt")
		local dataFile = io.open(TEMP_DIR.."msg.txt")
		local inEntry = false
		local allFound = false
		local currGame = {}
		local games = {}
		if dataFile then
			for line in dataFile:lines() do
				local key, type, val = string.match(line,"^%s%s+([%a%s]*)%s%s+([%a%p]*)%s*(.*)")
				if key ~= nil and string.match(key, "DisplayName") then
					currGame["name"] = val
				end
				if key ~= nil and string.match(key, "Product GUID") then
					os.execute("REG QUERY \"HKLM\\SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\"..val.."\" /v DisplayIcon > "..TEMP_DIR.."msg2.txt")
					currGame["guid"] = val
				end
				if key ~= nil and string.match(key, "Install Dir") then
					currGame["path"] = getExePath(val)
					allFound = true
				end
				if allFound then
					allFound = false
					table.insert(games, currGame)
					currGame = {}
				end
			end
			dataFile:close()
			os.execute("del "..TEMP_DIR.."msg.txt")
		else
			--game family file not found file not found
			debug("Error: Could not open the file created by running the REG command")
			return nil
		end
		return games
	end

	function getExePath(gameGUID)
		local dataFile = io.open(TEMP_DIR.."msg2.txt")
		local inEntry = false
		local allFound = false
		local actualPath = nil
		if dataFile then
			for line in dataFile:lines() do
				local key, type, val = string.match(line,"^%s%s+([%a%s]*)%s%s+([%a%p]*)%s*(.*)")
				if key ~= nil and string.match(key, "DisplayIcon") then
					actualPath = val:sub(2,-2)
				end
			end
			dataFile:close()
		else
			--game family file not found file not found
			debug("Error: Could not open the file created by running the REG command")
			return nil
		end
		os.execute("del "..TEMP_DIR.."msg2.txt")
		return actualPath
	end

	local function finalizeGames(games)

		local resultTable = {}
		local currTable = {}

		if games ~= nil then 
			for i=1, table.getn(games) do
				currTable["appID"]= games[i].guid
				currTable["appName"] = games[i].name
				currTable["installed"] = true
				currTable["hidden"] = false
				currTable["lastPlayed"] =  nil
				currTable["appPath"] = games[i].path
				currTable["bannerURL"] = nil --TODO
				currTable["bannerName"] = games[i].name..".png"		--TODO
				currTable["launcher"] = Origin

				table.insert(resultTable, currTable)
				currTable = {}
			end
		end

		return resultTable

	end
	
	local gameData = parseFileData()
	local final = finalizeGames(gameData)
	for a = 1, table.getn(final) do
		debug("App Name: "..final[a].appName.."","App Path: "..final[a].appPath.."","App ID: "..final[a].appID.."","")
	end
	debug("Total number of games found: ",table.getn(final))

	return final
		
end