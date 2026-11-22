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
# предмет с ОДНИМ живым frozen-тегом и битым pin: класс не определён (bootstrap
# применяется ТОЛЬКО при нуле frozen-тегов) → ПРЕДУПРЕЖДЕНИЕ с записью.
# Сверх того — ещё три клетки различения (е, ж, з): класс нового предмета
# берётся из ДЕРЕВА OBJECT, поэтому ОТСУТСТВИЕ файла контракта (net_stroki) и
# SYMLINK вместо него (neodnoznachno) — класс НЕ ОПРЕДЕЛЁН, а по слову
# владельца 21.11 12:06 это ПРЕДУПРЕЖДЕНИЕ с записью (предмет считается
# рисковым), а не «обычный» по умолчанию; и ошибка чтения списка frozen-тегов
# (git for-each-ref → rc 127) — ошибка инструмента ≠ пустой список тегов:
# класс не определён → предупреждение, а не bootstrap.
# И ещё четыре клетки повтора суда (и, к, л, м): повторный круг той же роли на
# том же OBJECT — по контракту 208 (слово владельца 22.11, вариант А) ОТКАЗ
# OBJECT_UZHE_SUZHEN (rc 1, учёт не меняется), а не предупреждение: повтор
# допускается ТОЛЬКО по записанной в учёте санкции SANKCIJA с ПОЛНЫМ адресом
# (repoId+subjectId+rol+object) и только пока круг не исчерпан. (и) повтор без
# санкции — отказ; (к) тот же повтор со СТАРОЙ частной строкой
# `РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР:` — тот же отказ и НИКАКОГО применения разрешения
# (частная строка убрана, её заменила общая); (л) третий круг — тот же отказ;
# (м) чужая частная строка (чужой OBJECT, чужая роль, чужой предмет, строка
# вне формата) — тот же отказ.
# И ещё шесть клеток ГРАММАТИКИ записи санкции SANKCIJA (т, у, ш, щ, ю, к1) —
# контракт 208, инвариант 6: запись санкции несёт ПОЛНЫЙ адрес, сравнение
# ЛИТЕРАЛЬНОЕ, алфавиты замкнуты (repoId — идентификатор репозитория,
# subjectId — [0-9]{3}, rol — роль из JUDGES, object — 40-hex). (т) санкция с
# полным адресом — повтор ДОПУСКАЕТСЯ (круг записан); (у) санкция с чужим
# полем адреса (OBJECT, роль, предмет, repoId) — повтор отказ; (ш) санкция при
# исчерпанном круге (круги суда кончились) — отказ: санкция допускает ОДИН
# круг; (щ) SLOVO и снятая владельцем частная строка санкцией НЕ являются —
# отказ; (ю) значения полей с метасимволами, чужим регистром, лишним пробелом
# или неверной длиной — санкцией не являются (сравнение литеральное) — отказ;
# (к1) значение поля «склеено» (40-hex и хвост через пробел) — не санкция —
# отказ.
# И ещё две клетки того же слова — про ПОВТОР ИМЕНИ держателя (н, о): имя
# держателя не идентификатор круга. (н) состоявшийся первый круг и второй —
# под ТЕМ ЖЕ именем: повтор виден двери → ОТКАЗ, круг НЕ записывается (отказ
# учёт не меняет). (о) тот же повтор, но его RELEASE — технический обрыв
# `obryv_bez_verdikta`: обрыв не стирает состоявшийся первый круг — следующий
# запрос — тот же отказ (круг считается по учёту).
# И ещё три клетки РАСКЛАДКИ реестра контрактов у владельца (п, р, с) —
# проектный реестр: у проекта он лежит в .harness/registry/contracts.tsv (в
# registry/ такого файла нет). (п) реестр ТОЛЬКО в проектном пути, у предмета
# аннотированный frozen-тег и строка реестра — судья ДОПУСКАЕТСЯ дверью
# (rc 0 PUSCHEM); (р) реестра нет нигде — класс не определён → ПРЕДУПРЕЖДЕНИЕ
# с записью; (с) основной реестр есть, строки предмета в нём нет, а в
# проектном пути строка есть — то же предупреждение: запасной путь основной
# НЕ подменяет.
# И ещё четыре клетки ОБЩЕЙ СТРОКИ ВЛАДЕЛЬЦА (а, б, в, г) — слово владельца
# 21.11 12:06: `РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: <NNN> <КОД> [<OBJECT 40hex>]`
# пропускает ровно ОДИН отказ для предмета (и OBJECT, если указан): (а) пропуск
# один раз (PAUZA) с записью применения; (б) повтор той же строки — отказ, учёт
# не меняется; (в) чужие предмет/код/OBJECT — отказ; (г) отказ, который строка
# не отменяет (изоляция рабочего), — отказ.
#
# И ещё четыре клетки СОПОСТАВЛЕНИЯ кругов и реестра при передаче (р1, р2, р3,
# р4) — перенос с ветки #1173 (ремонт теста по FAIL Adv140V9) на дверь
# УПРОЩЕНИЯ ЗАМКА (A2). Источник клеток: f728e83553 (ветка
# wip/140/implementer-k01); здесь они адаптированы под A2.
# Соотнесение START↔RELEASE: RELEASE закрывает ПОСЛЕДНИЙ открытый START СВОЕГО
# holder'а в том же repoId/subjectId; фильтр по роли/OBJECT/классу — ПОСЛЕ
# соотнесения. (р1) промежуточный START того же держателя (другая роль/OBJECT)
# и обрыв того же держателя: обрыв закрывает ПРОМЕЖУТОЧНЫЙ круг, первый круг
# судьи не стёрт → дверь видит повтор круга; (р2) RELEASE ЧУЖОГО держателя не
# закрывает открытый START круга судьи → тот же повтор; (р3) промежуточный
# START ДРУГОГО класса/роли/OBJECT между кругом и обрывом: фильтр применяется
# ПОСЛЕ соотнесения → тот же повтор; (р4) D39 с ПРОЕКТНЫМ реестром (строка
# предмета только в .harness/registry/contracts.tsv): проверяемая передача
# ПРИНЯТА (rc 0 PEREDANO).
#
# АДАПТАЦИЯ ПОД СЕМАНТИКУ A2 (слово владельца 21.11 12:06): в A2 отказ
# OBJECT_UZHE_SUZHEN — не отказ, а ПРЕДУПРЕЖДЕНИЕ с записью в учёт
# (rc 0, «ПРЕДУПРЕЖДЕНИЕ: OBJECT_UZHE_SUZHEN: …», запись {"t":"warn",…}).
# Поэтому клетки (р1)–(р3) судят НЕ отказ, а РАЗЛИЧИЕ честной и мутантной
# двери по соотнесению START↔RELEASE, и различие в A2 остаётся различающим:
# мутант сопоставления считает круг НУЛЕВЫМ → предупреждения о повторе нет
# вовсе и записи warn нет; честная дверь пишет и предупреждение, и запись.
# Сверка счётчика — номер повтора в записи warn (2 = первый круг жив): при
# «съеденном» первом круге номер был бы 1.
#
# АДАПТАЦИЯ ПОД СЕМАНТИКУ 208 (слово владельца 22.11, вариант А): повтор той
# же роли на том же OBJECT — ИМЕНОВАННЫЙ ОТКАЗ OBJECT_UZHE_SUZHEN (rc 1, учёт
# не меняется, записи warn нет), а не предупреждение; допуск — только по
# санкции SANKCIJA полного адреса (repoId+subjectId+rol+object) и только пока
# круг не исчерпан. Поэтому клетки повтора ((и)–(о), (р1)–(р3)) судят ОТКАЗ,
# а различает их прежний мутант сопоставления START↔RELEASE: «съеденный» им
# первым кругом даёт НЕ отказ, а ПРОПУСК повтора (rc 0) — различие остаётся
# различающим (и острее прежнего: наблюдение «предупреждение» сменилось
# наблюдением «отказ»). Клетка (т) — положительный контроль грамматики
# санкции: санкция с полным адресом повтор ДОПУСКАЕТ (rc 0, круг записан);
# клетки (у), (ш), (щ), (ю), (к1) — негативы грамматики (чужие поля адреса,
# исчерпанный круг, SLOVO и снятая частная строка как «санкция», значения
# полей с метасимволами/регистром/пробелом/неверной длиной, «склеенное»
# значение поля) — ни одна из них санкцией НЕ является.
#
# НЕРАЗДЕЛИМОСТЬ МУТАНТОВ (наблюдение implementer Impl140K01, подтверждено
# прогоном; Н-39: привязка стабов — по коду, не прозой): мутанты `first`
# (RELEASE закрывает ПЕРВЫЙ открытый START своего holder'а) и `preselect`
# (START'ы отбираются по klass/rol/object ДО сопоставления) НЕ разделяются
# НИКАКИМ миром. Доказательство на входе: оба мутанта закрывают ОДНУ И ТУ ЖЕ
# запись тогда и только тогда, когда открытый START круга судьи есть и он —
# первый из открытых START'ов своего holder'а, переживших отбор `preselect`
# (у круга судьи klass=sudja, rol=роль судьи, object=OBJECT круга). В (р1) у
# holder'а ровно два открытых START'а — круг судьи и промежуточный
# (sudja/adversary/чуждой OBJECT): `preselect` промежуточный отбрасывает (роль
# и OBJECT чужие), `first` берёт первый из оставшихся — круг судьи. Оба
# закрывают круг судьи → счёт кругов и наблюдаемая разница совпадают.
# Измерение: оба мутанта краснят ОДНИ И ТЕ ЖЕ клетки — (р1) и (р3), и ни
# одной другой; (р2) обоих проходит. Различает их обоих клетка (р1) (и (р3));
# чистый разликатель для `foreignholder` (RELEASE закрывает последний открытый
# START вообще, без holder'а) — клетка (р2): там закрывается чужой holder.
#
# Мир — в mktemp; сеть и omp не нужны; git/jq/bash обязательны, а для клетки
# (р4) — python3 с jsonschema (иначе дверь отвечает NOT_IMPLEMENTED и клетка
# НЕ измерена: это не «класс закрыт честно», и профиль об этом сообщает).
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
  # Профиль проекта — состояние КЛЕТКИ, а не мира: клетка, которой путь реестра
  # нужен, объявляет его сама (zp_profil_reestr). Иначе объявление утекает в
  # следующие клетки и меняет их путь реестра.
  rm -rf "$ZP_T/repo/harness.project.json" "$ZP_T/repo/.profile" || return 1
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

