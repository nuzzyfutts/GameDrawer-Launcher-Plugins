GameDrawer Launcher Plugins
===
Lua plugin that detects installed games for different launchers

This plugin grabs games from multiple launchers and consolidates them, with the ability to launch them. It also grabs banners and other information. The list of things that it grabs is as follows:

    appID - The unique identifier for the game
    lastPlayed - When the game was last played
    appName - The full name for the game
    installed - Is the game installed
    hidden - Should the game be hidden
    appPath - THe path to launch the game
    bannerURL - The URL to download the banner
    bannerName - What the banner name will be saved as
    launcher - what launcher is the game using
    
All the games from all launchers will use this standardized format. If any changes need to be made, all of the scripts will be adjusted to accomodate them.

## Compatability
- Steam
	- Once provided with a default steam directory, obtains all games across all Steam folders located in each drive.
	-Grabs banners and last played data for sorting
	-Grabs urls for launching games through the use of Steam's Desktop API
- Battlenet
	- Grabs all games and banners for all games on Battlenet
	- Grabs urls for launching games through the use of Blizzard's Desktop API

### Upcoming
- GOG Galaxy
- Origin
- Bethesda (Maybe)
