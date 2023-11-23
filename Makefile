FULL := $(shell nproc --all --ignore 1)
HALF := $(shell echo "$(FULL) / 2" | bc)
CWD  := $(shell pwd)

PAGES := $(shell echo '$(shell date +%Y) - 2006'  | bc)
INDEX := 3

ROOTDIR := src
CACHEDIR := cache/$(KALACLISTA_ENV)

ifeq ($(KALACLISTA_ENV),test)
ROOTDIR := t/fixtures
endif

.PHONY: clean build dev test

.test-in-shell:
	@test -n "$(IN_PERL_SHELL)" || (echo 'you need to enter perl shell by `make shell`' >&2 ; exit 1)

.test-set-stage:
	@test -n "$(KALACLISTA_ENV)" || (echo 'this command needs to set `KALACLISTA_ENV`.' >&2 ; exit 1)

css: .test-in-shell .test-set-stage
	@echo generate css
	@perl bin/compile-css.pl

css-test: .test-in-shell .test-set-stage
	@prove bin/compile-css.pl

images: .test-in-shell .test-set-stage
	@echo generate webp
	@openssl dgst -r -sha256 $$(find $(ROOTDIR)/images -type f | grep -v '.git') | sort >$(CACHEDIR)/images/now.sha256sum
	@touch $(CACHEDIR)/images/latest.sha256sum
	@comm -23 $(CACHEDIR)/images/now.sha256sum $(CACHEDIR)/images/latest.sha256sum \
		| cut -d ' ' -f2 \
		| sed 's#*$(ROOTDIR)/images/##' \
		| xargs -I{} -P$(FULL) perl bin/compile-webp.pl "{}" 640 1280
	@mv $(CACHEDIR)/images/now.sha256sum $(CACHEDIR)/images/latest.sha256sum

images-test: .test-in-shell .test-set-stage
	@prove bin/compile-webp.pl

entries: .test-in-shell .test-set-stage
	@echo generate precompiled entries source
	@test -d $(CACHEDIR)/entries || mkdir -p $(CACHEDIR)/entries
	@openssl dgst -r -sha256 $$(find $(ROOTDIR)/entries/src -type f | grep -v '.git') | sort >$(CACHEDIR)/entries/now.sha256sum
	@touch $(CACHEDIR)/entries/latest.sha256sum
	@comm -23 $(CACHEDIR)/entries/now.sha256sum $(CACHEDIR)/entries/latest.sha256sum \
		| cut -d ' ' -f2 \
		| sed 's#*$(ROOTDIR)/entries/src/##' >$(CACHEDIR)/entries/target
	@pnpm exec node bin/gen-precompile.js $(ROOTDIR) $(CACHEDIR)/entries/target
	@mv $(CACHEDIR)/entries/now.sha256sum $(CACHEDIR)/entries/latest.sha256sum
	@rm $(CACHEDIR)/entries/target

website: .test-in-shell .test-set-stage
	@echo generate website.json
	@perl bin/compile-website-yaml.pl

assets: .test-in-shell .test-set-stage
	@echo copy assets
	@cp -r $(ROOTDIR)/assets/* public/$(KALACLISTA_ENV)/

sitemap_xml: .test-in-shell .test-set-stage
	@echo generate sitemap.xml
	@perl bin/gen.pl sitemap.xml

pages: .test-in-shell .test-set-stage
	@echo generate pages
	@seq 2006 $(shell date +%Y) | xargs -I{} -P$(PAGES) perl bin/gen.pl permalinks {}

index: .test-in-shell .test-set-stage
	@echo generate index
	@echo -e "posts\nechos\nnotes" | xargs -I{} -P$(INDEX) perl bin/gen.pl index {}

home: .test-in-shell .test-set-stage
	@echo generate home
	@perl bin/gen.pl home

gen: .test-in-shell .test-set-stage
	@$(MAKE) images
	@$(MAKE) entries
	@$(MAKE) -j6 assets css website sitemap_xml home index
	@$(MAKE) pages

clean: .test-in-shell .test-set-stage
	@test ! -d public/$(KALACLISTA_ENV) || rm -rf public/$(KALACLISTA_ENV)
	@mkdir -p public/$(KALACLISTA_ENV)
	@test ! -e cache/$(KALACLISTA_ENV)/images/latest.sha256sum || rm cache/$(KALACLISTA_ENV)/images/latest.sha256sum
	@test ! -e cache/$(KALACLISTA_ENV)/images/data || rm -rf cache/$(KALACLISTA_ENV)/images/data

cleanup: .test-in-shell
	@$(MAKE) KALACLISTA_ENV=production clean
	@$(MAKE) KALACLISTA_ENV=staging clean
	@$(MAKE) KALACLISTA_ENV=development clean
	@$(MAKE) KALACLISTA_ENV=test clean

production: .test-in-shell
	@env KALACLISTA_ENV=production $(MAKE) gen

development: .test-in-shell
	@env KALACLISTA_ENV=development $(MAKE) gen

testing:
	@env KALACLISTA_ENV=test $(MAKE) gen

test: .test-in-shell
	@$(MAKE) KALACLISTA_ENV=production clean
	@$(MAKE) KALACLISTA_ENV=production test-scripts
	@$(MAKE) KALACLISTA_ENV=production clean
	@$(MAKE) KALACLISTA_ENV=production gen
	@env KALACLISTA_ENV=production prove -j$(FULL) -r t/

test-scripts: .test-in-shell .test-set-stage
	prove bin/compile-*.pl
	prove bin/gen.pl

ci: .test-in-shell
	@$(MAKE) KALACLISTA_ENV=test clean
	@$(MAKE) KALACLISTA_ENV=test test-scripts
	@$(MAKE) KALACLISTA_ENV=test clean
	@$(MAKE) KALACLISTA_ENV=test gen
	# TODO: wait for improve tests
	#@env KALACLISTA_ENV=test prove -j$(FULL) -r t/

.PHONY: shell serve up

# temporary solution
up: .test-in-shell cleanup production
	pnpm exec wrangler pages deploy public/production

shell:
	@cp /etc/nixos/flake.lock .
	@nix develop
	@pkill proclet || true

cpan: .test-in-shell
	@test ! -d extlib || rm -rf extlib
	@cpm install -L extlib --home=$(HOME)/Applications/Development/cpm --cpanfile app/cpanfile
	@cpm install -L extlib --home=$(HOME)/Applications/Development/cpm --cpanfile cpanfile

serve: .test-in-shell
	proclet start --color

.PHONY: posts echos

posts: .test-in-shell
	@bash bin/new-entry.sh posts

echos: .test-in-shell
	@bash bin/new-entry.sh echos
