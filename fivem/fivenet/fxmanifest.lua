fx_version 'cerulean'
game 'gta5'

author 'Galexrt and FiveNet contributors'
description 'FiveNet Plugin for FiveM servers.'
version '0.0.1'

lua54 'yes'

ui_page "ui/.output/public/index.html"

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
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
    'server/events/*.lua'
}

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua'
}

client_scripts {
	'client/*.lua'
}

convar_category 'FiveNet' {
	"Configuration Options",
	{
		{ "Tracking - Clear Table on resource start", "$fnet_clear_on_start", "CV_BOOL", "false" },
	}
}
