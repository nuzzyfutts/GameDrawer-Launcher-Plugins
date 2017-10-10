function main(argv)
    
    function getIDsAndLastPlayed()
        local steamVDFPATH = "C:\\Program Files (x86)\\Steam\\userdata\\75154095\\config\\localconfig.vdf"
        local vdfFile = io.open(steamVDFPATH,"r")
        local count = 0
        local found = false
        local opens = 0
        local closes = 0
        local ending = nil
        local currApp = {}
        local apps = {}

        if vdfFile then
            for line in io.lines(steamVDFPATH) do
                count = count + 1
                line = string.lower(line)
                if found or string.match(line,'%s*apps') then
                    
                    --sets start line for check of closing of apps section
                    if not found then
                        found = true
                        start = count
                    end
                    
                    --increment entry opens/closes to check for closing of apps section
                    if string.match(line,"^%s+{") then
                        opens = opens + 1
                    end
                    if string.match(line,"^%s+}") then
                        closes = closes + 1
                        if closes ~= opens then
                            currApp["appID"] = appID
                        end
                        table.insert(apps,currApp)
                        currApp = {}
                    end
                    
                    --individual game parameters capture
                    if string.match(line,'^%s*"(%d+)"') then
                        appID = string.match(line,'^%s*"(%d+)"')
                    end
                    
                    if opens == closes + 2 then
                        local title = string.match(line,'^%s*"(%w*)"')
                        if title == "lastplayed" then
                            currApp["lastPlayed"] = string.match(line,'.*"(%d*)"')
                        end
                    end

                    --checks to stop reading file if apps section has ended
                    if opens == closes  and start ~= count then
                        ending = count
                        break
                    end
                end
            end
        end

        return apps

    end

    function getAllDirectories(libFoldersVDFPath)

        libFoldersVDFPath = "C:\\Program Files (x86)\\Steam\\steamapps\\libraryfolders.vdf"
        local libVDFFile = io.open(libFoldersVDFPath)
        local dirs = {"C:/Program Files (x86)/Steam/"}

        if libVDFFile then
            for line in io.lines(libFoldersVDFPath) do
                local dirline = string.match(line,'^%s*"%d+"%s*"(.*)"')
                if dirline then
                    table.insert(dirs,dirline)
                end
            end
        end
        return dirs
    end

    function checkAppManifests(directories,appTable)

        currInstalled = false
        
        for i=1,table.getn(directories) do
            for curr = 1, table.getn(appTable) do
                local currManifest = directories[i].."/steampps/"..appTable[appID]
                manifestFile = io.open(currManifest,"r")
                if manifestFile:read('*all') then
                    print(manifestFile)
                end
            end
        end
    end

    checkAppManifests(getAllDirectories(""),getIDsAndLastPlayed())

end