# fivem

This is a very basic FiveM plugin for FiveNet.
It enables the use of the tablet in-game, tracks user locations, and certain events if setup correctly.

Please note that a bunch of custom events are necessary to be added to ESX plugin code for FiveNet to reach its full potential.

> For screenshots, please go to [README.md](../../README.md#fivem-plugin).

## Requirements

- FiveM Server version `10488` and higher.
    - If you don't use a compiled release, you need to modify the Yarn Builder by adding `--ignore-engines` flag to the `yarn_cli.js` call, see [the diff below](#yarn-builder-patch).
- Frameworks ESX and QB-Core Frameworks are supported via the `Config.Framework` option in the `config/server.lua` file
- A running FiveNet server or at least FiveNet's DBSync configured.
    - Must be running at least FiveNet version `v2025.5.3` or higher.

## Building

FiveM servers with the yarn builder will auto build the FiveNet script parts needed for the plugin, but not the UI.

```console
yarn run build
```

## Configuration

The config is split into `client.lua` and `server.lua` in the [`config/` directory](config/).

Config hints:

* `config/client.lua`:
    * `Config.WebURL` - Needs to be your FiveNet's instance URL, the default one `"https://fivenet.app"` is pointing to FiveNet's documentation page.
* `config/server.lua`:
    * `Config.Framework` - **Must be set to the framework you are using!** Can be `esx` or `qbcore`.
    * `Config.API` section - Make sure to set the host (`Config.API.Host`) and token (`Config.API.Token`) that your FiveNet instance uses for the sync API.

## Event List

FiveM base events such as `onResourceStart`, etc. are not listed.

| Name                            | Type     | Description                                                                               | File                                                                                                       |
| ------------------------------- | -------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `esx:playerLoaded`              | Base ESX | Player/Character loaded                                                                   | [`server/events/player_props.lua`](server/events/player_props.lua)                                         |
| `esx:playerDropped`             | Base ESX | Player/Character dropped/quit server                                                      | [`server/tracking.lua`](server/tracking.lua), [`server/events/timeclock.lua`](server/events/timeclock.lua) |
| `esx_multichar:onCharTransfer`  | Custom   | Custom event added after a char has been transfered.                                      | [`server/events/char_transfer.lua`](server/events/char_transfer.lua)                                       |
| `esx:setJob`                    | Base ESX | Event should be already triggered by ESX accordingly when a char is selected/logged into. | [`server/events/timeclock.lua`](server/events/timeclock.lua)                                               |
| `esx_billing:sentBill`          | Custom   | Custom event sent after a bill has been sent to an user.                                  | [`server/events/billing.lua`](server/events/billing.lua)                                                   |
| `esx_billing:removedBill`       | Custom   |                                                                                           | [`server/events/billing.lua`](server/events/billing.lua)                                                   |
| `esx_billing:paidBill`          | Custom   |                                                                                           | [`server/events/billing.lua`](server/events/billing.lua)                                                   |
| `esx_license:addLicense`        | Custom   |                                                                                           | [`server/events/licenses.lua`](server/events/licenses.lua)                                                 |
| `esx_license:removeLicense`     | Custom   |                                                                                           | [`server/events/licenses.lua`](server/events/licenses.lua)                                                 |
| `esx_prison:jailPlayer`         | Custom   |                                                                                           | [`server/events/police.lua`](server/events/police.lua)                                                     |
| `esx_prison:unjailedByPlayer`   | Custom   |                                                                                           | [`server/events/police.lua`](server/events/police.lua)                                                     |
| `esx_prison:escapePoliceNotify` | Custom   |                                                                                           | [`server/events/police.lua`](server/events/police.lua)                                                     |
| `esx_policeJob:panicButton`     | Custom   |                                                                                           | [`server/events/police.lua`](server/events/police.lua)                                                     |
| `esx_society:fired`             | Custom   |                                                                                           | [`server/events/society.lua`](server/events/society.lua)                                                   |
| `esx_society:gradeChanged`      | Custom   |                                                                                           | [`server/events/society.lua`](server/events/society.lua)                                                   |
| `esx_society:hired`             | Custom   |                                                                                           | [`server/events/society.lua`](server/events/society.lua)                                                   |

## Yarn Builder Patch

This is the diff/patch to apply to the yarn_builder resource to allow it to compile the FiveNet plugin correctly, if you are not using the available pre-built release build.

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
