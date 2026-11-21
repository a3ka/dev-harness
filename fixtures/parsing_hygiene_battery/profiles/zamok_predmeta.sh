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
# Класс silent-drop несёт ещё две клетки поведения двери (г, д): первый critic
# НОВОГО предмета (ни одного frozen/contracts/<NNN>/* у владельца) не
# теряется молча — класс риска берётся из ДЕРЕВА OBJECT; и негатив к нему —
# предмет с ОДНИМ живым frozen-тегом и битым pin отклоняется как прежде
# (bootstrap применяется ТОЛЬКО при нуле frozen-тегов).
# Сверх того — ещё три клетки различения (е, ж, з): класс нового предмета
# берётся из ДЕРЕВА OBJECT, поэтому ОТСУТСТВИЕ файла контракта (net_stroki) и
# SYMLINK вместо него (neodnoznachno) отказом с названной причиной, а не
# «обычным» по умолчанию; и ошибка чтения списка frozen-тегов (git
# for-each-ref → rc 127) — fail-closed («закреплённый frozen недоступен»), а
# не bootstrap (ошибка инструмента ≠ пустой список тегов).
#
# Мир — в mktemp; сеть и omp не нужны; git/jq/bash обязательны.
ZP_REPO="$(cd "$HERE/../.." && pwd -P)"
ZP_SUBJ="$ZP_REPO/scripts/zamok_predmeta.sh"
ZP_T=''
ZP_TAB=$'\t'
ZP_WT=''; ZP_BR=''; ZP_SHA=''; ZP_PIN=''

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

# Ожидание: код возврата + ИМЯ отказа + ПРИЧИНА внутри отказа.
# Одного имени мало: KLASS_RISKA_NET бывает и от битого pin (клетка (д)), и
# от нечитаемого класса риска (клетки (е)/(ж)) — различает фрагмент причины.
zp_expect_prichina() {  # <rc> <имя-отказа> <фрагмент-причины> <метка>
  zp_expect "$1" "$2" "$4" || return 1
  if ! printf '%s' "$ZP_OUT" | grep -Fq "$3"; then
    printf 'zamok_predmeta: %s: нет причины «%s»; вывод: %s\n' "$4" "$3" "$ZP_OUT" >&2
    return 1
  fi
  return 0
}

# Событие: один элемент {agent,name,task[,isolated]}.
# v5 (контракт 140, заявка 199:19): у РАБОЧЕГО item события спавна обязателен
# реальный isolated === true из ПОЛЯ item (omp task wire schema → нормализация
# стража спавна → событие двери); слово в тексте задания источником не
# является. Миграция входов рабочих: поле несёт сам вход. Судьям требование
# не распространяется (факт записывается, но не требуется).
zp_event() {  # <файл> <agent> <name> <строки-задания…>
  local f="$1" a="$2" n="$3"
  shift 3
  local task
  task="$(printf '%s\n' "$@")"
  case "$a" in
    architect|implementer|implementer-glm|implementer-vision)
      jq -cn --arg a "$a" --arg n "$n" --arg t "$task" \
        '{agent:$a,name:$n,task:$t,isolated:true}' > "$f" ;;
    *)
      jq -cn --arg a "$a" --arg n "$n" --arg t "$task" \
        '{agent:$a,name:$n,task:$t}' > "$f" ;;
  esac
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

# Кандидат предмета: контракт в ДЕРЕВЕ OBJECT (класс риска читается оттуда),
# ветка wip/<NNN>/avtor — рабочая ветка носителя.
zp_kandidat() {  # <NNN> → ZP_WT, ZP_BR, ZP_SHA
  local n="$1"
  local wt="$ZP_T/kand$n"
  rm -rf "$wt"
  mkdir -p "$wt/contracts"
  git -C "$wt" init -q . 2>/dev/null
  git -C "$wt" remote add origin 'ssh://git@github.com/a3ka/dev-harness.git'
  printf '# контракт %s\nКЛАСС РИСКА: обычный\n' "$n" > "$wt/contracts/$n-novyi.md"
  git -C "$wt" checkout -q -b "wip/$n/avtor" 2>/dev/null
  git -C "$wt" add -A
  git -C "$wt" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
      commit -q -m "k$n"
  ZP_WT="$wt"; ZP_BR="wip/$n/avtor"; ZP_SHA="$(git -C "$wt" rev-parse HEAD)"
}

