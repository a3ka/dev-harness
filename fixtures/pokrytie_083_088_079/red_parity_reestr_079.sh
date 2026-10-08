#!/usr/bin/env bash
# Семья 079, часть Р2: verify_ci_parity 083 — площадь покрытия, пере-выраженная
# через реестр (И-3), и сумма-инвариант шардов НА СГЕНЕРИРОВАННОМ БЛОКЕ (И-5).
# Дыра покрытия (аудит 079): ни одна существующая клетка не вызывает
# verify_ci_parity.sh; семейство fixtures/verify_ci_parity/ судит только
# ДОреестровую форму (case_* про цепочки команд/шарды-legacy). Мутант «parity
# молча зелен при реестре» / «шарды по реестровым строкам, не по блоку»
# проходит всё существующее.
#
# Модель тою-мира — по ЖИВОЙ форме ключей (grep-проверено в verify_ci_parity.sh):
# шард-ключ = BASENAME .sh-цели значения npm-скрипта (SCRIPT_BY_BASENAME:
# значение «bash fixtures/shard_a.sh» → ключ «shard_a» покрывает npm
# «check:shard-a»), и каждый шард-ключ обязан иметь каталог
# fixtures/<ключ>/case_*.sh (мёртвый ключ). Скрипт check:shard-b существует
# ТОЛЬКО в мирах Р2-шарды/Р2-реестр/диф — в конформных мирах его нет вовсе
# (иначе он сам — непокрытый ключ).
#
# Использование: bash red_parity_reestr_079.sh <корень> [Р2-реестр Р2-реестр/диф
#   Р2-область Р2-исключение Р2-шарды] [--parity <файл>] [--normalizator <файл>]
#   --parity       — подменить verify_ci_parity.sh тою-мира (стаб-пак);
#   --normalizator — подменить НОРМАЛИЗАТОР блока шардов перед судом (стаб д5:
#                    мутант, судящий реестровые shard-строки: переписывает блок
#                    под реестр ДО честного parity — моделирует дефектный оракул).
# Коды: 0 — все судимые клетки зелёные; 1 — есть красная; 2 — нечем проверить.
#
# Клетки (вход → ожидание):
#   Р2-реестр     конформный мир: npm check:alpha покрыт ТОЛЬКО потреблением
#                 реестром (step a1 → npm run check:alpha; в блоке шардов
#                 alpha НЕ названа), шард-ключ shard_a — в блоке → rc 0.
#   Р2-реестр/диф реестр без step-npm: alpha покрыта БЛОКОМ (keys: alpha
#                 shard_a shard_b) → rc 0 у честного И у ДОреестровой формы
#                 (диффпроба д3: различимость Р2-реестр — реестровым
#                 потреблением, не формой шарда).
#   Р2-область    + npm check:orphan (есть цель-файл), НЕ в реестре/CI/
#                 исключениях → rc 1, FAIL именует orphan (правило 6: приёмка
#                 не богаче CI молча).
#   Р2-исключение тот же мир + живая запись-причина в
#                 config/ci_parity_exceptions.txt → rc 0.
#   Р2-шарды      registry shard-строка ap1 несёт shard_b, блок — shard_a (у
#                 обоих каталоги с case-файлом): rc 1, FAIL именует shard_b
#                 (сумма судит СГЕНЕРИРОВАННЫЙ блок: реестровая shard-строка
#                 покрытием не служит).
#
# PAK (стаб → клетка; дефект):
#   д3 → Р2-реестр    parity игнорирует реестр (ДОреестровая форма): на
#                     конформном мире красен, именуя check:alpha; диффпроба —
#                     Р2-реестр/диф (покрытие блоком) rc 0, как честный.
#   д4 → Р2-область   parity при наличии реестра молча зелен (auto-cover-all):
#                     на Р2-область rc 0 (честный rc 1); диффпроба — на
#                     Р2-реестр rc 0, как честный.
#   д5 → Р2-шарды     parity судит реестровые shard-строки (нормализатор
#                     переписывает блок под реестр): на Р2-шарды FAIL именует
#                     shard_a (не shard_b); диффпроба — на Р2-реестр (блок уже
#                     равен реестру) rc 0, как честный.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
shift || true
PARITY=""; NORM=""
kletki=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --parity) PARITY="$2"; shift 2 ;;
    --normalizator) NORM="$2"; shift 2 ;;
    *) kletki+=("$1"); shift ;;
  esac