# Журнал держателя с признаком сдачи (yield) — судья сдал свой круг.
zp_sdal() {  # <holder>
  printf '{"timestamp":"2026-11-21T00:00:00.000Z","message":{"role":"assistant"}}\n{"type":"toolResult","toolCallId":"toolu_x","toolName":"yield","content":[{"type":"text","text":"Result submitted."}]}\n' \
      > "$ZP_T/zhurnaly/$1.jsonl"
}

# Число START-записей держателя по предмету в учёте — контроль «отказ не
# записал круг» (поведение двери, а не текст счётчика).
zp_startov() {  # <NNN> <holder>
  jq -r --arg n "$1" --arg h "$2" \
      'select(.t=="START" and .subjectId==$n and .holder==$h) | .holder' \
      "$ZP_T/sost/uchet.jsonl" 2>/dev/null | wc -l
}

# Предупреждение двери (слово владельца 21.11 12:06): отказ только за реальный
# вред, остальное — строка stderr «ПРЕДУПРЕЖДЕНИЕ: <КОД>: <детали>» и запись
# {"t":"warn",…} в учёт. Клетки ниже судят ОБА эффекта.
zp_est_predupr() {  # <КОД> <метка>
  if ! printf '%s' "$ZP_OUT" | grep -Fq "ПРЕДУПРЕЖДЕНИЕ: $1:"; then
    printf 'zamok_predmeta: %s: нет строки «ПРЕДУПРЕЖДЕНИЕ: %s:»; вывод: %s\n' \
        "$2" "$1" "$ZP_OUT" >&2
    return 1
  fi
  return 0
}

# Запись warn в учёте: {"t":"warn","kod":…,"subjectId":…}.
zp_est_warn() {  # <КОД> <предмет> <метка>
  [ -f "$ZP_T/sost/uchet.jsonl" ] || {
    printf 'zamok_predmeta: %s: нет учёта — нет записи warn %s/%s\n' "$3" "$2" "$1" >&2
    return 1
  }
  if ! jq -se --arg k "$1" --arg s "$2" \
      'any(.[]; .t == "warn" and .kod == $k and .subjectId == $s)' \
      "$ZP_T/sost/uchet.jsonl" >/dev/null 2>&1; then
    printf 'zamok_predmeta: %s: нет записи warn %s/%s\n' "$3" "$2" "$1" >&2
    return 1
  fi
  return 0
}

# Запись override в учёте: применение общей строки владельца.
zp_est_override() {  # <КОД> <предмет> <метка>
  [ -f "$ZP_T/sost/uchet.jsonl" ] || {
    printf 'zamok_predmeta: %s: нет учёта — нет записи override %s/%s\n' "$3" "$2" "$1" >&2
    return 1
  }
  if ! jq -se --arg k "$1" --arg s "$2" \
      'any(.[]; .t == "override" and .kod == $k and .subjectId == $s)' \
      "$ZP_T/sost/uchet.jsonl" >/dev/null 2>&1; then
    printf 'zamok_predmeta: %s: нет записи override %s/%s\n' "$3" "$2" "$1" >&2
    return 1
  fi
  return 0
}

# Число записей override по коду и предмету — контроль одноразовости строки.
zp_override_schet() {  # <КОД> <предмет>
  [ -f "$ZP_T/sost/uchet.jsonl" ] || { printf '0'; return 0; }
  jq -se --arg k "$1" --arg s "$2" \
      '[.[] | select(.t == "override" and .kod == $k and .subjectId == $s)] | length' \
      "$ZP_T/sost/uchet.jsonl" 2>/dev/null | tail -n 1
}

# Номер повтора в записи warn — сверка счётчика кругов суда: «круг считается
# по учёту», и номер повтора в записи — наблюдаемый след этого счёта.
zp_est_povtor() {  # <КОД> <предмет> <ожидаемый номер> <метка>
  [ -f "$ZP_T/sost/uchet.jsonl" ] || {
    printf 'zamok_predmeta: %s: нет учёта — нет номера повтора %s/%s\n' "$4" "$2" "$1" >&2
    return 1
  }
  local got
  got="$(jq -sr --arg k "$1" --arg s "$2" \
      '[.[] | select(.t == "warn" and .kod == $k and .subjectId == $s) | .povtor] | last // empty' \
      "$ZP_T/sost/uchet.jsonl" 2>/dev/null | tail -n 1)"
  if [ "$got" != "$3" ]; then
    printf 'zamok_predmeta: %s: номер повтора %s ≠ %s (запись warn %s/%s)\n' \
        "$4" "${got:-нет}" "$3" "$2" "$1" >&2
    return 1
  fi
  return 0
}

# Отсутствие предупреждения двери: в A2 отказ — только за реальный вред,
# остальное — предупреждение с записью, поэтому «предупреждения НЕТ» —
# самостоятельное наблюдаемое различие (клетка (р4): честная дверь прочитала
# ПРОЕКТНЫЙ реестр — предупреждения о неудостоверенной frozen-версии нет).
zp_net_predupr() {  # <КОД> <метка>
  if printf '%s' "$ZP_OUT" | grep -Fq "ПРЕДУПРЕЖДЕНИЕ: $1:"; then
    printf 'zamok_predmeta: %s: неожиданное «ПРЕДУПРЕЖДЕНИЕ: %s:»; вывод: %s\n' \
        "$2" "$1" "$ZP_OUT" >&2
    return 1
  fi
  return 0
}

# Отсутствие записи warn по коду и предмету — второе плечо того же различия.
zp_net_warn() {  # <КОД> <предмет> <метка>
  [ -f "$ZP_T/sost/uchet.jsonl" ] || return 0
  if jq -se --arg k "$1" --arg s "$2" \
      'any(.[]; .t == "warn" and .kod == $k and .subjectId == $s)' \
      "$ZP_T/sost/uchet.jsonl" >/dev/null 2>&1; then
    printf 'zamok_predmeta: %s: неожиданная запись warn %s/%s\n' "$3" "$2" "$1" >&2
    return 1
  fi
  return 0
}

# START-запись произвольного класса/роли/OBJECT — промежуточный круг в
# последовательности START держателя (формат учёта прежний, как пишет дверь).
zp_start_zapis() {  # <NNN> <holder> <klass> <rol> <object> <worktree> <branch>
  jq -nc --arg s "$1" --arg h "$2" --arg k "$3" --arg ro "$4" --arg o "$5" \
      --arg w "$6" --arg b "$7" --arg at '2026-11-21T00:00:00Z' \
      '{t:"START",repoId:"dev-harness",subjectId:$s,group:"harness",holder:$h,
        klass:$k,rol:$ro,object:$o,worktree:$w,branch:$b,at:$at}' \
      >> "$ZP_T/sost/uchet.jsonl"
}

# RELEASE-запись держателя: обрыв круга (формат учёта прежний, как пишет дверь).
zp_release_zapis() {  # <NNN> <holder> <prichina>
  jq -nc --arg t RELEASE --arg r dev-harness --arg s "$1" --arg h "$2" \
      --arg p "$3" --arg at '2026-11-21T00:00:00Z' \
      '{t:$t,repoId:$r,subjectId:$s,holder:$h,prichina:$p,at:$at}' \
      >> "$ZP_T/sost/uchet.jsonl"
}

# Строка учёта — СЫРАЯ, значения полей задаёт клетка: грамматику записи
# санкции SANKCIJA (контракт 208, инвариант 6) проверяет дверь, а не клетка.
zp_uchet_stroka() {  # <json-строка>
  printf '%s\n' "$1" >> "$ZP_T/sost/uchet.jsonl"
}

# Снимок учёта и его сверка: отказ (контракт 208) учёт НЕ меняет — ни START'а,
# ни записи warn. Снимок снимается ПОСЛЕ подготовки мира клетки (сама санкция
# SANKCIJA — часть подготовки, а не следствие вызова).
zp_uchet_snimok() {
  cp "$ZP_T/sost/uchet.jsonl" "$ZP_T/uchet.snimok" || return 1
}
zp_uchet_nezmenen() {  # <метка>
  if ! cmp -s "$ZP_T/sost/uchet.jsonl" "$ZP_T/uchet.snimok"; then
    printf 'zamok_predmeta: %s: отказ изменил учёт\n' "$1" >&2
    return 1
  fi
  return 0
}

