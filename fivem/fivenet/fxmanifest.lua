fx_version 'cerulean'
game 'gta5'

author 'Galexrt and FiveNet contributors'
description 'FiveNet Plugin for FiveM servers.'
version 'v1.7.0'

lua54 'yes'
node_version '22'

dependencies {
	'yarn'
}

ui_page 'ui/.output/public/index.html'

files {
	'ui/.output/public/**/*.html',
	'ui/.output/public/**/*.js',
	'ui/.output/public/**/*.css',
	'ui/.output/public/**/*.woff2',
	'ui/.output/public/**/*.json',
	'ui/.output/public/**/*.png',
}

shared_scripts {
	'shared/lib/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config/server.lua',
	'dist/server.js',
	'server/bootstrap.lua',
	'server/lib/*.lua',
	'server/framework.lua',
	'server/helpers.lua',
	'server/activity.lua',
	'server/dispatch.lua',
	'server/markers.lua',
	'server/user_updates.lua',
	'server/updatecheck.lua',
	'server/cmds/*.lua',
	'server/tracking.lua',
	'server/events/esx/*.lua',
	'server/events/qbcore/*.lua',
}

client_scripts {
	'config/client.lua',
	'client/bootstrap.lua',
	'client/functions.lua',
	'client/tablet.lua',
	'client/tokenmgmt.lua',
	'client/dispatch.lua',
	'client/cmds/*.lua',
}

convar_category 'FiveNet' {
	'Configuration Options',
	{
		{ 'Tracking - Clear Table on resource start', 'fivenet_locations_clear_on_start', 'CV_BOOL', 'true' },
		{ 'Timeclock - End active entries on resource start', 'fivenet_end_timeclock_on_start', 'CV_BOOL', 'true' },
		-- Tablet URL for clients to override the config
		{ 'Tablet - Client URL', '$fivenet_tablet_client_url', 'CV_STRING', '' },
		-- Sync API convars to override the config
		{ 'Sync - API Host', 'fivenet_sync_api_host', 'CV_STRING', '' },
		{ 'Sync - API Token', 'fivenet_sync_api_token', 'CV_PASSWORD', '' },
		{ 'Sync - API Insecure', 'fivenet_sync_api_insecure', 'CV_BOOL', '' },
	}
}
