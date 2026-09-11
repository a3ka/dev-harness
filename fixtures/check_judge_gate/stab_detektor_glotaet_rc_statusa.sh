#!/usr/bin/env bash
# НЕ БАРЬЕР: СЛАБАЯ ФОРМА детектора 024 — «глотание rc status» (правка-круг 3,
# вердикт адверсария d67ac4b, блокер 1 / класс S-git-status-1).
# СЛАБОСТЬ: манифест читает `git status` через process substitution
# `done < <(git …)` — rc producer'а глотается: отказ status с пустым stdout
# неотличим от чистого дерева, снимок/сверка проходят пустыми и «чисто».
# Дельта от честной формы (stab_detektor_chestnyj.sh) — ТОЛЬКО механизм
# чтения status: предпроверка утилит, именованные отказы нечитаемого файла и
# недостижимого HEAD сохранены.
# УМИРАЕТ на воротах 15 red_detektor_utechek.sh (свой вход: контрольный git в
# PATH, подкоманда status → rc 1): rc 0 «успеха» вместо именованного rc 2
# «манифест не прочитан». Причина смерти: «S-git-status-1».
set -uo pipefail
export LC_ALL=C
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'
P_NET_SNIMKA='снимок отсутствует'
P_ABS='корень обязан быть абсолютным'
P_CHUZH='снимок чужого корня'

usage() { printf 'ОТКАЗ диспетчер: использование: check_no_leak.sh --snapshot|--check <абс-корень>\n' >&2; exit 1; }
[ "$#" -eq 2 ] || usage
MODE="$1"; ROOT_ARG="$2"
case "$MODE" in --snapshot|--check) ;; *) usage ;; esac
case "$ROOT_ARG" in /*) ;; *)
  printf 'ОТКАЗ: %s: %s (CLI судит абсолютный корень основного чекаута — относительный путь резолвится от случайного cwd, Н-85-класс)\n' "$P_ABS" "$ROOT_ARG" >&2
  exit 1 ;; esac

for util in git sha256sum cut sort comm mkdir cat; do
  command -v "$util" >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: утилита %s отсутствует\n' "$util" >&2; exit 2; }
done

CANON="$(cd "$ROOT_ARG" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: %s не каталог\n' "$ROOT_ARG" >&2; exit 2; }
git -C "$CANON" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$CANON" >&2; exit 2; }

SNAP_DIR="${TMPDIR:-/tmp}/dev-harness-leak/$(printf '%s' "$CANON" | sha256sum | cut -c1-8)"
SNAP="$SNAP_DIR/porcelain"

emit_manifest() {  # <канон-корень> <префикс-путей>
  local root="$1" prefix="$2" entry xy path full fp head
  while IFS= read -r -d '' entry; do
    xy="${entry:0:2}"
    path="${entry:3}"; path="${path%/}"
    full="$root/$path"
    if [ -d "$full" ] && [ -e "$full/.git" ]; then
      head="$(git -C "$full" rev-parse HEAD 2>/dev/null)" || {
        printf 'NOT_IMPLEMENTED: HEAD недостижим в %s\n' "$full" >&2
        return 2
      }
      printf '%s:@head:%s\t%s%s\n' "$xy" "$head" "$prefix" "$path"
      emit_manifest "$full" "$prefix$path/" || return 2
    elif [ -e "$full" ]; then
      fp="$(sha256sum -- "$full" 2>/dev/null)" || {
        printf 'NOT_IMPLEMENTED: не смог прочитать %s\n' "$full" >&2
        return 2
      }
      fp="${fp%% *}"
      printf '%s:%s\t%s%s\n' "$xy" "$fp" "$prefix" "$path"
    else
      printf '%s:-\t%s%s\n' "$xy" "$prefix" "$path"
    fi
  done < <(git -C "$root" status --porcelain -uall -z --no-renames --ignore-submodules=none 2>/dev/null)
}
manifest() { emit_manifest "$1" "$2" | sort; }

do_snapshot() {
  local m manifest_rc
  m="$(manifest "$CANON" '')"
  manifest_rc=$?
  if [ "$manifest_rc" -eq 2 ]; then
    exit 2
  fi
  [ "$manifest_rc" -eq 0 ] \
    || { printf 'ОТКАЗ: status отказал в %s (rc=%d)\n' "$CANON" "$manifest_rc" >&2; exit 1; }
  mkdir -p "$SNAP_DIR" || { printf 'NOT_IMPLEMENTED: %s не создать\n' "$SNAP_DIR" >&2; exit 2; }
  { printf 'root %s\n' "$CANON"; printf '%s\n' "$m"; } > "$SNAP"
}

do_check() {
  local first base cur delta names l p manifest_rc read_rc
  if [ ! -f "$SNAP" ]; then
    printf 'ОТКАЗ: %s (%s) — снимок ДО спавна пачки обязателен: без него сверка отказывает, а не пропускает (fail-closed)\n' \
      "$P_NET_SNIMKA" "$SNAP" >&2
    exit 1
  fi
  { IFS= read -r first; base="$(cat)"; } < "$SNAP"; read_rc=$?
  if [ "$read_rc" -ne 0 ] && [ -z "$base" ]; then
    printf 'ОТКАЗ: снимок не прочитан: %s\n' "$SNAP" >&2
    exit 1
  fi
  if [ "$first" != "root $CANON" ]; then
    printf 'ОТКАЗ: %s: снимок = [%s], сверяется [%s] — hash8-коллизия либо чужой файл; переснимите свою пачку\n' \
      "$P_CHUZH" "$first" "$CANON" >&2
    exit 1
  fi
  cur="$(manifest "$CANON" '')"
  manifest_rc=$?
  if [ "$manifest_rc" -eq 2 ]; then
    exit 2
  fi
  [ "$manifest_rc" -eq 0 ] \
    || { printf 'ОТКАЗ: status отказал в %s (rc=%d)\n' "$CANON" "$manifest_rc" >&2; exit 1; }
  delta="$(printf '%s\n' "$cur" | comm -23 - <(printf '%s\n' "$base" | sort))"
  if [ -n "$delta" ]; then
    names=""
    while IFS= read -r l; do
      [ -n "$l" ] || continue
      p="${l#*$'\t'}"
      if [ -z "$names" ]; then names="$p"; else names="$names, $p"; fi
    done <<< "$delta"
    printf 'ОТКАЗ: %s: %s\n' "$P_ZAGR" "$names" >&2
    exit 1
  fi
  printf '%s\n' "$P_CHISTO"
}

case "$MODE" in
  --snapshot) do_snapshot ;;
  --check)    do_check ;;
esac
exit 0
