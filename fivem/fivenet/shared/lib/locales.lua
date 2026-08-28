Locales = Locales or {}

-- Add new locales below using the same key structure as Locales.en.
-- Set the matching locale code in Config.Locale. PRs are welcome for new locales.
Locales.en = {
	tablet = {
		open = 'Open FiveNet Tablet',
		fix = 'Fix FiveNet Tablet problems',
		keybind = 'Open Tablet',
	},
	token = {
		open = 'Open FiveNet account management',
		reset = 'Use token ~g~%{token}~s~ to reset your FiveNet password.',
	},
	status = {
		unavailable = 'The FiveNet sync status request did not return a response.',
	},
}

Locales.de = {
	tablet = {
		open = 'FiveNet Tablet öffnen',
		fix = 'Probleme mit dem FiveNet Tablet lösen',
		keybind = 'Tablet öffnen',
	},
	token = {
		open = 'FiveNet Kontoverwaltung öffnen',
		reset = 'Nutze den Token ~g~%{token}~s~, um dein FiveNet-Passwort zurückzusetzen.',
	},
	status = {
		unavailable = 'Die FiveNet-Synchronisierungsstatusabfrage hat keine Antwort geliefert.',
	},
}
