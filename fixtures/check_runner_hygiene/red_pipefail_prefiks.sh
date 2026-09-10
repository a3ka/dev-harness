#!/usr/bin/env bash
# КРАСНОЕ 025-И-2 (пачка B-1): settings pipefail-префикс в .omp/config.yml.
# ЕДИНЫЙ ИСТОЧНИК строки префикса — контракт 025 §Пачка B-1; config несёт её
# побайтово. СЕГОДНЯ: секции нет → именованный отказ rc 1. ПОСЛЕ: rc 0.
# Грамматика проверки: ключ prefix: в bash-секции несёт ОДНОВРЕМЕННО маркеры
# pipefail, 141 и EXIT (Г4-кавер обязана жить в самой строке префикса).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
CFG="$ROOT/.omp/config.yml"
[ -f "$CFG" ] || { printf 'КРАСНОЕ 025-И-2: %s отсутствует\n' "$CFG" >&2; exit 1; }
line="$(grep -n 'prefix:' "$CFG" | head -1)"
if [ -z "$line" ]; then
  printf 'КРАСНОЕ 025-И-2: настройки не несут pipefail-префикс — ключ prefix: отсутствует в %s; форма Н-84 (rc хвоста пайпа) жива во всех сессиях\n' "$CFG" >&2
  exit 1
fi
val="${line#*prefix:}"
for marker in pipefail 141 EXIT; do
  case "$val" in *$marker*) ;; *)
    printf 'КРАСНОЕ 025-И-2: префикс без маркера %s (Г4-кавер обязана жить в строке префикса): %s\n' "$marker" "$val" >&2
    exit 1 ;;
  esac
done
exit 0