# Мир повтора суда: предмет с кандидатом (контракт в дереве OBJECT), автор
# сдал, ПЕРВЫЙ critic сдал — круг суда роли на этом OBJECT состоялся.
# Возвращает ZP_WT/ZP_BR/ZP_SHA кандидата.
zp_mir_povtora() {  # <NNN>
  zp_world || return 1
  zp_kandidat "$1" || return 1
  zp_avtor_sdal "$1" "Avtor$1" "$ZP_WT" "$ZP_BR" || return 1
  zp_sdal "Critic$1"
  zp_event "$ZP_T/e1.json" critic "Critic$1" "SUBJECT=$1" "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e1.json"
  if [ "$ZP_RC" -ne 0 ]; then
    printf 'zamok_predmeta: первый critic не пропущен (rc %s): %s\n' "$ZP_RC" "$ZP_OUT" >&2
    return 1
  fi
  return 0
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

# ── раскладка реестра контрактов у владельца (клетки п, р, с) ──────────────
# Путь реестра — ДАННЫЕ ПРОФИЛЯ (workflowPaths.registry); без профиля —
# реестр репозитория (registry/). Клетки судят РАСКЛАДКУ, а не текст:
# пина предмета нет нигде / пин только в объявленном профилем пути /
# объявленный путь есть, а строки предмета в нём нет (в необъявленном
# каталоге строка есть — она реестром НЕ является).

# Убрать оба пути реестра у владельца (раскладка задаётся клеткой явно).
zp_reestr_snyat() {
  rm -rf "$ZP_T/repo/registry" "$ZP_T/repo/.harness/registry" || return 1
  git -C "$ZP_T/repo" add -A || return 1
  if ! git -C "$ZP_T/repo" diff --cached --quiet; then
    git -C "$ZP_T/repo" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
        commit -q -m 'reestr snyat' || return 1
  fi
  return 0
}

# Профиль проекта, объявляющий путь реестра (workflowPaths.registry): путь
# реестра — данные профиля, а не угадывание по дереву. Слой проекта —
# .profile/project.json (не в каталоге реестра: клетка реестр снимает).
zp_profil_reestr() {  # <репозиторий> <путь реестра относительно корня>
  local repo="$1" reg="$2"
  mkdir -p "$repo/.profile" "$repo/$reg" "$repo/contracts" "$repo/verdicts" \
           "$repo/fixtures" || return 1
  printf '%s\n' '{"schemaVersion":1,"repoId":"dev-harness","language":"bash","projectLayer":{"version":"1","profilePath":".profile/project.json"},"workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"'"$reg"'","fixtures":"fixtures"}}' \
      > "$repo/harness.project.json" || return 1
  printf '%s\n' '{"schemaVersion":1,"version":"1","projectId":"toy","workspaceId":"toy","defaults":{}}' \
      > "$repo/.profile/project.json" || return 1
  git -C "$repo" add -A || return 1
  if ! git -C "$repo" diff --cached --quiet; then
    git -C "$repo" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
        commit -q -m 'profil proekta' || return 1
  fi
  return 0
}

# Строка реестра контрактов в указанном пути у владельца (путь — раскладка).
zp_reestr_stroka() {  # <путь> <NNN> <объект-тега>
  local p="$1" n="$2" obj="$3"
  mkdir -p "$ZP_T/repo/$(dirname "$p")" || return 1
  printf '%s → %s\n' "$n" "$obj" > "$ZP_T/repo/$p" || return 1
  git -C "$ZP_T/repo" add -A || return 1
  git -C "$ZP_T/repo" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
      commit -q -m "reestr $n" || return 1
  return 0
}

# Владелец предмета: контракт в дереве frozen + аннотированный тег
# frozen/contracts/<NNN>/1 (класс риска дверь читает из дерева этого
# коммита). Печатает объект аннотированного тега — его ждёт строка реестра.
zp_vladelec_frozen() {  # <NNN> → объект аннотированного тега
  local n="$1"
  mkdir -p "$ZP_T/repo/contracts" || return 1
  printf '# контракт %s\nКЛАСС РИСКА: обычный\n' "$n" > "$ZP_T/repo/contracts/$n-proekt.md" || return 1
  git -C "$ZP_T/repo" add -A || return 1
  git -C "$ZP_T/repo" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
      commit -q -m "kontrakt $n" || return 1
  git -C "$ZP_T/repo" -c user.name=b -c user.email=b@t -c tag.gpgsign=false \
      tag -a "frozen/contracts/$n/1" -m frozen || return 1
  git -C "$ZP_T/repo" rev-parse "refs/tags/frozen/contracts/$n/1"
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
  # (г) «склеенное» значение поля записи санкции SANKCIJA (контракт 208): хвост
  #     соседнего поля внутри значения — значение НЕ разбирается по
  #     разделителю и не обрезается: такая запись санкцией не является.
  zp_kletka_sankcija_skleennyj_znach || return 1
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
  # (г) Метасимволы и чужие форматы в полях записи санкции SANKCIJA (контракт
  #     208): значение поля — литерал, шаблон НЕ разворачивается и не
  #     подгоняется; такая запись санкцией не является.
  zp_kletka_sankcija_grammatika || return 1
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
  #     не на frozen-тег) — класс НЕ ОПРЕДЕЛЁН: по слову владельца 21.11 12:06
  #     это ПРЕДУПРЕЖДЕНИЕ с записью (предмет считается рисковым), а не отказ.
  #     Отличие от (г) — в наличии предупреждения: там класс читается из ДЕРЕВА
  #     OBJECT (bootstrap), здесь frozen владельца недоступен.
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
  zp_expect 0 - 'предмет с frozen-тегом и битым pin' || return 1
  zp_est_predupr KLASS_RISKA_NET 'предмет с frozen-тегом и битым pin' || return 1
  zp_est_warn KLASS_RISKA_NET 204 'предмет с frozen-тегом и битым pin' || return 1
  # (е)(ж)(з) — три клетки различения вокруг класса риска и ошибки инструмента.
  # Каждая идёт ОТДЕЛЬНО и печатает свой rc: иначе первый пробитый скрыл бы
  # остальные (мутант двери ломает их по-разному), и профиль не показал бы,
  # КАКОЙ именно вход не различился.
  # (и)(к)(л)(м) — четыре клетки повтора суда вокруг снятой владельцем строки
  # `РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР:` (слово владельца 21.11 12:06; контракт 208 —
  # вариант А): повтор той же роли на том же OBJECT — именованный отказ, пока
  # нет записанной в учёте санкции SANKCIJA полного адреса; снятая строка
  # санкцией не является (ни сама по себе, ни чужая по предмету/роли/OBJECT).
  # (т)(у)(ш)(щ) — четыре клетки ГРАММАТИКИ записи санкции (контракт 208):
  # санкция полного адреса допускает повтор (не теряется молча), санкция с
  # чужим полем адреса и санкция при исчерпанном круге — нет; SLOVO и снятая
  # строка санкцией не являются.
  # (н)(о) — две клетки ПОВТОРА ИМЕНИ держателя: имя не идентификатор круга.
  # (п)(р)(с) — три клетки РАСКЛАДКИ реестра контрактов у владельца (проект):
  # реестр только в .harness/registry/contracts.tsv — судья допускается; реестра
  # нет нигде — отказ; основной реестр есть, строки предмета в нём нет (в
  # проектном пути она есть) — отказ: запасной путь основной НЕ подменяет.
  local kletka_probit=0
  zp_kletka_net_stroki || kletka_probit=1
  zp_kletka_symlink || kletka_probit=1
  zp_kletka_failref || kletka_probit=1
  zp_kletka_povtor_bez_stroki || kletka_probit=1
  zp_kletka_povtor_so_stroka || kletka_probit=1
  zp_kletka_povtor_tretiy || kletka_probit=1
  zp_kletka_povtor_chuzhaya || kletka_probit=1
  zp_kletka_povtor_tretiy_ten_imya || kletka_probit=1
  zp_kletka_povtor_obryv_ten_imya || kletka_probit=1
  zp_kletka_reestr_proekt || kletka_probit=1
  zp_kletka_reestr_net || kletka_probit=1
  zp_kletka_reestr_osnovnoy || kletka_probit=1
  zp_kletka_zamok_stroka_raz || kletka_probit=1
  zp_kletka_zamok_stroka_povtor || kletka_probit=1
  zp_kletka_zamok_stroka_chuzhaya || kletka_probit=1
  zp_kletka_zamok_stroka_neotmenyaemaya || kletka_probit=1
  zp_kletka_release_poslednij_start || kletka_probit=1
  zp_kletka_release_chuzhoy_holder || kletka_probit=1
  zp_kletka_release_filtr_posle_sootneseniya || kletka_probit=1
  zp_kletka_d39_proektny_reestr || kletka_probit=1
  zp_kletka_sankcija_polnyj_adres || kletka_probit=1
  zp_kletka_sankcija_chuzhye_pole || kletka_probit=1
  zp_kletka_sankcija_krug_ischerpan || kletka_probit=1
  zp_kletka_sankcija_ne_sankcija || kletka_probit=1
  [ "$kletka_probit" -eq 0 ] || return 1
  return 0
}

# Отчёт по клетке: имя + код возврата (сырой вывод приёмки читается по клеткам).
zp_kletka() {  # <имя-клетки> <rc>
  printf 'БАТАРЕЯ %s: клетка %s — rc %s\n' "${PROFILE_NAME:-zamok_predmeta}" "$1" "$2"
}

# (е) Первый critic НОВОГО предмета, у которого OBJECT БЕЗ файла контракта.
#     Класс риска берётся из ДЕРЕВА OBJECT: файла нет — класс НЕ ОПРЕДЕЛЁН. По
#     слову владельца 21.11 12:06 это ПРЕДУПРЕЖДЕНИЕ с записью (предмет
#     считается рисковым), а не отказ; дверь, подставляющая класс константой,
#     такой предмет пропускает БЕЗ предупреждения — клетка различает.
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
  zp_expect 0 - '(е) critic нового предмета: OBJECT без файла контракта' || return 1
  zp_est_predupr KLASS_RISKA_NET '(е) critic нового предмета: OBJECT без файла контракта' || return 1
  zp_est_warn KLASS_RISKA_NET 205 '(е) critic нового предмета: OBJECT без файла контракта' || return 1
  return 0
}

