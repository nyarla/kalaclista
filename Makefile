URL = https://the.kalaclista.com

FULL := $(shell nproc --all --ignore 1)
HALF := $(shell echo "$(FULL) / 2" | bc)
CWD  := $(shell pwd)
RUN  := perl app/bin/kalaclista.pl -u $(URL) -c $(CWD)/config.pl -a

.PHONY: clean build dev test

_gen_split_content:
	@echo split contnet
	@$(RUN) split-content -t $(FULL)

_gen_clean_exif:
	@echo clean exif
	@find content/assets/images -type f -name '*.jpg' \
		| xargs -I{} -P$(FULL) -n1 jhead -purejpg {}

_gen_resize_images: _gen_clean_exif
	@echo resize images
	@$(RUN) resize-images -t $(FULL)

_gen_sitemap_xml: _gen_split_content
	@echo generate sitemap.xml
	@$(RUN) generate-sitemap-xml -t 1

_gen_archive: _gen_split_content
	@echo generate archive
	@$(RUN) generate-archive -t $(FULL)

_gen_permalink: _gen_split_content _gen_resize_images
	@echo generate permalink
	@$(RUN) generate-permalink -t $(FULL)

_gen_assets: _gen_resize_images
	@echo generate assets
	@$(RUN) generate-assets -t $(FULL)
	@cp -R content/assets/* dist/
	@cp -R templates/static/* dist/assets/

_opti_png:
	@find content/assets -type f -name '*.png' \
		| xargs -I{} -P$(FULL) -n1 optipng {} 2>/dev/null

gen: \
	_gen_split_content \
	_gen_clean_exif \
	_gen_resize_images \
	_gen_sitemap_xml \
	_gen_archive \
	_gen_assets \
	_gen_permalink

optimize: \
	_opti_png

clean:
	@test ! -d dist || rm -rf dist
	@mkdir -p dist

build:
	@$(MAKE) gen URL=https://the.kalaclista.com -j3

dev:
	@$(MAKE) gen URL=http://nixos:1313

test:
	prove -j$(FULL) t/*/*.t

.PHONY: shell serve

shell:
	@cp app/cpanfile.nix cpanfile.nix
	@cp app/flake.lock flake.lock
	@nix develop -c env SHELL=zsh sh -c 'env PERL5LIB=$(shell pwd)/app/lib:$$PERL5LIB zsh'
	@pkill proclet || true

serve:
	proclet start --color	
