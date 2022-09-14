#!/usr/bin/env bash

main() {
  local types=$1;
  local datetime="$(date +%Y-%m-%dT%H:%M:%S)"
  local fn="$(pwd)/content/entries/${types}/$(echo "$datetime" | sed 's![-T]!/!g' | sed 's!:!!g').md"

  local dir="$(dirname "${fn}")"

  test -d "${dir}" || mkdir -p "${dir}"
  cat <<... >${fn}
---
title: ''
type: ${types}
date: ${datetime}+09:00
---

...
}

main $1
