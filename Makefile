FULL := $(shell nproc --all --ignore 1)
HALF := $(shell echo "$(FULL) / 2" | bc)
CWD  := $(shell pwd)

PAGES := $(shell echo '$(shell date +%Y) - 2006'  | bc)
INDEX := 3

.PHONY: clean build dev test

# generate assets
_gen_bundle_css:
	@echo generate css
	@perl bin/gen.pl main.css
	@cp -RH node_modules/normalize.css/normalize.css src/stylesheets/normalize.css
	@esbuild --bundle --platform=browser --minify src/stylesheets/main.css >public/bundle/main.css
	@cp public/bundle/main.css public/dist/main.css

_gen_assets:
	@echo copy assets
	@cp -R content/assets/* public/dist/

_gen_images:
	@echo generate images
	@sha256sum -b $$(find content/assets/images -type f) | sort >public/state/sha256.images.new
	@touch public/state/sha256.images.latest
	@comm -23 public/state/sha256.images.{new,latest} \
		| cut -d ' ' -f2 \
		| sed 's#*content/assets/images/##' \
		| xargs -I{} -P$(shell nproc --all --ignore 1) bash bin/gen-image.sh {}
	@mv public/state/sha256.images.{new,latest}
	@find public/dist/images -type f ! -name '*.webp' -exec rm {} \;

_gen_entries:
	@echo generate precompiled entries source
	@sha256sum -b $$(find content/entries -type f) | sort >public/state/sha256.entries.new
	@touch public/state/sha256.entries.latest
	@comm -23 public/state/sha256.entries.{new,latest} \
		| cut -d ' ' -f2 \
		| sed 's#*content/entries/##' \
		| xargs -I{} -P$(FULL) bash bin/gen-precompiled.sh {}
	@mv public/state/sha256.entries.{new,latest}

# generate content
_gen_sitemap_xml:
	@echo generate sitemap.xml
	@perl bin/gen.pl sitemap.xml

_gen_pages:
	@echo generate pages
	@seq 2006 $(shell date +%Y) | xargs -I{} -P$(PAGES) perl bin/gen.pl permalinks {}

_gen_index:
	@echo generate index
	@echo -e "posts\nechos\nnotes" | xargs -I{} -P$(INDEX) perl bin/gen.pl index {}

_gen_home:
	@echo generate home
	@perl bin/gen.pl home

_gen_standalone: \
	_gen_bundle_css \
	_gen_sitemap_xml \
	_gen_pages \
	_gen_index \
	_gen_home

gen:
	@$(MAKE) _gen_assets
	@$(MAKE) _gen_images
	@$(MAKE) _gen_entries
	@test -d public/bundle || mkdir -p public/bundle
	@$(MAKE) _gen_standalone -j7

clean:
	@test ! -d public/dist || rm -rf public/dist
	@test ! -e public/state/sha256.images.latest || rm public/state/sha256.images.latest
	@mkdir -p public/dist

reset: clean
	@test ! -d public/state || rm -rf public/state
	@mkdir -p public/state

build:
	@env URL="https://the.kalaclista.com" $(MAKE) gen

dev:
	@env URL="http://nixos:1313" $(MAKE) gen

test:
	prove -j$(FULL) t/*/*.t

.PHONY: shell serve up

# temporary solution
up: clean build
	pnpm exec wrangler pages deploy public/dist

shell:
	@cp /etc/nixos/flake.lock .
	@nix develop
	@pkill proclet || true

cpan:
	@test ! -d extlib || rm -rf extlib
	@cpm install -L extlib --home=$(HOME)/Applications/Development/cpm

serve:
	proclet start --color

.PHONY: posts echos

posts:
	@bash bin/new-entry.sh posts

echos:
	@bash bin/new-entry.sh echos