# (ж) Тот же critic, но файл контракта в OBJECT — SYMLINK: запись не читается
#     как канон → класс не определён → ПРЕДУПРЕЖДЕНИЕ с записью.
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
  zp_expect 0 - '(ж) critic нового предмета: symlink вместо файла контракта' || return 1
  zp_est_predupr KLASS_RISKA_NET '(ж) critic нового предмета: symlink вместо файла контракта' || return 1
  zp_est_warn KLASS_RISKA_NET 206 '(ж) critic нового предмета: symlink вместо файла контракта' || return 1
  return 0
}

# (з) Первый critic нового предмета, когда git НЕ ЧИТАЕТ перечень frozen-тегов
#     (for-each-ref → rc 127): ошибка инструмента ≠ пустой перечень. Дверь
#     обязана ЗАКРЫТЬСЯ (KLASS_RISKA_NET: класс не определён — предупреждение
#     с записью), а не считать перечень пустым и пойти в bootstrap: дверь,
#     трактующая ошибку как пустой перечень, читает класс из ДЕРЕВА OBJECT и
#     обходится БЕЗ предупреждения — клетка различает.
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
  zp_expect 0 - '(з) critic нового предмета: git for-each-ref недоступен' || return 1
  zp_est_predupr KLASS_RISKA_NET '(з) critic нового предмета: git for-each-ref недоступен' || return 1
  zp_est_warn KLASS_RISKA_NET 207 '(з) critic нового предмета: git for-each-ref недоступен' || return 1
  return 0
}

# (и) Второй круг ТОЙ ЖЕ роли на ТОМ ЖЕ OBJECT БЕЗ санкции SANKCIJA —
#     ИМЕНОВАННЫЙ ОТКАЗ (контракт 208, слово владельца 22.11, вариант А):
#     повтор допускается только по записанной в учёте санкции полного
#     адреса; отказ учёт не меняет и записи warn не пишет.
zp_kletka_povtor_bez_stroki() {
  zp_mir_povtora 208 || return 1
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic Critic208b 'SUBJECT=208' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(и) повтор той же роли на том же OBJECT без санкции — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(и) повтор той же роли на том же OBJECT без санкции — отказ' || return 1
  zp_net_warn OBJECT_UZHE_SUZHEN 208 \
      '(и) повтор той же роли на том же OBJECT без санкции — отказ' || return 1
  zp_uchet_nezmenen \
      '(и) повтор той же роли на том же OBJECT без санкции — отказ' || return 1
  return 0
}

# (к) Тот же повтор СО ЧАСТНОЙ строкой `РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР:` — частная
#     строка УБРАНА (её заменила общая `РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК:`, слово
#     владельца 21.11 12:06; контракт 208 — санкцией повтора она не является):
#     повтор — тот же отказ, и никакого применения разрешения в учёте.
zp_kletka_povtor_so_stroka() {
  zp_mir_povtora 208 || return 1
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic Critic208b 'SUBJECT=208' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 208 critic $ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(к) повтор той же роли со частной строкой (не действует)' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(к) повтор той же роли со частной строкой (не действует)' || return 1
  if [ "$(zp_override_schet OBJECT_UZHE_SUZHEN 208)" != '0' ]; then
    printf 'zamok_predmeta: (к) частная строка дала применение разрешения в учёте\n' >&2
    return 1
  fi
  zp_uchet_nezmenen \
      '(к) повтор той же роли со частной строкой (не действует)' || return 1
  return 0
}

# (л) ТРЕТИЙ круг той же роли на том же OBJECT — отказ (контракт 208): снятая
#     владельцем частная строка санкцией повтора НЕ является, поэтому ни второй,
#     ни третий круг не проходят; отказ учёт не меняет, круг не записывается.
zp_kletka_povtor_tretiy() {
  zp_mir_povtora 208 || return 1
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic Critic208b 'SUBJECT=208' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 208 critic $ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(л) второй круг той же роли той же строкой — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(л) второй круг той же роли той же строкой — отказ' || return 1
  zp_sdal Critic208b
  zp_event "$ZP_T/e3.json" critic Critic208c 'SUBJECT=208' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 208 critic $ZP_SHA"
  zp_sudit "$ZP_T/e3.json"
  zp_kletka '(л) третий круг той же роли той же строкой — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(л) третий круг той же роли той же строкой — отказ' || return 1
  zp_uchet_nezmenen \
      '(л) третий круг той же роли той же строкой — отказ' || return 1
  return 0
}

# (м) Частная строка с ЧУЖИМ предметом/ролью/OBJECT (и вне формата) — тем
#     более не действует: повтор — отказ (контракт 208), применения разрешения
#     в учёте нет, учёт не меняется.
zp_kletka_povtor_chuzhaya() {
  zp_mir_povtora 208 || return 1
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic Critic208b 'SUBJECT=208' "OBJECT=$ZP_SHA" \
      'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 208 critic 0000000000000000000000000000000000000000'
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(м) частная строка с чужим OBJECT' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(м) частная строка с чужим OBJECT' || return 1
  # Судья сдал (журнал с yield) — иначе следующий запрос упёрся бы в живой
  # замок прежнего судьи, а не в правило строки.
  zp_sdal Critic208b
  zp_event "$ZP_T/e3.json" critic Critic208b 'SUBJECT=208' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 208 adversary $ZP_SHA"
  zp_sudit "$ZP_T/e3.json"
  zp_kletka '(м) частная строка с чужой ролью' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(м) частная строка с чужой ролью' || return 1
  zp_sdal Critic208b
  zp_event "$ZP_T/e4.json" critic Critic208b 'SUBJECT=208' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 209 critic $ZP_SHA"
  zp_sudit "$ZP_T/e4.json"
  zp_kletka '(м) частная строка с чужим предметом' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(м) частная строка с чужим предметом' || return 1
  zp_sdal Critic208b
  zp_event "$ZP_T/e5.json" critic Critic208b 'SUBJECT=208' "OBJECT=$ZP_SHA" \
      'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 208 critic ne-40hex'
  zp_sudit "$ZP_T/e5.json"
  zp_kletka '(м) частная строка вне формата' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(м) частная строка вне формата' || return 1
  if [ "$(zp_override_schet OBJECT_UZHE_SUZHEN 208)" != '0' ]; then
    printf 'zamok_predmeta: (м) чужая частная строка дала применение разрешения в учёте\n' >&2
    return 1
  fi
  zp_uchet_nezmenen '(м) чужая частная строка' || return 1
  return 0
}

# (н) Третий круг под ТЕМ ЖЕ именем держателя, что и первый: имя держателя —
#     НЕ идентификатор круга (между сессиями имена не уникализируются).
#     Состоявшийся первый круг виден двери и под ТЕМ ЖЕ именем: повтор —
#     ИМЕНОВАННЫЙ ОТКАЗ (контракт 208), круг НЕ записывается, учёт не меняется.
#     Клетка судит ПОВЕДЕНИЕ двери (rc + отказ + неизменность учёта), а не текст
#     счётчика.
zp_kletka_povtor_tretiy_ten_imya() {
  zp_mir_povtora 210 || return 1
  local h='Critic210' n_start
  n_start="$(zp_startov 210 "$h")"
  zp_uchet_snimok || return 1
  # Второй круг ПОД ТЕМ ЖЕ ИМЕНЕМ — тот же повтор: отказ.
  zp_event "$ZP_T/e2.json" critic "$h" 'SUBJECT=210' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 210 critic $ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(н) второй круг под тем же именем держателя — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(н) второй круг под тем же именем держателя — отказ' || return 1
  if [ "$(zp_startov 210 "$h")" -ne "$n_start" ]; then
    printf 'zamok_predmeta: (н) отказ повтора записал круг START %s\n' "$h" >&2
    return 1
  fi
  zp_sdal "$h"
  # Третий круг под тем же именем — тот же отказ.
  zp_event "$ZP_T/e3.json" critic "$h" 'SUBJECT=210' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 210 critic $ZP_SHA"
  zp_sudit "$ZP_T/e3.json"
  zp_kletka '(н) третий круг под тем же именем держателя' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(н) третий круг под тем же именем держателя' || return 1
  zp_uchet_nezmenen '(н) третий круг под тем же именем держателя' || return 1
  return 0
}

