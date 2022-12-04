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
	@seq 2006 2022 | xargs -I{} -P$(FULL) perl bin/gen.pl permalinks {}

_gen_index: _gen_assets
	@echo generate index
	@echo -e "posts\nechos\nnotes" | xargs -I{} -P$(FULL) perl bin/gen.pl index {}

_gen_content: \
	_gen_index \
	_gen_pages

_gen_assets_copy:
	@echo copy assets
	@cp -R content/assets/* dist/public

_gen_assets_css:
	@echo generate css
	@test -d resources/assets || mkdir -p resources/assets
	@cp -RH node_modules/normalize.css/normalize.css resources/assets/normalize.css
	@esbuild --bundle --platform=browser --minify resources/assets/stylesheet.css >resources/assets/main.css

_gen_assets_script:
	@echo generate scripts
	@test -d resources/assets || mkdir -p resources/assets
	@esbuild --bundle --platform=browser --minify templates/assets/budoux.js >resources/assets/main.js
	@esbuild --bundle --platform=browser --minify templates/assets/ads.js >resources/assets/ads.js

_gen_assets: \
	_gen_images \
	_gen_assets_copy \
	_gen_assets_css \
	_gen_assets_script

gen: \
	_gen_assets \
	_gen_sitemap_xml \
	_gen_content

clean:
	@test ! -d dist/public || rm -rf dist/public
	@mkdir -p dist/public

build:
	@env URL="https://the.kalaclista.com" $(MAKE) gen -j$(FULL)

dev:
	@env URL="http://nixos:1313" $(MAKE) gen -j$(FULL)

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
