#!/usr/bin/env bash
# Профиль батареи гигиены парсинга для scripts/zamok_predmeta.sh (контракт 140,
# норма 041 — новый гард чужого ввода: строки задания спавна, JSON события,
# JSONL единого учёта, TSV-реестр ПАУЗЫ, вывод git). Живое предъявление —
# строка инварианта 10 контракта 140:
#   bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta   → rc 0
# Классы те же четыре, что у соседних профилей: delimiter-collision,
# regex-injection, silent-drop, self-application-green. Клетки g01–g06 батареи
# 140 покрывают эти же классы на модели; здесь — на ПОСТАВЛЕННОЙ двери
# (scripts/zamok_predmeta.sh), а не на эталоне.
#
# Мир — в mktemp; сеть и omp не нужны; git/jq/bash обязательны.
ZP_REPO="$(cd "$HERE/../.." && pwd -P)"
ZP_SUBJ="$ZP_REPO/scripts/zamok_predmeta.sh"
ZP_T=''
ZP_TAB=$'\t'

# ── мир: состояние + журналы + реестр + репозиторий пина ─────────────────────
zp_world() {  # мир строится один раз на прогон профиля; состояние — чистое на каждый класс
  if [ -z "$ZP_T" ]; then
    ZP_T="$(mktemp -d "${TMPDIR:-/tmp}/battery_zamok.XXXXXX")" || return 1
    trap 'rm -rf "$ZP_T"' EXIT
    mkdir -p "$ZP_T/repo" "$ZP_T/wt"
    git -C "$ZP_T/repo" init -q . 2>/dev/null
    git -C "$ZP_T/repo" remote add origin 'ssh://git@github.com/a3ka/dev-harness.git'
    git -C "$ZP_T/repo" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
        commit -q --allow-empty -m w
    git -C "$ZP_T/wt" init -q . 2>/dev/null
    git -C "$ZP_T/wt" remote add origin 'ssh://git@github.com/a3ka/dev-harness.git'
    git -C "$ZP_T/wt" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
        commit -q --allow-empty -m w
  fi
  rm -rf "$ZP_T/sost" "$ZP_T/zhurnaly"
  mkdir -p "$ZP_T/sost" "$ZP_T/zhurnaly"
  return 0
}

# ── вызов двери ─────────────────────────────────────────────────────────────
zp_sudit() {  # <event.json> → ZP_OUT, ZP_RC
  if [ ! -f "$ZP_SUBJ" ]; then
    ZP_OUT='предмет отсутствует: scripts/zamok_predmeta.sh'; ZP_RC=127; return
  fi
  ZP_OUT="$(bash "$ZP_SUBJ" --sudit --sostojanie "$ZP_T/sost" \
      --zhurnaly "$ZP_T/zhurnaly" --repo "$ZP_T/repo" "$1" 2>&1)"
  ZP_RC=$?
}

# Ожидание: код возврата и (непустое) имя именованной причины.
zp_expect() {  # <rc> <причина|-> <метка>
  if [ "$ZP_RC" -ne "$1" ]; then
    printf 'zamok_predmeta: %s: rc %s ≠ %s; вывод: %s\n' "$3" "$ZP_RC" "$1" "$ZP_OUT" >&2
    return 1
  fi
  if [ "$2" != '-' ] && ! printf '%s' "$ZP_OUT" | grep -Fq "ОТКАЗ: $2:"; then
    printf 'zamok_predmeta: %s: нет причины %s; вывод: %s\n' "$3" "$2" "$ZP_OUT" >&2
    return 1
  fi
  return 0
}

# Событие: один элемент {agent,name,task}.
zp_event() {  # <файл> <agent> <name> <строки-задания…>
  local f="$1" a="$2" n="$3"
  shift 3
  local task
  task="$(printf '%s\n' "$@")"
  jq -cn --arg a "$a" --arg n "$n" --arg t "$task" '{agent:$a,name:$n,task:$t}' > "$f"
}

# Событие: пакет из готовых элементов.
zp_batch() {  # <файл> <элемент…>
  local f="$1"
  shift
  jq -s '{tasks:.}' "$@" > "$f"
}

