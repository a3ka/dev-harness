#!/usr/bin/env bash
# Детектор утечек основного чекаута (контракт 024, семейство 2 записи Н-85).
# НЕ БАРЬЕР: детектор зовётся церемонией с наблюдаемым rc (норма-строка 024 в
# roles/orchestrator.md); красные/стабы/проба/канарейка живут вне case-глоба в
# семейном каталоге fixtures/check_judge_gate/ мета-барьера scripts/check_judge_gate.sh
# (замороженный текст 024, прецедент red_mera_parallelnosti_okon.sh контракта 021)
# — verify_antiplacebo не покрывает.
#
# Зачем. Правки субагентов, оставленные относительным путём без cwd, ложатся в основное дерево
# сессии (А-72/А-95/А-99; ×5 утечек 2026-09-08..10, две ночные при живых Н-85-инструкциях).
# Дисциплина измерено мертва — нужна механизация, а не правило (Н-85:2271-2280). Решение владельца
# 2026-09-10 (Г5): «D→среда ДА, D детектор (дёшев, независим, механизирует ручную меру), среда
# превенция». Этот файл — D.
#
# КАК ЗОВЁТСЯ. Два режима, ОДИН абсолютный корень основного чекаута:
#   --snapshot <абс-корень>  манифест состояния дерева в файле ВНЕ стерегомого;
#   --check    <абс-корень>  дельта манифеста: новые строки ⇒ rc 1 «основной чекаут загрязнён».
# Относительный путь в обоих режимах ⇒ rc 1 «корень обязан быть абсолютным» ДО какого-либо cd
# (блокер 5 вердикта 4d1d265).
#
# МАНИФЕСТ судит СОДЕРЖИМОЕ, не строку статуса (блокер 1 вердикта 4d1d265: «строка porcelain
# описывает состояние пути, не его байты» — три контрольных эксперимента обходили v1). Для
# каждой записи `git status --porcelain -uall -z --no-renames --ignore-submodules=none`
# строка «XY:отпечаток<TAB>путь»:
#   * обычный файл — sha256 байтов;
#   * каталог с .git (submodule/вложенный репозиторий) — «@head:<sha HEAD>» + РЕКУРСИЯ манифеста
#     вложенного репозитория с префиксом пути (правка внутри уже-грязного submodule меняет
#     вложенный отпечаток);
#   * отсутствующий путь (D) — «-».
# Дополнение байтов в уже-грязный tracked-путь, файл под свёрнутым `?? dir/`, правка внутри
# уже-грязного submodule — меняют отпечаток/строку и ловятся (ворота 9/10/11 red_detektor_utechek.sh).
#
# ФАЙЛ-СНИМОК. Первая строка — «root <канонический корень>» (защита от hash8-коллизии каталогов
# снимков, совет 1 вердикта), далее отсортированные строки манифеста. Хранится ВНЕ стерегомого —
# `${TMPDIR:-/tmp}/dev-harness-leak/<hash8-канонического-корня>/porcelain` (hash8-паттерн
# spawn_agent.sh:250, TMPDIR уважается, перезапись: последний выигрывает).
#
# ЧТО СУДИТСЯ/НЕ СУДИТСЯ (Демаркация контракта 024). Сверка — ПОДМНОЖЕСТВО: новая строка
# манифеста (новый путь, смена XY ИЛИ смена отпечатка) ⇒ утечка; исчезновение — чистка.
# Записи в ignored-пути (porcelain их не отражает) и скоммиченные до сверки изменения истории —
# вне 024 (адрес 025). Снятие/сверка НЕ меняют porcelain стерегомого (ворота 14; снимок лежит
# в TMPDIR, все git-вызовы -C).
#
# ГИГИЕНА Н-85. Корень проверяется на абсолютность ДО cd; все git-вызовы `git -C <канон>` —
# cwd не влияет на решение НИ В ОДНУ сторону (блокер 2 вердикта, ворота 7/8); rc фиксируется
# БЕЗ пайпов (Н-84: pipefail-обёртка для суждения не используется).
#
# Выход: 0 — снимок сделан / дельта пуста («основной чекаут чист»); 1 — именованный
#               отказ («основной чекаут загрязнён: <имена>» / «снимок отсутствует» /
#               «корень обязан быть абсолютным» / «снимок чужого корня»); 2 — окружение
#               не годится (нет утилит закрытого списка, git status rc≠0, нет git,
#               каталог/репозиторий недоступны).
set -uo pipefail
export LC_ALL=C

