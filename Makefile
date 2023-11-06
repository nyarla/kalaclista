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
	@test ! -d public/dist || rm -rf public/dist
	@mkdir -p public/dist
	@test ! -e cache/images/latest.sha256sum || rm cache/images/latest.sha256sum
	@test ! -e cache/images/data || rm -rf cache/images/data

reset: .check clean
	@test ! -d public/state || rm -rf public/state
	@mkdir -p public/state

build: .check
	@env URL="https://the.kalaclista.com" KALACLISTA_ENV=production $(MAKE) gen

dev: .check
	@env URL="http://nixos:1313" KALACLISTA_ENV=development $(MAKE) gen

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
