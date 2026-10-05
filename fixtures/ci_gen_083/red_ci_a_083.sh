#!/usr/bin/env bash
# 083-БАТАРЕЯ — CI-А: параллельные lane из генератора шагов + инкрементальные
# проверки истории (контракт 083; круг 3 — правка по арбитражу 083-krug2:
# П1-а клетка Г8 «генерация, не сверка» (write-режим генератора как функция
# реестра), П1-б клетка Г9 «исполнение lane-шага, не упоминание» (живой прогон
# извлечённой run:-команды), П2 — в timing_083.sh, см. отдельный скрипт).
# Дом семьи — fixtures/ci_gen_083/ (probe-only 034: предмет — ГЕНЕРАТОР
# scripts/gen_ci_steps.sh + реестр registry/ci-steps.tsv + блоки ci.yml,
# ИСПОЛНЕНИЕ lane scripts/run_ci_lane.sh И режим --incr ЧЕТЫРЁХ исторических
# чеков через scripts/lib_incr.sh; барьерного ключа scripts/check_ci_gen.sh
# НЕТ и не появится), раннер — fixtures/_krasnye_083.sh. До-заморозочный
# носитель закоммичен АРХИТЕКТОРОМ (прецеденты 058/070/072/078/080).
#
# СТРУКТУРА (две части):
#   Часть Г — генератор+исполнение: честные клетки Г0-Г9 (КРАСНЫ до
#     реализации, зеленеют вместе с предметом) + стаб-клетки Г-С1/Г-С2
#     (toy-входы, ЗЕЛЁНЫ всегда: оракул батареи — собственный парсер блока —
#     различает обман на входе, где дефект наблюдаем). Г2 дополнительно
#     доказывает, что блок ЖИВЁТ ВНУТРИ джобы ci как её matrix (структурно:
#     strategy/matrix, маркеры в теле джобы, ровно один lane-шаг через
#     matrix.keys, последовательные npm-шаги отсутствуют); Г6 сравнивает
#     ключи КАЖДОГО шарда блок↔реестр поключево; Г7 РЕАЛЬНО ИСПОЛНЯЕТ
#     run_ci_lane.sh на toy-реестре (порядок, fail-fast именем ключа,
#     неизвестный ключ — именованный отказ); Г8 (арбитраж 083-krug2 П1-а)
#     доказывает ГЕНЕРАЦИЮ write-режимом: пустые блоки toy → --write →
#     записанное судится оракулом батареи (K/покрытие/баланс/шарды),
#     дифференциал по изменённому реестру обязан менять блок, неизменённая
#     копия обязана оставаться rc 0 (ловушка арность-заглушки); Г9
#     (арбитраж 083-krug2 П1-б) ИСПОЛНЯЕТ lane-шаг из ci.yml: run:-значение
#     единственного lane-шага (однострочный скаляр, иначе именованное
#     красное), токен '${{ matrix.keys }}' → 'k2 k4 k6', живой прогон из
#     toy L7, зелёное = rc 0 И журнал k2 k4 k6 по порядку (echo-имитация
#     даёт пустой журнал — различимость по исполнению, не по тексту).
#   Часть И — инкрементальность: И0/И0б (живое дерево, 4 чека, гость: КРАСНА
#     до реализации; И0б — непустое окно HEAD~1..HEAD: маркер с ИСТИННЫМ
#     числом коммитов + перезапись кеша), И1 позитивный контроль (полный
#     режим check_charter на toy — ЗЕЛЁН до и после), И2-И5 честные
#     window-клетки на charter-toy, И6-И14 — ТАКИЕ ЖЕ window-клетки для
#     check_zones/check_ids/check_protected (валидность toy полным режимом
#     + нарушение ниже базы зелёно + нарушение в окне красно): noop-ветка
#     --incr («маркер и rc 0») ловится клеткой «нарушение в окне», молча
#     полный прогон — клеткой «нарушение ниже базы». Стаб-пак С1-С4 против
#     мини-референса окна, носитель В БАТАРЕЕ, не субъект.
#
# Привязки обманных стабов к входам (Н-39 — живут ЗДЕСЬ, в коде батареи,
# НЕ в прозе контракта):
#   Г-С1 «генератор не параллелит» (весь блок — ОДНА lane со всеми ключами)
#        — наблюдаем на входе «include-блок ci.yml»: оракул даёт
#        «lane-число 1 < 6»; на конформном блоке (7 lane) — «ок».
#   Г-С2 «генератор теряет шаг» (в блоке нет ключа k7) — наблюдаем на том же
#        входе покрытием: «ключ k7 не покрыт»; на конформном — «покрытие
#        полное».
#   С1 «молча деградирует до полного» (игнорирует base, судит всю историю)
#        — наблюдаем на входе И2 (нарушение НИЖЕ базы): честное окно rc 0,
#        стаб rc 1.
#   С2 «молча ничего не судит» (маркер с верным N, судит пусто) — наблюдаем
#        на входе И3 (нарушение В окне): честное rc 1, стаб rc 0.
#   С3 «принимает поддельный кеш» (sha-не-предок пропущен) — наблюдаем
#        на входе И4-3: честный именованный отказ, стаб rc 0.
#   С4 «не пишет кеш» (зелёный прогон не обновляет кеш) — наблюдаем
#        на входе И2-повтор: окно снова судится (N>0), честное — 0 коммитов.
#
# Демаркация контрпримеров (правило 041/019): конформная toy-история каждого
# чека — коммиты, допустимые грамматикой предмета ЭТОГО чека; КРАСНЫЙ вход —
# нарушение именно предметной грамматики (charter: модификация AGENTS.md без
# РАЗРЕШИЛ-ВЛАДЕЛЕЦ; zones: коммит в диапазоне заморозки вне ЗОНА-строк;
# ids: номер артефакта без тега выдачи; protected: исчезновение существовавшего
# защищённого файла). Валидность каждого toy ДОКАЗАНА живым прогоном полного
# режима текущих чеков (клетки И1/И6/И9/И12) — вход конформен и красен ДО
# реализации предмета. Валидный контрпример против «инкрементальность не
# ослабляет» = расхождение композиции окон с полным прогоном на КОНФОРМНОЙ
# истории, а не вход вне грамматики чека.
#
# И0/И0б пишут tmp внутри судимого корня (норма самих чеков: mktemp $ROOT/tmp)
# — прогонять на корне, где запись законна (чистый клон/чекаут судьи);
# check_zones дополнительно требует тегов frozen/* в клоне (fetch --tags).
#
# Прогон: bash red_ci_a_083.sh [корень]
#   rc 0 — все клетки зелёные (после реализации предмета);
#   rc 1 — есть красные (до реализации: Г0-Г9, И0, И0б, И2-И5, И7-И8,
#          И10-И11, И13-И14 красны по умыслу, стаб-пак и И1/И6/И9/И12 зелёны).
# Печать никогда не говорит PASS — только счёт ok/FAIL по клеткам (rc — истина).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
case "$ROOT" in
  /*) ;;
  *) ROOT="$PWD/$ROOT" ;;
esac
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P)" || { printf '083-батарея ОТКАЗ: корень %s не каталог\n' "$ROOT" >&2; exit 1; }

die() { printf '083-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }
command -v git >/dev/null 2>&1 || die "нет git"
command -v timeout >/dev/null 2>&1 || die "нет timeout"
command -v jq >/dev/null 2>&1 || die "нет jq (Г4 сверяет package.json)"

SCRATCH="${CI083_SCRATCH:-}"
if [ -z "$SCRATCH" ]; then
  SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/ci-a-083.XXXXXX")" || die "mktemp отказал"
  OWN_SCRATCH=1
else
  mkdir -p "$SCRATCH" || die "не смог создать $SCRATCH"
  OWN_SCRATCH=0
fi
[ "$OWN_SCRATCH" = 1 ] && trap 'rm -rf "$SCRATCH"' EXIT

oks=0; fails=0
ok()  { oks=$((oks+1));  printf '  ok   %s\n' "$*" >&2; }
bad() { fails=$((fails+1)); printf '  FAIL %s\n' "$*" >&2; }

# ═══════════════════════════════════════════════════════════════════════════
# Оракул батареи: парсер include-блока ci.yml (собственный, НЕ субъект).
# Блок между маркерами; lane-строки `*- lane: <имя>`; ключи `*keys: <...>`.
# ═══════════════════════════════════════════════════════════════════════════
block_body() { # <файл> <BEGIN-маркер> <END-маркер>
  awk -v b="$2" -v e="$3" 'index($0,b)==1 && !f {f=1; next} index($0,e)==1 && f {f=0; next} f' "$1" 2>/dev/null
}
block_lanes() { # <файл> <BEGIN> <END> → имена lane по одной
  block_body "$1" "$2" "$3" | sed -n 's/^[[:space:]]*-[[:space:]]*lane:[[:space:]]*//p'
}
block_lane_keys() { # <файл> <BEGIN> <END> → ключи всех lane через пробел (порядок сохранён)
  block_body "$1" "$2" "$3" | sed -n 's/^[[:space:]]*keys:[[:space:]]*//p' | tr '\n' ' '
}
block_shard_names() { block_body "$1" "$2" "$3" | sed -n 's/^[[:space:]]*-[[:space:]]*shard:[[:space:]]*//p'; }
block_shard_keys()  { block_body "$1" "$2" "$3" | sed -n 's/^[[:space:]]*keys:[[:space:]]*//p' | tr '\n' ' '; }
block_shard_pairs() { # <файл> <BEGIN> <END> → строки 'имя<TAB>ключи' (пара shard/keys)
  block_body "$1" "$2" "$3" | awk '/^[[:space:]]*-[[:space:]]*shard:[[:space:]]*/{ n=$0; sub(/^[[:space:]]*-[[:space:]]*shard:[[:space:]]*/,"",n); gsub(/[[:space:]]+$/,"",n); pend=n; next }
    pend!="" && /^[[:space:]]*keys:[[:space:]]*/{ k=$0; sub(/^[[:space:]]*keys:[[:space:]]*/,"",k); print pend "\t" k; pend=""; next }
    /^[[:space:]]*-[[:space:]]*shard:/{ pend="" }'
}
ci_job_body() { # <файл> → тело джобы `ci:` (от '  ci:' до следующей джобы того же отступа)
  awk '!f && /^  ci:[[:space:]]*$/ {f=1; next} f && /^  [A-Za-z0-9_-]+:/ {exit} f' "$1" 2>/dev/null
}