# ЕДИНЫЙ источник фраз — Демаркация контракта 024, потребители несут побайтово.
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'
P_NET_SNIMKA='снимок отсутствует'
P_ABS='корень обязан быть абсолютным'
P_CHUZH='снимок чужого корня'

usage() {
  printf 'ОТКАЗ диспетчер: использование: check_no_leak.sh --snapshot|--check <абс-корень>\n' >&2
  exit 1
}
[ "$#" -eq 2 ] || usage
MODE="$1"; ROOT_ARG="$2"
case "$MODE" in
  --snapshot|--check) ;;
  *) usage ;;
esac

# Абсолютность — ДО какого-либо cd (блокер 5 вердикта 4d1d265). Ловит форму, молча
# принимающую относительный путь и резолвящую его от случайного cwd (Н-85-класс).
case "$ROOT_ARG" in
  /*) ;;
  *)
    printf 'ОТКАЗ: %s: %s (CLI судит абсолютный корень основного чекаута — относительный путь резолвится от случайного cwd, Н-85-класс)\n' \
      "$P_ABS" "$ROOT_ARG" >&2
    exit 1
    ;;
esac

# Блокер 2 вердикта d67ac4b: явная предпроверка ЗАКРЫТОГО списка утилит ДО любой
# работы. rc=2 NOT_IMPLEMENTED именованный «утилита X отсутствует» по грамматике
# контракта 024 («rc 2 — окружение не годится»; «утилита мимо PATH / rc 127
# выглядит успехом»). Перечень — по факту использования в этом скрипте: git
# (все вызовы), sha256sum/cut (hash8-каталог снимка, отпечаток файла), sort
# (канонический манифест и снимок/текущая дельта), comm (дельта-ПОДМНОЖЕСТВО),
# mkdir (каталог снимка), cat (чтение снапшота), mktemp (буфер git status —
# переменная-посредник с фиксацией rc, см. emit_manifest ниже). Ловит класс
# S-no-sha256sum: sha256sum/cut rc 127 НЕ превращается в «чисто».
for util in git sha256sum cut sort comm mkdir cat mktemp; do
  command -v "$util" >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: утилита %s отсутствует\n' "$util" >&2; exit 2; }
done

# Канонизация корня — cd + pwd -P. После этого ВСЕ дальнейшие операции идут по $CANON,
# cwd детектора не имеет значения (ворота 7/8: грязный cwd не влияет на решение).
CANON="$(cd "$ROOT_ARG" 2>/dev/null && pwd -P)" \
  || { printf 'NOT_IMPLEMENTED: %s не каталог\n' "$ROOT_ARG" >&2; exit 2; }
git -C "$CANON" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$CANON" >&2; exit 2; }

# Снимок ВНЕ стерегомого дерева (И-1/И-8). Путь — от канонического корня через hash8:
# два вызова с разными cwd сходятся в один файл (И-7). TMPDIR уважается.
SNAP_DIR="${TMPDIR:-/tmp}/dev-harness-leak/$(printf '%s' "$CANON" | sha256sum | cut -c1-8)"
SNAP="$SNAP_DIR/porcelain"

# Манифест состояния дерева: рекурсивно, пофайлово, по содержимому.
# emit_manifest <канон-корень> <префикс-путей> — префикс пуст на верхнем уровне и
# наращивается при рекурсии в submodule (внутренние пути идут как "<sub>/<file>").
#
# Блокер 1 вердикта d67ac4b: rc `git status` фиксируется ДО ветвлений и ДО стрима,
# переменной-посредником через mktemp (process substitution `< <(git ...)` rc
# producer'а глотает — провал status с пустым stdout неотличим от чистого дерева
# и проходит как «основной чекаут чист»). Любой rc≠0 ⇒ rc=2 NOT_IMPLEMENTED
# именованный «манифест не прочитан: git status rc=N в <root>», дальнейшая
# работа не выполняется.
emit_manifest() {  # <root> <prefix>
  local root="$1" prefix="$2" entry xy path full fp head status_rc tmpf
  tmpf="$(mktemp)" || {
    printf 'NOT_IMPLEMENTED: mktemp отказал\n' >&2
    return 2
  }
  # Явная фиксация rc producer'а в переменной (Н-85/Н-84: rc без пайпов).
  git -C "$root" status --porcelain -uall -z --no-renames --ignore-submodules=none \
    > "$tmpf" 2>/dev/null
  status_rc=$?
  if [ "$status_rc" -ne 0 ]; then
    rm -f -- "$tmpf"
    printf 'NOT_IMPLEMENTED: манифест не прочитан: git status rc=%d в %s\n' \
      "$status_rc" "$root" >&2
    return 2
  fi
  while IFS= read -r -d '' entry; do
    xy="${entry:0:2}"
    path="${entry:3}"; path="${path%/}"
    full="$root/$path"
    if [ -d "$full" ] && [ -e "$full/.git" ]; then
      # submodule/gitlink или вложенный репозиторий — @head + РЕКУРСИЯ внутрь с префиксом.
      head="$(git -C "$full" rev-parse HEAD 2>/dev/null || printf -- '-')"
      printf '%s:@head:%s\t%s%s\n' "$xy" "$head" "$prefix" "$path"
      emit_manifest "$full" "$prefix$path/"
    elif [ -e "$full" ]; then
      # обычный файл — sha256 байтов.
      fp="$(sha256sum -- "$full" 2>/dev/null)" && fp="${fp%% *}" || fp='ERR'
      printf '%s:%s\t%s%s\n' "$xy" "$fp" "$prefix" "$path"
    else
      # D-запись (удалённое) — отпечаток отсутствия.
      printf '%s:-\t%s%s\n' "$xy" "$prefix" "$path"
    fi
  done < "$tmpf"
  rm -f -- "$tmpf"
}
manifest() { emit_manifest "$1" "$2" | sort; }

do_snapshot() {
  local m manifest_rc
  m="$(manifest "$CANON" '')"
  manifest_rc=$?
  if [ "$manifest_rc" -ne 0 ]; then
    # rc=2 NOT_IMPLEMENTED (git status rc≠0, mktemp отказ и т.п.) — сообщение
    # уже напечатано в emit_manifest; rc 2 контракта 024 для непригодного
    # окружения должен сохраняться, а не превращаться в rc 1 «ОТКАЗ».
    [ "$manifest_rc" -eq 2 ] && exit 2
    printf 'ОТКАЗ: status отказал в %s (rc=%d)\n' "$CANON" "$manifest_rc" >&2
    exit 1
  fi
  mkdir -p "$SNAP_DIR" \
    || { printf 'NOT_IMPLEMENTED: %s не создать\n' "$SNAP_DIR" >&2; exit 2; }
  # Перезапись: последний выигрывает (И-1, ворота 6).
  { printf 'root %s\n' "$CANON"; printf '%s\n' "$m"; } > "$SNAP"
}

do_check() {
  local first base cur delta names l p manifest_rc
  # И-4 fail-closed: снимок отсутствует — отказ, НЕ пропуск.
  if [ ! -f "$SNAP" ]; then
    printf 'ОТКАЗ: %s (%s) — снимок ДО спавна пачки обязателен: без него сверка отказывает, а не пропускает (fail-closed)\n' \
      "$P_NET_SNIMKA" "$SNAP" >&2
    exit 1
  fi
  # Первая строка — root <канон>. Не сошлась — чужой снимок (hash8-коллизия ИЛИ подмена,
  # совет 1 вердикта). Имена НЕ извлекаем — это не утечка, это ошибка церемонии.
  { IFS= read -r first; base="$(cat)"; } < "$SNAP" || true
  if [ "$first" != "root $CANON" ]; then
    printf 'ОТКАЗ: %s: снимок = [%s], сверяется [%s] — hash8-коллизия либо чужой файл; переснимите свою пачку\n' \
      "$P_CHUZH" "$first" "$CANON" >&2
    exit 1
  fi
  cur="$(manifest "$CANON" '')"
  manifest_rc=$?
  if [ "$manifest_rc" -ne 0 ]; then
    [ "$manifest_rc" -eq 2 ] && exit 2
    printf 'ОТКАЗ: status отказал в %s (rc=%d)\n' "$CANON" "$manifest_rc" >&2
    exit 1
  fi
  # Дельта — ПОДМНОЖЕСТВО: новые строки манифеста ⇒ утечка. Исчезновения — чистка, не краснеем.
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
