--[[
	@Author: NuzzyFutts
	@Github: github.com/NuzzyFutts
	@File: Battlenet
	@input: {string} BNET_CONFIG_FILE_PATH - The path of the Battle.net config file
]]

function main(BNET_CONFIG_FILE_PATH)
	
		local BNET_CONFIG_FILE_PATH = "C:\\Users\\Aimal\\AppData\\Roaming\\Battle.net\\battle.net.config"
	
		local LIST_OF_GAMES = {prometheus="Pro",destiny2="DST2",hero="Hero",hearthstone="WTCG",diablo3="D3",warcraft="WoW",starcraft2="S2",starcraft2="S1"}
		local GAME_NAMES = {prometheus="Overwatch",destiny2="Destiny 2",hero="Heroes of the Storm",hearthstone="Hearthstone",diablo3="Diablo 3",warcraft="World of Warcraft",starcraft2="Starcraft 2",starcraft2="Starcraft"}
		local BANNER_URLS = {prometheus="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-overwatch.jpg",destiny2="https://bnetproduct-a.akamaihd.net//ff5/c9fb7c865fa0eb80b1cacef42dd3cb1e-feature-07.png",herp="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-heroes.jpg",hearthstone="http://us.blizzard.com/static/_images/games/hearthstone/gamecard-games-hearthstone-en.jpg",diablo3="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-d3.jpg",warcraft="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-wow.jpg",starcraft2="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-sc2.jpg",starcraft2="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-sc1.jpg"}
	
		local function getInstalledGames()
			local familyFile = io.open(BNET_CONFIG_FILE_PATH,"r")
			local count = 0
			local found = false
			local level = 0
			local start = nil
			local count = 0
			local entry = nil
			local uid = nil
			local games = {}
	
			if familyFile then
				for line in io.lines(BNET_CONFIG_FILE_PATH) do
					
					count = count + 1
	
					if found or string.match(line,'Games') then
	
						entry = string.match(line,'^%s*"([%w%p]+)": {')
	
						if entry ~= nil and level == 1 and entry ~= "battle_net" and entry ~= "prometheus_test" then
							table.insert(games, entry)
						end
	
						if string.match(line, "{") then
							level = level + 1
						end
	
						if string.match(line, "}") then
							level = level - 1
						end
	
						if not found then
							found = true
							start = count
						end
	
						if level == 0 and start ~= count then
							break
						end
					end
				end
			else
				--game family file not found file not found
				debug("Error: Could not find/open the file 'battle.net.config'")
				return nil
			end
			return games
		end
		
		local function finalizeGames(games)
	
			local resultTable = {}
			local currTable = {}
	
			for i=1, table.getn(games) do
				currTable["appID"]= LIST_OF_GAMES[games[i]]
				currTable["appName"] = GAME_NAMES[games[i]]
				currTable["installed"] = true
				currTable["hidden"] = false
				currTable["lastPlayed"] =  nil
				currTable["appPath"] = "battlenet://"..LIST_OF_GAMES[games[i]]
				currTable["bannerURL"] = BANNER_URLS[games[i]]
				currTable["bannerName"] = LIST_OF_GAMES[games[i]]..".jpg"		--TODO
				currTable["launcher"] = "battlenet"
	
				table.insert(resultTable, currTable)
				currTable = {}
	
			end
	
			return resultTable
	
		end
	
		local installedGames = getInstalledGames()
		local final = finalizeGames(installedGames)
	
		return final
	
	end