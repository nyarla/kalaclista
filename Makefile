URL = https://the.kalaclista.com
CWD = $(shell pwd)
JOBS = $(shell cat /proc/cpuinfo | grep processor | tail -n1 | cut -d\  -f2)

.PHONY: clean build dev test

_build_split_files:
	@perl -Iapp/lib app/bin/kalaclista.pl -u $(URL) -a split-content -c $(CWD)/config.pl -t $(JOBS)

_build_sitemap_xml:
	@perl -Iapp/lib app/bin/kalaclista.pl -u $(URL) -a generate-sitemap-xml -c $(CWD)/config.pl -t $(JOBS)

build: \
	_build_split_files \
	_build_sitemap_xml

clean:
	test ! -d dist || rm -rf dist
	mkdir -p dist
	
release:
	@$(MAKE) URL=https://the.kalaclista.com build

dev:
	@$(MAKE) URL=http://nixos:1313 build

test: clean release
	prove -Iapp/lib t/*.t


.PHONY: shell

shell:
	@cp app/cpanfile.nix cpanfile.nix
	@nix develop -c env SHELL=zsh sh -c 'env PERL5LIB=$(shell pwd)/app/lib:$$PERL5LIB zsh'
