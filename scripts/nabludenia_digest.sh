#!/usr/bin/env bash
# Дайджест старта сессии: открытые наблюдения с адресами + состояние дерева +
# черновики механизма 2 + указатель на HANDOFF §«ГДЕ МЫ».
#
# Контракт 015, механизм 3 (Н-62-ядро). НЕ БАРЬЕР — собирает и печатает секции, судится
# дриллом drill_startup_digest.sh. ИНВАРИАНТЫ:
#
#   1. Открытые записи с адресами — id + адрес-строка ТОЙ ЖЕ грамматикой, что механизм 1
#      (строка `# ГРАММАТИКА:` побайтово та же — инвариант 1.5); оба файла; запись без
#      адреса тоже называется, с пометкой «(без адреса)».
#   2. Дерево: HEAD vs origin (ahead/behind), непушенные теги поимённо (`git tag -l` минус
#      `git ls-remote --tags`; remote недоступен → строка «remote недоступен», не падает),
#      аномалии `git status --short` (пусто → «чисто»).
#   3. Черновики механизма 2 — поимённо из ${TMPDIR}/dev-harness-nabludenia/drafts/;
#      пусто → «черновиков: 0».
#   4. Указатель на HANDOFF.md §«ГДЕ МЫ» — имя раздела, не текст.
#
# Пустая секция печатается нулём, а не молчит; превышение потолка — хвост списка
# схлопывается строкой «…и ещё N»; любая внутренняя ошибка — одна строка «дайджест не
# собран: <причина>», rc=0 (fail-open: старт сессии не имеет права упасть).
#
# НЕ БАРЬЕР: утилита-дайджест, логика судится дриллом drill_startup_digest.sh на собственной
# песочнице (12 фикстур красных входов через подмену субъектов).
#
#
set -uo pipefail
export LC_ALL=C

# ── аргументы ──────────────────────────────────────────────────────────────────
MODE=""; ROOT_ARG=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --for-session) MODE="for-session"; shift ;;
    --root)        ROOT_ARG="${2:-}"; shift 2 || shift ;;
    *) shift ;;
  esac
done

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${ROOT_ARG:-"$SELF_DIR/.."}" && pwd)"

command -v python3 >/dev/null 2>&1 || {
  printf 'дайджест не собран: нет python3\n'
  exit 0
}
command -v git >/dev/null 2>&1 || {
  printf 'дайджест не собран: нет git\n'
  exit 0
}