done
SRCPAR="$ROOT/scripts/verify_ci_parity.sh"
[ -f "$SRCPAR" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$SRCPAR" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }

KRASNYH=0; ZELENYH=0
zeleno() { printf 'ЗЕЛЕНО: %s\n' "$1"; ZELENYH=$((ZELENYH+1)); }
krasno() { printf 'КРАСНО: %s\n' "$1"; KRASNYH=$((KRASNYH+1)); }
nado() { [ "${#kletki[@]}" -eq 0 ] || case " ${kletki[*]} " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
SCR="$(mktemp -d "${TMPDIR:-/tmp}/pokrytie079-par.XXXXXX")" || exit 2
trap 'rm -rf -- "$SCR"' EXIT

# ── тою-мир parity ────────────────────────────────────────────────────────────
# mir <dir> <orphan:0|1|2> <blok-shard-keys> <reestr-shard-keys>
# Скрипт check:shard-b и каталог fixtures/shard_b/ добавляются, только если
# shard_b назван реестром ИЛИ блоком (миры Р2-шарды и диф).
mir() {
  local d="$1" orphan="$2" blok="$3" reestr="$4"
  local est_b=0
  case "$reestr$blok" in *shard_b*) est_b=1 ;; esac
  rm -rf -- "$d"
  mkdir -p "$d/registry" "$d/.github/workflows" "$d/config" "$d/scripts" \
           "$d/fixtures/shard_a" "$d/fixtures/alpha"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$d/fixtures/alpha.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$d/fixtures/shard_a.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$d/fixtures/shard_b.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$d/fixtures/antiplacebo.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$d/fixtures/cipar.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$d/fixtures/shard_a/case_a.sh"
  local sc='"check:alpha": "bash fixtures/alpha.sh", "check:shard-a": "bash fixtures/shard_a.sh", "check:antiplacebo": "bash fixtures/antiplacebo.sh", "check:ci-parity": "bash fixtures/cipar.sh"'
  if [ "$est_b" = 1 ]; then
    mkdir -p "$d/fixtures/shard_b"
    printf '#!/usr/bin/env bash\nexit 0\n' > "$d/fixtures/shard_b/case_b.sh"
    sc='"check:alpha": "bash fixtures/alpha.sh", "check:shard-a": "bash fixtures/shard_a.sh", "check:shard-b": "bash fixtures/shard_b.sh", "check:antiplacebo": "bash fixtures/antiplacebo.sh", "check:ci-parity": "bash fixtures/cipar.sh"'
  fi
  if [ "$orphan" != 0 ]; then
    sc="\"check:orphan\": \"bash fixtures/orphan.sh\", $sc"
    printf '#!/usr/bin/env bash\nexit 0\n' > "$d/fixtures/orphan.sh"
  fi
  printf '{ "name": "toy", "scripts": { %s } }\n' "$sc" > "$d/package.json"
  printf 'lanes\t6\nstep\ta1\t10\tnpm run check:alpha\nshard\tap1\t%s\n' "$reestr" > "$d/registry/ci-steps.tsv"
  cat > "$d/.github/workflows/ci.yml" <<EOF
name: ci
on: [push]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - run: npm run check:ci-parity
      # BEGIN GENERATED CI JOBS (083)
      # END GENERATED CI JOBS (083)
  antiplacebo:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        include:
          - shard: ap1
            keys: $blok
    steps:
      - run: npm run check:antiplacebo -- --scope \${{ matrix.keys }}
      # BEGIN GENERATED CI SHARDS (083)
      # END GENERATED CI SHARDS (083)
EOF
  : > "$d/config/ci_parity_exceptions.txt"
  if [ "$orphan" = 2 ]; then
    printf 'check:orphan = локальный пункт станционной обвязки, каталог станции недоступен раннеру CI\n' >> "$d/config/ci_parity_exceptions.txt"
  fi
  if [ -n "$PARITY" ]; then cp -- "$PARITY" "$d/scripts/verify_ci_parity.sh"
  else cp -- "$SRCPAR" "$d/scripts/verify_ci_parity.sh"; fi
  if [ -n "$NORM" ]; then
    bash "$NORM" "$d" || { printf 'NOT_IMPLEMENTED: нормализатор отказал\n' >&2; exit 2; }
  fi
}

run_par() { # <dir> → rc; вывод в $PAROUT
  PAROUT="$(bash "$1/scripts/verify_ci_parity.sh" "$1" 2>&1)"; return $?
}

# ── клетки ────────────────────────────────────────────────────────────────────
if nado Р2-реестр; then
  M="$SCR/w-konform"; mir "$M" 0 'shard_a' 'shard_a'
  run_par "$M"; rc=$?
  if [ "$rc" -eq 0 ]; then
    zeleno "Р2-реестр: конформный мир rc 0 (alpha покрыта реестром, shard_a — блоком)"
  else
    krasno "Р2-реестр: конформный мир rc=$rc: $PAROUT"
  fi
fi

if nado Р2-реестр/диф; then
  M="$SCR/w-diff"; mir "$M" 0 'alpha shard_a shard_b' 'shard_a'
  # alpha как шард-ключ требует case-файл (мёртвый ключ) — только в этом мире
  printf '#!/usr/bin/env bash\nexit 0\n' > "$M/fixtures/alpha/case_alpha.sh"
  # реестр без step-npm (осталась только shard-строка): alpha покрыта БЛОКОМ
  printf 'lanes\t6\nshard\tap1\tshard_a\n' > "$M/registry/ci-steps.tsv"
  run_par "$M"; rc=$?
  if [ "$rc" -eq 0 ]; then
    zeleno "Р2-реестр/диф: покрытие блоком (реестровых npm-шагов нет) rc 0"
  else
    krasno "Р2-реестр/диф: ждали rc 0, rc=$rc: $PAROUT"
  fi
fi

if nado Р2-область; then
  M="$SCR/w-oblast"; mir "$M" 1 'shard_a' 'shard_a'
  run_par "$M"; rc=$?
  if [ "$rc" -eq 1 ] && grep -q 'FAIL.*orphan' <<<"$PAROUT"; then
    zeleno "Р2-область: непокрытый ключ именован (rc 1): $(grep -m1 'FAIL.*orphan' <<<"$PAROUT")"
  else
    krasno "Р2-область: ждали rc 1 + FAIL-строку про orphan, rc=$rc: $PAROUT"
  fi
fi

if nado Р2-исключение; then
  M="$SCR/w-iskl"; mir "$M" 2 'shard_a' 'shard_a'
  run_par "$M"; rc=$?
  if [ "$rc" -eq 0 ]; then
    zeleno "Р2-исключение: ключ с живой записью-причиной rc 0"
  else
    krasno "Р2-исключение: ждали rc 0, rc=$rc: $PAROUT"
  fi
fi

if nado Р2-шарды; then
  M="$SCR/w-shardy"; mir "$M" 0 'shard_a' 'shard_b'
  run_par "$M"; rc=$?
  if [ "$rc" -eq 1 ] && grep -q 'FAIL.*shard_b' <<<"$PAROUT" && ! grep -q 'FAIL.*shard_a' <<<"$PAROUT"; then
    zeleno "Р2-шарды: сумма судит СГЕНЕРИРОВАННЫЙ блок — выпавший из блока shard_b именован (rc 1)"
  else
    krasno "Р2-шарды: ждали rc 1 + FAIL-строку про shard_b (и НЕ про shard_a), rc=$rc: $PAROUT"
  fi
fi

printf 'red_parity_reestr_079.sh: зелёных %d, красных %d\n' "$ZELENYH" "$KRASNYH"
[ "$KRASNYH" -eq 0 ] || exit 1
[ "$ZELENYH" -gt 0 ] || exit 2
exit 0