JOBS_B="# BEGIN GENERATED CI JOBS (083)"
JOBS_E="# END GENERATED CI JOBS (083)"
SHARDS_B="# BEGIN GENERATED CI SHARDS (083)"
SHARDS_E="# END GENERATED CI SHARDS (083)"
CIYML="$ROOT/.github/workflows/ci.yml"
REG="$ROOT/registry/ci-steps.tsv"

# ═══════════════════════════════════════════════════════════════════════════
# Часть Г — генератор шагов + исполнение lane
# ═══════════════════════════════════════════════════════════════════════════
printf 'Часть Г — генератор шагов\n' >&2

reg_lanes=""; reg_keys=""; reg_weights_ok=1
declare -A W=() REG_SHARDS=()
if [ ! -f "$REG" ]; then
  bad "Г0: предмет отсутствует: нет реестра $REG"
elif ! grep -Eq $'^lanes[[:space:]]+[6-8][[:space:]]*$' "$REG"; then
  bad "Г0: реестр вне грамматики: нет строки 'lanes <K>' с K 6..8"
else
  reg_lanes="$(awk -F$'\t' '$1=="lanes"{print $2; exit}' "$REG" | tr -d '[:space:]')"
  ok "Г0: реестр парсится, lanes K=$reg_lanes"
fi
# step-строки: key (поле 2), weight (поле 3), command (поле 4..)
if [ -f "$REG" ] && [ -n "$reg_lanes" ]; then
  while IFS=$'\t' read -r kind key weight command; do
    [ "$kind" = "step" ] || continue
    case "$key" in
      *[!a-z0-9._:-]* | "") bad "Г0: ключ step вне алфавита: '$key'"; reg_weights_ok=0; continue ;;
    esac
    case "$key" in
      [0-9]*) bad "Г0: ключ step начинается с цифры: '$key'"; reg_weights_ok=0; continue ;;
    esac
    case "$weight" in
      ""|*[!0-9]*) bad "Г0: вес не целое ≥0 у '$key': '$weight'"; reg_weights_ok=0; continue ;;
    esac
    case "$command" in
      "npm run "*|"bash "*) ;;
      *) bad "Г0: команда вне грамматики у '$key': '$command'"; reg_weights_ok=0; continue ;;
    esac
    reg_keys="$reg_keys $key"
    W["$key"]="$weight"
  done < <(grep -v $'^[[:space:]]*#' "$REG")
  # дубликаты ключей
  dups="$(printf '%s\n' $reg_keys | sort | uniq -d | tr '\n' ' ')"
  [ -z "${dups//[[:space:]]/}" ] || { bad "Г0: дубликат step-ключей: $dups"; reg_weights_ok=0; }
  [ -n "${reg_keys//[[:space:]]/}" ] || bad "Г0: реестр без единой step-строки"
fi
# shard-строки
if [ -f "$REG" ]; then
  while IFS=$'\t' read -r kind name keys; do
    [ "$kind" = "shard" ] || continue
    [ -n "$name" ] && [ -n "$keys" ] || { bad "Г0: shard-строка вне грамматики: '$name'"; continue; }
    REG_SHARDS["$name"]="$keys"
  done < <(grep -v $'^[[:space:]]*#' "$REG")
fi

# Г1: генератор существует и --check зелёный; на правленом toy-блоке — rc 1.
GEN="$ROOT/scripts/gen_ci_steps.sh"
if [ ! -f "$GEN" ]; then
  bad "Г1: предмет отсутствует: нет генератора $GEN"
else
  out="$(cd "$ROOT" && bash scripts/gen_ci_steps.sh --check 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then
    ok "Г1: gen_ci_steps.sh --check rc 0"
  else
    bad "Г1: gen_ci_steps.sh --check rc=$rc: ${out##*$'\n'}"
  fi
  # правленый toy: копия ci.yml+реестра+package.json, одна lane-строка изменена
  if [ -f "$CIYML" ] && [ -f "$REG" ]; then
    TOY="$SCRATCH/g1toy"; mkdir -p "$TOY/.github/workflows" "$TOY/registry" "$TOY/scripts"
    cp "$CIYML" "$TOY/.github/workflows/ci.yml"; cp "$REG" "$TOY/registry/ci-steps.tsv"
    cp "$ROOT/package.json" "$TOY/package.json"; cp "$GEN" "$TOY/scripts/gen_ci_steps.sh"
    sed -i "s/^\([[:space:]]*-[[:space:]]*lane:[[:space:]]*\)l\([^[:space:]]*\)/\1lX\2/" "$TOY/.github/workflows/ci.yml"
    out="$(cd "$TOY" && bash scripts/gen_ci_steps.sh --check --root "$TOY" 2>&1)"; rc=$?
    [ "$rc" -eq 1 ] && ok "Г1: правка внутри блока красна (toy, rc 1)" \
                     || bad "Г1: правленый блок НЕ распознан (toy rc=$rc): $out"
  else
    bad "Г1: нет ci.yml/реестра для toy-пробы"
  fi
fi

# Г2: блок ЖИВЁТ В ДЖОБЕ ci как её matrix: ровно K lane 6..8, различны, непусты;
# стратегия matrix в теле джобы ci; маркеры ВНУТРИ тела джобы; ровно ОДИН
# lane-шаг (run_ci_lane.sh, потребляет matrix.keys); последовательные npm-шаги
# исчезли (не более одного npm run — gate check:ci-parity).
if [ -f "$CIYML" ] && grep -qF "$JOBS_B" "$CIYML" && grep -qF "$JOBS_E" "$CIYML"; then
  n_lanes="$(block_lanes "$CIYML" "$JOBS_B" "$JOBS_E" | wc -l | tr -d ' ')"
  dups_l="$(block_lanes "$CIYML" "$JOBS_B" "$JOBS_E" | sort | uniq -d | tr '\n' ' ')"
  n_keys_lines="$(block_body "$CIYML" "$JOBS_B" "$JOBS_E" | grep -c '^[[:space:]]*keys:')"
  g2_bad=""
  if [ "$n_lanes" -lt 6 ] || [ "$n_lanes" -gt 8 ] || [ "$n_lanes" -ne "${reg_lanes:-0}" ] \
     || [ -n "${dups_l//[[:space:]]/}" ] || [ "$n_keys_lines" -ne "$n_lanes" ]; then
    g2_bad="$g2_bad lane=$n_lanes(K=${reg_lanes:-нет}), дубли='$dups_l', keys-строк=$n_keys_lines"
  fi
  jobb="$(ci_job_body "$CIYML")"
  if [ -z "$jobb" ]; then
    g2_bad="$g2_bad джоба-ci-не-найдена"
  else
    printf '%s\n' "$jobb" | grep -q '^[[:space:]]*strategy:' || g2_bad="$g2_bad нет-strategy"
    printf '%s\n' "$jobb" | grep -q '^[[:space:]]*matrix:' || g2_bad="$g2_bad нет-matrix"
    printf '%s\n' "$jobb" | grep -qF "$JOBS_B" || g2_bad="$g2_bad маркеры-JOBS-вне-джобы-ci"
    lane_steps="$(printf '%s\n' "$jobb" | grep -c 'run_ci_lane.sh')"
    [ "$lane_steps" -eq 1 ] || g2_bad="$g2_bad lane-шагов=$lane_steps(≠1)"
    printf '%s\n' "$jobb" | grep -q 'matrix\.keys' || g2_bad="$g2_bad lane-шаг-не-потребляет-matrix.keys"
    npm_steps="$(printf '%s\n' "$jobb" | grep -cE 'run:.*npm run')"
    [ "$npm_steps" -le 1 ] || g2_bad="$g2_bad последовательных-npm-шагов=$npm_steps(>1: джоба не перестроена)"
  fi
  if [ -z "${g2_bad//[[:space:]]/}" ]; then
    ok "Г2: блок ci.yml несёт K=$n_lanes lane ВНУТРИ matrix джобы ci (lane-шаг один, последов. npm-шагов: $npm_steps)"
  else
    bad "Г2: блок не является matrix джобы ci:$g2_bad"
  fi
else
  bad "Г2: предмет отсутствует: нет marker-блока GENERATED CI JOBS (083) в ci.yml"
fi

