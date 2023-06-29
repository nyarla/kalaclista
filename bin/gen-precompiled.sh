#!/usr/bin/env bash

set -euo pipefail

cd "$(cd "$(dirname "${0}")/.." && pwd)"

export SRCDIR=content/entries
export DISTDIR=content/precompiled

htmlfy() {
  local file="$1"

  sed -z 's/^---\n\([^:]\+:[^\n]\+\?\n\)\+---\n\+//' "$file" \
    | cmark --unsafe --to html \
    | bash node_modules/.bin/budoux -H \
    | perl -npe 's{^<span>|</span>$}{}m' \
    | sed 's!に<wbr>ゃるら!にゃるら!' \
    | sed 's|style="word-break: keep-all; overflow-wrap: break-word;"|style="word-break: keep-all; overflow-wrap: anywhere;"|g'

}

main() {
  local filename="${1}"
  local src="$SRCDIR/$filename" dest="$DISTDIR/$filename"

  test -d "$(dirname "$dest")" || mkdir -p "$(dirname "$dest")"
  echo "${filename}"
  htmlfy $src | bash node_modules/.bin/html-minifier \
    --collapse-whitespace \
    --continue-on-parse-error \
    --keep-closing-slash \
    --minify-css \
    --prevent-attributes-escaping \
    --process-conditional-comments \
    --remove-attribute-quotes \
    --remove-comments \
    --remove-empty-attributes \
    --remove-empty-elements \
    --remove-optional-tags \
    --remove-redundant-attributes \
    --remove-tag-whitespace \
    --sort-attributes \
    --sort-class-name \
  >"$dest"
}

main "${@}"
