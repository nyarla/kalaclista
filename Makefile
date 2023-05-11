FULL := $(shell nproc --all --ignore 1)
HALF := $(shell echo "$(FULL) / 2" | bc)
CWD  := $(shell pwd)

.PHONY: clean build dev test

# bundle assets
_gen_bundle_css:
	@echo generate css
	@test -d public/bundle || mkdir -p public/bundle
	@perl bin/gen.pl main.css
	@cp -RH node_modules/normalize.css/normalize.css src/stylesheets/normalize.css
	@esbuild --bundle --platform=browser --minify src/stylesheets/main.css >public/bundle/main.css
	@cp public/bundle/main.css public/dist/main.css

_gen_bundle_script:
	@echo generate scripts
	@test -d public/bundle || mkdir -p public/bundle
	@esbuild --bundle --platform=browser --minify src/scripts/budoux.js >public/bundle/main.js
	@esbuild --bundle --platform=browser --minify src/scripts/production.js >public/bundle/production.js
	@cp public/bundle/main.js public/dist/main.js
	@cp public/bundle/production.js public/dist/production.js

bundle: \
	_gen_bundle_css \
	_gen_bundle_script

# static assets
_gen_assets:
	@echo copy assets
	@cp -R content/assets/* public/dist/

_gen_images:
	@echo generate images
	@perl bin/gen.pl images

# generate content
_gen_sitemap_xml:
	@echo generate sitemap.xml
	@perl bin/gen.pl sitemap.xml

_gen_pages: _gen_assets
	@echo generate pages
	@seq 2006 $(shell date +%Y) | xargs -I{} -P$(HALF) perl bin/gen.pl permalinks {}

_gen_index: _gen_assets
	@echo generate index
	@echo -e "posts\nechos\nnotes" | xargs -I{} -P$(HALF) perl bin/gen.pl index {}

_gen_home: _gen_assets
	@echo generate home
	@perl bin/gen.pl home

_gen_content: \
	_gen_sitemap_xml \
	_gen_index \
	_gen_pages \
	_gen_home

gen: \
	_gen_assets \
	_gen_images \
	_gen_content

clean:
	@test ! -d public/dist || rm -rf public/dist
	@mkdir -p public/dist

build:
	@$(MAKE) bundle
	@env URL="https://the.kalaclista.com" $(MAKE) gen -j2

dev:
	@$(MAKE) bundle
	@env URL="http://nixos:1313" $(MAKE) gen -j2

test:
	prove -j$(FULL) t/*/*.t

.PHONY: shell serve up

# temporary solution
up: clean build
	cd public/dist && find . -type f | sort | xargs -I{} -P31 sha256sum '{}' >../state/new.txt
	perl bin/up.pl >public/state/upload.txt
	env AWS_PROFILE=kalaclista S3_ENDPOINT_URL="https://storage.googleapis.com" s5cmd run public/state/upload.txt
	cd public/state && mv new.txt old.txt

shell:
	@cp /etc/nixos/flake.lock .
	@cp app/cpanfile.nix cpanfile.nix
	@nix develop -c env SHELL=zsh sh -c 'env PERL5LIB=$(shell pwd)/app/lib:$(shell pwd)/lib:$$PERL5LIB zsh'
	@pkill proclet || true

serve:
	proclet start --color

.PHONY: posts echos

posts:
	@bash bin/new-entry.sh posts

echos:
	@bash bin/new-entry.sh echos
