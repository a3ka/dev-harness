# Каркас семьи check_precision_gate (контракт 043). Строит МИНИМАЛЬНЫЙ, но
# НАСТОЯЩИЙ git-репозиторий: задача (а) читает frozen/contracts/* теги через
# lib_zones.sh (zones_load), toy-однокоммитное дерево check_check_contract_ready
# здесь НЕ годится (036 §2, тот же вывод: реальная история нужна для zones_load).
#
# Конверсия на протокол шардового раннера verify_antiplacebo.sh (находка Н1,
# контракт 041, тот же приём: барьер вызывается через внедряемую $BARRIER).
set -uo pipefail
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/check_precision_gate.sh"

LAST_OUT=''; LAST_RC=0
run_barrier() {  # <корень> <отн-путь>
  LAST_OUT="$("$BARRIER" "$1" "$2" 2>&1)"; LAST_RC=$?
}

refuse() {  # <имя-входа> <фраза>
  local gate="$1" phrase="$2"
  [ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: %s: rc %s (ожидался 1)\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s\n' "$LAST_OUT" | grep -Fq "$phrase" || { printf 'ОТКАЗ: %s: причина не названа дословно «%s»:\n%s\n' "$gate" "$phrase" "$LAST_OUT" >&2; exit 1; }
  printf '%s: отказ rc 1, причина названа дословно\n' "$gate" >&2
}

accept() {  # <имя-входа>
  local gate="$1"
  [ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: %s: rc %s (ожидался 0)\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s: rc 0\n' "$gate" >&2
}

# mk_toy_repo <каталог> — git-репозиторий с package.json/.github здоровыми
# (verify_ci_parity тривиально паритетен: ноль команд, ноль исключений).
mk_toy_repo() {
  local d="$1"
  mkdir -p "$d/.github/workflows" "$d/scripts" "$d/fixtures" "$d/registry" "$d/roles" "$d/contracts" "$d/config"
  printf '{"name":"toy","scripts":{}}\n' > "$d/package.json"
  : > "$d/config/ci_parity_exceptions.txt"
  git -C "$d" init -q
  git -C "$d" -c user.name=toy -c user.email=toy@dev-harness.local commit -q --allow-empty -m init
}

# mk_foreign_frozen <каталог> <NNN> <автор> <путь> — коммитит и замораживает
# ЧУЖОЙ контракт с ЗОНА <автор>: <путь>, тег frozen/contracts/<NNN>/1.
mk_foreign_frozen() {
  local d="$1" nnn="$2" author="$3" path="$4"
  mkdir -p "$d/contracts" "$(dirname "$d/$path")"
  printf '%s\n' "$path" > "$d/$path"
  cat > "$d/contracts/${nnn}-foreign.md" <<EOF
# Контракт ${nnn} — чужой (toy)

## Predmet
p

## Зоны

ЗОНА ${author}: ${path}
EOF
  git -C "$d" add -A
  git -C "$d" -c user.name=toy -c user.email=toy@dev-harness.local commit -q -m "toy: ${nnn} foreign"
  git -C "$d" -c user.name=toy -c user.email=toy@dev-harness.local \
    tag -a "frozen/contracts/${nnn}/1" -m "toy freeze ${nnn}" >/dev/null
}

# put_draft <файл> <тело>
put_draft() { printf '%s\n' "$2" > "$1"; }

# mk_mint <каталог> <NNN> — тег id/CONTRACT/<NNN> на текущий HEAD (представляет
# «номер минтован, работа ещё не начата»).
mk_mint() { git -C "$1" tag "id/CONTRACT/$2"; }

# mk_family_case <каталог> <key> <case-basename> <тело-скрипта> — кладёт (НЕ
# коммитит — новизна судится против МИНТ-тега, не диска) case-файл фиктивной
# семьи fixtures/check_<key>/.
mk_family_case() {
  local d="$1" key="$2" cf="$3" body="$4"
  mkdir -p "$d/fixtures/check_${key}"
  printf '%s\n' "$body" > "$d/fixtures/check_${key}/${cf}"
  chmod +x "$d/fixtures/check_${key}/${cf}"
}

# mk_dummy_barrier <каталог> <key> — честный барьер-заглушка: rc 0 всегда,
# двухаргументная сигнатура (как настоящие семьи).
mk_dummy_barrier() {
  local d="$1" key="$2"
  mkdir -p "$d/scripts"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$d/scripts/check_${key}.sh"
  chmod +x "$d/scripts/check_${key}.sh"
}
