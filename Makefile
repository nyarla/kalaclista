URL = https://the.kalaclista.com
CWD = $(shell pwd)
JOBS = $(shell cat /proc/cpuinfo | grep processor | tail -n1 | cut -d\  -f2)

.PHONY: clean build dev test

_gen:
	@echo action: $(ACTION)
	@perl app/bin/kalaclista.pl -u $(URL) -a $(ACTION) -c $(CWD)/config.pl -t $(JOBS)

_gen_split_content: clean
	@$(MAKE) ACTION=split-content _gen

_gen_resize_images: clean
	@$(MAKE) ACTION=resize-images _gen

_gen_sitemap_xml: _gen_split_content
	@$(MAKE) ACTION=generate-sitemap-xml _gen

_gen_archive: _gen_split_content
	@$(MAKE) ACTION=generate-archive _gen

_gen_permalink: _gen_split_content
	@$(MAKE) ACTION=generate-permalink _gen

_gen_assets: _gen_resize_images
	@$(MAKE) ACTION=generate-assets _gen
	@cp -R content/assets/* dist/
	@cp -R templates/static/* dist/assets/

generate: \
	_gen_sitemap_xml \
	_gen_archive \
	_gen_assets \
	_gen_permalink

clean:
	test ! -d dist || rm -rf dist
	mkdir -p dist

build: clean
	@$(MAKE) URL=https://the.kalaclista.com generate -j$(JOBS)

dev: clean
	@$(MAKE) URL=http://nixos:1313 generate -j$(JOBS)

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
