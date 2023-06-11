#!/usr/bin/env bash

set -euo pipefail

cd "$(cd "$(dirname "${0}")/.." && pwd)"

export SRCDIR=content/entries
export DISTDIR=content/precompiled

furigana() {
  local src="$(echo "${1}" | sed 's/[{}]//g')"
  local text="${src%%\|*}" ruby="${src#*\|}" 

  if test $(echo "${ruby}" | tr '|' "\n" | wc -l) = 1 ; then
    echo "<ruby>${text}<rp>（</rp><rt>${ruby}</rt><rp>）</rp></ruby>"
    return 0
  fi

  local rt=($(echo "${ruby}" | tr '|' "\n" | xargs -I{} echo '<rp>（</rp><rt>{}</rt><rp>）</rp>'))
  local rb=($(echo "${text}" | sed 's/\(.\)/\1\n/g' | grep -v '^$'))

  local ruby=

  for idx in $(seq 0 $((${#rb[@]} - 1)) ); do
    ruby="${ruby}${rb[$idx]}${rt[$idx]}"
  done

  echo "<ruby>${ruby}</ruby>"
  return 0
}

htmlfy() {
  local file="$1"

  sed -z 's/^---\n\([^:]\+:[^\n]\+\?\n\)\+---\n\+//' "$file" \
    | cmark --unsafe --to html \
    | perl -lnpe 's%(?<!code>)(\{[^}]+\})%\0$1\0%g' \
    | tr "\0" "\n" \
    | (while read line ; do ([[ $line =~ ^\{[^}]+\}$$ ]] && furigana $line) || echo $line; done) \
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
  htmlfy $src >$dest
}

main "${@}"