# ГРАММАТИКА: ^ГОЛОВА(ХВОСТ?)?$ — синхронно с check_nabludenia.sh и миграционной пробой
# (побайтово один источник). Рассинхронизация — красная ветвь дрилла механизма 3.
GRAMMAR_RE='^(контракт[а-яё]* 0[0-9][0-9]|очеред[а-яё]* автономности|пачк[а-яё]* (Н|А)-[0-9]+|ROADMAP[- ]*шаг[а-яё]* [0-9]+|правил[а-яё]* роли [A-Za-z]+|закрыто [0-9][0-9][0-9]|историческое, не чинить: ..*|cognitive-only.*риск|contracts/[^` ]+)([] ,.;:!?()«»„“”‘’"'\''…—–/*+&%#@~=<>^$|{}].*)?$'

ENTRY_RE='^### ([НА])-([0-9]+)\.'

CEILING=40
SECT_OPEN_MAX=30
SECT_DRAFT_MAX=3

SECT_OPEN="$(mktemp -t nabludenia-digest-open.XXXXXX)"
SECT_TREE="$(mktemp -t nabludenia-digest-tree.XXXXXX)"
SECT_DRAFT="$(mktemp -t nabludenia-digest-draft.XXXXXX)"
SECT_HAND="$(mktemp -t nabludenia-digest-hand.XXXXXX)"
trap 'rm -f "$SECT_OPEN" "$SECT_TREE" "$SECT_DRAFT" "$SECT_HAND"' EXIT

# ── секция 1: открытые записи с адресами ─────────────────────────────────────────
for f in NABLIUDENIA.md NABLIUDENIA_ARCHITECT.md; do
  p="$ROOT/$f"
  [ -e "$p" ] || continue
  python3 - "$p" "$GRAMMAR_RE" "$ENTRY_RE" >> "$SECT_OPEN" 2>/dev/null <<'PY' || true
import re, sys
path, grammar_re_s, entry_re_s = sys.argv[1], sys.argv[2], sys.argv[3]
ENTRY = re.compile(entry_re_s)
GRAMMAR = re.compile(grammar_re_s)
BT = re.compile(r'`([^`]*)`')
with open(path, encoding='utf-8') as fh:
    for line in fh:
        line = line.rstrip('\n')
        m = ENTRY.match(line)
        if not m:
            continue
        rid = '%s-%s' % (m.group(1), m.group(2))
        groups = BT.findall(line)
        if not groups:
            continue
        marker = groups[-1]
        if not marker.startswith('ОТКРЫТО'):
            continue
        if 'адрес:' not in marker:
            print('%s (без адреса)' % rid)
            continue
        tail = marker.split('адрес:', 1)[1].strip()
        if not tail or not GRAMMAR.fullmatch(tail):
            print('%s (без адреса)' % rid)
            continue
        print('%s \u2192 %s' % (rid, tail))
PY
done

if [ ! -s "$SECT_OPEN" ]; then
  printf 'открытых: 0\n' > "$SECT_OPEN"
fi

total_open=$(wc -l < "$SECT_OPEN" | tr -d ' ')
if [ "$total_open" -gt "$SECT_OPEN_MAX" ]; then
  head -n "$SECT_OPEN_MAX" "$SECT_OPEN" > "$SECT_OPEN.tmp"
  rest_n=$((total_open - SECT_OPEN_MAX))
  printf '…и ещё %s\n' "$rest_n" >> "$SECT_OPEN.tmp"
  mv "$SECT_OPEN.tmp" "$SECT_OPEN"
fi

# ── секция 2: дерево ────────────────────────────────────────────────────────────
if ! git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  printf 'дайджест не собран: %s не репозиторий git\n' "$ROOT" > "$SECT_TREE"
else
  ahead_behind="$(git -C "$ROOT" rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || true)"
  if [ -n "$ahead_behind" ]; then
    ahead="$(printf '%s' "$ahead_behind" | awk '{print $1}')"
    behind="$(printf '%s' "$ahead_behind" | awk '{print $2}')"
    printf 'HEAD vs origin: ahead %s, behind %s\n' "$ahead" "$behind" > "$SECT_TREE"
  else
    printf 'remote недоступен\n' > "$SECT_TREE"
  fi

  local_tags="$(git -C "$ROOT" tag -l 2>/dev/null | sort -u || true)"
  remote_tags="$(git -C "$ROOT" ls-remote --tags origin 2>/dev/null | awk '{print $2}' | sed 's|^refs/tags/||' | sort -u || true)"
  unpushed="$(comm -23 <(printf '%s\n' "$local_tags") <(printf '%s\n' "$remote_tags" 2>/dev/null) || true)"
  if [ -z "$unpushed" ]; then
    printf 'непушенных тегов: 0\n' >> "$SECT_TREE"
  else
    unpushed_n=$(printf '%s\n' "$unpushed" | wc -l)
    printf 'непушенных тегов: %s\n' "$unpushed_n" >> "$SECT_TREE"
    shown=0
    while IFS= read -r t; do
      [ -z "$t" ] && continue
      if [ "$shown" -lt 5 ]; then
        printf '  %s\n' "$t" >> "$SECT_TREE"
        shown=$((shown + 1))
      fi
    done <<< "$unpushed"
    if [ "$unpushed_n" -gt 5 ]; then
      printf '  …и ещё %d\n' "$((unpushed_n - 5))" >> "$SECT_TREE"
    fi
  fi

  status_short="$(git -C "$ROOT" status --short 2>/dev/null || true)"
  if [ -z "$status_short" ]; then
    printf 'статус: чисто\n' >> "$SECT_TREE"
  else
    printf 'статус: аномалии\n' >> "$SECT_TREE"
    shown=0
    while IFS= read -r l; do
      [ -z "$l" ] && continue
      if [ "$shown" -lt 5 ]; then
        printf '  %s\n' "$l" >> "$SECT_TREE"
        shown=$((shown + 1))
      fi
    done <<< "$status_short"
    total_status=$(printf '%s\n' "$status_short" | wc -l)
    if [ "$total_status" -gt 5 ]; then
      printf '  …и ещё %d\n' "$((total_status - 5))" >> "$SECT_TREE"
    fi
  fi
fi

# ── секция 3: черновики механизма 2 ────────────────────────────────────────────
TMPDIR_RAW="${TMPDIR:-/tmp}"
_p="$TMPDIR_RAW"; _tail=""
while [ ! -d "$_p" ] && [ -n "$_p" ]; do _tail="/${_p##*/}${_tail}"; _p="${_p%/*}"; done
DRAFTS=""
if [ -n "$_p" ] && _canon="$(cd "$_p" 2>/dev/null && pwd -P 2>/dev/null)"; then
  DRAFTS="${_canon}${_tail}/dev-harness-nabludenia/drafts"
fi

if [ -z "$DRAFTS" ] || [ ! -d "$DRAFTS" ]; then
  printf 'черновиков: 0\n' > "$SECT_DRAFT"
else
  draft_files="$(ls "$DRAFTS"/*.md 2>/dev/null | grep -v README | sort || true)"
  if [ -z "$draft_files" ]; then
    printf 'черновиков: 0\n' > "$SECT_DRAFT"
  else
    draft_n=$(printf '%s\n' "$draft_files" | wc -l)
    printf 'черновиков: %d\n' "$draft_n" > "$SECT_DRAFT"
    shown=0
    while IFS= read -r df; do
      [ -z "$df" ] && continue
      if [ "$shown" -lt "$SECT_DRAFT_MAX" ]; then
        printf '  %s\n' "$(basename "$df")" >> "$SECT_DRAFT"
        shown=$((shown + 1))
      fi
    done <<< "$draft_files"
    if [ "$draft_n" -gt "$SECT_DRAFT_MAX" ]; then
      printf '  …и ещё %d\n' "$((draft_n - SECT_DRAFT_MAX))" >> "$SECT_DRAFT"
    fi
  fi
fi

# ── секция 4: HANDOFF.md §«ГДЕ МЫ» ──────────────────────────────────────────────
HANDOFF="$ROOT/HANDOFF.md"
if [ ! -f "$HANDOFF" ]; then
  printf 'указатель: HANDOFF.md отсутствует\n' > "$SECT_HAND"
else
  handoff_line="$(grep -nE '^## ГДЕ МЫ' "$HANDOFF" | head -n 1 | cut -d: -f1 || true)"
  if [ -n "$handoff_line" ]; then
    printf 'HANDOFF.md §ГДЕ МЫ, строка %s\n' "$handoff_line" > "$SECT_HAND"
  else
    printf 'указатель: раздел ГДЕ МЫ не найден\n' > "$SECT_HAND"
  fi
fi

# ── сборка ─────────────────────────────────────────────────────────────────────
mkdir -p "$ROOT/tmp" 2>/dev/null || true
OUT="$ROOT/tmp/nabludenia-digest-output-$$"
{
  printf 'открытые с адресами:\n'
  cat "$SECT_OPEN"
  printf '\nдерево:\n'
  cat "$SECT_TREE"
  printf '\nчерновики:\n'
  cat "$SECT_DRAFT"
  printf '\nHANDOFF:\n'
  cat "$SECT_HAND"
} > "$OUT" 2>/dev/null || {
  printf 'дайджест не собран: ошибка сборки\n'
  exit 0
}

out_total=$(wc -l < "$OUT" | tr -d ' ')
if [ "$out_total" -gt "$CEILING" ]; then
  head -n "$CEILING" "$OUT" > "$OUT.tmp"
  rest_n=$((out_total - CEILING))
  printf '…и ещё %d\n' "$rest_n" >> "$OUT.tmp"
  mv "$OUT.tmp" "$OUT"
fi

cat "$OUT"
rm -f "$OUT"
exit 0