# Г3: покрытие-сумма — ключи блока == step-ключи реестра, каждый ровно один раз.
if [ -f "$CIYML" ] && grep -qF "$JOBS_B" "$CIYML"; then
  blk="$(printf '%s\n' $(block_lane_keys "$CIYML" "$JOBS_B" "$JOBS_E") | sort | uniq -c | awk '$1!=1{print $2}' | tr '\n' ' ')"
  only_blk="$(comm -23 <(printf '%s\n' $(block_lane_keys "$CIYML" "$JOBS_B" "$JOBS_E") | sort -u) <(printf '%s\n' $reg_keys | sort -u))"
  only_reg="$(comm -13 <(printf '%s\n' $(block_lane_keys "$CIYML" "$JOBS_B" "$JOBS_E") | sort -u) <(printf '%s\n' $reg_keys | sort -u))"
  if [ -z "${blk//[[:space:]]/}" ] && [ -z "${only_blk//[[:space:]]/}" ] && [ -z "${only_reg//[[:space:]]/}" ]; then
    ok "Г3: покрытие: ключи блока == step-ключи реестра, каждый ровно один раз"
  else
    bad "Г3: покрытие нарушено: дубликаты='$blk' только-в-блоке='$only_blk' только-в-реестре='$only_reg'"
  fi
else
  bad "Г3: нет блока JOBS — покрытие не судимо"
fi

# Г4: резолв команд реестра (npm → package.json, bash → файл в дереве).
if [ -f "$REG" ] && [ -n "${reg_keys//[[:space:]]/}" ]; then
  g4_bad=""
  while IFS=$'\t' read -r kind key weight command; do
    [ "$kind" = "step" ] || continue
    case "$command" in
      "npm run "*)
        npmkey="$(printf '%s' "$command" | awk '{print $3}')"
        jq -e --arg k "$npmkey" '.scripts[$k] != null' "$ROOT/package.json" >/dev/null 2>&1 \
          || g4_bad="$g4_bad $key(npm:$npmkey)"
        ;;
      "bash "*)
        p="$(printf '%s' "$command" | cut -d' ' -f2)"
        [ -f "$ROOT/$p" ] || g4_bad="$g4_bad $key(bash:$p)"
        ;;
    esac
  done < <(grep -v $'^[[:space:]]*#' "$REG")
  [ -z "${g4_bad//[[:space:]]/}" ] && ok "Г4: все команды реестра резолвятся (npm↔package.json, bash↔дерево)" \
                                    || bad "Г4: нерезолвящиеся команды:$g4_bad"
else
  bad "Г4: реестр недоступен — резолв не судим"
fi

# Г5: баланс — max load lane ≤ ceil(total/K)+max(weight).
if [ -f "$CIYML" ] && grep -qF "$JOBS_B" "$CIYML" && [ "$reg_weights_ok" = 1 ] && [ -n "$reg_lanes" ]; then
  total=0; maxw=0
  for k in $reg_keys; do
    w="${W[$k]:-0}"; total=$((total+w)); [ "$w" -gt "$maxw" ] && maxw="$w"
  done
  bound=$(( (total + reg_lanes - 1) / reg_lanes + maxw ))
  maxload=0
  while IFS= read -r keysline; do
    load=0
    for k in $keysline; do load=$((load + ${W[$k]:-0})); done
    [ "$load" -gt "$maxload" ] && maxload="$load"
  done < <(block_body "$CIYML" "$JOBS_B" "$JOBS_E" | sed -n 's/^[[:space:]]*keys:[[:space:]]*//p')
  if [ "$maxload" -le "$bound" ]; then
    ok "Г5: баланс: max load=$maxload ≤ ceil($total/$reg_lanes)+maxw($maxw)=$bound"
  else
    bad "Г5: баланс нарушен: max load=$maxload > границы $bound (total=$total, K=$reg_lanes, maxw=$maxw)"
  fi
else
  bad "Г5: блок JOBS/веса реестра недоступны — баланс не судим"
fi

# Г6: шарды — ПОКЛЮЧЕВОЕ равенство: для КАЖДОГО шарда ключи блока == ключам
# его shard-строки реестра (мультимножество, порядок независим); имена —
# взаимно однозначно; каждый ключ шарда — существующий scripts/<key>.sh.
if [ -f "$CIYML" ] && grep -qF "$SHARDS_B" "$CIYML"; then
  g6_bad=""
  declare -A BLK_SHARDS=()
  n_pairs=0
  while IFS=$'\t' read -r name keys; do
    [ -n "$name" ] || continue
    n_pairs=$((n_pairs+1))
    if [ -n "${BLK_SHARDS[$name]+set}" ]; then
      g6_bad="$g6_bad shard:$name-дважды-в-блоке"
    else
      BLK_SHARDS["$name"]="$keys"
    fi
  done < <(block_shard_pairs "$CIYML" "$SHARDS_B" "$SHARDS_E")
  [ "$n_pairs" -eq "${#REG_SHARDS[@]}" ] || g6_bad="$g6_bad шардов-в-блоке=$n_pairs, в-реестре=${#REG_SHARDS[@]}"
  for name in "${!BLK_SHARDS[@]}"; do
    [ -n "${REG_SHARDS[$name]+set}" ] || { g6_bad="$g6_bad shard:$name-нет-в-реестре"; continue; }
    b="$(printf '%s\n' ${BLK_SHARDS[$name]} | sort | tr '\n' ' ')"
    r="$(printf '%s\n' ${REG_SHARDS[$name]} | sort | tr '\n' ' ')"
    [ "$b" = "$r" ] || g6_bad="$g6_bad ключи-$name-расходятся: блок='$b'реестр='$r'"
  done
  for name in "${!REG_SHARDS[@]}"; do
    [ -n "${BLK_SHARDS[$name]+set}" ] || g6_bad="$g6_bad shard:$name-нет-в-блоке"
  done
  for k in $(block_shard_keys "$CIYML" "$SHARDS_B" "$SHARDS_E"); do
    [ -f "$ROOT/scripts/$k.sh" ] || g6_bad="$g6_bad key:$k-нет-scripts/$k.sh"
  done
  [ -z "${g6_bad//[[:space:]]/}" ] && ok "Г6: ключи КАЖДОГО шарда блока == его shard-строке реестра (поключево)" \
                                     || bad "Г6: расхождение шардов:$g6_bad"
else
  bad "Г6: предмет отсутствует: нет marker-блока GENERATED CI SHARDS (083) в ci.yml"
fi

# Г7: lane-исполнитель РЕАЛЬНО исполняет шаги (toy-реестр + живой прогон
# run_ci_lane.sh из корня toy; каждый sk-скрипт дописывает свой ключ в done.log
# рядом с собой — cwd-независимо).
LANE="$ROOT/scripts/run_ci_lane.sh"
build_lane7() { # <dir> — toy L7 (общий для Г7 и Г9): sk1..sk6 (k5 отказывает
  # rc 1), реестр k1..k6, раннер из дерева; sk-скрипты пишут свой ключ в
  # done.log рядом с собой — cwd-независимо.
  local d="$1" i
  rm -rf "$d"; mkdir -p "$d/scripts" "$d/registry"
  cp "$LANE" "$d/scripts/run_ci_lane.sh"
  i=1
  while [ "$i" -le 6 ]; do
    { printf '#!/usr/bin/env bash\n'
      printf 'printf "%%s\\n" k%s >> "$(dirname "$0")/../done.log"\n' "$i"
      [ "$i" = "5" ] && printf 'exit 1\n'
    } > "$d/scripts/sk$i.sh"
    i=$((i+1))
  done
  { printf 'lanes\t6\n'
    i=1; while [ "$i" -le 6 ]; do printf 'step\tk%s\t10\tbash scripts/sk%s.sh\n' "$i" "$i"; i=$((i+1)); done
  } > "$d/registry/ci-steps.tsv"
}
if [ ! -f "$LANE" ]; then
  bad "Г7: предмет отсутствует: нет lane-исполнителя $LANE"
else
  L7="$SCRATCH/lane7"; build_lane7 "$L7"
  rm -f "$L7/done.log"
  out="$(cd "$L7" && timeout 30 bash scripts/run_ci_lane.sh k2 k4 k6 2>&1)"; rc=$?
  log=""; [ -f "$L7/done.log" ] && log="$(tr '\n' ' ' < "$L7/done.log")"
  if [ "$rc" -eq 0 ] && [ "$log" = "k2 k4 k6 " ]; then
    ok "Г7-порядок: run_ci_lane исполнил k2 k4 k6 по порядку (rc 0, журнал='$log')"
  else
    bad "Г7-порядок: run_ci_lane НЕ исполнил шаги (rc=$rc, журнал='$log'): $out"
  fi
  rm -f "$L7/done.log"
  out="$(cd "$L7" && timeout 30 bash scripts/run_ci_lane.sh k1 k5 k3 2>&1)"; rc=$?
  log=""; [ -f "$L7/done.log" ] && log="$(tr '\n' ' ' < "$L7/done.log")"
  if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q 'k5' && ! printf '%s' "$log" | grep -q 'k3'; then
    ok "Г7-fail-fast: отказ шага k5 остановил lane именем ключа, k3 НЕ исполнен (rc=$rc)"
  else
    bad "Г7-fail-fast: остановка на отказе не доказана (rc=$rc, журнал='$log'): $out"
  fi
  out="$(cd "$L7" && timeout 30 bash scripts/run_ci_lane.sh nokey 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q 'nokey'; then
    ok "Г7-неизвестный-ключ: nokey — именованный отказ (rc=$rc)"
  else
    bad "Г7-неизвестный-ключ: отказ не именует ключ (rc=$rc): $out"
  fi
fi

