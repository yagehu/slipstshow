build_dir ?= build

ifndef XDG_DATA_HOME
  XDG_DATA_HOME := ${HOME}/.local/share
endif

prefix ?= ${XDG_DATA_HOME}/typst/packages/preview/slipstshow/0.1.0

root = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
typst_srcs := \
  lib.typ \
  slipstshow.typ
typst_targets := $(patsubst %,$(build_dir)/%,$(typst_srcs))

targets := \
  $(build_dir)/slipstshow.js \
  $(build_dir)/slipstshow.css \
  $(build_dir)/typst.toml \
  $(build_dir)/LICENSE \
  $(build_dir)/README.md \
  $(typst_targets)

.PHONY: build
build: $(targets)

.PHONY: install
install: $(targets)
	for file in $(targets); do \
	  target="$(prefix)$$(sed 's/^$(build_dir)//' <<< $${file})"; \
	  echo $${target}; \
	  install -D $${file} $${target}; \
	done

$(build_dir)/slipstshow.js: lib.ts
	npx esbuild $^ \
	  --bundle \
	  --minify \
	  --outfile=$@

$(build_dir)/slipstshow.css: slipstshow.css
	npx esbuild $^ --bundle --minify --outfile=$@

$(build_dir)/typst.toml: typst.toml
	cp $^ $@

$(build_dir)/LICENSE: LICENSE
	cp $^ $@

$(build_dir)/README.md: README.md
	cp $^ $@

$(build_dir)/%.typ: %.typ
	cp $^ $@