# Живой держатель предмета: START в учёте + занятие + журнал БЕЗ yield.
zp_zhivoy_derzhatel() {  # <NNN> <holder> <klass>
  local n="$1" h="$2" k="$3"
  mkdir -p "$ZP_T/sost/zamki/dev-harness/$n/zanyat"
  jq -cn --arg s "$n" --arg h "$h" --arg k "$k" \
      '{holder:$h,klass:$k,rol:"architect",object:"-",worktree:"-",branch:"-",startedAt:"2026-10-26T00:00:00Z"}' \
      > "$ZP_T/sost/zamki/dev-harness/$n/zanyat/holder.json"
  jq -nc --arg t START --arg r dev-harness --arg s "$n" --arg g harness --arg h "$h" --arg k "$k" \
      '{t:$t,repoId:$r,subjectId:$s,group:$g,holder:$h,klass:$k,rol:"architect",object:"-",worktree:"-",branch:"-",at:"2026-10-26T00:00:00Z"}' \
      >> "$ZP_T/sost/uchet.jsonl"
  printf '{"timestamp":"2026-10-26T00:00:00.000Z","message":{"role":"assistant"}}\n' \
      > "$ZP_T/zhurnaly/$h.jsonl"
}

# ── класс 1: delimiter-collision ─────────────────────────────────────────────
battery_delimiter_collision() {
  # (а) TAB в ИМЕНИ holder'а — байт ВНЕ алфавита имени, а не разделитель
  #     полей: имя не должно молча обрезаться до первого поля и не должно
  #     пройти как «простое» имя.
  zp_world || return 1
  zp_event "$ZP_T/e1.json" architect "Ar${ZP_TAB}ch" \
      'SUBJECT=140' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/140/avtor'
  zp_sudit "$ZP_T/e1.json"
  zp_expect 1 IMJA_NET 'TAB в имени' || return 1
  # (б) TAB ВНУТРИ значения WORKTREE — байт-разделитель соседнего слоя внутри
  #     значения: путь не должен молча обрезаться по разделителю (иначе пин
  #     указывал бы на другой каталог, чем заявлено).
  zp_event "$ZP_T/e2.json" architect Arch140 \
      'SUBJECT=140' "WORKTREE=$ZP_T/wt${ZP_TAB}podstroka" 'BRANCH=wip/140/avtor'
  zp_sudit "$ZP_T/e2.json"
  zp_expect 1 PIN_NET 'TAB внутри WORKTREE' || return 1
  # (в) TAB внутри значения BRANCH — то же для второй строки пары пина.
  zp_event "$ZP_T/e3.json" architect Arch140 \
      'SUBJECT=140' "WORKTREE=$ZP_T/wt" "BRANCH=wip/140/avtor${ZP_TAB}podstroka"
  zp_sudit "$ZP_T/e3.json"
  zp_expect 1 PIN_NET 'TAB внутри BRANCH' || return 1
  return 0
}

# ── класс 2: regex-injection ────────────────────────────────────────────────
battery_regex_injection() {
  # (а) Метасимволы regex/glob в ИМЕНИ holder'а: имя — литеральный набор
  #     [A-Za-z0-9._-], «Arch140.*» не имя, а шаблон; шаблон не разворачивается.
  zp_world || return 1
  zp_event "$ZP_T/e1.json" architect 'Arch140.*' \
      'SUBJECT=140' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/140/avtor'
  zp_sudit "$ZP_T/e1.json"
  zp_expect 1 IMJA_NET 'метасимволы в имени' || return 1
  # (б) «SUBJECT=14x» — класс [0-9]{3} литерален: не «140 с хвостом», а
  #     предмет вне грамматики (тихий прогон недопустим).
  zp_event "$ZP_T/e2.json" architect Arch140 \
      'SUBJECT=14x' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/140/avtor'
  zp_sudit "$ZP_T/e2.json"
  zp_expect 1 SUBJECT_NET_V_ZADANII 'SUBJECT вне грамматики' || return 1
  # (в) Две якорные строки SUBJECT — предмет неоднозначен: молча взять первую
  #     нельзя (иначе подмена предмета проходит под видом честного).
  zp_event "$ZP_T/e3.json" architect Arch140 \
      'SUBJECT=140' 'SUBJECT=141' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/140/avtor'
  zp_sudit "$ZP_T/e3.json"
  zp_expect 1 SUBEKT_DVA_V_ZADANII 'две строки SUBJECT' || return 1
  return 0
}