# (о) Тот же повтор под тем же именем, но его RELEASE — ТЕХНИЧЕСКИЙ ОБРЫВ
#     `obryv_bez_verdikta`: обрыв закрывает только свой круг — обрыв круг НЕ
#     тратит (круг считается по учёту). Порядок наблюдений при контракте 208
#     (повтор — отказ): второй круг — отказ (первый круг жив); обрыв закрывает
#     этот первый круг — следующий запрос круг начинает заново (rc 0, круг
#     записан); после него — тот же повтор, отказ.
zp_kletka_povtor_obryv_ten_imya() {
  zp_mir_povtora 211 || return 1
  local h='Critic211' n_start
  # Второй круг ПОД ТЕМ ЖЕ ИМЕНЕМ: первый круг жив — повтор виден дверью.
  zp_event "$ZP_T/e2.json" critic "$h" 'SUBJECT=211' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 211 critic $ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(о) второй круг под тем же именем — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(о) второй круг под тем же именем — отказ' || return 1
  # Технический обрыв круга судьи: RELEASE судьи без закоммиченного вердикта.
  # Строку пишет сама дверь (--osvobodit); в офлайн-мире судью не освободить
  # (нужен ls-remote origin), поэтому строка обрыва пишется в учёт прямо — тем
  # же форматом, что пишет дверь (формат учёта прежний).
  jq -nc --arg t RELEASE --arg r dev-harness --arg s 211 --arg h "$h" \
      --arg p obryv_bez_verdikta --arg at '2026-11-21T00:00:00Z' \
      '{t:$t,repoId:$r,subjectId:$s,holder:$h,prichina:$p,at:$at}' \
      >> "$ZP_T/sost/uchet.jsonl"
  n_start="$(zp_startov 211 "$h")"
  # Запрос без строки: обрыв круг не тратит — дверь считает круг НУЛЕВЫМ, круг
  # начинается заново (допуск), и круг записывается.
  zp_event "$ZP_T/e3.json" critic "$h" 'SUBJECT=211' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e3.json"
  zp_kletka '(о) запрос без строки после обрыва повтора под тем же именем' "$ZP_RC"
  zp_expect 0 - \
      '(о) запрос без строки после обрыва повтора под тем же именем' || return 1
  if [ "$(zp_startov 211 "$h")" -le "$n_start" ]; then
    printf 'zamok_predmeta: (о) круг после обрыва не записан START %s\n' "$h" >&2
    return 1
  fi
  # Запрос со строкой: круг состоялся — тот же повтор, отказ.
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e4.json" critic "$h" 'SUBJECT=211' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 211 critic $ZP_SHA"
  zp_sudit "$ZP_T/e4.json"
  zp_kletka '(о) запрос со строкой после обрыва повтора под тем же именем' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(о) запрос со строкой после обрыва повтора под тем же именем' || return 1
  zp_uchet_nezmenen \
      '(о) запрос со строкой после обрыва повтора под тем же именем' || return 1
  return 0
}

# (п) Проектная раскладка реестра контрактов: путь реестра ОБЪЯВЛЕН профилем
#     (workflowPaths.registry = .harness/registry), строка реестра лежит
#     ТОЛЬКО там (в registry/ такого файла нет), у предмета аннотированный
#     frozen-тег и строка реестра → судья ДОПУСКАЕТСЯ дверью (rc 0 PUSCHEM) и
#     класс определён (предупреждения KLASS_RISKA_NET нет). Дверь, читающая
#     реестр только по реестру репозитория, отказывает «закреплённый frozen
#     недоступен» — клетка различает.
zp_kletka_reestr_proekt() {
  zp_world || return 1
  zp_kandidat 212 || return 1
  zp_avtor_sdal 212 Avtor212 "$ZP_WT" "$ZP_BR" || return 1
  local tagobj
  zp_reestr_snyat || return 1
  tagobj="$(zp_vladelec_frozen 212)" || return 1
  zp_reestr_stroka '.harness/registry/contracts.tsv' 212 "$tagobj" || return 1
  zp_profil_reestr "$ZP_T/repo" '.harness/registry' || return 1
  zp_event "$ZP_T/e9.json" adversary Adv212 'SUBJECT=212' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e9.json"
  zp_kletka '(п) реестр проекта только в .harness/registry/contracts.tsv' "$ZP_RC"
  zp_expect 0 - '(п) реестр проекта только в .harness/registry/contracts.tsv' || return 1
  if ! printf '%s' "$ZP_OUT" | grep -Fq 'PUSCHEM'; then
    printf 'zamok_predmeta: (п) реестр проекта: нет PUSCHEM; вывод: %s\n' "$ZP_OUT" >&2
    return 1
  fi
  # Пин прочитан из ОБЪЯВЛЕННОГО профилем реестра: предупреждения о
  # непрочитанном frozen нет (иначе клетка прошла бы вхолостую — «рисковый по
  # умолчанию» при непрочитанном классе).
  zp_net_predupr KLASS_RISKA_NET '(п) реестр проекта только в .harness/registry/contracts.tsv' || return 1
  return 0
}

# (р) Реестра нет НИГДЕ (ни registry/, ни .harness/registry/) — предмет с
#     аннотированным frozen-тегом: класс риска НЕ ОПРЕДЕЛЁН → по слову
#     владельца 21.11 12:06 это ПРЕДУПРЕЖДЕНИЕ с записью (предмет считается
#     рисковым), а не отказ. Клетка — негатив к (п): запасной путь не является
#     «созданием» реестра, и предупреждение остаётся.
zp_kletka_reestr_net() {
  zp_world || return 1
  zp_kandidat 213 || return 1
  zp_avtor_sdal 213 Avtor213 "$ZP_WT" "$ZP_BR" || return 1
  zp_reestr_snyat || return 1
  zp_vladelec_frozen 213 >/dev/null || return 1
  zp_event "$ZP_T/e10.json" adversary Adv213 'SUBJECT=213' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e10.json"
  zp_kletka '(р) реестра нет нигде' "$ZP_RC"
  zp_expect 0 - '(р) реестра нет нигде' || return 1
  zp_est_predupr KLASS_RISKA_NET '(р) реестра нет нигде' || return 1
  zp_est_warn KLASS_RISKA_NET 213 '(р) реестра нет нигде' || return 1
  return 0
}

# (с) Реестр репозитория ЕСТЬ, строки предмета в нём НЕТ, а в НЕОБЪЯВЛЕННОМ
#     каталоге (.harness/registry/) строка есть → класс НЕ ОПРЕДЕЛЁН:
#     ПРЕДУПРЕЖДЕНИЕ с записью. Путь реестра — объявленный профилем (без
#     профиля — реестр репозитория); файл в необъявленном каталоге реестром
#     НЕ является, и дверь его не подменяет (иначе дверь признала бы запись
#     чужого реестра) — предупреждение остаётся, класс не читается.
zp_kletka_reestr_osnovnoy() {
  zp_world || return 1
  zp_kandidat 214 || return 1
  zp_avtor_sdal 214 Avtor214 "$ZP_WT" "$ZP_BR" || return 1
  local tagobj
  zp_reestr_snyat || return 1
  tagobj="$(zp_vladelec_frozen 214)" || return 1
  # основной путь — с чужой строкой (предмета 214 в нём нет)
  zp_reestr_stroka 'registry/contracts.tsv' 999 "$tagobj" || return 1
  # проектный путь — со строкой предмета: перекрывать основной он не вправе
  zp_reestr_stroka '.harness/registry/contracts.tsv' 214 "$tagobj" || return 1
  zp_event "$ZP_T/e11.json" adversary Adv214 'SUBJECT=214' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e11.json"
  zp_kletka '(с) основной реестр есть, строки предмета нет' "$ZP_RC"
  zp_expect 0 - '(с) основной реестр есть, строки предмета нет' || return 1
  zp_est_predupr KLASS_RISKA_NET '(с) основной реестр есть, строки предмета нет' || return 1
  zp_est_warn KLASS_RISKA_NET 214 '(с) основной реестр есть, строки предмета нет' || return 1
  return 0
}

# ПАУЗА предмета у владельца (реестр registry/pauzy.tsv) — коммит только при
# изменении содержимого (иначе git commit без изменений возвращает rc 1).
zp_pauza_predmet() {  # <NNN>
  local n="$1"
  mkdir -p "$ZP_T/repo/registry" || return 1
  printf '%s\t2026-11-21\tвладелец\tпозже\n' "$n" > "$ZP_T/repo/registry/pauzy.tsv" || return 1
  git -C "$ZP_T/repo" add -A || return 1
  if ! git -C "$ZP_T/repo" diff --cached --quiet; then
    git -C "$ZP_T/repo" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
        commit -q -m "pauza $n" || return 1
  fi
  return 0
}

# ── ОБЩАЯ СТРОКА ВЛАДЕЛЬЦА (слово владельца 21.11 12:06) ──────────────────
# `РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: <NNN> <КОД> [<OBJECT 40hex>]` — ОДНОРАЗОВОЕ
# разрешение ровно одного отказа для предмета (и OBJECT, если указан).
# Четыре клетки: (а) пропуск один раз; (б) повтор — отказ; (в) чужие
# предмет/код/OBJECT — отказ; (г) отказ, который строка не отменяет
# (изоляция рабочего), — отказ.

# (а) Пропуск ровно один раз: предмет на ПАУЗЕ + строка владельца → rc 0,
#     START пишется, применение строки — в учёте (override).
zp_kletka_zamok_stroka_raz() {
  zp_world || return 1
  zp_pauza_predmet 215 || return 1
  zp_event "$ZP_T/e12.json" architect Arch215 \
      'SUBJECT=215' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/215/avtor' \
      'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 215 PAUZA_VLADELTSA'
  zp_sudit "$ZP_T/e12.json"
  zp_kletka '(а) общая строка: пропуск один раз' "$ZP_RC"
  zp_expect 0 - '(а) общая строка: пропуск один раз' || return 1
  zp_est_override PAUZA_VLADELTSA 215 '(а) общая строка: пропуск один раз' || return 1
  if [ "$(zp_startov 215 Arch215)" != '1' ]; then
    printf 'zamok_predmeta: (а) общая строка: START рабочего не записан\n' >&2
    return 1
  fi
  return 0
}

# (б) ПОВТОР той же строки — отказ (строка одноразовая): применение в учёте
#     уже есть, второй раз пропускать нельзя; учёт не меняется.
zp_kletka_zamok_stroka_povtor() {
  zp_world || return 1
  zp_pauza_predmet 215 || return 1
  zp_event "$ZP_T/e12.json" architect Arch215 \
      'SUBJECT=215' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/215/avtor' \
      'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 215 PAUZA_VLADELTSA'
  zp_sudit "$ZP_T/e12.json"
  if [ "$ZP_RC" -ne 0 ]; then
    printf 'zamok_predmeta: (б) первый пропуск не состоялся (rc %s): %s\n' "$ZP_RC" "$ZP_OUT" >&2
    return 1
  fi
  local before
  before="$(cat "$ZP_T/sost/uchet.jsonl")"
  zp_event "$ZP_T/e13.json" architect Arch215b \
      'SUBJECT=215' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/215/avtor' \
      'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 215 PAUZA_VLADELTSA'
  zp_sudit "$ZP_T/e13.json"
  zp_kletka '(б) общая строка: повтор — отказ' "$ZP_RC"
  zp_expect 1 PAUZA_VLADELTSA '(б) общая строка: повтор — отказ' || return 1
  if [ "$(cat "$ZP_T/sost/uchet.jsonl")" != "$before" ]; then
    printf 'zamok_predmeta: (б) отказ повторной строки изменил учёт\n' >&2
    return 1
  fi
  return 0
}

