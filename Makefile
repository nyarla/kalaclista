URL = https://the.kalaclista.com

FULL := $(shell nproc --all --ignore 1)
HALF := $(shell echo "$(FULL) / 2" | bc)
CWD  := $(shell pwd)
RUN  := perl app/bin/kalaclista.pl -u $(URL) -c $(CWD)/config.pl -a

.PHONY: clean build dev test

_gen_images:
	@echo generate images
	@perl bin/gen.pl images

_gen_sitemap_xml:
	@echo generate sitemap.xml
	@perl bin/gen.pl sitemap.xml

_gen_pages: _gen_assets
	@echo generate pages
	@$(RUN) generate -t $(FULL)

_gen_index: _gen_assets
	@echo generate index
	@$(RUN) generate-index -t $(FULL)

_gen_entries: _gen_assets
	@echo generate entries
	@$(RUN) generate-entries -t $(FULL)

_gen_assets_by_app:
	@$(RUN) generate-assets -t $(FULL)

_gen_assets_copy:
	@echo copy assets
	@cp -R content/assets/* dist/public

_gen_assets_css: _gen_assets_by_app
	@echo generate css
	@test -d resources/assets || mkdir -p resources/assets
	@cp -RH node_modules/normalize.css/normalize.css resources/assets/normalize.css
	@esbuild --bundle --platform=browser --minify resources/assets/stylesheet.css >resources/assets/main.css

_gen_assets_script:
	@echo generate scripts
	@test -d resources/assets || mkdir -p resources/assets
	@esbuild --bundle --platform=browser --minify templates/assets/budoux.js >resources/assets/main.js
	@esbuild --bundle --platform=browser --minify templates/assets/ads.js >resources/assets/ads.js

_opti_png:
	@find content/assets -type f -name '*.png' \
		| xargs -I{} -P$(FULL) -n1 optipng {} 2>/dev/null

_gen_assets: \
	_gen_clean_exif \
	_gen_resize_images \
	_gen_assets_copy \
	_gen_assets_css \
	_gen_assets_script

gen: \
	_gen_assets \
	_gen_sitemap_xml \
	_gen_index \
	_gen_entries

optimize: \
	_opti_png

clean:
	@test ! -d dist/public || rm -rf dist/public
	@mkdir -p dist/public

build:
	@$(MAKE) gen URL=https://the.kalaclista.com -j$(FULL)

dev:
	@$(MAKE) gen URL=http://nixos:1313 -j$(FULL)

test:
	prove -j$(FULL) t/*/*.t

.PHONY: shell serve up

# temporary solution
up: clean build
	@dist/bin/push

shell:
	@cp app/cpanfile.nix cpanfile.nix
	@cp app/flake.lock flake.lock
	@nix develop -c env SHELL=zsh sh -c 'env PERL5LIB=$(shell pwd)/app/lib:$(shell pwd)/lib:$$PERL5LIB zsh'
	@pkill proclet || true

serve:
	proclet start --color

.PHONY: posts echos

posts:
	@bash bin/new-entry.sh posts

echos:
	@bash bin/new-entry.sh echos
