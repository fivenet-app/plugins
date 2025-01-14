# fivem

This is a very basic FiveM plugin for FiveNet.
It enables the use of the tablet in-game, tracks user locations, and certain events if setup correctly.

Please note that a bunch of custom events are necessary to be added to ESX plugin code for FiveNet to reach its full potential.

> For screenshots, please go to [README.md](../../README.md#fivem-plugin).

## Requirements

* FiveM Server version `10488` and higher.
    * Webpack and Yarn Builder Plugins
* ESX Framework (most ESX usages in the code can easily be replaced with your framework of choice or your own implementation)
* Running FiveNet instance (server, worker)
    * Depending on if FiveNet uses the gameserver's database, might need FiveNet's DBSync credentials.

## Building

FiveM servers with the yarn builder will auto build the FiveNet script parts needed for the plugin, but not the UI.

```console
yarn run build
```

## Configuration

The config is split into `client.lua` and `server.lua` in the [`config/` directory](config/).

Config hints:

* `client.lua`:
    * `Config.WebURL` - Needs to be your FiveNet's instance URL, the default one `"https://fivenet.app"` is pointing to FiveNet's documentation page.
* `server.lua`:
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
