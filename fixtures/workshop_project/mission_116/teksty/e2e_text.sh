#!/usr/bin/env bash
# Stand-in android-e2e (replay): повторяет Maestro-флоу mission — для каждого
# имени takeScreenshot из флоу кладёт кадр из e2e-nositeli в Maestro-раскладку
# под kadry_dir. Нет носителя для имени — кадра не будет; неизвестный флоу rc 3.
set -u
flow="${1:?imja floy}"
f="mobile/.maestro/$flow.yaml"
[ -f "$f" ] || exit 3
for tema in dark light; do
  d="mobile/maestro-out-mission/$tema/20261022T120000Z/$flow/takeScreenshot"
  mkdir -p "$d"
  sed -n 's/.*takeScreenshot:[[:space:]]*//p' "$f" | while IFS= read -r name; do
    [ -n "$name" ] || continue
    if [ -f "mobile/e2e-nositeli/$tema/$name.png" ]; then
      cp "mobile/e2e-nositeli/$tema/$name.png" "$d/$name.png"
    fi
  done
done
