function main(argv)

	BNET_CONFIG_FILES_PATH = argv[1]
	USER_ID = argv[2]

	--TODO
	--Get actual list of game names in cfg files
	LIST_OF_GAMES = {"battlet_net","prometheus","prometheus_test","destiny2","hero","hearthstone","diablo3","warcraft","starcraft2","starcraft"}

	function removeByElem(list,elem)
		for index, value in pairs(list) do
			if value == elem then
				return index
			end
		end
	end

	function getInstalledGames()

		local gameList = LIST_OF_GAMES
		local found = false
		local level = 0
		local start = nil
		local count = 0
		local installedGamesFile = BNET_CONFIG_FILES_PATH.."Battle.net.config"
		local cfgFile = io.open(installedGamesFile)
		local installedGames = {}

		for line in io.lines(installedGamesFile) do
			count = count + 1
			curr = string.match(line,'^[%s*},]"Games"')
			if found or curr then
				if not found then
					found = true
					start = count
				end

				local currLine = string.match(line,'[%s*}{,}]"(.*)"')

				if currLine in gameList then
					currGame = currLine
					table.remove(gameList,removeByElem(gameList,currGame))
				end
				
				if string.match(line,'.*}%s*,') then
					table.insert(installedGames,currGame)
				end

				if string.match('^%s*}\n') then
					break
				end

			end
		end
	end
end