# Г8: ГЕНЕРАЦИЯ, не сверка (арбитраж 083-krug2, П1-а): write-режим инв. 1 —
# блок обязан быть ФУНКЦИЕЙ реестра. Toy — хирургическая копия входов
# генератора (ci.yml + реестр + package.json + генератор + цели bash-путей
# реестра, чтобы резолв И-3 в toy был честным). Три предъявления:
#   (3) НЕИЗМЕНЁННАЯ toy-копия → --check rc 0 (ловушка арность-считающей
#       заглушки: 3 аргумента ≠ «правка в блоке»; конформный вход обязан
#       быть зелёным — сама по себе НЕ достаточна, потому (1)-(2) обязательны);
#   (1) тела ОБОИХ блоков удалены (маркеры оставлены) → --check rc 1
#       с именованным дрейфом → --write rc 0 → ОРАКУЛ батареи (собственный
#       парсер, НЕ повторный вызов субъекта) судит записанное: lane-строк
#       ровно K реестра, ключи всех lane == step-ключам реестра каждый ровно
#       один раз, граница баланса И-4, шарды поключево == shard-строкам →
#       --check rc 0;
#   (2) дифференциал реестра: K → другое значение 6..8 И один step-ключ
#       переименован (в step- и shard-строках) → write → блок изменился
#       соответственно (lane-строк = новое K, новый ключ присутствует,
#       старый отсутствует) — хранимая константа, а не генерация, красна.
build_gen_toy() { # <dir> — копия входов генератора для Г8
  local t="$1" p
  rm -rf "$t"; mkdir -p "$t/.github/workflows" "$t/registry" "$t/scripts"
  cp "$CIYML" "$t/.github/workflows/ci.yml"
  cp "$REG" "$t/registry/ci-steps.tsv"
  cp "$ROOT/package.json" "$t/package.json"
  cp "$GEN" "$t/scripts/gen_ci_steps.sh"
  while IFS=$'\t' read -r kind key weight command; do
    [ "$kind" = "step" ] || continue
    case "$command" in
      "bash "*) p="${command#bash }"; p="${p%% *}"; mkdir -p "$t/$(dirname "$p")"; cp "$ROOT/$p" "$t/$p" ;;
    esac
  done < <(grep -v $'^[[:space:]]*#' "$REG")
}
empty_blocks() { # <ci.yml> — удалить тела ОБОИХ marker-блоков, маркеры оставить
  awk -v b1="$JOBS_B" -v e1="$JOBS_E" -v b2="$SHARDS_B" -v e2="$SHARDS_E" '
    index($0,b1)==1 { print; s=1; next }
    index($0,e1)==1 { s=0; print; next }
    index($0,b2)==1 { print; s=1; next }
    index($0,e2)==1 { s=0; print; next }
    !s' "$1" > "$1.g8tmp" && mv "$1.g8tmp" "$1"
}
if [ ! -f "$GEN" ]; then
  bad "Г8: предмет отсутствует: нет генератора $GEN"
elif [ ! -f "$REG" ] || [ -z "${reg_lanes//[[:space:]]/}" ] || [ -z "${reg_keys//[[:space:]]/}" ]; then
  bad "Г8: предмет отсутствует: реестр не распарсен (см. Г0) — генерация не судима"
elif [ ! -f "$CIYML" ] || ! grep -qF "$JOBS_B" "$CIYML" || ! grep -qF "$SHARDS_B" "$CIYML"; then
  bad "Г8: предмет отсутствует: нет marker-блоков (083) в ci.yml — write-режим не судим"
else
  FIRSTKEY="$(printf '%s' "$reg_keys" | awk '{print $1}')"
  T8="$SCRATCH/g8toy"; build_gen_toy "$T8"; T8CI="$T8/.github/workflows/ci.yml"
  # граница баланса И-4 — считаем сами (не полагаемся на переменные Г5)
  t8_total=0; t8_maxw=0
  for k in $reg_keys; do w8="${W[$k]:-0}"; t8_total=$((t8_total+w8)); [ "$w8" -gt "$t8_maxw" ] && t8_maxw="$w8"; done
  t8_bound=$(( (t8_total + reg_lanes - 1) / reg_lanes + t8_maxw ))
  g8_bad=""
  # (3) неизменённая копия — конформный вход, обязан быть rc 0
  out="$(cd "$T8" && timeout 60 bash scripts/gen_ci_steps.sh --check --root "$T8" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || g8_bad="$g8_bad неизменённая-копия rc=$rc (ожидался 0 — конформный вход): $out"
  # (1) пустые блоки → именованный дрейф → write → оракул → check
  empty_blocks "$T8CI"
  out="$(cd "$T8" && timeout 60 bash scripts/gen_ci_steps.sh --check --root "$T8" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && [ -n "$out" ]; } || g8_bad="$g8_bad пустые-блоки rc=$rc (ожидался 1 с именованным дрейфом): $out"
  out="$(cd "$T8" && timeout 60 bash scripts/gen_ci_steps.sh --write --root "$T8" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || g8_bad="$g8_bad write rc=$rc: $out"
  # оракул батареи судит ЗАПИСАННЫЙ блок (парсер батареи, не субъект)
  tn="$(block_lanes "$T8CI" "$JOBS_B" "$JOBS_E" | wc -l | tr -d ' ')"
  [ "$tn" -eq "$reg_lanes" ] || g8_bad="$g8_bad lane-строк=$tn ≠ K=$reg_lanes"
  tblk="$(printf '%s\n' $(block_lane_keys "$T8CI" "$JOBS_B" "$JOBS_E") | sort | uniq -c | awk '$1!=1{print $2}' | tr '\n' ' ')"
  tonly_b="$(comm -23 <(printf '%s\n' $(block_lane_keys "$T8CI" "$JOBS_B" "$JOBS_E") | sort -u) <(printf '%s\n' $reg_keys | sort -u))"
  tonly_r="$(comm -13 <(printf '%s\n' $(block_lane_keys "$T8CI" "$JOBS_B" "$JOBS_E") | sort -u) <(printf '%s\n' $reg_keys | sort -u))"
  { [ -z "${tblk//[[:space:]]/}" ] && [ -z "${tonly_b//[[:space:]]/}" ] && [ -z "${tonly_r//[[:space:]]/}" ]; } \
    || g8_bad="$g8_bad покрытие-записанного: дубли='$tblk' только-в-блоке='$tonly_b' только-в-реестре='$tonly_r'"
  tmax=0
  while IFS= read -r keysline; do
    tload=0
    for k in $keysline; do tload=$((tload + ${W[$k]:-0})); done
    [ "$tload" -gt "$tmax" ] && tmax="$tload"
  done < <(block_body "$T8CI" "$JOBS_B" "$JOBS_E" | sed -n 's/^[[:space:]]*keys:[[:space:]]*//p')
  [ "$tmax" -le "$t8_bound" ] || g8_bad="$g8_bad баланс-записанного: max load=$tmax > границы $t8_bound"
  declare -A T8_BLK=()
  while IFS=$'\t' read -r name keys; do
    [ -n "$name" ] || continue
    if [ -n "${T8_BLK[$name]+set}" ]; then
      g8_bad="$g8_bad shard:$name-дважды-в-блоке"
    else
      T8_BLK["$name"]="$keys"
    fi
  done < <(block_shard_pairs "$T8CI" "$SHARDS_B" "$SHARDS_E")
  [ "${#T8_BLK[@]}" -eq "${#REG_SHARDS[@]}" ] || g8_bad="$g8_bad шардов-в-блоке=${#T8_BLK[@]} в-реестре=${#REG_SHARDS[@]}"
  for name in "${!T8_BLK[@]}"; do
    tb8="$(printf '%s\n' ${T8_BLK[$name]} | sort | tr '\n' ' ')"
    treg="$(printf '%s\n' ${REG_SHARDS[$name]:-} | sort | tr '\n' ' ')"
    [ "$tb8" = "$treg" ] || g8_bad="$g8_bad шарды-$name-расходятся: блок='$tb8' реестр='$treg'"
  done
  out="$(cd "$T8" && timeout 60 bash scripts/gen_ci_steps.sh --check --root "$T8" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || g8_bad="$g8_bad check-после-write rc=$rc: $out"
  # (2) дифференциал реестра: K' + переименование первого step-ключа
  K1=$(( reg_lanes == 6 ? 7 : 6 ))
  awk -F'\t' -v OFS='\t' -v nk="$K1" -v old="$FIRSTKEY" -v new="renamed083" '
    $1=="lanes" { $2=nk }
    $1=="step" && $2==old { $2=new }
    $1=="shard" { n=split($3,a," "); s=""; for (j=1;j<=n;j++) s=s (j>1?" ":"") (a[j]==old?new:a[j]); $3=s }
    { print }' "$T8/registry/ci-steps.tsv" > "$T8/registry/ci-steps.tsv.g8tmp" && mv "$T8/registry/ci-steps.tsv.g8tmp" "$T8/registry/ci-steps.tsv"
  out="$(cd "$T8" && timeout 60 bash scripts/gen_ci_steps.sh --write --root "$T8" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || g8_bad="$g8_bad write-дифференциал rc=$rc: $out"
  tn="$(block_lanes "$T8CI" "$JOBS_B" "$JOBS_E" | wc -l | tr -d ' ')"
  [ "$tn" -eq "$K1" ] || g8_bad="$g8_bad дифференциал: lane-строк=$tn ≠ новому K=$K1"
  tkeys9="$(block_lane_keys "$T8CI" "$JOBS_B" "$JOBS_E")"
  case " $tkeys9 " in *" renamed083 "*) : ;; *) g8_bad="$g8_bad дифференциал: переименованный ключ отсутствует в блоке" ;; esac
  case " $tkeys9 " in *" $FIRSTKEY "*) g8_bad="$g8_bad дифференциал: старый ключ '$FIRSTKEY' остался в блоке" ;; esac
  if [ -z "${g8_bad//[[:space:]]/}" ]; then
    ok "Г8: write-режим сгенерировал блоки из реестра (пустые→записаны и подтверждены оракулом; дифференциал K=$reg_lanes→$K1 + rename отработан; неизменённая копия rc 0)"
  else
    bad "Г8: генерация не доказана (блок не функция реестра):$g8_bad"
  fi
