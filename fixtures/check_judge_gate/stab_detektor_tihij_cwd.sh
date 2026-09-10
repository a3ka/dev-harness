#!/usr/bin/env bash
# НЕ БАРЬЕР: слабая форма детектора контракта 024 — «тихий-cwd-красный»
# (вторая грань блокера 2 вердикта 4d1d265). Отличается от честной формы
# (stab_detektor_chestnyj.sh, правка-круг 2) ровно одной ветвью: жертва
# проверяется честно и имя приманки НЕ печатается, но при cwd ≠ жертве,
# являющемся git-репозиторием с непустым status, сверка МОЛЧА краснеет
# (rc 1 «основной чекаут загрязнён» с именами жертвы либо без имён).
# На воротах 1–7 red_detektor_utechek.sh форма неотличима от честной
# (ворота 7: rc 1, жертва названа, приманка — нет); дефект наблюдаем на
# воротах 8 «cwd-симметрия»: жертва ЧИСТА, cwd-приманка грязна → rc 1
# вместо договорного rc 0 «основной чекаут чист» — грязный cwd краснит
# чистую жертву. Привязка — кодом этой шапки и кодом пробы (Н-39).
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
  printf 'ОТКАЗ: %s: %s\n' "$P_ABS" "$ROOT_ARG" >&2
  exit 1 ;; esac

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
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
      head="$(git -C "$full" rev-parse HEAD 2>/dev/null || printf -- '-')"
      printf '%s:@head:%s\t%s%s\n' "$xy" "$head" "$prefix" "$path"
      emit_manifest "$full" "$prefix$path/"
    elif [ -e "$full" ]; then
      fp="$(sha256sum -- "$full" 2>/dev/null)" && fp="${fp%% *}" || fp='ERR'
      printf '%s:%s\t%s%s\n' "$xy" "$fp" "$prefix" "$path"
    else
      printf '%s:-\t%s%s\n' "$xy" "$prefix" "$path"
    fi
  done < <(git -C "$root" status --porcelain -uall -z --no-renames --ignore-submodules=none 2>/dev/null)
}
manifest() { emit_manifest "$1" "$2" | sort; }

do_snapshot() {
  local m
  m="$(manifest "$CANON" '')" \
    || { printf 'ОТКАЗ: status отказал в %s\n' "$CANON" >&2; exit 1; }
  mkdir -p "$SNAP_DIR" || { printf 'NOT_IMPLEMENTED: %s не создать\n' "$SNAP_DIR" >&2; exit 2; }
  { printf 'root %s\n' "$CANON"; printf '%s\n' "$m"; } > "$SNAP"
}

do_check() {
  local first base cur delta names l p cwd cwd_por
  if [ ! -f "$SNAP" ]; then
    printf 'ОТКАЗ: %s (%s) — снимок ДО спавна пачки обязателен: без него сверка отказывает, а не пропускает (fail-closed)\n' "$P_NET_SNIMKA" "$SNAP" >&2
    exit 1
  fi
  { IFS= read -r first; base="$(cat)"; } < "$SNAP" || true
  if [ "$first" != "root $CANON" ]; then
    printf 'ОТКАЗ: %s: снимок = [%s], сверяется [%s]\n' "$P_CHUZH" "$first" "$CANON" >&2
    exit 1
  fi
  cur="$(manifest "$CANON" '')" \
    || { printf 'ОТКАЗ: status отказал в %s\n' "$CANON" >&2; exit 1; }
  delta="$(printf '%s\n' "$cur" | comm -23 - <(printf '%s\n' "$base" | sort))"
  # ДЕФЕКТ: чужой грязный cwd молча краснит чистую жертву (имён приманки не
  # печатаем — ровно чтобы пройти запрет ворот 7).
  cwd="$(pwd -P)"
  if [ "$cwd" != "$CANON" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    cwd_por="$(git -C "$cwd" status --porcelain)"
    if [ -n "$cwd_por" ]; then
      delta="${delta:+$delta
}cwd-primanka-gryazna"
    fi
  fi
  if [ -n "$delta" ]; then
    names=""
    while IFS= read -r l; do
      [ -n "$l" ] || continue
      case "$l" in *$'\t'*) p="${l#*$'\t'}" ;; *) p="$l" ;; esac
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
