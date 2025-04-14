ZIP_PREFIX = fivenet-

.PHONY: build-all
build-all: plugin-fivem

plugin-fivem:
	$(MAKE) -C fivem/fivenet build
	cd fivem && zip -r ../$(ZIP_PREFIX)fivem-plugin.zip ./fivenet -x **/node_modules/**\* **/.nuxt/**\*