fi

# Г9: ИСПОЛНЕНИЕ lane-шага workflow, не упоминание (арбитраж 083-krug2, П1-б):
# из тела джобы ci извлекается run:-значение ЕДИНСТВЕННОГО lane-шага
# (однострочный скаляр; run: | / run: > и иное неизвлекаемое значение —
# именованное красное, никогда зелёное), литеральный токен '${{ matrix.keys }}'
# заменяется на 'k2 k4 k6' (любой оставшийся '${{' — именованное красное),
# команда исполняется 'bash -eo pipefail -c' из корня toy L7 (тот же toy,
# что в Г7). Зелёное = rc 0 И журнал 'k2 k4 k6' по порядку. Различимость —
# по журналу исполнения, не по тексту run:-строки: echo-имитация печатает
# строку и даёт ПУСТОЙ журнал. Стык «шаг → раннер» доказывается одним
# прогоном; fail-fast раннера уже доказан Г7-б.
if [ ! -f "$LANE" ]; then
  bad "Г9: предмет отсутствует: нет lane-исполнителя $LANE"
elif [ ! -f "$CIYML" ] || [ -z "$(ci_job_body "$CIYML")" ]; then
  bad "Г9: предмет отсутствует: тело джобы ci не найдено в $CIYML"
else
  jobb9="$(ci_job_body "$CIYML")"
  n_lane9="$(printf '%s\n' "$jobb9" | grep -c 'run_ci_lane.sh')"
  runv9="$(printf '%s\n' "$jobb9" | sed -n 's/^[[:space:]]*run:[[:space:]]*//p' | grep 'run_ci_lane.sh' | head -n1)"
  if [ "$n_lane9" -ne 1 ] || [ -z "$runv9" ]; then
    bad "Г9: lane-шаг не извлекаем: run:-строк с run_ci_lane.sh в теле ci — $n_lane9 (нужна ровно одна, однострочный скаляр)"
  else
    case "$runv9" in
      '|'*|'>'*)
        bad "Г9: lane-шаг не извлекаем: значение run: не однострочный скаляр: '$runv9'"
        ;;
      *)
        cmd9="$(printf '%s' "$runv9" | sed 's/\${{ matrix\.keys }}/k2 k4 k6/g')"
        case "$cmd9" in
          *'${{'*)
            bad "Г9: lane-шаг несёт незаменённый токен '\${{': '$cmd9'"
            ;;
          *)
            L9="$SCRATCH/g9lane7"; build_lane7 "$L9"; rm -f "$L9/done.log"
            out="$(cd "$L9" && timeout 60 bash -eo pipefail -c "$cmd9" 2>&1)"; rc=$?
            log9=""; [ -f "$L9/done.log" ] && log9="$(tr '\n' ' ' < "$L9/done.log")"
            if [ "$rc" -eq 0 ] && [ "$log9" = "k2 k4 k6 " ]; then
              ok "Г9-исполнение: lane-шаг ci.yml исполнен живьём (токен→k2 k4 k6), журнал по порядку ('$log9')"
            else
              bad "Г9-исполнение: lane-шаг НЕ исполнил ключи (rc=$rc, журнал='$log9') — упоминание без исполнения?: $out"
            fi
            ;;
        esac
        ;;
    esac
  fi
fi

# Г-С1/Г-С2: стаб-входы против оракула батареи (зелёны всегда).
mk_toy_workflow() { # <файл> <lane:ключи...>
  local f="$1"; shift
  { printf '# статическая оболочка (не предмет)\n'; printf '%s\n' "$JOBS_B"
    for spec in "$@"; do
      printf '          - lane: %s\n' "${spec%%:*}"
      printf '            keys: %s\n' "${spec#*:}"
    done
    printf '%s\n' "$JOBS_E"
  } | tee "$f" >/dev/null
}
oracle_lanes() { # <файл> → 0 ok / 1 красно с причиной на stderr
  local n; n="$(block_lanes "$1" "$JOBS_B" "$JOBS_E" | wc -l | tr -d ' ')"
  if [ "$n" -ge 6 ] && [ "$n" -le 8 ]; then printf 'lane-число %s в 6..8\n' "$n"; return 0
  else printf 'lane-число %s < 6\n' "$n"; return 1; fi
}
oracle_cover() { # <файл> <ожидаемые ключи> → 0/1
  local missing; missing="$(comm -13 <(printf '%s\n' $(block_lane_keys "$1" "$JOBS_B" "$JOBS_E") | sort -u) <(printf '%s\n' $2 | sort -u) | tr '\n' ' ')"
  if [ -z "${missing//[[:space:]]/}" ]; then printf 'покрытие полное\n'; return 0
  else printf 'ключ %s не покрыт\n' "${missing%% *}"; return 1; fi
}
SW="$SCRATCH/gstab"; mkdir -p "$SW"
mk_toy_workflow "$SW/one-lane.yml" "l1:k1 k2 k3 k4 k5 k6 k7 k8"
mk_toy_workflow "$SW/ok-lanes.yml" l1:k1 l2:k2 l3:k3 l4:k4 l5:k5 l6:k6 l7:k7
mk_toy_workflow "$SW/drop-key.yml" l1:k1 l2:k2 l3:k3 l4:k4 l5:k5 l6:k6
r="$(oracle_lanes "$SW/one-lane.yml")"; rc=$?
[ "$rc" -eq 1 ] && ok "Г-С1: «не параллелит» пойман оракулом ($r)" || bad "Г-С1: оракул ПРОПУСТИЛ одну-lane блок"
r="$(oracle_lanes "$SW/ok-lanes.yml")"; rc=$?
[ "$rc" -eq 0 ] && ok "Г-С1-диффпроба: конформный блок (7 lane) проходит ($r)" || bad "Г-С1-диффпроба: оракул сломан на конформном блоке"
r="$(oracle_cover "$SW/drop-key.yml" "k1 k2 k3 k4 k5 k6 k7")"; rc=$?
[ "$rc" -eq 1 ] && ok "Г-С2: «теряет шаг» пойман оракулом ($r)" || bad "Г-С2: оракул ПРОПУСТИЛ потерю ключа"
r="$(oracle_cover "$SW/ok-lanes.yml" "k1 k2 k3 k4 k5 k6 k7")"; rc=$?
[ "$rc" -eq 0 ] && ok "Г-С2-диффпроба: полное покрытие проходит ($r)" || bad "Г-С2-диффпроба: оракул сломан на полном покрытии"

# ═══════════════════════════════════════════════════════════════════════════
# Часть И — инкрементальные проверки истории
# ═══════════════════════════════════════════════════════════════════════════
printf 'Часть И — инкрементальность\n' >&2