# (в) ЧУЖАЯ строка (чужой предмет, чужой код, чужой OBJECT) — разрешения нет:
#     отказ как без строки.
zp_kletka_zamok_stroka_chuzhaya() {
  zp_world || return 1
  zp_pauza_predmet 215 || return 1
  zp_event "$ZP_T/e12.json" architect Arch215 \
      'SUBJECT=215' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/215/avtor' \
      'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 216 PAUZA_VLADELTSA'
  zp_sudit "$ZP_T/e12.json"
  zp_kletka '(в) общая строка: чужой предмет — отказ' "$ZP_RC"
  zp_expect 1 PAUZA_VLADELTSA '(в) общая строка: чужой предмет — отказ' || return 1
  zp_event "$ZP_T/e13.json" architect Arch215 \
      'SUBJECT=215' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/215/avtor' \
      'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 215 PEREDACHA_REMOTE'
  zp_sudit "$ZP_T/e13.json"
  zp_kletka '(в) общая строка: чужой код — отказ' "$ZP_RC"
  zp_expect 1 PAUZA_VLADELTSA '(в) общая строка: чужой код — отказ' || return 1
  zp_event "$ZP_T/e14.json" architect Arch215 \
      'SUBJECT=215' "WORKTREE=$ZP_T/wt" 'BRANCH=wip/215/avtor' \
      'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 215 PAUZA_VLADELTSA 1234567890123456789012345678901234567890'
  zp_sudit "$ZP_T/e14.json"
  zp_kletka '(в) общая строка: чужой OBJECT — отказ' "$ZP_RC"
  zp_expect 1 PAUZA_VLADELTSA '(в) общая строка: чужой OBJECT — отказ' || return 1
  if [ "$(zp_override_schet PAUZA_VLADELTSA 215)" != '0' ]; then
    printf 'zamok_predmeta: (в) чужая строка дала применение разрешения в учёте\n' >&2
    return 1
  fi
  return 0
}

# (г) Строка на отказ, который НЕ отменяется (изоляция рабочего) — отказ
#     NE_IZOLIROVAN: цена изоляции — реальный вред, строка её не отменяет.
#     Событие — БЕЗ поля isolated (иначе изоляция соблюдена и гейт не сработает).
zp_kletka_zamok_stroka_neotmenyaemaya() {
  zp_world || return 1
  jq -cn --arg a architect --arg n Arch215 \
      --arg t "SUBJECT=215
WORKTREE=$ZP_T/wt
BRANCH=wip/215/avtor
РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 215 NE_IZOLIROVAN" \
      '{agent:$a,name:$n,task:$t}' > "$ZP_T/e12.json"
  zp_sudit "$ZP_T/e12.json"
  zp_kletka '(г) общая строка: неотменяемый отказ — отказ' "$ZP_RC"
  zp_expect 1 NE_IZOLIROVAN '(г) общая строка: неотменяемый отказ — отказ' || return 1
  if [ "$(zp_override_schet NE_IZOLIROVAN 215)" != '0' ]; then
    printf 'zamok_predmeta: (г) неотменяемый отказ дал применение разрешения в учёте\n' >&2
    return 1
  fi
  return 0
}

# ── сопоставление START↔RELEASE и проектный реестр D39 (клетки р1–р4) ──────
# Перенос клеток ремонта по FAIL Adv140V9 (ветка #1173, источник f728e83553)
# на дверь УПРОЩЕНИЯ ЗАМКА (A2). В A2 отказ OBJECT_UZHE_SUZHEN — ПРЕДУПРЕЖДЕНИЕ
# с записью (rc 0), поэтому клетки судят РАЗЛИЧИЕ честной и мутантной двери:
# мутант сопоставления START↔RELEASE считает круг НУЛЕВЫМ → предупреждения о
# повторе нет вовсе (и записи warn нет); честная дверь пишет и предупреждение,
# и запись с номером повтора 2 (первый круг жив). Место сопоставления в A2
# прежнее — функция подсчёта кругов krugov_suda в scripts/zamok_predmeta.sh.

# (р1) Промежуточный START того же держателя (другая роль/OBJECT) и обрыв
#     (`obryv_bez_verdikta`) того же держателя: RELEASE закрывает ПОСЛЕДНИЙ
#     открытый START СВОЕГО holder'а — то есть промежуточный, а НЕ состоявшийся
#     первый круг судьи. Первый круг не стёрт → дверь видит повтор круга:
#     ОТКАЗ OBJECT_UZHE_SUZHEN (контракт 208), учёт не меняется.
#     Дверь, закрывающая ПЕРВЫЙ открытый START держателя (мутант `first`),
#     стёрла бы первый круг — отказа не было бы вовсе (повтор прошёл бы).
zp_kletka_release_poslednij_start() {
  zp_mir_povtora 216 || return 1
  zp_start_zapis 216 'Critic216' 'sudja' 'adversary' \
      '1111111111111111111111111111111111111111' "$ZP_WT" "$ZP_BR" || return 1
  zp_release_zapis 216 'Critic216' 'obryv_bez_verdikta' || return 1
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic 'Critic216b' 'SUBJECT=216' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(р1) обрыв закрывает ПОСЛЕДНИЙ открытый START своего держателя' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(р1) обрыв закрывает ПОСЛЕДНИЙ открытый START своего держателя' || return 1
  zp_net_warn OBJECT_UZHE_SUZHEN 216 \
      '(р1) обрыв закрывает ПОСЛЕДНИЙ открытый START своего держателя' || return 1
  zp_uchet_nezmenen \
      '(р1) обрыв закрывает ПОСЛЕДНИЙ открытый START своего держателя' || return 1
  return 0
}

# (р2) RELEASE ЧУЖОГО держателя: он закрывает последний открытый START СВОЕГО
#     holder'а, и открытый START круга судьи (другой держатель) закрывать не
#     вправе. Поэтому состоявшийся первый круг судьи жив → дверь видит повтор:
#     ОТКАЗ OBJECT_UZHE_SUZHEN (контракт 208), учёт не меняется. Дверь,
#     закрывающая последний открытый START вообще (без holder'а; мутант
#     `foreignholder`), стёрла бы круг судьи — отказа не было бы (повтор прошёл бы).
zp_kletka_release_chuzhoy_holder() {
  zp_mir_povtora 217 || return 1
  zp_release_zapis 217 'Avtor217' 'obryv_bez_verdikta' || return 1
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic 'Critic217b' 'SUBJECT=217' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(р2) RELEASE чужого держателя не закрывает открытый START круга' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(р2) RELEASE чужого держателя не закрывает открытый START круга' || return 1
  zp_net_warn OBJECT_UZHE_SUZHEN 217 \
      '(р2) RELEASE чужого держателя не закрывает открытый START круга' || return 1
  zp_uchet_nezmenen \
      '(р2) RELEASE чужого держателя не закрывает открытый START круга' || return 1
  return 0
}

# (р3) Соотнесение START↔RELEASE при промежуточном START ДРУГОГО класса/роли/
#     OBJECT: RELEASE соотносится по ПОСЛЕДОВАТЕЛЬНОСТИ START своего holder'а,
#     а фильтр по роли/OBJECT/классу применяется ПОСЛЕ соотнесения. Промежуточный
#     START другого класса (rabochiy) поглощает обрыв, первый круг судьи
#     (sudja/critic/OBJECT) остаётся → дверь видит повтор: ОТКАЗ
#     OBJECT_UZHE_SUZHEN (контракт 208), учёт не меняется. Дверь, отбирающая START
#     по роли/OBJECT/классу ДО соотнесения (мутант `preselect`) либо закрывшая
#     ПЕРВЫЙ открытый START (мутант `first`), закрыла бы первый круг —
#     отказа не было бы (повтор прошёл бы).
zp_kletka_release_filtr_posle_sootneseniya() {
  zp_mir_povtora 218 || return 1
  zp_start_zapis 218 'Critic218' 'rabochiy' 'implementer' \
      '2222222222222222222222222222222222222222' "$ZP_WT" "$ZP_BR" || return 1
  zp_release_zapis 218 'Critic218' 'obryv_bez_verdikta' || return 1
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic 'Critic218b' 'SUBJECT=218' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(р3) фильтр по роли/OBJECT/классу — ПОСЛЕ соотнесения START↔RELEASE' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN \
      '(р3) фильтр по роли/OBJECT/классу — ПОСЛЕ соотнесения START↔RELEASE' || return 1
  zp_net_warn OBJECT_UZHE_SUZHEN 218 \
      '(р3) фильтр по роли/OBJECT/классу — ПОСЛЕ соотнесения START↔RELEASE' || return 1
  zp_uchet_nezmenen \
      '(р3) фильтр по роли/OBJECT/классу — ПОСЛЕ соотнесения START↔RELEASE' || return 1
  return 0
}

