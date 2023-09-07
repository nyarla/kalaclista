FULL := $(shell nproc --all --ignore 1)
HALF := $(shell echo "$(FULL) / 2" | bc)
CWD  := $(shell pwd)

PAGES := $(shell echo '$(shell date +%Y) - 2006'  | bc)
INDEX := 3

.PHONY: clean build dev test

.check:
	@test -n "$(IN_PERL_SHELL)" || (echo 'you need to enter perl shell by `make shell`' >&2 ; exit 1)

# generate assets
_gen_bundle_css: .check
	@echo generate css
	@perl bin/gen.pl main.css
	@cp -RH node_modules/normalize.css/normalize.css src/stylesheets/normalize.css
	@esbuild --bundle --platform=browser --minify src/stylesheets/main.css >public/bundle/main.css
	@cp public/bundle/main.css public/dist/main.css

_gen_assets: .check
	@echo copy assets
	@cp -R content/assets/* public/dist/

_gen_images: .check
	@echo generate images
	@sha256sum -b $$(find content/assets/images -type f) | sort >public/state/sha256.images.new
	@touch public/state/sha256.images.latest
	@comm -23 public/state/sha256.images.{new,latest} \
		| cut -d ' ' -f2 \
		| sed 's#*content/assets/images/##' \
		| xargs -I{} -P$(shell nproc --all --ignore 1) bash bin/gen-image.sh {}
	@mv public/state/sha256.images.{new,latest}
	@find public/dist/images -type f ! -name '*.webp' -exec rm {} \;

_gen_entries: .check
	@echo generate precompiled entries source
	@sha256sum -b $$(find content/entries -type f) | sort >public/state/sha256.entries.new
	@touch public/state/sha256.entries.latest
	@comm -23 public/state/sha256.entries.{new,latest} \
		| cut -d ' ' -f2 \
		| sed 's#*content/entries/##' \
		| xargs -I{} -P$(FULL) bash bin/gen-precompiled.sh {}
	@mv public/state/sha256.entries.{new,latest}

# generate content
_gen_sitemap_xml: .check
	@echo generate sitemap.xml
	@perl bin/gen.pl sitemap.xml

_gen_pages: .check
	@echo generate pages
	@seq 2006 $(shell date +%Y) | xargs -I{} -P$(PAGES) perl bin/gen.pl permalinks {}

_gen_index: .check
	@echo generate index
	@echo -e "posts\nechos\nnotes" | xargs -I{} -P$(INDEX) perl bin/gen.pl index {}

_gen_home: .check
	@echo generate home
	@perl bin/gen.pl home

_gen_standalone: \
	.check \
	_gen_bundle_css \
	_gen_sitemap_xml \
	_gen_pages \
	_gen_index \
	_gen_home

gen: .check
	@$(MAKE) _gen_assets
	@$(MAKE) _gen_images
	@$(MAKE) _gen_entries
	@test -d public/bundle || mkdir -p public/bundle
	@$(MAKE) _gen_standalone -j7

clean: .check
	@test ! -d public/dist || rm -rf public/dist
	@test ! -e public/state/sha256.images.latest || rm public/state/sha256.images.latest
	@mkdir -p public/dist

reset: .check clean
	@test ! -d public/state || rm -rf public/state
	@mkdir -p public/state

build: .check
	@env URL="https://the.kalaclista.com" $(MAKE) gen

dev: .check
	@env URL="http://nixos:1313" $(MAKE) gen

test: .check
	prove -j$(FULL) t/*/*.t

.PHONY: shell serve up

# temporary solution
up: .check clean build
	pnpm exec wrangler pages deploy public/dist

shell:
	@cp /etc/nixos/flake.lock .
	@nix develop
	@pkill proclet || true

cpan: .check
	@test ! -d extlib || rm -rf extlib
	@cpm install -L extlib --home=$(HOME)/Applications/Development/cpm --cpanfile app/cpanfile
	@cpm install -L extlib --home=$(HOME)/Applications/Development/cpm

serve: .check
	proclet start --color

.PHONY: posts echos

posts:
	@bash bin/new-entry.sh posts

echos:
	@bash bin/new-entry.sh echos