build_charter_toy() { # <dir> <with_violation:0|1> → печает "C1 C2 C3" (sha, C2=«-» если чистый)
  local d="$1" viol="$2"
  rm -rf "$d"; mkdir -p "$d/scripts" "$d/registry"
  local s
  for s in check_charter.sh next_id.sh lib_registry.sh lib_roles.sh lib_incr.sh; do
    cp "$ROOT/scripts/$s" "$d/scripts/$s" 2>/dev/null || { printf 'НЕТ-ЗАВИСИМОСТИ:%s\n' "$s"; return 1; }
  done
  ( cd "$d" && git init -q -b main \
    && git -c user.name=toy -c user.email=toy@t commit -q --allow-empty -m init ) >/dev/null 2>&1
  printf 'agents body\n' > "$d/AGENTS.md"
  printf 'roadmap\n'   > "$d/ROADMAP.md"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c1 import" || return 1
  local C1; C1="$(git -C "$d" rev-parse HEAD)"
  if [ "$viol" = 1 ]; then
    printf 'agents body v2\n' > "$d/AGENTS.md"
    git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c2 violation" || return 1
  fi
  local C2; C2="$(git -C "$d" rev-parse HEAD)"
  printf 'benign\n' > "$d/other.txt"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c3 benign" || return 1
  local C3; C3="$(git -C "$d" rev-parse HEAD)"
  git -C "$d" tag ustav/1 "$C1"
  printf '%s %s %s\n' "$C1" "$C2" "$C3"
}
# zones-toy: c1 — контракт с ЗОНА-строкой + заморозка (frozen/contracts/090/1);
# c2 — НАРУШЕНИЕ: коммит в диапазоне заморозки вне зоны (benign.txt автором toy);
# c3 — benign: правка внутри зоны тем же автором.
build_zones_toy() { # <dir> → "C1 C2 C3"
  local d="$1"
  rm -rf "$d"; mkdir -p "$d/scripts" "$d/contracts"
  local s
  for s in check_zones.sh next_id.sh lib_roles.sh lib_zones.sh lib_registry.sh lib_incr.sh; do
    cp "$ROOT/scripts/$s" "$d/scripts/$s" 2>/dev/null || { printf 'НЕТ-ЗАВИСИМОСТИ:%s\n' "$s"; return 1; }
  done
  ( cd "$d" && git init -q -b main \
    && git -c user.name=toy -c user.email=toy@t commit -q --allow-empty -m init ) >/dev/null 2>&1
  printf '# toy contract\n\nЗОНА toy: contracts/090-demo.md\n' > "$d/contracts/090-demo.md"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c1 contract" || return 1
  local C1; C1="$(git -C "$d" rev-parse HEAD)"
  git -C "$d" tag frozen/contracts/090/1 "$C1"
  printf 'benign\n' > "$d/benign.txt"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c2 outside-zone" || return 1
  local C2; C2="$(git -C "$d" rev-parse HEAD)"
  printf ' v2\n' >> "$d/contracts/090-demo.md"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c3 inside-zone" || return 1
  local C3; C3="$(git -C "$d" rev-parse HEAD)"
  printf '%s %s %s\n' "$C1" "$C2" "$C3"
}
# ids-toy: c1 — чистый импорт; c2 — НАРУШЕНИЕ: contracts/090-bad.md с номером
# без тега выдачи id/CONTRACT/090 («номер назначен рукой»); c3 — benign.
build_ids_toy() { # <dir> → "C1 C2 C3"
  local d="$1"
  rm -rf "$d"; mkdir -p "$d/scripts" "$d/contracts"
  local s
  for s in check_ids.sh next_id.sh lib_roles.sh lib_registry.sh lib_incr.sh; do
    cp "$ROOT/scripts/$s" "$d/scripts/$s" 2>/dev/null || { printf 'НЕТ-ЗАВИСИМОСТИ:%s\n' "$s"; return 1; }
  done
  ( cd "$d" && git init -q -b main \
    && git -c user.name=toy -c user.email=toy@t commit -q --allow-empty -m init ) >/dev/null 2>&1
  printf 'ok\n' > "$d/contracts/082-ok.md"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c1 import" || return 1
  git -C "$d" tag id/CONTRACT/082
  local C1; C1="$(git -C "$d" rev-parse HEAD)"
  printf 'bad\n' > "$d/contracts/090-bad.md"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c2 hand-number" || return 1
  local C2; C2="$(git -C "$d" rev-parse HEAD)"
  printf 'benign\n' > "$d/other.txt"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c3 benign" || return 1
  local C3; C3="$(git -C "$d" rev-parse HEAD)"
  printf '%s %s %s\n' "$C1" "$C2" "$C3"
}
# protected-toy: c1 — plans/001-x.md добавлен; c2 — НАРУШЕНИЕ: файл удалён
# («существовал — обязан существовать»); c3 — benign.
build_prot_toy() { # <dir> → "C1 C2 C3"
  local d="$1"
  rm -rf "$d"; mkdir -p "$d/scripts" "$d/plans"
  cp "$ROOT/scripts/check_protected.sh" "$d/scripts/check_protected.sh" 2>/dev/null \
    || { printf 'НЕТ-ЗАВИСИМОСТИ:check_protected.sh\n'; return 1; }
  cp "$ROOT/scripts/lib_incr.sh" "$d/scripts/lib_incr.sh" 2>/dev/null \
    || { printf 'НЕТ-ЗАВИСИМОСТИ:%s\n' lib_incr.sh; return 1; }
  ( cd "$d" && git init -q -b main \
    && git -c user.name=toy -c user.email=toy@t commit -q --allow-empty -m init ) >/dev/null 2>&1
  printf 'plan\n' > "$d/plans/001-x.md"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c1 add-plan" || return 1
  local C1; C1="$(git -C "$d" rev-parse HEAD)"
  git -C "$d" rm -q plans/001-x.md
  git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c2 del-plan" || return 1
  local C2; C2="$(git -C "$d" rev-parse HEAD)"
  printf 'benign\n' > "$d/other.txt"
  git -C "$d" add -A && git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm "c3 benign" || return 1
  local C3; C3="$(git -C "$d" rev-parse HEAD)"
  printf '%s %s %s\n' "$C1" "$C2" "$C3"
}
foreign_head() { # sha, не являющийся предком ни одного toy
  rm -rf "$SCRATCH/foreign"; mkdir -p "$SCRATCH/foreign"
  ( cd "$SCRATCH/foreign" && git init -q -b main && git -c user.name=f -c user.email=f@f commit -q --allow-empty -m f ) >/dev/null 2>&1
  git -C "$SCRATCH/foreign" rev-parse HEAD
}

# --- И0/И0б: живое дерево, 4 чека, гость (красны до реализации) -------------
# zones требует тегов frozen/* в клоне — иначе именованный отказ среды.
TAGS_FROZEN="$(git -C "$ROOT" for-each-ref --format='%(refname)' 'refs/tags/frozen/' 2>/dev/null | sed -n 1p)"
for chk in check_charter check_zones check_ids check_protected; do
  if [ "$chk" = "check_zones" ] && [ -z "$TAGS_FROZEN" ]; then
    bad "И0/$chk: клон без тегов frozen/* — прогони git fetch origin --tags и повтори"
    continue
  fi
  C="$SCRATCH/incr-$chk.cache"
  HEADSHA="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null)" || { bad "И0/$chk: корень не git-репозиторий"; continue; }
  printf '%s\n' "$HEADSHA" > "$C"
  out="$(cd "$ROOT" && timeout 60 bash "scripts/$chk.sh" --incr "$C" 2>&1)"; rc=$?
  after="$(head -n1 "$C" 2>/dev/null)"
  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q "incr: $chk судит .* (0 коммитов)" && [ "$after" = "$HEADSHA" ]; then
    ok "И0/$chk: --incr на живом дереве: пустое окно, маркер, кеш=$after"
  else
    if [ "$rc" -eq 124 ]; then
      bad "И0/$chk: предмет отсутствует: --incr не распознан, чек ушёл в полный прогон (timeout 60)"
    else
      bad "И0/$chk: предмет отсутствует: нет маркера 'incr: $chk судит' (rc=$rc)"
    fi
  fi
  # И0б: непустое окно HEAD~1..HEAD — маркер обязан нести ИСТИННОЕ число
  # коммитов окна (сверено с rev-list батареи), зелёный вердикт перезаписывает
  # кеш HEAD~1 → HEAD (запись кеша на непустом окне, не вакуумная).
  BASE="$(git -C "$ROOT" rev-parse HEAD~1 2>/dev/null)"
  NWIN="$(git -C "$ROOT" rev-list --count HEAD~1..HEAD 2>/dev/null)"
  if [ -z "$BASE" ] || [ "${NWIN:-0}" -lt 1 ]; then
    bad "И0б/$chk: окно HEAD~1..HEAD пусто/нет HEAD~1 — зонд не судим (N=${NWIN:-нет})"
    continue
  fi
  C="$SCRATCH/incr2-$chk.cache"; printf '%s\n' "$BASE" > "$C"
  out="$(cd "$ROOT" && timeout 60 bash "scripts/$chk.sh" --incr "$C" 2>&1)"; rc=$?
  after="$(head -n1 "$C" 2>/dev/null)"
  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q "incr: $chk судит .* ($NWIN коммит" && [ "$after" = "$HEADSHA" ]; then
    ok "И0б/$chk: непустое окно: маркер с истинным N=$NWIN, кеш перезаписан HEAD"
  else
    bad "И0б/$chk: предмет отсутствует/лжёт: ждали rc 0 + маркер '($NWIN коммит' + кеш=HEAD; rc=$rc: $out"
  fi
done

# --- charter-toy миры --------------------------------------------------------
read -r TV_C1 TV_C2 TV_C3 <<< "$(build_charter_toy "$SCRATCH/toy_viol" 1)"
if [ "${TV_C1:-}" = "НЕТ-ЗАВИСИМОСТ"* ] || [ -z "${TV_C1:-}" ]; then
  bad "И1: toy-мир не построен (зависимости чека не найдены в $ROOT/scripts)"
  TOY_OK=0
