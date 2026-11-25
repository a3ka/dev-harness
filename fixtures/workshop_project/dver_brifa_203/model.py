#!/usr/bin/env python3
"""203 v2: executable reference overlay of the four-point fix.

Production files are never modified. Only model copies receive these deltas;
the same observer that judges production runs the overlay, so the etalon
exercises the real make_task/freeze pipeline, real git archive and real Node
module resolution instead of returning precomputed answers. Both patched
doors are read from the exact BASE commit, so a later implementer landing in
scripts/ cannot destroy the etalon anchors.
"""
from pathlib import Path
import shutil
import subprocess

BASE = 'e767f5132c2c2d40064d7bf374ea9aaa152b1b89'

# (1) Н-454(а): выгрузка git archive не несёт node_modules, а CLI пина их
# требует. Дверь подключает зависимости САМА: симлинк node_modules
# установленного клона при побайтовом равенстве lock; любое расхождение —
# именованный отказ ARCH_BRIEF_DEPS с рекомендацией npm ci. Сеть не трогается;
# дерево без lock и без runtime-зависимостей исполняется как прежде.
DEPENDENCIES = '''  # КОНТРАКТ 203 (Н-454): зависимости выгрузки закреплённого пина. git archive
  # несёт исходники БЕЗ node_modules, а CLI пина требует модулей; дверь
  # подключает зависимости САМА — симлинком node_modules установленного клона
  # ($root) при побайтовом равенстве его package-lock.json lock'у ВЫГРУЗКИ.
  # Несовпадение/отсутствие lock, отсутствие node_modules, зависимости без
  # lock — именованный отказ ARCH_BRIEF_DEPS с рекомендацией npm ci на
  # закреплённом пине; сеть дверь не трогает. Дерево без lock и без
  # runtime-зависимостей исполняется как прежде, без заимствования модулей.
  if [ -f "$tmp/package-lock.json" ]; then
    if ! cmp -s "$tmp/package-lock.json" "$root/package-lock.json"; then
      rm -rf "$tmp"
      ARCH187_REFUSAL="ARCH_BRIEF_DEPS: package-lock.json закреплённого пина не совпадает с установленным клоном модели: $root; npm ci на закреплённом пине"
      return 1
    fi
    if [ ! -d "$root/node_modules" ]; then
      rm -rf "$tmp"
      ARCH187_REFUSAL="ARCH_BRIEF_DEPS: в установленном клоне модели нет node_modules: $root; npm ci на закреплённом пине"
      return 1
    fi
    ln -s "$(cd "$root/node_modules" && pwd -P)" "$tmp/node_modules" \\
      || { rm -rf "$tmp"
           ARCH187_REFUSAL="ARCH_BRIEF_DEPS: node_modules выгрузки не подключить"
           return 1; }
  elif [ -f "$tmp/package.json" ] \\
       && jq -e '(.dependencies // {}) | length > 0' "$tmp/package.json" >/dev/null 2>&1; then
    rm -rf "$tmp"
    ARCH187_REFUSAL="ARCH_BRIEF_DEPS: у закреплённого пина есть runtime-зависимости без package-lock.json; npm ci на закреплённом пине"
    return 1
  fi
'''

# (2) Н-454(в): причина отказа brief — целиком из ответа модели (код +
# сообщение). Настоящий CLI печатает отказ многострочным JSON-отчётом, первая
# строка которого «{»; строки причины предшествует разбор ответа ЦЕЛИКОМ.
# Вне грамматики сохранена прежняя первая непустая строка stderr, при пустом
# stderr — прежняя константа: байты прежних потребителей не меняются.
REASON_OLD = '''    [ -n "$first" ] || first="(stderr модели пуст)"
    printf 'ARCH_BRIEF_STDERR: %s\\n' "$first" >&2
'''
REASON_NEW = '''    # КОНТРАКТ 203: причина отказа — ИЗ ОТВЕТА МОДЕЛИ (код + сообщение).
    # Настоящий CLI при отказе печатает stderr МНОГОСТРОЧНЫМ JSON-отчётом
    # {status,scope,findings:[{code,message}]}; его первая строка «{»
    # причиной не является. Ответ разбирается ЦЕЛИКОМ: строка
    # ARCH_BRIEF_STDERR несёт код И сообщение модели. Вне грамматики —
    # прежняя первая непустая строка stderr, пустой stderr — прежняя
    # константа (байты прежних потребителей сохранены).
    _r203=""
    _r203="$(printf '%s' "$err" | jq -r '
      if (type == "object") and ((.findings[0].code | length) > 0)
      then (.findings[0].code) + (if ((.findings[0].message | length) > 0) then ": " + .findings[0].message else "" end)
      else "" end' 2>/dev/null)" || _r203=""
    _r203="$(printf '%s' "$_r203" | tr '\\r\\n\\t' '   ' | sed -e 's/  */ /g' -e 's/^ //' -e 's/ $//')"
    if [ -n "$_r203" ]; then
      first="$_r203"
    else
      [ -n "$first" ] || first="(stderr модели пуст)"
    fi
    printf 'ARCH_BRIEF_STDERR: %s\\n' "$first" >&2
'''