# ── грамматика записи санкции SANKCIJA (контракт 208, инвариант 6) ─────────
# Санкция повтора — строка учёта {"t":"SANKCIJA","repoId":…,"subjectId":…,
# "rol":…,"object":…} с ПОЛНЫМ адресом, равным событию; сравнение ЛИТЕРАЛЬНОЕ,
# алфавиты замкнуты (repoId — идентификатор репозитория, subjectId — [0-9]{3},
# rol — роль из JUDGES, object — 40-hex). Клетки ниже — гигиена ПАРСИНГА этой
# записи: подходящая запись допускает повтор; неподходящая (чужое поле адреса,
# чужой формат, чужой регистр, лишний пробел, «склеенное» значение, запись
# вовсе не о санкции) — санкцией НЕ является.

# (т) Санкция с ПОЛНЫМ адресом — повтор той же роли на том же OBJECT
#     ДОПУСКАЕТСЯ (rc 0), круг записывается. Дверь, читающая санкцию не по
#     полному адресу (или не читающая её вовсе), отказала бы в повторе.
zp_kletka_sankcija_polnyj_adres() {
  zp_mir_povtora 219 || return 1
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 219 --arg ro critic \
      --arg o "$ZP_SHA" \
      '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')" || return 1
  zp_event "$ZP_T/e2.json" critic Critic219b 'SUBJECT=219' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(т) санкция SANKCIJA с полным адресом — повтор допущен' "$ZP_RC"
  zp_expect 0 - '(т) санкция SANKCIJA с полным адресом — повтор допущен' || return 1
  if [ "$(zp_startov 219 Critic219b)" -lt 1 ]; then
    printf 'zamok_predmeta: (т) допущенный повтор не записал круга START Critic219b\n' >&2
    return 1
  fi
  return 0
}

# (у) Санкция с ЧУЖИМ полем адреса (OBJECT / роль / предмет / repoId) — санкцией
#     НЕ является: адрес не равен событию. Повтор — отказ, учёт не меняется.
zp_kletka_sankcija_chuzhye_pole() {
  local chuhoi='4444444444444444444444444444444444444444'
  zp_mir_povtora 220 || return 1
  # (у1) чужой OBJECT.
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 220 --arg ro critic \
      --arg o "$chuhoi" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic Critic220b 'SUBJECT=220' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(у) санкция с чужим OBJECT — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(у) санкция с чужим OBJECT — отказ' || return 1
  zp_uchet_nezmenen '(у) санкция с чужим OBJECT — отказ' || return 1
  # (у2) чужая роль (роль из JUDGES: critic/adversary/reviewer).
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 220 --arg ro reviewer \
      --arg o "$ZP_SHA" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e3.json" critic Critic220c 'SUBJECT=220' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e3.json"
  zp_kletka '(у) санкция с чужой ролью — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(у) санкция с чужой ролью — отказ' || return 1
  zp_uchet_nezmenen '(у) санкция с чужой ролью — отказ' || return 1
  # (у3) чужой предмет.
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 225 --arg ro critic \
      --arg o "$ZP_SHA" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e4.json" critic Critic220d 'SUBJECT=220' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e4.json"
  zp_kletka '(у) санкция с чужим предметом — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(у) санкция с чужим предметом — отказ' || return 1
  zp_uchet_nezmenen '(у) санкция с чужим предметом — отказ' || return 1
  # (у4) чужой repoId (пространство имён замка).
  zp_uchet_stroka "$(jq -nc --arg r other-repo --arg s 220 --arg ro critic \
      --arg o "$ZP_SHA" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e5.json" critic Critic220e 'SUBJECT=220' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e5.json"
  zp_kletka '(у) санкция с чужим repoId — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(у) санкция с чужим repoId — отказ' || return 1
  zp_uchet_nezmenen '(у) санкция с чужим repoId — отказ' || return 1
  return 0
}

# (ш) Санкция есть, но круг ИСЧЕРПАН: допуск — только пока кругов суда один
#     (инвариант 6). Второй круг санкцией допускается (и круг записывается);
#     после его закрытия кругов два — следующий повтор отказ, санкция в учёте
#     не помогает.
zp_kletka_sankcija_krug_ischerpan() {
  zp_mir_povtora 221 || return 1
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 221 --arg ro critic \
      --arg o "$ZP_SHA" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_event "$ZP_T/e2.json" critic Critic221b 'SUBJECT=221' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(ш) санкция при неисчерпанном круге — повтор допущен' "$ZP_RC"
  zp_expect 0 - '(ш) санкция при неисчерпанном круге — повтор допущен' || return 1
  if [ "$(zp_startov 221 Critic221b)" -lt 1 ]; then
    printf 'zamok_predmeta: (ш) допущенный повтор не записал круга START Critic221b\n' >&2
    return 1
  fi
  zp_sdal Critic221b
  # Круг закрыт собственным RELEASE holder'а: кругов суда стало два.
  zp_release_zapis 221 Critic221b 'verdikt_zakommiten' || return 1
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e3.json" critic Critic221c 'SUBJECT=221' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e3.json"
  zp_kletka '(ш) санкция при исчерпанном круге — отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(ш) санкция при исчерпанном круге — отказ' || return 1
  zp_uchet_nezmenen '(ш) санкция при исчерпанном круге — отказ' || return 1
  return 0
}

# (щ) Запись учёта, санкцией НЕ являющаяся: SLOVO (лимит группы) и снятая
#     владельцем частная строка задания `РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР:` — ни то,
#     ни другое повтор не разрешает. Повтор — отказ, учёт не меняется.
zp_kletka_sankcija_ne_sankcija() {
  zp_mir_povtora 222 || return 1
  # (щ1) SLOVO в учёте.
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 222 \
      '{t:"SLOVO",repoId:$r,subjectId:$s}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic Critic222b 'SUBJECT=222' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(щ) SLOVO в учёте — не санкция повтора, отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(щ) SLOVO в учёте — не санкция повтора, отказ' || return 1
  zp_uchet_nezmenen '(щ) SLOVO в учёте — не санкция повтора, отказ' || return 1
  # (щ2) снятая владельцем частная строка задания.
  zp_event "$ZP_T/e3.json" critic Critic222c 'SUBJECT=222' "OBJECT=$ZP_SHA" \
      "РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: 222 critic $ZP_SHA"
  zp_sudit "$ZP_T/e3.json"
  zp_kletka '(щ) снятая частная строка — не санкция, отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(щ) снятая частная строка — не санкция, отказ' || return 1
  zp_uchet_nezmenen '(щ) снятая частная строка — не санкция, отказ' || return 1
  return 0
}

# (ю) Грамматика значений записи: метасимволы, чужой регистр, лишний пробел,
#     неверная длина — санкцией НЕ являются (сравнение литеральное, склейки
#     из чужого текста нет). Повтор — отказ, учёт не меняется.
zp_kletka_sankcija_grammatika() {
  zp_mir_povtora 223 || return 1
  # (ю1) object короче 40-hex.
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 223 --arg ro critic \
      --arg o "${ZP_SHA%?}" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic Critic223b 'SUBJECT=223' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(ю) object не 40-hex — не санкция, отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(ю) object не 40-hex — не санкция, отказ' || return 1
  zp_uchet_nezmenen '(ю) object не 40-hex — не санкция, отказ' || return 1
  # (ю2) subjectId с метасимволами.
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s '223 OR 1=1' --arg ro critic \
      --arg o "$ZP_SHA" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e3.json" critic Critic223c 'SUBJECT=223' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e3.json"
  zp_kletka '(ю) subjectId с метасимволами — не санкция, отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(ю) subjectId с метасимволами — не санкция, отказ' || return 1
  zp_uchet_nezmenen '(ю) subjectId с метасимволами — не санкция, отказ' || return 1
  # (ю3) роль вне JUDGES (с метасимволом).
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 223 --arg ro 'critic.*' \
      --arg o "$ZP_SHA" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e4.json" critic Critic223d 'SUBJECT=223' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e4.json"
  zp_kletka '(ю) роль вне JUDGES — не санкция, отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(ю) роль вне JUDGES — не санкция, отказ' || return 1
  zp_uchet_nezmenen '(ю) роль вне JUDGES — не санкция, отказ' || return 1
  # (ю4) тип записи в чужом регистре.
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 223 --arg ro critic \
      --arg o "$ZP_SHA" '{t:"sankcija",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e5.json" critic Critic223e 'SUBJECT=223' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e5.json"
  zp_kletka '(ю) тип записи в чужом регистре — не санкция, отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(ю) тип записи в чужом регистре — не санкция, отказ' || return 1
  zp_uchet_nezmenen '(ю) тип записи в чужом регистре — не санкция, отказ' || return 1
  # (ю5) repoId с лишним пробелом.
  zp_uchet_stroka "$(jq -nc --arg r 'dev-harness ' --arg s 223 --arg ro critic \
      --arg o "$ZP_SHA" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e6.json" critic Critic223f 'SUBJECT=223' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e6.json"
  zp_kletka '(ю) repoId с лишним пробелом — не санкция, отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(ю) repoId с лишним пробелом — не санкция, отказ' || return 1
  zp_uchet_nezmenen '(ю) repoId с лишним пробелом — не санкция, отказ' || return 1
  return 0
}

