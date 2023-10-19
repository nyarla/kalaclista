FULL := $(shell nproc --all --ignore 1)
HALF := $(shell echo "$(FULL) / 2" | bc)
CWD  := $(shell pwd)

PAGES := $(shell echo '$(shell date +%Y) - 2006'  | bc)
INDEX := 3

.PHONY: clean build dev test

.check:
	@test -n "$(IN_PERL_SHELL)" || (echo 'you need to enter perl shell by `make shell`' >&2 ; exit 1)

css:
	@echo generate css
	@perl bin/compile-css.pl

images: .check
	@echo generate webp
	@openssl dgst -r -sha256 $$(find "src/images" -type f | grep -v '.git') | sort >cache/images/now.sha256sum
	@touch cache/images/latest.sha256sum
	@comm -23 cache/images/{now,latest}.sha256sum \
		| cut -d ' ' -f2 \
		| sed 's#*src/images/##' \
		| xargs -I{} -P$(FULL) perl bin/compile-webp.pl "{}" 640 1280
	@mv cache/images/{now,latest}.sha256sum

website: .check
	@echo generate website.json
	@cat src/website/src/*.nix | perl -pge 's<\}\n\{><>g' >cache/website/website.nix
	@nix eval --json --file cache/website/website.nix >cache/website/website.json

# generate assets
_gen_assets: .check
	@echo copy assets
	@cp -R content/assets/* public/dist/

_gen_entries: .check
	@echo generate precompiled entries source
	@sha256sum -b $$(find content/entries -type f) | sort >public/state/sha256.entries.new
	@touch public/state/sha256.entries.latest
	@comm -23 public/state/sha256.entries.{new,latest} \
		| cut -d ' ' -f2 \
		| sed 's#*content/entries/##' > public/state/process.entries
	@node bin/gen-precompile.js public/state/process.entries
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
	css \
	_gen_sitemap_xml \
	_gen_pages \
	_gen_index \
	_gen_home

gen: .check
	@$(MAKE) _gen_assets
	@$(MAKE) images
	@$(MAKE) _gen_entries
	@test -d public/bundle || mkdir -p public/bundle
	@$(MAKE) _gen_standalone -j7

clean: .check
	@test ! -d public/dist || rm -rf public/dist
	@mkdir -p public/dist
	@test ! -e cache/images/latest.sha256sum || rm cache/images/latest.sha256sum
	@test ! -e cache/images/data || rm -rf cache/images/data

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
	@cpm install -L extlib --home=$(HOME)/Applications/Development/cpm --cpanfile cpanfile

serve: .check
	proclet start --color

.PHONY: posts echos

posts:
	@bash bin/new-entry.sh posts

echos:
	@bash bin/new-entry.sh echos
