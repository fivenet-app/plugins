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

1. Make sure you fulfill all the [requirements above](#requirements) before continuing with the installation.
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

**Config hints:**

- `config/client.lua`:
    - `Config.WebURL` - Needs to be your FiveNet's instance URL, the default one `"https://fivenet.app"` is pointing to FiveNet's documentation page.
    - `Functions.CallNumber(number)` - Client hook used by the tablet when a phone number is dialed. Replace the example with your phone resource integration.
    - `Functions.SetRadioFrequency(frequency)` - Client hook used by the tablet when a radio frequency is changed. Replace the example with your radio resource integration.
- `config/server.lua`:
    - `Config.Framework` - **Must be set to the framework you are using!** Can be `esx` or `qbcore`.
    - `Config.API` section
        - Make sure to set the host and token (`Config.API.Host` and `Config.API.Token`) are set to your FiveNet Instances' DBSync API details, e.g., in FiveNet Cloud you can get the Sync API credentials from the instance settings page.
    - `Config.Dispatches.DisableClientDispatches` - If set to `true`, it will disable dispatches created from the client side, and only allow dispatches created from the server side. This is recommended for better security (default `false`).

### User Tracking (Livemap Locations)

- `Config.Tracking.Enabled` - Enables user tracking, which sends the user's location to FiveNet every `Config.Tracking.Interval` milliseconds.
- `Config.Tracking.Jobs` - A list of jobs that will be tracked.
- `Config.Tracking.Item` - If set, this item is required to be in the user's inventory for the user to appear on the map (if on duty).
    - This requires you to configure `Functions.CheckIfPlayerHidden` in `config/server.lua` so it checks your server's inventory system.
    - The default implementation is only an example. Replace it if you use a different inventory resource or different duty logic.
- `Config.Tracking.Interval` - The interval in milliseconds to send the user's location to FiveNet, default is `3000` (3 seconds). It is not recommended to set it lower than `3000` to avoid excessive load on the server and FiveNet.

### Server Hooks

`config/server.lua` contains integration hooks under `Functions = {}`. These are the parts you are expected to adapt to your server setup.

- `Functions.CheckIfPlayerHidden(xPlayer)` - Called by the tracking loop to decide whether a player should be hidden on the live map.
    - Return `true` to hide the player.
    - If `Config.Tracking.Item` is set, make sure the inventory check matches your inventory resource.
    - The default implementation shows how to handle ESX and QB-Core, but it is not universal.

#### Common Inventory Examples

##### ESX with `ox_inventory`

```lua
Functions.CheckIfPlayerHidden = function(xPlayer)
    if not Config.Tracking.Item then return false end

    local hasItem = exports.ox_inventory:Search(xPlayer.source, 'count', Config.Tracking.Item)
    return not xPlayer.job.onDuty or (hasItem or 0) < 1
end
```

##### QB-Core with `qb-inventory`

```lua
Functions.CheckIfPlayerHidden = function(xPlayer)
    if not Config.Tracking.Item then return false end

    local hasItem = exports['qb-inventory']:HasItem(xPlayer.PlayerData.source, Config.Tracking.Item)
    return not xPlayer.PlayerData.job.onduty or not hasItem
end
```

### Client Hooks

`config/client.lua` contains integration hooks under `Functions = {}` for client-side resources.

- `Functions.CallNumber(number)` - Called when the tablet UI wants to dial a number.
    - Replace the example phone integration with your own phone resource.
    - Return `false` if you want to block the action.
- `Functions.SetRadioFrequency(frequency)` - Called when the tablet UI wants to change the player's radio frequency.
    - Replace the example radio integration with your own radio resource.
    - Return `false` if you want to block the action.

#### Example: Start a Call

```lua
Functions.CallNumber = function(number)
    if number == nil or number == '' then
        return false
    end

    -- Your phone's export/event to start a call to `number` here
end
```

##### GKSPhone

```lua
exports["gksphone"]:StartingCall(number)
```

##### LB Phone

```lua
exports["lb-phone"]:CreateCall({ number = number })
```

#### Example: Set Radio Frequency

```lua
Functions.SetRadioFrequency = function(frequency)
    local currentChannel = exports['pma-voice']:getRadioChannel()

    if currentChannel ~= frequency then
        TriggerEvent('tgiann-radio:t', frequency)
    end
end
```

## Convars

| Name                  | Description                                                                                                                                               | Default |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `fnet_clear_on_start` | If set to `true`, it will clear all user locations on server start. This is useful if the server crashed and users are still marked as online on the map. | `false` |

## Event List

FiveM base events such as `onResourceStart`, etc. are not listed.

| Name                            | Type     | Description                                                                               | File                                                                                                               |
| ------------------------------- | -------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `esx:playerDropped`             | Base ESX | Player/Character dropped/quit server                                                      | [`server/events/esx/tracking.lua`](server/events/esx/tracking.lua), [`server/events/esx/timeclock.lua`](server/events/esx/timeclock.lua) |
| `esx_multichar:onCharTransfer`  | Custom   | Custom event added after a char has been transfered.                                      | [`server/events/esx/char_transfer.lua`](server/events/esx/char_transfer.lua)                                       |
| `esx:setJob`                    | Base ESX | Event should be already triggered by ESX accordingly when a char is selected/logged into. | [`server/events/esx/timeclock.lua`](server/events/esx/timeclock.lua)                                               |
| `esx_billing:sentBill`          | Custom   | Custom event sent after a bill has been sent to an user.                                  | [`server/events/esx/billing.lua`](server/events/esx/billing.lua)                                                   |
| `esx_billing:removedBill`       | Custom   | Removal of a bill from a player.                                                          | [`server/events/esx/billing.lua`](server/events/esx/billing.lua)                                                   |
| `esx_billing:paidBill`          | Custom   | Payment of a bill by a player.                                                            | [`server/events/esx/billing.lua`](server/events/esx/billing.lua)                                                   |
| `esx_license:addLicense`        | Custom   | Addition of a license to a player.                                                        | [`server/events/esx/licenses.lua`](server/events/esx/licenses.lua)                                                 |
| `esx_license:removeLicense`     | Custom   | Removal of a license from a player.                                                       | [`server/events/esx/licenses.lua`](server/events/esx/licenses.lua)                                                 |
| `esx_prison:jailPlayer`         | Custom   | Sending a player to jail.                                                                 | [`server/events/esx/jail.lua`](server/events/esx/jail.lua)                                                         |
| `esx_prison:unjailedByPlayer`   | Custom   | Releasing a player from jail by another player.                                           | [`server/events/esx/jail.lua`](server/events/esx/jail.lua)                                                         |
| `esx_prison:escapePoliceNotify` | Custom   | Notification to police of a player's escape from jail.                                    | [`server/events/esx/jail.lua`](server/events/esx/jail.lua)                                                         |
| `esx_policeJob:panicButton`     | Custom   | Police panic button activation.                                                           | [`server/events/esx/panic.lua`](server/events/esx/panic.lua)                                                       |
| `esx_society:fired`             | Custom   | Firing a player from a society/job.                                                       | [`server/events/esx/society.lua`](server/events/esx/society.lua)                                                   |
| `esx_society:gradeChanged`      | Custom   | Change of a player's job grade in a society.                                              | [`server/events/esx/society.lua`](server/events/esx/society.lua)                                                   |
| `esx_society:hired`             | Custom   | Hiring a player into a society/job.                                                       | [`server/events/esx/society.lua`](server/events/esx/society.lua)                                                   |

## Exports

### Client

The plugin provides the following exports on the **client side** for other resources to use:

| Name             | Description                                                                                        | File                                           |
| ---------------- | -------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| `createDispatch` | Creates a dispatch for a single job. It calls the server event `fivenet:createDispatchFromClient`. | [`client/functions.lua`](client/functions.lua) |

### Server

The plugin provides the following exports on the **server side** for other resources to use:

| Name                           | Description                                                                                                                                                                                         | File                                           |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| **Helpers**                    |                                                                                                                                                                                                     |                                                |
| `getPlayerUniqueIdentifier`    | Returns the unique identifier for a player source. On ESX this is the character identifier, on QB-Core it includes the citizen ID and license.                                                      | [`server/framework.lua`](server/framework.lua) |
| `getUserIDFromIdentifier`      | Returns the user's database ID for a framework identifier. On ESX this is the `users.id` row for the character identifier. On QB-Core this is the `players.id` row for the citizen ID and CID pair. | [`server/framework.lua`](server/framework.lua) |
| `getUserDBID`                  | Returns the user's database ID for a player source. This is the helper you usually want when you only have `source`.                                                                                | [`server/framework.lua`](server/framework.lua) |
| **Features**                   |                                                                                                                                                                                                     |                                                |
| `addUserActivity`              | Adds user activity for `tIdentifier`. If `sIdentifier` is omitted, the target user's DB ID is reused as the source user.                                                                            | [`server/activity.lua`](server/activity.lua) |
| `setUserProps`                 | Sets user properties for `tIdentifier`. The helper resolves and injects the internal user DB ID before sending, and mutates the passed table by adding `userId`.                                    | [`server/activity.lua`](server/activity.lua) |
| `updateOpenFines`              | Adds or subtracts from the open fine total for `tIdentifier`. Positive values add, negative values subtract.                                                                                        | [`server/activity.lua`](server/activity.lua) |
| `setUserWantedState`           | Sets the wanted state for `tIdentifier`. Pass a reason when you want the change to be attributed.                                                                                                   | [`server/activity.lua`](server/activity.lua) |
| `setUserBloodType`             | Sets the blood type for `tIdentifier`. This is usually only needed when external systems update it.                                                                                                 | [`server/activity.lua`](server/activity.lua) |
| `addJobColleagueActivity`      | Adds job colleague activity for `tIdentifier`. Pass both identifiers explicitly; there is no fallback when `sIdentifier` is omitted.                                                                | [`server/activity.lua`](server/activity.lua) |
| `setColleagueProps`            | Sets colleague properties for `tIdentifier`. The helper resolves and injects the internal user DB ID before sending, and mutates the passed table by adding `userId`.                               | [`server/activity.lua`](server/activity.lua) |
| `createDispatch`               | Creates a dispatch for the given user DB ID. `job` can be a string or a list of jobs.                                                                                                               | [`server/dispatch.lua`](server/dispatch.lua) |
| `createDispatchFromIdentifier` | Creates a dispatch for the given user identifier. This is the safer helper if you do not already have the DB ID.                                                                                    | [`server/dispatch.lua`](server/dispatch.lua) |

(Not all exports are listed here, as some are internal only, e.g., `SetupClient`, etc.)

## Examples

### Creating a Dispatch

> [!TIP]
> It is recommended to create dispatches from the server side if possible.

From the client side, you can create a dispatch like this (this example is for an ambulance dispatch at the player's current location and in the context of a `SendDistressSignal` function used by many death screen plugins):

```lua
SendDistressSignal = function()
    local coords = GetEntityCoords(PlayerPedId())
    local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    local message = "Help! I'm in trouble at " .. streetName

    -- Create a dispatch (this will trigger the server event `fivenet:createDispatchFromClient`)
    exports["fivenet"]:createDispatch("ambulance", "Help Request", message, coords.x, coords.y, false)
end
```

From the server side, you can create a dispatch like this (this example is for an ambulance dispatch at the player's current location, and it uses the `createDispatchFromIdentifier` export):

```lua
local function createAmbulanceDispatchForPlayer(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
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

If you want one dispatch to target multiple jobs, pass a job list on the server side:

```lua
exports["fivenet"]:createDispatch({ "ambulance", "police" }, "Multi Agency Call", "Backup requested", coords.x, coords.y, false, identifier)
```

## Building

> [!WARNING]
> It is not recommended to build the plugin and/or UI manually, as pre-built releases are provided via each [Releases' Assets](https://github.com/fivenet-app/plugins/releases).

FiveM servers with the yarn builder will auto build the FiveNet script parts needed for the plugin, but not the UI.

```console
yarn run build
```
