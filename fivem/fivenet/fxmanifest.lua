fx_version 'cerulean'
game 'gta5'

author 'Galexrt and FiveNet contributors'
description 'FiveNet Plugin for FiveM servers.'
version 'v1.6.3'

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
	'ui/.output/public/**/*.woff',
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
    'server/user_updates.lua',
    'server/updatecheck.lua',
    'client/cmds/*.lua',
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
		{ 'Tracking - Clear Table on resource start', '$fnet_clear_on_start', 'CV_BOOL', 'false' },
	}
}
