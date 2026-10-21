#!/usr/bin/env python3
"""Подмены батареи 130: честная модель поверх scripts/ дерева и обманные стабы.

  podmena.py model <каталог scripts>      ставит модель: model/gitw_teg_130.sh + крюк в gitw
                                           + терпимость «тег в ожидании текста» в чеке (2) 071
  podmena.py stub <id> <каталог scripts>  поверх модели — одна обманная подмена
  podmena.py list                          «<id>\t<клетка>\t<дефект>» по строке на стаб

Каждый якорь обязан встречаться в своём файле РОВНО один раз, иначе rc 2 (подмена не
состоялась — стаб был бы пойман пустым местом). Привязка стаба к клетке — поле cell ниже
(Н-39: привязка живёт в коде, не в прозе контракта).
"""
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))

GITW_ANCHOR = '  PF_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"\n'
GITW_HOOK = (
    '  T130="$(cd "$(dirname "$0")" 2>/dev/null && pwd)/gitw_teg_130.sh"\n'
    '  if [ ! -f "$T130" ]; then\n'
    "    printf 'gitw ТЕГ-ОТКАЗ: (обмен): состав обмена не читается: гард 130 отсутствует\\n' >&2\n"
    '    exit 1\n'
    '  fi\n'
    '  bash "$T130" push "$target" "$REAL" "$post_sub_idx" "${orig[@]}"\n'
    '  trc=$?\n'
    '  [ "$trc" -eq 0 ] || exit "$trc"\n'
)
PF_ANCHOR = '      if [ "$remote_sha" != "$sha" ]; then\n'
PF_HOLD = (
    '      if [ -z "$remote_sha" ] && [ "${name#refs/tags/frozen/}" != "$name" ] \\\n'
    '         && bash "$SELF_DIR/gitw_teg_130.sh" held "$TGT" "$name"; then\n'
    "        printf 'gitw ПРЕДПОЛЁТ: тег в ожидании текста: %s\\n' \"$short\" >&2\n"
    '      elif [ "$remote_sha" != "$sha" ]; then\n'
)

G = 'gitw_teg_130.sh'
PF = 'gitw_preflight_071.sh'

