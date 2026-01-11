# fivem

This is a very basic FiveM plugin for FiveNet.
It enables the use of the tablet in-game, tracks user locations, and certain events if setup correctly.

Please note that a bunch of custom events are necessary to be added to ESX, QB-Core, and plugin code for FiveNet to reach its full potential, see [the Event List below](#event-list).

For screenshots, checkout the [README FiveM Plugin section](../../README.md#fivem-plugin).

> [!TIP]
> To install the plugin, it is recommended to use the pre-built releases provided via the [Releases' Assets](https://github.com/fivenet-app/plugins/releases).
>
> If you want to build the plugin yourself, which is not recommended unless you have advanced knowledge in NodeJS/Javascript, please see the [Building](#building) section below.

## Requirements

- FiveM Server version `10488` and higher.
- FiveM Yarn Builder Plugin (part of [the cfx-server-data repository](https://github.com/citizenfx/cfx-server-data/tree/master/resources/[system]/[builders]/yarn)).
    - IMPORTANT: You must modify the Yarn Builder file `yarn_cli.js` to add the `--ignore-engines` flag to the `yarn` call/execution, see [the code change here](#yarn-builder-patch).
- Frameworks ESX and QB-Core Frameworks are supported via the `Config.Framework` option in the `config/server.lua` file
- A running FiveNet server or at least FiveNet's DBSync configured.
    - Must be running at least FiveNet version `v2025.5.3` or higher.

### Yarn Builder Patch

This is the diff/patch to apply to the `yarn_builder` resource to allow it to compile the FiveNet plugin correctly, if you are not using the available pre-built release build.

```diff
diff --git a/resources/[BASE]/[system]/[builders]/yarn/yarn_builder.js b/resources/[BASE]/[system]/[builders]/yarn/yarn_builder.js
index 5e85d839ae..47ce760626 100644
--- a/resources/[BASE]/[system]/[builders]/yarn/yarn_builder.js
+++ b/resources/[BASE]/[system]/[builders]/yarn/yarn_builder.js
@@ -43,7 +43,7 @@ const yarnBuildTask = {
 			currentBuildingModule = resourceName;
 			const proc = child_process.fork(
 				require.resolve('./yarn_cli.js'),
-				['install', '--ignore-scripts', '--cache-folder', path.join(initCwd, 'cache', 'yarn-cache'), '--mutex', 'file:' + path.join(initCwd, 'cache', 'yarn-mutex')],
+				['install', '--ignore-scripts', '--ignore-engines', '--cache-folder', path.join(initCwd, 'cache', 'yarn-cache'), '--mutex', 'file:' + path.join(initCwd, 'cache', 'yarn-mutex')],
 				{
 					cwd: path.resolve(GetResourcePath(resourceName)),
 					stdio: 'pipe',
```
(Green line with the `+` at the start is the line how it should look after making the change.)

You might need to delete the `.yarn.installed` from the FiveNet plugin directory to ensure Yarn builder to install the dependencies correctly this time.
Make sure to restart your FiveM server after applying the patch to the `yarn_builder` resource.

## Installation

1.
2. Download the latest release from the [Releases' Assets](https://github.com/fivenet-app/plugins/releases). The file is named `fivenet-fivem-plugin.zip`.
    - **Don't clone the repo** unless you know what manual steps are needed to build the plugin!
3. Extract the contents of the zip file into your FiveM server's `resources` directory.
4. Add `ensure fivenet` to your server's `server.cfg` file. Otherwise the FiveM server might not load the plugin.
5. Configure the plugin by editing the files in the `config/` directory, see [the Configuration section below](#configuration).
6. Make sure to look into how to integrate FiveNet into your server's plugins.
7. Restart your FiveM server and enjoy!

## Updating the Plugin

To update the plugin, follow these steps:

1. In the existing `fivenet` plugin directory, delete the following directories and files:
    - `client/`
    - `scripts/`
    - `server/`
    - `ui/`
    - `config/` (optional, if you want to reset the config to default)
        - Take a backup of your existing config files if you have made changes to them in case you accidentally overwrite them when updating.
        - Make sure to compare your current configs with the new default configs in the new release, as new config options may have been added.
2. Download the latest release from the [Releases' Assets](https://github.com/fivenet-app/plugins/releases). The file is named `fivenet-fivem-plugin.zip`.
3. Extract the contents of the zip file and copy over the contents into the existing `fivenet` plugin directory and overwrite all files, except your `config/*.lua` files if prompted.

## Configuration

The config is split into `client.lua` and `server.lua` in the [`config/` directory](config/).



Config hints:

- `config/client.lua`:
    - `Config.WebURL` - Needs to be your FiveNet's instance URL, the default one `"https://fivenet.app"` is pointing to FiveNet's documentation page.
- `config/server.lua`:
    - `Config.Framework` - **Must be set to the framework you are using!** Can be `esx` or `qbcore`.
    - `Config.API` section
        - Make sure to set the host and token (`Config.API.Host` and `Config.API.Token`) are set to your FiveNet Instances' DBSync API details, e.g., in FiveNet Cloud you can get the Sync API credentials from the instance settings page.
    - `Config.Dispatches.DisableClientDispatches` - If set to `true`, it will disable dispatches created from the client side, and only allow dispatches created from the server side. This is recommended for better security (default `false`).

### User Tracking (Livemap Locations)

- `Config.Tracking.Enabled` - Enables user tracking, which sends the user's location to FiveNet every `Config.Tracking.Interval` milliseconds.
- `Config.Tracking.Jobs` - A list of jobs that will be tracked.
- `Config.Tracking.Item` - If set, this item is required to be in the user's inventory for the user to appear on the map (if on duty).
    - This requires you to configure the `Functions.CheckIfPlayerHidden` function to check your servers' inventory system for the item.
- `Config.Tracking.Interval` - The interval in milliseconds to send the user's location to FiveNet, default is `3000` (3 seconds). It is not recommended to set it lower than `3000` to avoid excessive load on the server and FiveNet.

## Convars

| Name                  | Description                                                                                                                                               | Default |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `fnet_clear_on_start` | If set to `true`, it will clear all user locations on server start. This is useful if the server crashed and users are still marked as online on the map. | `false` |

## Event List

FiveM base events such as `onResourceStart`, etc. are not listed.

| Name                            | Type     | Description                                                                               | File                                                                                                       |
| ------------------------------- | -------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `esx:playerLoaded`              | Base ESX | Player/Character loaded                                                                   | [`server/events/player_props.lua`](server/events/player_props.lua)                                         |
| `esx:playerDropped`             | Base ESX | Player/Character dropped/quit server                                                      | [`server/tracking.lua`](server/tracking.lua), [`server/events/timeclock.lua`](server/events/timeclock.lua) |
| `esx_multichar:onCharTransfer`  | Custom   | Custom event added after a char has been transfered.                                      | [`server/events/char_transfer.lua`](server/events/char_transfer.lua)                                       |
| `esx:setJob`                    | Base ESX | Event should be already triggered by ESX accordingly when a char is selected/logged into. | [`server/events/timeclock.lua`](server/events/timeclock.lua)                                               |
| `esx_billing:sentBill`          | Custom   | Custom event sent after a bill has been sent to an user.                                  | [`server/events/billing.lua`](server/events/billing.lua)                                                   |
| `esx_billing:removedBill`       | Custom   | Removal of a bill from a player.                                                          | [`server/events/billing.lua`](server/events/billing.lua)                                                   |
| `esx_billing:paidBill`          | Custom   | Payment of a bill by a player.                                                            | [`server/events/billing.lua`](server/events/billing.lua)                                                   |
| `esx_license:addLicense`        | Custom   | Addition of a license to a player.                                                        | [`server/events/licenses.lua`](server/events/licenses.lua)                                                 |
| `esx_license:removeLicense`     | Custom   | Removal of a license from a player.                                                       | [`server/events/licenses.lua`](server/events/licenses.lua)                                                 |
| `esx_prison:jailPlayer`         | Custom   | Sending a player to jail.                                                                 | [`server/events/jail.lua`](server/events/jail.lua)                                                         |
| `esx_prison:unjailedByPlayer`   | Custom   | Releasing a player from jail by another player.                                           | [`server/events/jail.lua`](server/events/jail.lua)                                                         |
| `esx_prison:escapePoliceNotify` | Custom   | Notification to police of a player's escape from jail.                                    | [`server/events/jail.lua`](server/events/jail.lua)                                                         |
| `esx_policeJob:panicButton`     | Custom   | Police panic button activation.                                                           | [`server/events/panic.lua`](server/events/panic.lua)                                                       |
| `esx_society:fired`             | Custom   | Firing a player from a society/job.                                                       | [`server/events/society.lua`](server/events/society.lua)                                                   |
| `esx_society:gradeChanged`      | Custom   | Change of a player's job grade in a society.                                              | [`server/events/society.lua`](server/events/society.lua)                                                   |
| `esx_society:hired`             | Custom   | Hiring a player into a society/job.                                                       | [`server/events/society.lua`](server/events/society.lua)                                                   |

## Exports

### Client

The plugin provides the following exports on the **client side** for other resources to use:

| Name             | Description                                                                   | File                                           |
| ---------------- | ----------------------------------------------------------------------------- | ---------------------------------------------- |
| `createDispatch` | Creates a dispatch (uses the server event `fivenet:createDispatchFromClient`) | [`client/functions.lua`](client/functions.lua) |

### Server

The plugin provides the following exports on the **server side** for other resources to use:

| Name                           | Description                                                                                                                                                                          | File                                           |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------- |
| **Helpers**                    |                                                                                                                                                                                      |                                                |
| `getPlayerUniqueIdentifier`    | Returns the unique identifier (license) of a player by source                                                                                                                        | [`server/framework.lua`](server/framework.lua) |
| `getUserIDFromIdentifier`      | Returns the user's unique database ID for a given user's identifier (e.g., ESX `id` column in `users` table)                                                                         | [`server/framework.lua`](server/framework.lua) |
| `getUserDBID`                  | Returns the user's unique database ID for a given player's source                                                                                                                    | [`server/framework.lua`](server/framework.lua) |
| **Features**                   |                                                                                                                                                                                      |                                                |
| `addUserActivity`              | Adds user activity for the given user identifier (`tIdentifier`) and uses `sIdentifier` as the source user if provided (otherwise it will be `nil` (created by the system))          | [`server/functions.lua`](server/functions.lua) |
| `setUserProps`                 | Sets the user properties for the given user identifier (`tIdentifier`)                                                                                                               | [`server/functions.lua`](server/functions.lua) |
| `updateOpenFines`              | Updates the open fines for the given user identifier (`tIdentifier`), if the `fine` is positive it will be added, negative will be substracted from the user's total.                | [`server/functions.lua`](server/functions.lua) |
| `setUserWantedState`           | Sets the user wanted state for the given user identifier (`tIdentifier`) with a (required) reason.                                                                                   | [`server/functions.lua`](server/functions.lua) |
| `setUserBloodType`             | Sets the user blood type for the given user identifier (`tIdentifier`). You normally don't use this as the char join/loaded event is used to set it "once."                          | [`server/functions.lua`](server/functions.lua) |
| `addJobColleagueActivity`      | Adds job colleague activity for the given user identifier (`tIdentifier`) and uses `sIdentifier` as the source use if provided (otherwise it will be `nil` (created by the system))  | [`server/functions.lua`](server/functions.lua) |
| `setColleagueProps`            | Sets the colleague's properties for the given job and user identifier (`tIdentifier`) with a (required) reason.                                                                      | [`server/functions.lua`](server/functions.lua) |
| `createDispatch`               | Creates a dispatch for the given **user DB ID**, so you would need to use `getUserDBID` export to get the user's DB ID first. For an example see below [here](#creating-a-dispatch). | [`server/functions.lua`](server/functions.lua) |
| `createDispatchFromIdentifier` | Creates a dispatch for the given user by their identifier. For an example see below [here](#creating-a-dispatch).                                                                    | [`server/functions.lua`](server/functions.lua) |

(Not all exports are listed here, as some are internal only, e.g., `SetupClient`, etc.)

## Examples

### Creating a Dispatch

> [!TIP]
> It is recommended to create dispatches from the server side if possible.

From the client side, you can create a dispatch like this (this example is for an ambulance dispatch at the player's current location and in the context of a `SendDistressSignal` function used by many death screen plugins):

```lua
SendDistressSignal = function()
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    local message = "Help! I'm in trouble at " .. streetName

    -- Create a dispatch (this will trigger the server event `fivenet:createDispatchFromClient`)
    exports["fivenet"]:createDispatch("ambulance", "Help Request", message, coords.x, coords.y, false, source)
end
```

From the server side, you can create a dispatch like this (this example is for an ambulance dispatch at the player's current location, and it uses the `createDispatchFromIdentifier` export):

```lua
local function createAmbulanceDispatchForPlayer(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    local heading = GetEntityHeading(GetPlayerPed(source))
    local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    local message = "Help! I'm in trouble at " .. streetName

    -- ESX example to get the player's identifier
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local identifier = xPlayer.identifier
    -- It is recommended to use the FiveNet `getPlayerUniqueIdentifier` export instead to get the identifier unless you know what you are doing.

    exports["fivenet"]:createDispatchFromIdentifier("ambulance", "Help Request", message, coords.x, coords.y, false, identifier)
end
```

## Building

> [!WARNING]
> It is not recommended to build the plugin and/or UI manually, as pre-built releases are provided via each [Releases' Assets](https://github.com/fivenet-app/plugins/releases).

FiveM servers with the yarn builder will auto build the FiveNet script parts needed for the plugin, but not the UI.

```console
yarn run build
```