# ── класс 3: silent-drop ────────────────────────────────────────────────────
battery_silent_drop() {
  # (а) Битое событие (не JSON) — именованный отказ, а не тихий пропуск.
  zp_world || return 1
  printf 'не json\n' > "$ZP_T/e1.json"
  zp_sudit "$ZP_T/e1.json"
  zp_expect 1 BITYJ_VHOD 'битое событие' || return 1
  # (б) Пустой список items — тоже отказ, а не «пустого предмета нет».
  printf '{"tasks": []}\n' > "$ZP_T/e2.json"
  zp_sudit "$ZP_T/e2.json"
  zp_expect 1 BITYJ_VHOD 'пустой items' || return 1
  # (в) Пакет из ДВУХ законных элементов: второй предмет не теряется молча
  #     (разбор, судящий только первый элемент, потерял бы его). Оба START
  #     обязаны появиться в учёте.
  zp_event "$ZP_T/e3a.json" architect Arch140 \
      'SUBJECT=140' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/140/avtor'
  zp_event "$ZP_T/e3b.json" architect Arch141 \
      'SUBJECT=141' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/141/avtor'
  zp_batch "$ZP_T/e3.json" "$ZP_T/e3a.json" "$ZP_T/e3b.json"
  zp_sudit "$ZP_T/e3.json"
  zp_expect 0 - 'пакет из двух предметов' || return 1
  local n140 n141
  n140="$(jq -r 'select(.t=="START" and .subjectId=="140") | .holder' "$ZP_T/sost/uchet.jsonl" 2>/dev/null | wc -l)"
  n141="$(jq -r 'select(.t=="START" and .subjectId=="141") | .holder' "$ZP_T/sost/uchet.jsonl" 2>/dev/null | wc -l)"
  if [ "$n140" != '1' ] || [ "$n141" != '1' ]; then
    printf 'zamok_predmeta: второй элемент пакета потерян: START 140=%s 141=%s\n' \
        "$n140" "$n141" >&2
    return 1
  fi
  return 0
}

# ── класс 4: self-application-green ─────────────────────────────────────────
battery_self_application_green() {
  # Субъект на СВОЁМ дереве: спавн исполнителя самого предмета 140 зелён на
  # чистом мире (WORKTREE = корень дерева двери, BRANCH = wip/140/…).
  # Негатив — тот же вход на непустом мире (живой держатель предмета): честная
  # дверь отказывает (RABOCHIJ_ZHIV), а дверь, хардкодящая «свой» accept, —
  # пропустила бы. Без негатива позитив не отличает честный гард от стаба.
  zp_world || return 1
  zp_event "$ZP_T/e1.json" implementer Impl140 \
      'реализация двери замка' 'SUBJECT=140' \
      "WORKTREE=$ZP_REPO" 'BRANCH=wip/140/implementer'
  zp_sudit "$ZP_T/e1.json"
  zp_expect 0 - 'самоприменение на своём дереве' || return 1
  if ! jq -e 'select(.t=="START" and .subjectId=="140" and .holder=="Impl140")' \
      "$ZP_T/sost/uchet.jsonl" >/dev/null 2>&1; then
    printf 'zamok_predmeta: самоприменение: START исполнителя 140 не записан\n' >&2
    return 1
  fi
  # Тот же вход, но предмет уже держит живой агент (второй дубль запрещён).
  zp_zhivoy_derzhatel 140 Arch140 rabochij
  zp_sudit "$ZP_T/e1.json"
  zp_expect 1 RABOCHIJ_ZHIV 'самоприменение при живом держателе' || return 1
  return 0
}