# id, клетка, файл, якорь, замена, дефект
STUBS = [
    ('s01-vsegda-razreshaet', 'c02-tolko-wip', G,
     'judge_tag() {\n', 'judge_tag() {\n  return 0\n',
     'гард всегда допускает тег'),
    ('s02-vsegda-otkazyvaet', 'c01-chestnyj', G,
     'judge_tag() {\n',
     "judge_tag() {\n  otkaz \"${1#refs/tags/}\" \"текст не в main цели\" заглушка\n  return 1\n",
     'гард всегда отказывает'),
    ('s03-imya-ne-blob', 'c03-staryj-blob', G,
     'if ! [ "$blob_main" = "$blob_tag" ]; then', 'if [ -z "$blob_main" ]; then',
     'сверяет наличие файла по имени, не blob'),
    ('s04-lokalnyj-main', 'c06-lokalnyj-main', G,
     'out="$(git ls-remote "$tgt" refs/heads/main 2>/dev/null)" || return 1',
     'out="$(printf \'%s\\trefs/heads/main\\n\' "$(git rev-parse --verify --quiet refs/heads/main)")" || return 1',
     'сверяет с локальным main, не с main цели'),
    ('s05-tracking-ref', 'c07-tracking', G,
     'out="$(git ls-remote "$tgt" refs/heads/main 2>/dev/null)" || return 1',
     'out="$(printf \'%s\\trefs/heads/main\\n\' "$(git rev-parse --verify --quiet refs/remotes/origin/main)")" || return 1',
     'сверяет с refs/remotes/origin/main (снимок), не с живым main цели'),
    ('s06-bez-verdikta', 'c04-bez-verdikta', G,
     '  vk=1\n', '  vk=$((v + 1))\n',
     'не сверяет вердикт критика'),
    ('s07-verdikt-ne-accept', 'c05-verdikt-fail', G,
     'if ! [ "$first" = accept ]; then', 'if [ -z "$first" ]; then',
     'сверяет наличие вердикта, не accept'),
    ('s08-tolko-literal', 'c08-tags', G,
     'sostav() {\n',
     'sostav() {\n  local a\n  for a in "${POST[@]}"; do case "$a" in refs/tags/frozen/*) printf \'%s\\t%s\\n\' "$a" "$a" ;; esac; done\n  return 0\n',
     'состав обмена — литералы argv, не git push --dry-run'),
    ('s09-fail-open-net-main', 'c12-net-main', G,
     '    otkaz "$short" "main цели не читается" "ls-remote refs/heads/main пуст или упал"\n    return 2\n',
     '    return 0\n',
     'нет main цели — допуск (fail-open)'),
    ('s10-fail-open-ne-lokalno', 'c13-main-ne-lokalno', G,
     '    otkaz "$short" "main цели не читается" "вершины ${RMAIN:0:12} нет локально — gitw fetch и повтор"\n    return 2\n',
     '    return 0\n',
     'вершины main цели нет локально — допуск (fail-open)'),
    ('s11-hold-blokiruet', 'c15-lend-s-hold', PF,
     '         && bash "$SELF_DIR/gitw_teg_130.sh" held "$TGT" "$name"; then\n',
     '         && false; then\n',
     'чек (2) 071 без терпимости: тег в ожидании блокирует ленд текста'),
    ('s12-hold-vsegda', 'c16-hold-posle-lenda', PF,
     '         && bash "$SELF_DIR/gitw_teg_130.sh" held "$TGT" "$name"; then\n',
     '         && true; then\n',
     'чек (2) 071 терпит любой локальный frozen-тег, и с текстом в main'),
    ('s13-done-sudit', 'c10-done', G,
     '        refs/tags/frozen/*) frozen+=',
     '        refs/tags/frozen/*|refs/tags/done/*|refs/tags/id/*) frozen+=',
     'судит теги done/ и id/ как заморозку'),
    ('s14-tolko-contracts', 'c19-plans', G,
     '^refs/tags/frozen/(contracts|plans)/', '^refs/tags/frozen/(contracts)/',
     'грамматика без plans/'),
    ('s15-vne-grammatiki-dopusk', 'c20-vne-grammatiki', G,
     '    otkaz "$short" "тег вне грамматики" "ожидается frozen/(contracts|plans)/NNN/v"\n    return 2\n',
     '    return 0\n',
     'тег вне грамматики — допуск'),
]


def die(msg, rc=2):
    sys.stderr.write('podmena: ' + msg + '\n')
    sys.exit(rc)


def subst(path, anchor, repl):
    with open(path, encoding='utf-8') as f:
        text = f.read()
    k = text.count(anchor)
    if k != 1:
        die('якорь встречается %d раз (нужен 1) в %s: %r' % (k, path, anchor[:60]))
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text.replace(anchor, repl, 1))

def model(sd):
    dst = os.path.join(sd, G)
    shutil.copyfile(os.path.join(HERE, 'model', G), dst)
    os.chmod(dst, 0o755)
    subst(os.path.join(sd, 'gitw'), GITW_ANCHOR, GITW_HOOK + GITW_ANCHOR)
    subst(os.path.join(sd, PF), PF_ANCHOR, PF_HOLD)


def main(argv):
    if len(argv) >= 1 and argv[0] == 'list':
        for s in STUBS:
            print('%s\t%s\t%s' % (s[0], s[1], s[5]))
        return 0
    if len(argv) == 2 and argv[0] == 'model':
        model(argv[1])
        return 0
    if len(argv) == 3 and argv[0] == 'stub':
        hit = [s for s in STUBS if s[0] == argv[1]]
        if not hit:
            die('нет такого стаба: ' + argv[1])
        model(argv[2])
        _, _, fname, anchor, repl, _ = hit[0]
        subst(os.path.join(argv[2], fname), anchor, repl)
        return 0
    die('вызов: model <scripts> | stub <id> <scripts> | list')


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
