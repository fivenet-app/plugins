build: plugin ui

.PHONY: plugin
plugin:
	yarn install
	yarn run build

	# Ensure that .yarn.installed is "newer" than package.json not to trigger
	# FiveM's yarn_builder plugin unnecessarily
	touch -r package.json .yarn.installed
	touch -d "$(date -d '1 minute' +%Y%m%d%H%M.%S)" .yarn.installed

.PHONY: ui
ui:
	cd ui && yarn install
	cd ui && yarn run generate