# Автор предмета сдал результат: START рабочего в учёте + журнал с yield.
zp_avtor_sdal() {  # <NNN> <holder> <worktree> <branch>
  local n="$1" h="$2" wt="$3" br="$4"
  jq -cn --arg s "$n" --arg h "$h" --arg w "$wt" --arg b "$br" \
      '{t:"START",repoId:"dev-harness",subjectId:$s,group:"harness",holder:$h,
        klass:"rabochij",rol:"implementer",object:"-",worktree:$w,branch:$b,
        at:"2026-11-21T00:00:00Z"}' >> "$ZP_T/sost/uchet.jsonl"
  printf '{"timestamp":"2026-11-21T00:00:00.000Z","message":{"role":"assistant"}}\n{"type":"toolResult","toolCallId":"toolu_x","toolName":"yield","content":[{"type":"text","text":"Result submitted."}]}\n' \
      > "$ZP_T/zhurnaly/$h.jsonl"
}

# Настоящий git ДО подмены PATH: обёртка клетки (з) зовёт его по абсолютному
# пути, иначе обёртка вызвала бы саму себя.
ZP_REAL_GIT="$(command -v git 2>/dev/null || true)"
case "$ZP_REAL_GIT" in /*) : ;; *) ZP_REAL_GIT=/usr/bin/git ;; esac
[ -x "$ZP_REAL_GIT" ] || ZP_REAL_GIT=/usr/bin/git

# Обёртка git: `for-each-ref` отдаёт ОШИБКУ (rc 127), прочее — настоящий git.
# Ошибка инструмента ≠ пустой список тегов: дверь обязана закрыться
# (fail-closed), а не считать предмет новым и пойти в bootstrap.
zp_git_obvertka() {  # → каталог с обёрткой (в PATH кладёт вызывающий)
  local d="$ZP_T/gitwrap"
  mkdir -p "$d" || return 1
  printf '#!/bin/bash\nfor x in "$@"; do [ "$x" = for-each-ref ] && exit 127; done\nexec %s "$@"\n' \
      "$ZP_REAL_GIT" > "$d/git" || return 1
  chmod +x "$d/git" || return 1
  printf '%s' "$d"
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
  # (г) Первый critic НОВОГО предмета (у владельца НИ ОДНОГО тега
  #     frozen/contracts/<NNN>/*) НЕ теряется молча: класс риска берётся из
  #     ДЕРЕВА OBJECT, спавн разрешён. Иначе дверь, требующая frozen до
  #     первого критика, отказывала бы законному входу молча и без записей
  #     (слово владельца 21.11 — «самое простое решение»).
  zp_world || return 1
  zp_kandidat 203 || return 1
  zp_avtor_sdal 203 Avtor203 "$ZP_WT" "$ZP_BR"
  zp_event "$ZP_T/e4.json" critic Critic203 'SUBJECT=203' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e4.json"
  zp_expect 0 - 'critic нового предмета без frozen' || return 1
  # (д) Негатив к (г): bootstrap применяется ТОЛЬКО при НУЛЕ frozen-тегов.
  #     Предмет с ОДНИМ живым frozen-тегом и битым pin (строка реестра указывает
  #     не на frozen-тег) — отказ как прежде: KLASS_RISKA_NET. Иначе bootstrap
  #     превратился бы в безусловный допуск мимо пина владельца.
  zp_kandidat 204 || return 1
  zp_avtor_sdal 204 Avtor204 "$ZP_WT" "$ZP_BR"
  git -C "$ZP_T/repo" -c user.name=b -c user.email=b@t -c tag.gpgsign=false \
      tag -a 'frozen/contracts/204/1' -m frozen
  git -C "$ZP_T/repo" -c user.name=b -c user.email=b@t -c tag.gpgsign=false \
      tag -a 'id/CONTRACT/204' -m mint
  ZP_PIN="$(git -C "$ZP_T/repo" rev-parse 'refs/tags/id/CONTRACT/204')"
  mkdir -p "$ZP_T/repo/registry"
  printf '204 → %s\n' "$ZP_PIN" > "$ZP_T/repo/registry/contracts.tsv"
  git -C "$ZP_T/repo" add -A
  git -C "$ZP_T/repo" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
      commit -q -m 'pin 204'
  zp_event "$ZP_T/e5.json" critic Critic204 'SUBJECT=204' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e5.json"
  zp_expect 1 KLASS_RISKA_NET 'предмет с frozen-тегом и битым pin' || return 1
  # (е)(ж)(з) — три клетки различения вокруг класса риска и ошибки инструмента.
  # Каждая идёт ОТДЕЛЬНО и печатает свой rc: иначе первый пробитый скрыл бы
  # остальные (мутант двери ломает их по-разному), и профиль не показал бы,
  # КАКОЙ именно вход не различился.
  local kletka_probit=0
  zp_kletka_net_stroki || kletka_probit=1
  zp_kletka_symlink || kletka_probit=1
  zp_kletka_failref || kletka_probit=1
  [ "$kletka_probit" -eq 0 ] || return 1
  return 0
}

# Отчёт по клетке: имя + код возврата (сырой вывод приёмки читается по клеткам).
zp_kletka() {  # <имя-клетки> <rc>
  printf 'БАТАРЕЯ %s: клетка %s — rc %s\n' "${PROFILE_NAME:-zamok_predmeta}" "$1" "$2"
}

# (е) Первый critic НОВОГО предмета, у которого OBJECT БЕЗ файла контракта.
#     Класс риска берётся из ДЕРЕВА OBJECT: файла нет — класс НЕ ОПРЕДЕЛЁН, дверь
#     обязана отказать (KLASS_RISKA_NET, причина net_stroki), а не считать
#     предмет «обычным». Дверь, подставляющая класс константой, такой предмет
#     пропускает — клетка различает.
zp_kletka_net_stroki() {
  zp_world || return 1
  zp_kandidat 205 || return 1
  zp_avtor_sdal 205 Avtor205 "$ZP_WT" "$ZP_BR"
  git -C "$ZP_WT" rm -q 'contracts/205-novyi.md' || return 1
  git -C "$ZP_WT" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
      commit -q -m 'net kontrakta' || return 1
  ZP_SHA="$(git -C "$ZP_WT" rev-parse HEAD)"
  zp_event "$ZP_T/e6.json" critic Critic205 'SUBJECT=205' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e6.json"
  zp_kletka '(е) critic нового предмета: OBJECT без файла контракта' "$ZP_RC"
  zp_expect_prichina 1 KLASS_RISKA_NET '(net_stroki)' \
      '(е) critic нового предмета: OBJECT без файла контракта' || return 1
  return 0
}

# (ж) Тот же critic, но файл контракта в OBJECT — SYMLINK: запись не читается
#     как канон → класс не определён → отказ KLASS_RISKA_NET (neodnoznachno).
zp_kletka_symlink() {
  zp_world || return 1
  zp_kandidat 206 || return 1
  zp_avtor_sdal 206 Avtor206 "$ZP_WT" "$ZP_BR"
  rm -f "$ZP_WT/contracts/206-novyi.md"
  ln -s 'cel-neizvestno.md' "$ZP_WT/contracts/206-novyi.md"
  git -C "$ZP_WT" add -A || return 1
  git -C "$ZP_WT" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
      commit -q -m 'symlink vmesto kontrakta' || return 1
  ZP_SHA="$(git -C "$ZP_WT" rev-parse HEAD)"
  zp_event "$ZP_T/e7.json" critic Critic206 'SUBJECT=206' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e7.json"
  zp_kletka '(ж) critic нового предмета: symlink вместо файла контракта' "$ZP_RC"
  zp_expect_prichina 1 KLASS_RISKA_NET '(neodnoznachno)' \
      '(ж) critic нового предмета: symlink вместо файла контракта' || return 1
  return 0
}

# (з) Первый critic НОВОГО предмета, когда git НЕ ЧИТАЕТ перечень frozen-тегов
#     (for-each-ref → rc 127): ошибка инструмента ≠ пустой перечень. Дверь
#     обязана закрыться (KLASS_RISKA_NET, «закреплённый frozen недоступен»), а
#     не считать перечень пустым и пойти в bootstrap. Дверь, трактующая ошибку
#     как пустой перечень, такого critic пропускает — клетка различает.
zp_kletka_failref() {
  local old_path="$PATH" wrap
  zp_world || return 1
  zp_kandidat 207 || return 1
  zp_avtor_sdal 207 Avtor207 "$ZP_WT" "$ZP_BR"
  wrap="$(zp_git_obvertka)" || return 1
  PATH="$wrap:$PATH"; export PATH
  zp_event "$ZP_T/e8.json" critic Critic207 'SUBJECT=207' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e8.json"
  PATH="$old_path"; export PATH
  zp_kletka '(з) critic нового предмета: git for-each-ref недоступен' "$ZP_RC"
  zp_expect_prichina 1 KLASS_RISKA_NET 'закреплённый frozen недоступен' \
      '(з) critic нового предмета: git for-each-ref недоступен' || return 1
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