else
  TOY_OK=1
  # И1: позитивный контроль — полный режим красен и именует c2 (зелёна ДО и ПОСЛЕ).
  out="$(cd "$SCRATCH/toy_viol" && timeout 60 bash scripts/check_charter.sh 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "уставной документ изменён без разрешения владельца: AGENTS.md в ${TV_C2:0:8}"; then
    ok "И1: полный режим на toy красен и именует c2 (${TV_C2:0:8})"
  else
    bad "И1: полный режим на toy неожиданен (rc=$rc, ждал rc 1 + имя ${TV_C2:0:8}): $out"
  fi

  run_incr() { # <toy-dir> <cache> → rc; вывод в $RUN_OUT
    RUN_OUT="$(cd "$1" && timeout 60 bash scripts/check_charter.sh --incr "$2" 2>&1)"; return $?
  }
  # И2: окно пусто, нарушение ниже базы → rc 0 + маркер 0 коммитов + кеш=HEAD.
  C="$SCRATCH/i2.cache"; printf '%s\n' "$TV_C3" > "$C"
  run_incr "$SCRATCH/toy_viol" "$C"; rc=$?
  if [ "$rc" -eq 0 ] && printf '%s' "$RUN_OUT" | grep -q "incr: check_charter судит .* (0 коммит" \
     && [ "$(head -n1 "$C")" = "$TV_C3" ]; then
    ok "И2: incr с base=c3 — зелёный, окно 0 коммитов, кеш=HEAD"
  else
    bad "И2: предмет отсутствует: ожидался rc 0 + маркер '(0 коммитов)' + кеш=HEAD; rc=$rc: $RUN_OUT"
  fi
  # И3: окно содержит нарушение → rc 1, именует c2, маркер 2 коммита.
  C="$SCRATCH/i3.cache"; printf '%s\n' "$TV_C1" > "$C"
  run_incr "$SCRATCH/toy_viol" "$C"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$RUN_OUT" | grep -q "incr: check_charter судит .* (2 коммит" \
     && printf '%s' "$RUN_OUT" | grep -q "${TV_C2:0:8}"; then
    ok "И3: incr с base=c1 — красный, именует c2"
  else
    bad "И3: предмет отсутствует: ждали rc 1 + маркер '(2 коммита)' + имя ${TV_C2:0:8}; rc=$rc: $RUN_OUT"
  fi
  # И4: кеш-отказы.
  C="$SCRATCH/i41.cache"; rm -f "$C"
  run_incr "$SCRATCH/toy_viol" "$C"; rc=$?
  if printf '%s' "$RUN_OUT" | grep -q "incr: check_charter полный прогон (кеш отсутствует)"; then
    ok "И4-1: отсутствующий кеш — ЯВНЫЙ полный прогон с маркером (rc=$rc — вердикт полного прогона)"
  else
    bad "И4-1: предмет отсутствует: нет маркера 'полный прогон (кеш отсутствует)'; rc=$rc: $RUN_OUT"
  fi
  C="$SCRATCH/i42.cache"; printf 'not-a-sha\n' | tee "$C" >/dev/null
  run_incr "$SCRATCH/toy_viol" "$C"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$RUN_OUT" | grep -qi 'кеш'; then
    ok "И4-2: мусорный кеш — именованный отказ (кеш назван)"
  else
    bad "И4-2: предмет отсутствует: ждали именованный отказ rc 1 с именем кеша; rc=$rc: $RUN_OUT"
  fi
  C="$SCRATCH/i43.cache"; printf '%s\n' "$(foreign_head)" | tee "$C" >/dev/null
  run_incr "$SCRATCH/toy_viol" "$C"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$RUN_OUT" | grep -q 'не предок'; then
    ok "И4-3: sha-не-предок — именованный отказ «не предок»"
  else
    bad "И4-3: предмет отсутствует: ждали отказ «не предок» rc 1; rc=$rc: $RUN_OUT"
  fi
fi

# --- И5: чистый toy, полнота (зелёная стрелка композиции) --------------------
read -r TC_C1 TC_C2 TC_C3 <<< "$(build_charter_toy "$SCRATCH/toy_clean" 0)"
if [ -n "${TC_C1:-}" ] && [ "${TC_C1#НЕТ-ЗАВИСИМОСТ}" = "$TC_C1" ]; then
  C="$SCRATCH/i5.cache"; printf '%s\n' "$TC_C1" > "$C"
  RUN_OUT="$(cd "$SCRATCH/toy_clean" && timeout 60 bash scripts/check_charter.sh --incr "$C" 2>&1)"; rc=$?
  FULL_OUT="$(cd "$SCRATCH/toy_clean" && timeout 60 bash scripts/check_charter.sh 2>&1)"; frc=$?
  if [ "$rc" -eq 0 ] && printf '%s' "$RUN_OUT" | grep -q "incr: check_charter судит .* (1 коммит)" \
     && [ "$(head -n1 "$C")" = "$TC_C3" ] && [ "$frc" -eq 0 ]; then
    ok "И5: чистый toy: incr зелёный (кеш=HEAD) и full зелёный — композиция совпала"
  else
    bad "И5: предмет отсутствует: ждали incr rc 0 + '(1 коммит)' + кеш=HEAD и full rc 0; rc=$rc/$frc: $RUN_OUT"
  fi
else
  bad "И5: чистый toy не построен"
fi

# --- И6-И14: window-клетки для check_zones / check_ids / check_protected ----
# (аналог И1-И3 charter: валидность toy полным режимом + нарушение ниже базы
# зелёно + нарушение в окне красно; для КАЖДОГО из четырёх субъектов И-7).
window_cells() { # <имя-чека> <toy-dir-префикс> <builder> <grep-валидности>
  local chk="$1" pref="$2" builder="$3" valid_re="$4"
  local c1 c2 c3
  read -r c1 c2 c3 <<< "$("$builder" "$SCRATCH/$pref")"
  if [ -z "${c1:-}" ] || [ "${c1#НЕТ-ЗАВИСИМОСТ}" != "$c1" ]; then
    bad "И-${chk}: toy не построен (зависимости чека не найдены): $c1"
    return 1
  fi
  # валидность контрпримера: полный режим КРАСЕН и именует нарушение (c2)
  local out rc
  out="$(cd "$SCRATCH/$pref" && timeout 60 bash "scripts/$chk.sh" . 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "$valid_re"; then
    ok "И-валид/$chk: полный режим toy красен и именует нарушение (${c2:0:8})"
  else
    bad "И-валид/$chk: toy НЕДЕЙСТВИТЕЛЕН: полный режим rc=$rc, ждал rc 1 + '$valid_re': $out"
    return 1
  fi
  # ниже базы: окно пусто, нарушение ниже → rc 0 + '(0 коммит' + кеш=HEAD
  local C="$SCRATCH/${pref}-b3.cache"; printf '%s\n' "$c3" > "$C"
  out="$(cd "$SCRATCH/$pref" && timeout 60 bash "scripts/$chk.sh" --incr "$C" 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q "incr: $chk судит .* (0 коммит" \
     && [ "$(head -n1 "$C")" = "$c3" ]; then
    ok "И-ниже/$chk: base=c3 — зелёный, окно пусто, кеш=HEAD"
  else
    bad "И-ниже/$chk: предмет отсутствует/судит-всю-историю: ждали rc 0 + '(0 коммит' + кеш=HEAD; rc=$rc: $out"
  fi
  # в окне: base=c1 → rc 1 + именование + маркер '(2 коммит'
  C="$SCRATCH/${pref}-b1.cache"; printf '%s\n' "$c1" > "$C"
  out="$(cd "$SCRATCH/$pref" && timeout 60 bash "scripts/$chk.sh" --incr "$C" 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "incr: $chk судит .* (2 коммит" \
     && printf '%s' "$out" | grep -q "${c2:0:8}"; then
    ok "И-окно/$chk: base=c1 — красный, именует нарушение (${c2:0:8})"
  else
    bad "И-окно/$chk: предмет отсутствует/noop: ждали rc 1 + '(2 коммит' + имя ${c2:0:8}; rc=$rc: $out"
  fi
  return 0
}
window_cells check_zones   toy_zon build_zones_toy 'вне зоны'
window_cells check_ids     toy_ids build_ids_toy   'назначен рукой'
window_cells check_protected toy_pro build_prot_toy 'plans/001-x.md'

# --- И-С* стаб-пак: мини-референс окна (носитель В БАТАРЕЕ) vs обманные стабы.
ref_incr() { # <repo> <cache> [full-if-no-cache] — референс семантики И-6
  local repo="$1" cache="$2" base head range n rc=0 c
  head="$(git -C "$repo" rev-parse HEAD)"
  if [ ! -f "$cache" ]; then
    printf 'incr: check_charter полный прогон (кеш отсутствует)\n' >&2; base=""
  else
    base="$(head -n1 "$cache")"
    if ! printf '%s' "$base" | grep -Eq '^[0-9a-f]{40}$'; then
      printf 'ОТКАЗ: кеш повреждён: первая строка не sha\n' >&2; return 1
    fi
    if ! git -C "$repo" merge-base --is-ancestor "$base" "$head" 2>/dev/null; then
      printf 'ОТКАЗ: base не предок HEAD\n' >&2; return 1
    fi
  fi
  range="${base:+$base..}$head"
  n="$(git -C "$repo" rev-list --count "$range")"
  printf 'incr: check_charter судит %s..%s (%s коммитов)\n' "${base:-root}" "${head:0:8}" "$n" >&2
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    if git -C "$repo" diff-tree --no-commit-id --name-only -r --diff-filter=M "$c" 2>/dev/null | grep -qxF 'AGENTS.md'; then
      git -C "$repo" log -1 --format=%B "$c" | grep -q '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' || { printf 'FAIL: AGENTS.md без разрешения в %s\n' "${c:0:8}" >&2; rc=1; }
    fi
  done < <(git -C "$repo" rev-list --reverse "$range")
  [ "$rc" -eq 0 ] && printf '%s\n' "$head" > "$cache"
  return "$rc"
}
# Стабы — обманная семантика ровно одного пункта И-6:
stub_c1_full()  { # «молча деградирует до полного»: игнорирует base, судит всю историю
  local repo="$1" cache="$2" head n rc=0 c
  head="$(git -C "$repo" rev-parse HEAD)"; base="$(head -n1 "$cache" 2>/dev/null)"
  [ -f "$cache" ] || { printf 'ОТКАЗ: нет кеша\n' >&2; return 1; }
  printf 'incr: check_charter судит %s..%s (%s коммитов)\n' "${base:0:8}" "${head:0:8}" "$(git -C "$repo" rev-list --count "${base:+$base..}$head")" >&2
  while IFS= read -r c; do
    git -C "$repo" diff-tree --no-commit-id --name-only -r --diff-filter=M "$c" 2>/dev/null | grep -qxF 'AGENTS.md' \
      && ! git -C "$repo" log -1 --format=%B "$c" | grep -q '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' \
      && { printf 'FAIL: AGENTS.md без разрешения в %s\n' "${c:0:8}" >&2; rc=1; }
  done < <(git -C "$repo" rev-list --reverse "$head")
  [ "$rc" -eq 0 ] && printf '%s\n' "$head" > "$cache"
  return "$rc"
}
stub_c2_noop() { # «молча ничего не судит»: маркер с верным N, судит пусто
  local repo="$1" cache="$2" head base n
  head="$(git -C "$repo" rev-parse HEAD)"; base="$(head -n1 "$cache")"
  printf '%s' "$base" | grep -Eq '^[0-9a-f]{40}$' || { printf 'ОТКАЗ: кеш повреждён\n' >&2; return 1; }
  git -C "$repo" merge-base --is-ancestor "$base" "$head" 2>/dev/null || { printf 'ОТКАЗ: base не предок HEAD\n' >&2; return 1; }
  n="$(git -C "$repo" rev-list --count "$base..$head")"
  printf 'incr: check_charter судит %s..%s (%s коммитов)\n' "${base:0:8}" "${head:0:8}" "$n" >&2
  printf '%s\n' "$head" > "$cache"; return 0
}
stub_c3_forge() { # «принимает поддельный кеш»: без проверки предка
  local repo="$1" cache="$2" head base rc=0 c
  head="$(git -C "$repo" rev-parse HEAD)"; base="$(head -n1 "$cache")"
  printf '%s' "$base" | grep -Eq '^[0-9a-f]{40}$' || { printf 'ОТКАЗ: кеш повреждён\n' >&2; return 1; }
  printf 'incr: check_charter судит %s..%s (0 коммитов)\n' "${base:0:8}" "${head:0:8}" >&2
  while IFS= read -r c; do
    git -C "$repo" diff-tree --no-commit-id --name-only -r --diff-filter=M "$c" 2>/dev/null | grep -qxF 'AGENTS.md' \
      && ! git -C "$repo" log -1 --format=%B "$c" | grep -q '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' \
      && { printf 'FAIL: AGENTS.md без разрешения в %s\n' "${c:0:8}" >&2; rc=1; }
  done < <(git -C "$repo" rev-list --reverse "${base}..$head" 2>/dev/null)
  [ "$rc" -eq 0 ] && printf '%s\n' "$head" > "$cache"
  return "$rc"
}
stub_c4_nowrite() { # «не пишет кеш»: зелёный прогон не обновляет кеш
  local repo="$1" cache="$2" head base n rc=0 c
  head="$(git -C "$repo" rev-parse HEAD)"; base="$(head -n1 "$cache")"
  printf '%s' "$base" | grep -Eq '^[0-9a-f]{40}$' || { printf 'ОТКАЗ: кеш повреждён\n' >&2; return 1; }
  git -C "$repo" merge-base --is-ancestor "$base" "$head" 2>/dev/null || { printf 'ОТКАЗ: base не предок HEAD\n' >&2; return 1; }
  n="$(git -C "$repo" rev-list --count "$base..$head")"
  printf 'incr: check_charter судит %s..%s (%s коммитов)\n' "${base:0:8}" "${head:0:8}" "$n" >&2
  while IFS= read -r c; do
    git -C "$repo" diff-tree --no-commit-id --name-only -r --diff-filter=M "$c" 2>/dev/null | grep -qxF 'AGENTS.md' \
      && ! git -C "$repo" log -1 --format=%B "$c" | grep -q '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' \
      && { printf 'FAIL: AGENTS.md без разрешения в %s\n' "${c:0:8}" >&2; rc=1; }
  done < <(git -C "$repo" rev-list --reverse "$base..$head")
  return "$rc"
}
# Ожидания — в памяти батареи (правило 8): toy_viol построен выше.
if [ "$TOY_OK" = 1 ]; then
  # С1 на входе И2 (нарушение ниже базы): честный rc 0, стаб rc 1.
  C="$SCRATCH/s1.cache"; printf '%s\n' "$TV_C3" | tee "$C" >/dev/null
  ref_incr "$SCRATCH/toy_viol" "$C" >/dev/null 2>&1; ref_rc=$?
  C="$SCRATCH/s1b.cache"; printf '%s\n' "$TV_C3" | tee "$C" >/dev/null
  stub_c1_full "$SCRATCH/toy_viol" "$C" >/dev/null 2>&1; stub_rc=$?
  if [ "$ref_rc" -eq 0 ] && [ "$stub_rc" -ne 0 ]; then
    ok "И-С1: «деградирует до полного» пойман (честный rc 0, стаб rc $stub_rc на входе И2)"
  else
    bad "И-С1: оракул не различает (реф rc $ref_rc, стаб rc $stub_rc)"
  fi
  # диффпроба С1: на чистом toy дефект не наблюдаем — стаб и реф совпадают.
  if [ -n "${TC_C1:-}" ]; then
    C="$SCRATCH/s1d.cache"; printf '%s\n' "$TC_C3" | tee "$C" >/dev/null
    stub_c1_full "$SCRATCH/toy_clean" "$C" >/dev/null 2>&1; d1=$?
    [ "$d1" -eq 0 ] && ok "И-С1-диффпроба: на чистом toy стаб ведёт себя как честный (rc 0)" \
                      || bad "И-С1-диффпроба: стаб сломан не своим дефектом (rc $d1)"
  fi
  # С2 на входе И3 (нарушение в окне): честный rc 1, стаб rc 0.
  C="$SCRATCH/s2.cache"; printf '%s\n' "$TV_C1" | tee "$C" >/dev/null
  ref_incr "$SCRATCH/toy_viol" "$C" >/dev/null 2>&1; ref_rc=$?
  C="$SCRATCH/s2b.cache"; printf '%s\n' "$TV_C1" | tee "$C" >/dev/null
  stub_c2_noop "$SCRATCH/toy_viol" "$C" >/dev/null 2>&1; stub_rc=$?
  if [ "$ref_rc" -eq 1 ] && [ "$stub_rc" -eq 0 ]; then
    ok "И-С2: «ничего не судит» пойман (честный rc 1, стаб rc 0 на входе И3)"
  else
    bad "И-С2: оракул не различает (реф rc $ref_rc, стаб rc $stub_rc)"
  fi
  # диффпроба С2: на чистом toy стаб rc 0 == реф rc 0.
  if [ -n "${TC_C1:-}" ]; then
    C="$SCRATCH/s2d.cache"; printf '%s\n' "$TC_C1" | tee "$C" >/dev/null
    stub_c2_noop "$SCRATCH/toy_clean" "$C" >/dev/null 2>&1; d2=$?
    [ "$d2" -eq 0 ] && ok "И-С2-диффпроба: на чистом toy стаб зелёён (rc 0), дефект не наблюдаем" \
                      || bad "И-С2-диффпроба: стаб сломан не своим дефектом (rc $d2)"
  fi
  # С3 на входе И4-3 (sha-не-предок): честный отказ, стаб не-отказ.
  FS="$(foreign_head)"
  C="$SCRATCH/s3.cache"; printf '%s\n' "$FS" | tee "$C" >/dev/null
  ref_incr "$SCRATCH/toy_viol" "$C" >/dev/null 2>&1; ref_rc=$?
  C="$SCRATCH/s3b.cache"; printf '%s\n' "$FS" | tee "$C" >/dev/null
  stub_c3_forge "$SCRATCH/toy_viol" "$C" >/dev/null 2>&1; stub_rc=$?
  if [ "$ref_rc" -eq 1 ] && [ "$stub_rc" -eq 0 ]; then
    ok "И-С3: «поддельный кеш принят» пойман (честный отказ rc 1, стаб rc 0)"
  else
    bad "И-С3: оракул не различает (реф rc $ref_rc, стаб rc $stub_rc)"
  fi
  # диффпроба С3: валидный кеш — стаб ведёт себя честно (rc = реф на том же входе).
  C="$SCRATCH/s3d.cache"; printf '%s\n' "$TV_C1" | tee "$C" >/dev/null
  stub_c3_forge "$SCRATCH/toy_viol" "$C" >/dev/null 2>&1; d3=$?
  [ "$d3" -eq 1 ] && ok "И-С3-диффпроба: на валидном кеше стаб красен как честный (rc 1)" \
                     || bad "И-С3-диффпроба: стаб сломан не своим дефектом (rc $d3)"
  # С4 на зелёном входе с base != HEAD (чистый toy, кеш=c1, HEAD=c3):
  # честный зелёный прогон ОБЯЗАН записать HEAD; стаб оставляет старый sha.
  if [ -n "${TC_C1:-}" ]; then
    C="$SCRATCH/s4.cache"; printf '%s\n' "$TC_C1" | tee "$C" >/dev/null
    stub_c4_nowrite "$SCRATCH/toy_clean" "$C" >/dev/null 2>&1; s4rc=$?
    C="$SCRATCH/s4r.cache"; printf '%s\n' "$TC_C1" | tee "$C" >/dev/null
    ref_incr "$SCRATCH/toy_clean" "$C" >/dev/null 2>&1; r4rc=$?
    if [ "$s4rc" -eq 0 ] && [ "$r4rc" -eq 0 ] \
       && [ "$(head -n1 "$SCRATCH/s4.cache")" = "$TC_C1" ] \
       && [ "$(head -n1 "$SCRATCH/s4r.cache")" = "$TC_C3" ]; then
      ok "И-С4: «не пишет кеш» пойман (стаб оставил c1 при rc 0, реф записал c3)"
    else
      bad "И-С4: дефект не наблюдаем (стаб rc=$s4rc кеш=$(head -n1 "$SCRATCH/s4.cache" | cut -c1-8); реф rc=$r4rc кеш=$(head -n1 "$SCRATCH/s4r.cache" | cut -c1-8))"
    fi
  else
    bad "И-С4: чистый toy не построен — дефект не судим"
  fi
else
  bad "И-С*: стаб-пак не судим — toy не построен"
fi

printf '\n083-батарея: ok=%d FAIL=%d (до реализации части Г и И красны по умыслу)\n' "$oks" "$fails" >&2
[ "$fails" -eq 0 ] || exit 1
exit 0
