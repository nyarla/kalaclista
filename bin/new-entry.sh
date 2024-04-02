#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${0}")/.."
entries="$(pwd)/src/entries/src"
export entries

main() {
  kind="${1:-posts}"

  now="$(date +%H:%M:%S)"
  day="$(date +%Y-%m-%d)"

  created_at="${day}T${now}+09:00"

  if [[ "${kind}" == "notes" ]]; then
    echo -e "Title: "
    read -r title
    fullpath="${entries}/${kind}/${title}.md"
    export fullpath
  else
    fullpath="${entries}/${kind}/${day//-/\/}/${now//:/}.md"
    export fullpath
  fi

  mkdir -p "$(dirname "${fullpath}")"
  cat <<... >"${fullpath}"
---
title: ""
summary: ""
type: ${kind}
date: "${created_at}"
lastmod: "${created_at}"
kind:
  - 
---

...

  echo "${fullpath}"
  nvim-run "${fullpath}"
}

main "$@"