# (к1) «СКЛЕЕННОЕ» значение поля: значение несёт хвост соседнего поля
#      (40-hex и роль через пробел) — дверь не должна ни обрезать, ни
#      разобрать значение по разделителю: санкцией такая запись НЕ является.
zp_kletka_sankcija_skleennyj_znach() {
  zp_mir_povtora 224 || return 1
  # (к1а) object = 40-hex + пробел + роль.
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 224 --arg ro critic \
      --arg o "$ZP_SHA critic" \
      '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e2.json" critic Critic224b 'SUBJECT=224' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e2.json"
  zp_kletka '(к1а) object «склеен» с ролью — не санкция, отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(к1а) object «склеен» с ролью — не санкция, отказ' || return 1
  zp_uchet_nezmenen '(к1а) object «склеен» с ролью — не санкция, отказ' || return 1
  # (к1б) роль = роль + пробел + 40-hex.
  zp_uchet_stroka "$(jq -nc --arg r dev-harness --arg s 224 --arg ro "critic $ZP_SHA" \
      --arg o "$ZP_SHA" '{t:"SANKCIJA",repoId:$r,subjectId:$s,rol:$ro,object:$o}')"
  zp_uchet_snimok || return 1
  zp_event "$ZP_T/e3.json" critic Critic224c 'SUBJECT=224' "OBJECT=$ZP_SHA"
  zp_sudit "$ZP_T/e3.json"
  zp_kletka '(к1б) роль «склеена» с OBJECT — не санкция, отказ' "$ZP_RC"
  zp_expect 1 OBJECT_UZHE_SUZHEN '(к1б) роль «склеена» с OBJECT — не санкция, отказ' || return 1
  zp_uchet_nezmenen '(к1б) роль «склеена» с OBJECT — не санкция, отказ' || return 1
  return 0
}

# ── проверяемая передача (D39): проектный реестр контрактов ─────────────────
# Путь реестра предмета у владельца — объявленный профилем
# (workflowPaths.registry = .harness/registry; без профиля — реестр
# репозитория; та же раскладка, что и в клетках (п)(р)(с)).
# [D39] версия frozen берётся из реестра В ДЕРЕВЕ СВИДЕТЕЛЬСТВА: реестр —
# объявленный профилем путь. Дверь, читающая реестр только по реестру
# репозитория, отказала бы «точная frozen-версия не удостоверена» —
# клетка (р4) различает.

# Вызов двери в режиме проверяемой передачи.
zp_peredat() {  # <репозиторий> <NNN> <коммит-свидетельство> → ZP_OUT, ZP_RC
  ZP_OUT="$(bash "$ZP_SUBJ" --peredat --sostojanie "$ZP_T/sost" \
      --zhurnaly "$ZP_T/zhurnaly" --repo "$1" "$2" "$3" 2>&1)"
  ZP_RC=$?
}

# Мир проверяемой передачи: продуктовый worktree (внешний продукт, иной
# канонический remote), рабочий START автора в учёте с журналом со сдачей,
# аннотированный frozen-тег в продукте и коммит-свидетельство на origin/main
# станции. Реестр предмета — ПРОЕКТНЫЙ: путь объявлен профилем
# (workflowPaths.registry = .harness/registry), строка лежит ТОЛЬКО в
# .harness/registry/contracts.tsv (в registry/ такого файла нет).
# Печатает sha коммита-свидетельства.
zp_mir_peredachi() {  # <NNN>
  local n="$1" repo wt br obj pobj pcommit worker digest receipt
  repo="$ZP_T/repo4"
  rm -rf "$repo"; mkdir -p "$repo"
  git -C "$repo" init -q . 2>/dev/null || return 1
  git -C "$repo" remote add origin 'ssh://git@github.com/a3ka/dev-harness.git' || return 1
  git -C "$repo" -c user.name=b -c user.email=b@t -c commit.gpgsign=false \
      commit -q --allow-empty -m w || return 1
  # Продукт: иной канонический remote, frozen-тег и доставленный результат.
  wt="$ZP_T/prod$n"
  rm -rf "$wt"; mkdir -p "$wt/contracts"
  git -C "$wt" init -q . 2>/dev/null || return 1
  git -C "$wt" remote add origin 'ssh://git@github.com/a3ka/Complior-mob.git' || return 1
  git -C "$wt" -c user.name=implementer -c user.email=i@t -c commit.gpgsign=false \
      checkout -q -b frozen-owner 2>/dev/null || return 1
  printf 'КЛАСС РИСКА: обычный\n' > "$wt/contracts/$n-product.md" || return 1
  git -C "$wt" add -A
  git -C "$wt" -c user.name=implementer -c user.email=i@t -c commit.gpgsign=false \
      commit -q -m 'product frozen' || return 1
  git -C "$wt" -c user.name=implementer -c user.email=i@t -c tag.gpgsign=false \
      tag -a "frozen/contracts/$n/1" -m frozen || return 1
  pobj="$(git -C "$wt" rev-parse "refs/tags/frozen/contracts/$n/1")" || return 1
  pcommit="$(git -C "$wt" rev-parse "refs/tags/frozen/contracts/$n/1^{commit}")" || return 1
  br="wip/$n/implementer"
  git -C "$wt" -c user.name=implementer -c user.email=i@t -c commit.gpgsign=false \
      checkout -q -b "$br" || return 1
  printf 'real delivered change\n' > "$wt/product.txt" || return 1
  git -C "$wt" add -A
  git -C "$wt" -c user.name=implementer -c user.email=i@t -c commit.gpgsign=false \
      commit -q -m delivered || return 1
  obj="$(git -C "$wt" rev-parse HEAD)" || return 1
  # Рабочий START автора в учёте + журнал со сдачей.
  jq -nc --arg s "$n" --arg h "Impl$n" --arg w "$wt" --arg b "$br" --arg o "$obj" \
      '{t:"START",repoId:"dev-harness",subjectId:$s,group:"harness",holder:$h,
        klass:"rabochij",rol:"implementer",object:$o,worktree:$w,branch:$b,
        at:"2026-11-21T00:00:00Z"}' >> "$ZP_T/sost/uchet.jsonl"
  zp_sdal "Impl$n"
  worker="$(jq -cSrs --arg r dev-harness --arg n "$n" \
      '[.[] | select(.t=="START" and .repoId==$r and .subjectId==$n and .klass=="rabochij")] | last // empty' \
      "$ZP_T/sost/uchet.jsonl")" || return 1
  digest="$(printf '%s' "$worker" | sha256sum | cut -d' ' -f1)" || return 1
  # Свидетельство — ровно поля схемы двери.
  zp_profil_reestr "$repo" '.harness/registry' || return 1
  mkdir -p "$repo/registry/dostavki" "$repo/.harness/registry" || return 1
  jq -cn --arg r dev-harness --arg n "$n" --arg h "Impl$n" --arg ws "$digest" \
      --arg cr 'ssh://git@github.com/a3ka/Complior-mob.git' --arg wt "$wt" --arg br "$br" \
      --arg o "$obj" --arg ft "frozen/contracts/$n/1" --arg fo "$pobj" --arg fc "$pcommit" \
      '{version:1,repoId:$r,subjectId:$n,holder:$h,author:"implementer",workerStart:$ws,
        canonicalRemote:$cr,worktree:$wt,branch:$br,object:$o,frozenTag:$ft,
        frozenObject:$fo,frozenCommit:$fc}' > "$repo/registry/dostavki/$n.json" || return 1
  # ПРОЕКТНЫЙ реестр: строка предмета ТОЛЬКО в .harness/registry/contracts.tsv.
  printf '%s → %s\n' "$n" "$pobj" > "$repo/.harness/registry/contracts.tsv" || return 1
  git -C "$repo" add -A || return 1
  git -C "$repo" -c user.name=orchestrator -c user.email=o@t -c commit.gpgsign=false \
      commit -q -m receipt || return 1
  receipt="$(git -C "$repo" rev-parse HEAD)" || return 1
  git -C "$repo" update-ref refs/remotes/origin/main "$receipt" || return 1
  printf '%s' "$receipt"
}

# (р4) D39 с ПРОЕКТНЫМ реестром: путь реестра объявлен профилем
#     (workflowPaths.registry = .harness/registry), строка предмета лежит
#     ТОЛЬКО в .harness/registry/contracts.tsv (в registry/ такого файла нет) —
#     проверяемая передача ПРИНЯТА (rc 0 PEREDANO). В A2 «точная frozen-версия
#     не удостоверена» — ПРЕДУПРЕЖДЕНИЕ с записью, а не отказ, поэтому различие
#     честной и мутантной двери — НАЛИЧИЕ этого предупреждения (и записи
#     warn): честная дверь прочитала объявленный профилем реестр —
#     предупреждения нет; дверь, читающая реестр только по реестру репозитория
#     (мутант `reg_put`), выдаст «ПРЕДУПРЕЖДЕНИЕ: KLASS_RISKA_NET: проверяемая
#     передача: точная frozen-версия не удостоверена» и запишет warn.
# Требуется python3 с jsonschema: без него дверь отвечает NOT_IMPLEMENTED, и
# клетка не измерена — это НЕ «класс закрыт честно» (сообщается явно).
zp_kletka_d39_proektny_reestr() {
  zp_world || return 1
  if ! python3 -c 'import jsonschema' >/dev/null 2>&1; then
    printf 'zamok_predmeta: (р4) D39 с проектным реестром: python3/jsonschema недоступны — клетка НЕ измерена\n' >&2
    return 1
  fi
  local receipt
  receipt="$(zp_mir_peredachi 219)" || return 1
  zp_peredat "$ZP_T/repo4" 219 "$receipt"
  zp_kletka '(р4) D39 с проектным реестром: передача принята' "$ZP_RC"
  zp_expect 0 - '(р4) D39 с проектным реестром: передача принята' || return 1
  if ! printf '%s' "$ZP_OUT" | grep -Fq 'PEREDANO'; then
    printf 'zamok_predmeta: (р4) D39 с проектным реестром: нет PEREDANO; вывод: %s\n' \
        "$ZP_OUT" >&2
    return 1
  fi
  # Честная дверь прочитала ПРОЕКТНЫЙ реестр: предупреждения о неудостоверенной
  # frozen-версии нет (и записи warn нет).
  zp_net_predupr KLASS_RISKA_NET '(р4) D39 с проектным реестром: передача принята' || return 1
  zp_net_warn KLASS_RISKA_NET 219 '(р4) D39 с проектным реестром: передача принята' || return 1
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
