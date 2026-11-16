#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s02 (Н-39: вход symlink-run-refused).
# Дефект: страж символьной ссылки на месте прогона снят — ссылка удаляется как
# «старый прогон». Честная модель на том же входе отказывает и ссылку хранит.
set -u

ROOT_ENV="${CI_ARTIFACTS_ROOT:-/var/lib/ci-artifacts}"
RET_ENV="${CI_ARTIFACTS_RETENTION_DAYS:-14}"
REPOS_ENV="${CI_ARTIFACTS_REPOS:-Complior-mob Complior-back}"

for c in date find rm sort; do
  command -v "$c" >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: нет %s\n' "$c" >&2; exit 2; }
done
case "$RET_ENV" in
  ''|*[!0-9]*) printf 'ОТКАЗ: срок не целое ≥1: %s\n' "$RET_ENV" >&2; exit 1 ;;
esac
[ "$RET_ENV" -ge 1 ] || { printf 'ОТКАЗ: срок не целое ≥1: %s\n' "$RET_ENV" >&2; exit 1; }
REPOS=''
for r in $REPOS_ENV; do
  case "$r" in
    ''|.|..|*/*) printf 'ОТКАЗ: недопустимое имя репо: %s\n' "$r" >&2; exit 1 ;;
  esac
  case "$r" in
    [!A-Za-z0-9]*|*[!A-Za-z0-9._-]*) printf 'ОТКАЗ: недопустимое имя репо: %s\n' "$r" >&2; exit 1 ;;
  esac
  REPOS="$REPOS $r"
done
if [ -L "$ROOT_ENV" ] || [ ! -d "$ROOT_ENV" ]; then
  printf 'ОТКАЗ: корень не каталог: %s\n' "$ROOT_ENV" >&2
  exit 1
fi
cutoff="$(date -u -d "-$RET_ENV days" '+%Y-%m-%d %H:%M:%S')" \
  || { printf 'NOT_IMPLEMENTED: date -d\n' >&2; exit 2; }
refuse=0
for repo in $REPOS; do
  rdir="$ROOT_ENV/$repo"
  if [ -e "$rdir" ] || [ -L "$rdir" ]; then
    if [ -L "$rdir" ] || [ ! -d "$rdir" ]; then
      printf 'ОТКАЗ: репо не каталог: %s\n' "$rdir" >&2
      refuse=1
      continue
    fi
  else
    continue
  fi
  deleted=0
  kept=0
  while IFS= read -r -d '' entry; do
    name="${entry##*/}"
    case "$name" in
      [0-9]*-[0-9]*) ;;
      *)
        printf 'ОТКАЗ: имя прогона вне грамматики <число>-<число>: %s\n' "$entry" >&2
        refuse=1
        continue ;;
    esac
    case "$name" in
      *[!0-9-]*)
        printf 'ОТКАЗ: имя прогона вне грамматики <число>-<число>: %s\n' "$entry" >&2
        refuse=1
        continue ;;
    esac
    case "$name" in
      *-*)
        rest="${name#*-}"
        case "$rest" in
          *-*)
            printf 'ОТКАЗ: имя прогона вне грамматики <число>-<число>: %s\n' "$entry" >&2
            refuse=1
            continue ;;
        esac
        ;;
    esac
    # ДЕФЕКТ: ветка отказа на символьную ссылку снята
    if [ ! -d "$entry" ] && [ ! -L "$entry" ]; then
      printf 'ОТКАЗ: прогон не каталог: %s\n' "$entry" >&2
      refuse=1
      continue
    fi
    if [ -n "$(find "$entry" -newermt "$cutoff" -print -quit 2>/dev/null)" ]; then
      kept=$((kept + 1))
    else
      rm -rf -- "$entry"
      deleted=$((deleted + 1))
      printf 'удалено: %s\n' "$entry"
    fi
  done < <(find "$rdir" -mindepth 1 -maxdepth 1 -print0 | sort -z)
  printf 'ci-artifacts: репо %s: удалено %d, хранится %d\n' "$repo" "$deleted" "$kept"
done
exit "$refuse"
