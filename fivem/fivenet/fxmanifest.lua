fx_version 'cerulean'
game 'gta5'

author 'Galexrt and FiveNet contributors'
description 'FiveNet Plugin for FiveM servers.'
version 'v1.5.0'

lua54 'yes'

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

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/server.lua',
    'dist/server.js',
    'server/bootstrap.lua',
    'server/lib/identifier.lua',
    'server/lib/jobs.lua',
    'server/lib/version.lua',
    'server/lib/user_locations.lua',
    'server/framework.lua',
    'server/helpers.lua',
    'server/activity.lua',
    'server/dispatch.lua',
    'server/user_updates.lua',
    'server/lib/tracking.lua',
    'server/updatecheck.lua',
    'server/tracking.lua',
    'server/events/esx/*.lua',
    'server/events/qbcore/*.lua',
}

client_scripts {
	'config/client.lua',
	'client/*.lua'
}

convar_category 'FiveNet' {
	'Configuration Options',
	{
		{ 'Tracking - Clear Table on resource start', '$fnet_clear_on_start', 'CV_BOOL', 'false' },
	}
}