# (3) R-0071 п.3: id строки «АРХИТЕКТУРА:» — только элементы модели ПО ПИНУ.
# Членство отвечает сама модель: краткий brief каждого id из выгрузки пина.
# Ответ с кодом UNKNOWN_ARCHITECTURE_ELEMENT — положительный вердикт «не
# элемент» → именованный отказ с самым id. Прочие исходы вердикта о членстве
# не несут: недоступная модель уже отказала ARCH_PIN/ARCH_BRIEF_DEPS в
# model_prepare, неизвестный id флага --arch-component отказывает кодом
# модели в ARCH_BRIEF_STDERR. Вызов — тихий: stdout отбрасывается, stderr —
# во временный файл, в вывод двери не печатается.
ELEMENT_IDS = '''# arch187_element_ids — каждый id строки «АРХИТЕКТУРА:» известен модели ПО
# ПИНУ (контракт 203). Членство отвечает САМА модель: краткий brief каждого
# id из ВЫГРУЗКИ закреплённого пина (без --with-rules, stdout отбрасывается,
# stderr — во временный файл, в вывод двери не печатается). rc 0 — элемент
# известен; ответ модели с кодом UNKNOWN_ARCHITECTURE_ELEMENT — её
# положительный вердикт «не элемент» → именованный отказ с самим id.
# Прочие исходы (иной код, пустой ответ) вердикта о членстве НЕ несут: их
# ловят соседние швы — недоступная модель отказывает ARCH_PIN/ARCH_BRIEF_DEPS
# в model_prepare, а неизвестный id флага --arch-component отказывает кодом
# модели в ARCH_BRIEF_STDERR строки arch187_brief.
arch187_element_ids() {
  local rest id errf rc=0 code
  rest="${ARCH187_COMPONENTS:-}"
  [ -n "$rest" ] || return 0
  [ -n "${ARCH187_MODEL_DIR:-}" ] || return 0
  while [ -n "$rest" ]; do
    id="${rest%%,*}"
    if [ "$rest" = "$id" ]; then rest=""; else rest="${rest#*,}"; fi
    errf="$(mktemp 2>/dev/null || true)"
    if [ -z "$errf" ] || [ ! -f "$errf" ]; then
      ARCH187_REFUSAL="ARCH_NOT_EVALUATED: членство id в модели не проверить (нет временного файла)"
      ARCH187_REFUSAL_RC="2"
      return 1
    fi
    rc=0
    (cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js brief --compact --component "$id") >/dev/null 2>"$errf" || rc=$?
    code="$(jq -r 'if (type == "object") and ((.findings[0].code | type) == "string") then .findings[0].code else "" end' "$errf" 2>/dev/null)" || code=""
    rm -f "$errf"
    if [ "$rc" -ne 0 ] && [ "$code" = "UNKNOWN_ARCHITECTURE_ELEMENT" ]; then
      ARCH187_REFUSAL="UNKNOWN_ARCHITECTURE_ELEMENT: $id"
      ARCH187_REFUSAL_RC="1"
      return 1
    fi
  done
  return 0
}

'''

MEMBER_OLD = '''  arch187_model_prepare "$repo" || return 1
'''
MEMBER_NEW = '''  arch187_model_prepare "$repo" || return 1
  # КОНТРАКТ 203: id строки «АРХИТЕКТУРА:» — только элементы модели ПО ПИНУ
  # (выгрузка уже развёрнута; отказ членства — до зон и до вопроса о флаге).
  if ! arch187_element_ids; then
    arch187_snapshot_drop
    return 1
  fi
'''

# (4) R-0071 п.4: кап пака — эффективный pack.maxBytes профиля (Б-4 в main),
# ветки ARCH_BRIEF_BUDGET капа 40000 в эталоне НЕТ: дельта make_task пуста.


def once(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError(f'MODEL_ANCHOR: expected one occurrence: {old[:90]!r}')
    return text.replace(old, new, 1)


def materialize(source: Path, target: Path):
    target.mkdir()
    shutil.copytree(source / 'scripts', target / 'scripts')
    # Other repository resources stay read-only and are shared with the source.
    for name in ('config', 'registry', 'roles', 'schemas', 'package.json'):
        if (source / name).exists():
            (target / name).symlink_to(source / name)
    archfile = target / 'scripts/check_architecture_contract.sh'
    arch = subprocess.run(['git', '-C', str(source), 'show',
                           BASE + ':scripts/check_architecture_contract.sh'],
                          check=True, capture_output=True, text=True).stdout
    arch = once(arch, '  ARCH187_MODEL_DIR="$tmp"\n  ARCH187_MODEL_TMP="$tmp"\n  return 0\n}',
                DEPENDENCIES + '  ARCH187_MODEL_DIR="$tmp"\n  ARCH187_MODEL_TMP="$tmp"\n  return 0\n}')
    arch = once(arch, REASON_OLD, REASON_NEW)
    arch = once(arch, '# arch187_line <file> — строка `АРХИТЕКТУРА:` текста.\n',
                ELEMENT_IDS + '# arch187_line <file> — строка `АРХИТЕКТУРА:` текста.\n')
    arch = once(arch, MEMBER_OLD, MEMBER_NEW)
    archfile.write_text(arch)
    # make_task: дельты нет — файл эталона читается из точной БАЗЫ, чтобы
    # стабы капа и флага имели неизменные якоря при любой будущей правке.
    taskfile = target / 'scripts/make_task.sh'
    task = subprocess.run(['git', '-C', str(source), 'show',
                           BASE + ':scripts/make_task.sh'],
                          check=True, capture_output=True, text=True).stdout
    taskfile.write_text(task)
    return target
