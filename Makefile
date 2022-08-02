URL = https://the.kalaclista.com

JOBS := $(shell nproc --all --ignore 1)
CWD  := $(shell pwd)
RUN  := perl app/bin/kalaclista.pl -u $(URL) -c $(CWD)/config.pl -t $(JOBS) -a

.PHONY: clean build dev test

_gen_split_content: clean
	@echo split-contnet
	@$(RUN) split-content

_gen_resize_images: clean
	@echo resize-images
	@$(RUN) resize-images

_gen_sitemap_xml: _gen_split_content
	@echo generate-sitemap-xml
	@$(RUN) generate-sitemap-xml

_gen_archive: _gen_split_content
	@echo generate-archive
	@$(RUN) generate-archive

_gen_permalink: _gen_split_content
	@echo generate-permalink
	@$(RUN) generate-permalink

_gen_assets: _gen_resize_images
	@echo generate-assets
	@$(RUN) generate-assets
	@cp -R content/assets/* dist/
	@cp -R templates/static/* dist/assets/

generate: \
	_gen_sitemap_xml \
	_gen_archive \
	_gen_assets \
	_gen_permalink

clean:
	@test ! -d dist || rm -rf dist
	@mkdir -p dist

build: clean
	@$(MAKE) URL=https://the.kalaclista.com generate

dev: clean
	@$(MAKE) URL=http://nixos:1313 generate

test:
	prove -j$(JOBS) t/*/*.t

.PHONY: shell serve

shell:
	@cp app/cpanfile.nix cpanfile.nix
	@cp app/flake.lock flake.lock
	@nix develop -c env SHELL=zsh sh -c 'env PERL5LIB=$(shell pwd)/app/lib:$$PERL5LIB zsh'
	@pkill proclet || true

serve:
	proclet start --color	
