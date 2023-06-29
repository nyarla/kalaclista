#!/usr/bin/env bash

set -euo pipefail

cd "$(cd "$(dirname "${0}")/.." && pwd)"

export DATADIR=content/data/pictures
export DESTDIR=public/dist/images
export SRCDIR=content/assets/images

export RESIZE_1X=640
export RESIZE_2X=1280

resize() {
  local src="$1" dest="$2" width="$3" size="$4" resize="$5"

  if test $width -le $resize ; then
    local height="$(cwebp -q 100 "$src" -o "${dest}_${size}.webp" 2>&1 | grep Dimension | cut -d ' ' -f4)"
    cat <<...
${size}:
  width: ${width}
  height: ${height}
...
  else
    local height="$(cwebp -resize ${resize} 0 -q 100 "$src" -o "${dest}_${size}.webp" 2>&1 | grep Dimension | cut -d ' ' -f4)"
    cat <<...
${size}:
  width: ${resize}
  height: ${height}
...
  fi
  return 0
}

main() {
  local filename="$1"

  local src="$SRCDIR/$filename" dest="$DESTDIR/${filename%%.*}" data="$DATADIR/${filename%%.*}.yaml"

  local info="$(identify "$src" | head -n1 | cut -d ' ' -f3)"
  local width="${info%%x*}"
  local height="${info##*x}"

  for fn in $dest $data ; do
    test -d "$(dirname "${fn}")" || mkdir -p "$(dirname "${fn}")"
  done

  if [[ $src =~ \.gif$ ]]; then
    cat - << EOS >$data
---
1x:
  width: ${width}
  height: ${height}
2x:
  width: ${width}
  height: ${height}
src:
  width: ${width}
  height: ${height}
EOS

    return 0
  fi

  exec 1>$data

  echo '---'
  resize $src $dest $width 1x $RESIZE_1X
  resize $src $dest $width 2x $RESIZE_2X
  cat - <<...
src:
  width: ${width}
  height: ${height}
...

  return 0
}

main "${@}"
