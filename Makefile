FULL := $(shell nproc --all --ignore 1)
HALF := $(shell echo "$(FULL) / 2" | bc)
CWD  := $(shell pwd)

PAGES := $(shell echo '$(shell date +%Y) - 2006'  | bc)
INDEX := 3

KALACLISTA_ENV := production

ROOTDIR := src
CACHEDIR := cache/$(KALACLISTA_ENV)

ifeq ($(KALACLISTA_ENV),test)
ROOTDIR := t/fixtures
endif

.PHONY: clean build dev test

.check:
	@test -n "$(IN_PERL_SHELL)" || (echo 'you need to enter perl shell by `make shell`' >&2 ; exit 1)

css:
	@echo generate css
	@perl bin/compile-css.pl

css-test:
	@prove bin/compile-css.pl

images: .check
	@echo generate webp
	@openssl dgst -r -sha256 $$(find $(ROOTDIR)/images -type f | grep -v '.git') | sort >$(CACHEDIR)/images/now.sha256sum
	@touch $(CACHEDIR)/images/latest.sha256sum
	@comm -23 $(CACHEDIR)/images/{now,latest}.sha256sum \
		| cut -d ' ' -f2 \
		| sed 's#*src/images/##' \
		| xargs -I{} -P$(FULL) perl bin/compile-webp.pl "{}" 640 1280
	@mv $(CACHEDIR)/images/{now,latest}.sha256sum

images-test: .check
	@prove bin/compile-webp.pl

entries: .check
	@echo generate precompiled entries source
	@test -d cache/entries || mkdir -p cache/entries
	@openssl dgst -r -sha256 $$(find "src/entries/src" -type f | grep -v '.git') | sort >cache/entries/now.sha256sum
	@touch cache/entries/latest.sha256sum
	@comm -23 cache/entries/{now,latest}.sha256sum \
		| cut -d ' ' -f2 \
		| sed 's#*src/entries/src/##' >cache/entries/target
	@node bin/gen-precompile.js cache/entries/target
	@mv cache/entries/{now,latest}.sha256sum
	@rm cache/entries/target

website: .check
	@echo generate website.json
	@cat src/website/src/*.nix | perl -pge 's<\}\n\{><>g' >cache/website/website.nix
	@nix eval --json --file cache/website/website.nix >cache/website/website.json

assets: .check
	@echo copy assets
	@cp -r src/assets/* public/dist/

sitemap_xml: .check
	@echo generate sitemap.xml
	@perl bin/gen.pl sitemap.xml

pages: .check
	@echo generate pages
	@seq 2006 $(shell date +%Y) | xargs -I{} -P$(PAGES) perl bin/gen.pl permalinks {}

index: .check
	@echo generate index
	@echo -e "posts\nechos\nnotes" | xargs -I{} -P$(INDEX) perl bin/gen.pl index {}

home: .check
	@echo generate home
	@perl bin/gen.pl home

parallel: \
	.check \
	css \
	sitemap_xml \
	pages \
	index \
	home

gen: .check
	@$(MAKE) assets
	@$(MAKE) images
	@$(MAKE) entries
	@test -d public/bundle || mkdir -p public/bundle
	@$(MAKE) parallel -j7

clean: .check
	@test ! -d public/$(KALACLISTA_ENV) || rm -rf public/$(KALACLISTA_ENV)
	@mkdir -p public/$(KALACLISTA_ENV)
	@test ! -e cache/$(KALACLISTA_ENV)/images/latest.sha256sum || rm cache/$(KALACLISTA_ENV)/images/latest.sha256sum
	@test ! -e cache/$(KALACLISTA_ENV)/images/data || rm -rf cache/$(KALACLISTA_ENV)/images/data

reset: .check clean
	@test ! -d public/state || rm -rf public/state
	@mkdir -p public/state

build: .check
	@env URL="https://the.kalaclista.com" KALACLISTA_ENV=production $(MAKE) gen

dev: .check
	@env URL="http://nixos:1313" KALACLISTA_ENV=development $(MAKE) gen

test: .check
	prove -j$(FULL) t/*/*.t

ci:
	@env KALACLISTA_ENV=test $(MAKE) clean
	@env KALACLISTA_ENV=test $(MAKE) gen
	@env KALACLISTA_ENV=test $(MAKE) test

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
