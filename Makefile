# Check to running environment
# ============================
ifeq (,$(findstring $(MAKECMDGOALS),shell))

# inside perl-shell?
# ------------------
ifndef IN_PERL_SHELL
$(error This command should running on perl-shell. You could enter to perl-shell by `make shell`)
endif

# KALACLISTA_ENV exists?
# ----------------------
ifeq (,$(findstring $(MAKECMDGOALS),"\
	production development testing cleanup \
	test test-scripts ci \
	up serve cpan \
	post echos notes \
"))

### KALACLISTA_ENV is defined?
ifndef KALACLISTA_ENV
$(error KALACLISTA_ENV is not defined. This variable required to them)
endif

### KALACLISTA_ENV is one of them?
ifeq (,$(findstring $(KALACLISTA_ENV),"production development staging test"))
$(error KALACLISTA_ENV should be ones of them: 'production', 'development', 'staging', 'test')
endif

endif ## END

endif # END

# CONSTANTS VARIABLES
# ===================
FULL := $(shell nproc --all --ignore 1)
HALF := $(shell echo "$(FULL) / 2" | bc)

PAGES := $(shell echo '$(shell date +%Y) - 2006'  | bc)
INDEX := 3

# files and directories
# ---------------------
ROOT  := $(shell pwd)
SRC   := $(ROOT)/src
CACHE := $(ROOT)/cache/$(KALACLISTA_ENV)
DIST  := $(ROOT)/public/$(KALACLISTA_ENV)

ifeq ($(KALACLISTA_ENV),test)
SRC   := $(ROOT)/t/fixtures
endif

# TASKS
# =====
.PHONY: clean build dev test
css:
	@echo generate css
	@pnpm exec tailwindcss -i $(ROOT)/deps/css/main.css -o $(CACHE)/css/main.css --minify
	@cp $(CACHE)/css/main.css $(DIST)/main-$$(openssl dgst -r -sha256 $(CACHE)/css/main.css | cut -c 1-7).css

images:
	@echo generate webp
	@test -d $(CACHE)/images || mkdir -p $(CACHE)/images
	@openssl dgst -r -sha256 $$(find $(SRC)/images -type f | grep -v '.git') | sort >$(CACHE)/images/now.sha256sum
	@touch $(CACHE)/images/latest.sha256sum
	@comm -23 $(CACHE)/images/now.sha256sum $(CACHE)/images/latest.sha256sum \
		| cut -d ' ' -f2 \
		| sed 's#*$(SRC)/images/##' \
		| xargs -I{} -P$(FULL) perl bin/compile-webp.pl "{}" 640 1280
	@mv $(CACHE)/images/now.sha256sum $(CACHE)/images/latest.sha256sum

entries:
	@echo generate precompiled entries source
	@test -d $(CACHE)/entries || mkdir -p $(CACHE)/entries
	@openssl dgst -r -sha256 $$(find $(SRC)/entries/src -type f | grep -v '.git') | sort >$(CACHE)/entries/now.sha256sum
	@touch $(CACHE)/entries/latest.sha256sum
	@comm -23 $(CACHE)/entries/now.sha256sum $(CACHE)/entries/latest.sha256sum \
		| cut -d ' ' -f2 \
		| sed 's#*$(SRC)/entries/src/##' >$(CACHE)/entries/target
	@pnpm exec node bin/gen-precompile.js $(SRC) $(CACHE)/entries/target
	@comm -23 $(CACHE)/entries/now.sha256sum $(CACHE)/entries/latest.sha256sum \
		| cut -d ' ' -f2 \
		| sed 's#*$(SRC)/entries/src/##' \
		| xargs -I{} -P$(FULL) perl bin/compile-syntax-highlight.pl "{}"
	@mv $(CACHE)/entries/now.sha256sum $(CACHE)/entries/latest.sha256sum
	@rm $(CACHE)/entries/target

assets:
	@echo copy assets
	@cp -r $(SRC)/assets/* $(DIST)/

sitemap_xml:
	@echo generate sitemap.xml
	@perl bin/gen.pl sitemap.xml

pages:
	@echo generate pages
	@seq 2006 $(shell date +%Y) | xargs -I{} -P$(PAGES) perl bin/gen.pl permalinks {}

index:
	@echo generate index
	@printf "%s\n%s\n%s\n" posts echos notes | xargs -I{} -P$(INDEX) perl bin/gen.pl index {}

home:
	@echo generate home
	@perl bin/gen.pl home

gen: css
	@$(MAKE) images
	@$(MAKE) entries
	@$(MAKE) -j6 assets sitemap_xml home index
	@$(MAKE) pages

clean:
	@(test ! -d $(DIST) || rm -rf $(DIST)) && mkdir -p $(DIST)
	@test ! -e $(CACHE)/images/latest.sha256sum || rm $(CACHE)/images/latest.sha256sum

cleanup:
	@env KALACLISTA_ENV=production $(MAKE) clean
	@env KALACLISTA_ENV=staging $(MAKE) clean
	@env KALACLISTA_ENV=development $(MAKE) clean
	@env KALACLISTA_ENV=test $(MAKE) clean

production:
	@env KALACLISTA_ENV=production $(MAKE) gen

development:
	@env KALACLISTA_ENV=development $(MAKE) gen

testing:
	@env KALACLISTA_ENV=test $(MAKE) gen

test:
	@env KALACLISTA_ENV=production $(MAKE) clean
	@env KALACLISTA_ENV=production $(MAKE) test-scripts
	@env KALACLISTA_ENV=production $(MAKE) clean
	@env KALACLISTA_ENV=production $(MAKE) gen
	@env KALACLISTA_ENV=production prove -j$(FULL) -r t/

test-scripts:
	prove -v bin/compile-*.pl

ci:
	@env KALACLISTA_ENV=test $(MAKE) clean
	@env KALACLISTA_ENV=test $(MAKE) test-scripts
	@env KALACLISTA_ENV=test $(MAKE) clean
	@env KALACLISTA_ENV=test $(MAKE) gen
	@env KALACLISTA_ENV=test prove -j$(FULL) -lvr t/lib
	@env KALACLISTA_ENV=test prove -j$(FULL) -lvr t/common

.PHONY: shell serve up

# temporary solution
up: cleanup production
	pnpm exec wrangler pages deploy public/production

shell:
	@cp /etc/nixos/flake.lock .
	@nix develop
	@pkill proclet || true

cpan:
	@test ! -d extlib || rm -rf extlib
	@cpm install -L extlib --home=$(HOME)/Applications/Development/cpm --cpanfile app/cpanfile
	@cpm install -L extlib --home=$(HOME)/Applications/Development/cpm --cpanfile cpanfile

serve:
	proclet start --color

.PHONY: posts echos

posts:
	@bash bin/new-entry.sh posts

echos:
	@bash bin/new-entry.sh echos

notes:
	@bash bin/new-entry.sh notes
