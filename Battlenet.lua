--[[
	@Author: NuzzyFutts
	@Github: github.com/NuzzyFutts
	@File: Battlenet
	@input: {string} BNET_CONFIG_FILE_PATH - The path of the Battle.net config file
]]

function main(BNET_CONFIG_FILE_PATH)
	
		-- Hard coded because this is standard throughout all systems (with C being the primary drive)
		local BNET_CONFIG_FILE_PATH = "C:\\Users\\Aimal\\AppData\\Roaming\\Battle.net\\battle.net.config"

		--Dictionary to convert names of games installed found in Battle.net.config to appID names to launch through the Blizzard App Desktop API
		local LIST_OF_GAMES = {prometheus="Pro",destiny2="DST2",hero="Hero",hearthstone="WTCG",diablo3="D3",warcraft="WoW",starcraft2="S2",starcraft2="S1"}
		
		--Dictionary to convert names found to names to be displayed in GameDrawer
		local GAME_NAMES = {prometheus="Overwatch",destiny2="Destiny 2",hero="Heroes of the Storm",hearthstone="Hearthstone",diablo3="Diablo 3",warcraft="World of Warcraft",starcraft2="Starcraft 2",starcraft2="Starcraft"}
		
		--Hard coded URLs to download banners from Blizzard's website since they don't have a system like Steam
		local BANNER_URLS = {prometheus="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-overwatch.jpg",destiny2="https://bnetproduct-a.akamaihd.net//ff5/c9fb7c865fa0eb80b1cacef42dd3cb1e-feature-07.png",herp="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-heroes.jpg",hearthstone="http://us.blizzard.com/static/_images/games/hearthstone/gamecard-games-hearthstone-en.jpg",diablo3="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-d3.jpg",warcraft="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-wow.jpg",starcraft2="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-sc2.jpg",starcraft2="http://us.blizzard.com/static/_images/lang/en-us/gamecard-games-sc1.jpg"}
	

		--[[
			Function to get the list of installed games from Battle.net.config
		]]
		local function getInstalledGames()
			local familyFile = io.open(BNET_CONFIG_FILE_PATH,"r")	--Open the file so it can be read
			local count = 0											--Counter to keep track of which line we are on (so we can exit)
			local found = false										--Boolean to not string.match every time on line 42
			local level = 0											--How many levels ({) deep arae we in the file
			local start = nil										--What the line of starting of the 'Games' entry is (so we can exit)
			local entry = nil										--What the current entry is (used for keeping track of actual games)
			local games = {}										--The list of all games to be returned later
	
			if familyFile then
				for line in io.lines(BNET_CONFIG_FILE_PATH) do
					
					count = count + 1
	
					--If we are encountering the Games entry for the first time or if we have found it already
					if found or string.match(line,'Games') then
	
						--Look for entries in the games section that match the syntax for a game entry
						entry = string.match(line,'^%s*"([%w%p]+)": {')
	
						--ignore battle_net and prometheus because they can't be launched through Blizzard Desktop API
						if entry ~= nil and level == 1 and entry ~= "battle_net" and entry ~= "prometheus_test" then
							table.insert(games, entry)
						end
	
						--increment level if we have a { on this line}
						if string.match(line, "{") then
							level = level + 1
						end
	
						--decrement level if we have a } on this line
						if string.match(line, "}") then
							level = level - 1
						end
	
						--if first run through, make found = true and set start line
						if not found then
							found = true
							start = count
						end
						
						--if we have exited the games entry in the json file, exit the loop
						if level == 0 and start ~= count then
							break
						end
					end
				end
			else
				--Battle.net.config not found file not found
				debug("Error: Could not find/open the file 'battle.net.config'")
				return nil
			end
			return games
		end
		
		local function finalizeGames(games)
	
			local resultTable = {}		--final table of all finalized games
			local currTable = {}		--Current table to keep track of individual games one at a time
			local currGame = nil
	
			--Assign all required values for ecah game
			for i=1, table.getn(games) do
				currGame = games[i]
				currTable["appID"]= LIST_OF_GAMES[currGame]							--The unique appID for each game
				currTable["appName"] = GAME_NAMES[currGame]							--The name of each game that will be displayed/user facing
				currTable["installed"] = true										--Initialized value for consistency with launchers
				currTable["hidden"] = false											--Initialized default value for use with GameDrawer
				currTable["lastPlayed"] =  nil										--Initialized for use with GameDrawer
				currTable["appPath"] = "battlenet://"..LIST_OF_GAMES[games[i]]		--Use of Blizzard desktop API
				currTable["bannerURL"] = BANNER_URLS[currGame]						--URLs of banners from Blizzard's website
				currTable["bannerName"] = LIST_OF_GAMES[currGame]..".jpg"			--The name that each banner will have
				currTable["launcher"] = "battlenet"									--The launcher of current game. For use with GameDrawer
	
				--Insert current game table into final table
				table.insert(resultTable, currTable)

				--Reset table for potential debugging
				currTable = {}
	
			end

			if resultTable == {} then
				debug("No installed games found for Blizzard App")
				return nil
			else
				return resultTable
			end
		end
	
		local installedGames = getInstalledGames()

		if installedGames == nil then
			local final = nil
		else
			local final = finalizeGames(installedGames)
		end
		
		return final
	
	end