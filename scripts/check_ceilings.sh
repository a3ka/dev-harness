#!/usr/bin/env bash
# scripts/check_ceilings.sh — потолки документов: байты, не символы (контракт 004 v1).
#
# Персона (каждый файл roles/) ≤ 51200 байт; файл-правило (AGENTS.md и каждый файл
# .omp/rules/) ≤ 30720 байт. Счётчик — wc -c: кириллица занимает вдвое больше байт,
# чем символов (замер арбитража potolki-granica-pokrytie: 16919 байт против 9864
# символов на одном файле). Нечитаемый размер (битая ссылка, права) — отказ, не пропуск.
#
# Каждый НЕЗАМОРОЖЕННЫЙ черновик contracts/NNN-*.md (нет тега frozen/contracts/<NNN>/*)
# обязан нести раздел «Незаполненные требования:» с телом: ровно слово «нет» ЛИБО
# непусто и каждая строка начинается с «- »; пустых строк в теле нет. Замороженность
# доказывается чтением тегов git — не списком известных номеров (арбитраж
# zamorozhennaya-proba: пара-двойник с порождаемыми номерами ловит whitelist).
#
# Отказ называет ИМЯ файла и ФАКТИЧЕСКИЙ размер в байтах. Класс, целиком отсутствующий
# в проверяемом дереве, — неприменим (печатается отдельной строкой, молчания нет).
#
# Коды возврата: 0 — в порядке, 1 — превышение или грамматика, 2 — нечем проверить.
set -uo pipefail

REPO="${1:-$(pwd)}"
die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
ok()   { printf '  ok   %s\n' "$*" >&2; }
bad()  { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
fails=0

command -v wc >/dev/null 2>&1 || skip "нет wc — размеры нечем считать"

PERSONA_LIMIT=51200
RULE_LIMIT=30720

shopt -s dotglob nullglob

# ── персоны: каждый файл roles/, включая скрытые имена ────────────────────────
personas=( "$REPO"/roles/*.md )
if [ "${#personas[@]}" -eq 0 ]; then
  ok "roles/ пуст или отсутствует — потолок персон неприменим"
else
  for f in "${personas[@]}"; do
    size=$(wc -c < "$f" 2>/dev/null) || { bad "персона $f: размер нечитаем — битая ссылка или права"; continue; }
    case "$size" in ''|*[!0-9]*) bad "персона $f: размер нечитаем ($size)"; continue ;; esac
    [ "$size" -gt "$PERSONA_LIMIT" ] && bad "персона $f: $size байт > потолка $PERSONA_LIMIT"
  done
  ok "персоны: ${#personas[@]} файл(ов), потолок $PERSONA_LIMIT байт"
fi

# ── файлы-правила: AGENTS.md и каждый файл .omp/rules/ ────────────────────────
rules=()
# [ -f ] следует по ссылке и ВЫБРАСЫВАЕТ битую до wc (находка ревьюера f86fa0c):
# правило существует, если оно файл ИЛИ ссылка — битая попадает в wc и даёт отказ.
if [ -f "$REPO/AGENTS.md" ] || [ -L "$REPO/AGENTS.md" ]; then rules+=( "$REPO/AGENTS.md" ); fi
for f in "$REPO"/.omp/rules/*.md; do [ -f "$f" ] || [ -L "$f" ] || continue; rules+=( "$f" ); done
if [ "${#rules[@]}" -eq 0 ]; then
  ok "файлы-правила отсутствуют — потолок правил неприменим"
else
  for f in "${rules[@]}"; do
    size=$(wc -c < "$f" 2>/dev/null) || { bad "файл-правило $f: размер нечитаем — битая ссылка или права"; continue; }
    case "$size" in ''|*[!0-9]*) bad "файл-правило $f: размер нечитаем ($size)"; continue ;; esac
    [ "$size" -gt "$RULE_LIMIT" ] && bad "файл-правило $f: $size байт > потолка $RULE_LIMIT"
  done
  ok "правила: ${#rules[@]} файл(ов), потолок $RULE_LIMIT байт"
fi

# ── раздел «Незаполненные требования:» у незамороженных черновиков ────────────
# Замороженность читается ИЗ ТЕГОВ git данного дерева; не-репозиторий — все
# черновики считаются незамороженными (тегов нет).
contracts=( "$REPO"/contracts/[0-9][0-9][0-9]-*.md )
if [ "${#contracts[@]}" -eq 0 ]; then
  ok "contracts/*.md отсутствуют — раздел требований неприменим"
else
  for f in "${contracts[@]}"; do
    base="$(basename "$f")"
    nnn="${base%%-*}"
    if git -C "$REPO" rev-parse --verify --quiet "refs/tags/frozen/contracts/$nnn/1" >/dev/null 2>&1 \
       || git -C "$REPO" for-each-ref "refs/tags/frozen/contracts/$nnn/" 2>/dev/null | grep -q .; then
      continue  # заморожено — текст неизменен, вне суда
    fi
    size=$(wc -c < "$f" 2>/dev/null) || size=0
    case "$size" in ''|*[!0-9]*) size=0 ;; esac
    body="$(awk '/^## Незаполненные требования:/ { flag=1; next } flag && /^## / { exit } flag { print }' "$f")"
    if ! grep -q '^## Незаполненные требования:' "$f"; then
      bad "контракт $f ($size байт): нет раздела «Незаполненные требования:»"
      continue
    fi
    if [ -z "$body" ]; then
      bad "контракт $f ($size байт): раздел «Незаполненные требования:» пуст — списка нет, слова «нет» нет"
      continue
    fi
    if [ "$body" = "нет" ]; then
      continue
    fi
    if printf '%s\n' "$body" | grep -qv '^- '; then
      bad "контракт $f ($size байт): тело раздела «Незаполненные требования:» вне грамматики — нужно ровно «нет» либо список «- …»"
    fi
  done
  ok "раздел требований: ${#contracts[@]} черновик(ов) судится, замороженные — по тегам"
fi
shopt -u dotglob nullglob

[ "$fails" -gt 0 ] && { printf 'превышений/нарушений: %d\n' "$fails" >&2; exit 1; }
printf 'потолки в порядке\n' >&2
