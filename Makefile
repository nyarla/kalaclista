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
	@cat $(CACHE)/entries/target \
		| xargs -I{} -P$(FULL) perl bin/compile-markdown.pl "{}"
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
	@seq 2006 $(shell date +%Y) | xargs -I{} -P$(shell echo '$(shell date +%Y) - 2006'  | bc) perl bin/gen.pl permalinks {}

index:
	@echo generate index
	@printf "%s\n%s\n%s\n" posts echos notes | xargs -I{} -P3 perl bin/gen.pl index {}

home:
	@echo generate home
	@perl bin/gen.pl home

gen:
	@$(MAKE) -j4 assets css images entries sitemap_xml
	@$(MAKE) -j3 home index pages

clean:
	@(test ! -d $(DIST) || rm -rf $(DIST)) && mkdir -p $(DIST)
	@test ! -e $(CACHE)/images/latest.sha256sum || rm $(CACHE)/images/latest.sha256sum

cleanup:
	@$(MAKE) KALACLISTA_ENV=development clean
	@$(MAKE) KALACLISTA_ENV=production clean
	@$(MAKE) KALACLISTA_ENV=staging clean
	@$(MAKE) KALACLISTA_ENV=test clean

production:
	@$(MAKE) KALACLISTA_ENV=production gen

development:
	@$(MAKE) KALACLISTA_ENV=development gen

testing:
	@$(MAKE) KALACLISTA_ENV=test gen

test: export KALACLISTA_ENV := production
test:
	@$(MAKE) clean
	@$(MAKE) test-scripts
	@$(MAKE) clean
	@$(MAKE) gen
	@prove -j$(FULL) -r t/

test-scripts:
	prove -j$(FULL) -v bin/compile-*.pl

ci: export KALACLISTA_ENV := test
ci:
	@$(MAKE) clean
	@$(MAKE) test-scripts
	@$(MAKE) clean
	@$(MAKE) gen
	@prove -j$(FULL) -lvr t/lib
	@prove -j$(FULL) -lvr t/common

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
