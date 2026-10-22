#!/usr/bin/env python3
"""Подмены батареи 130: честная модель поверх scripts/ дерева и обманные стабы.

  podmena.py model <каталог scripts>      ставит модель: model/gitw_teg_130.sh + функция teg130
                                           в gitw и её вызов перед КАЖДЫМ exec настоящего git
                                           при push (канарейка И-4б и И-8); предполёт 071 не трогается.
                                           Дерево, где проводка 130 УЖЕ вставлена (реализация И-1),
                                           повторно её не вставляет — сверяет якорями IMPL_* (R130-A1)
  podmena.py stub <id> <каталог scripts>  поверх модели — одна обманная подмена
  podmena.py list                          «<id>\t<клетка>\t<дефект>» по строке на стаб

Каждый якорь обязан встречаться в своём файле РОВНО один раз, иначе rc 2 (подмена не
состоялась — стаб был бы пойман пустым местом). Привязка стаба к клетке — поле cell ниже
(Н-39: привязка живёт в коде, не в прозе контракта): клетка — вход, на котором дефект
стаба наблюдаем (rc, класс отказа или состояние цели/ссылок расходится с оракулом).
"""
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))

# Функция крюка: после И-3 (подкоманда известна, i — индекс первого аргумента после неё).
GITW_FN_ANCHOR = '  *) exec "$REAL" "${orig[@]}" ;;\nesac\n'
GITW_FN = (
    'T130_PSI="$i"\n'
    'teg130() {\n'
    '  [ "$sub" = push ] || return 0\n'
    '  local t130\n'
    '  t130="$(cd "$(dirname "$0")" 2>/dev/null && pwd)/gitw_teg_130.sh"\n'
    '  [ -f "$t130" ] || return 0\n'
    '  bash "$t130" push "$CANON" "$REAL" "$T130_PSI" "${orig[@]}"\n'
    '}\n'
)
# Ранний exec канарейки И-4б (значение arity-2 опции принято за имя remote — F4 071).
GITW_EARLY_ANCHOR = '        continue\n      fi\n      exec "$REAL" "${orig[@]}"\n'
GITW_EARLY = '        continue\n      fi\n      teg130 || exit $?\n      exec "$REAL" "${orig[@]}"\n'
# Поздний крюк: перед вызовом предполёта 071 (а значит и перед exec И-8).
GITW_LATE_ANCHOR = '  PF_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"\n'
GITW_LATE = '  teg130 || exit $?\n'
# Проводка предмета в РЕАЛИЗОВАННОМ дереве (R130-A1): gitw уже несёт T130_PSI,
# функцию teg130 и оба вызова перед exec — вставка И-1 разрывает якоря вставки
# выше (GITW_EARLY_ANCHOR даёт 0 вхождений). На таком дереве модель не дублирует
# суд, а сверяет существующую проводку якорями (каждый ровно 1 раз); якорь
# раннего вызова — тот же, что ищет и снимает стаб s16.
IMPL_FN = 'teg130() {'
IMPL_CALL = 'bash "$t130" push "$CANON" "$REAL" "$T130_PSI" "${orig[@]}"'
IMPL_EARLY = '      teg130 || exit $?\n      exec "$REAL" "${orig[@]}"\n'
IMPL_LATE = '  teg130 || exit $?\n  PF_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"\n'

PF_ANCHOR = '      if [ "$remote_sha" != "$sha" ]; then\n'
PF_OSLABLEN = ('      if [ "$remote_sha" != "$sha" ] && { [ -n "$remote_sha" ] '
               '|| [ "${name#refs/tags/frozen/}" = "$name" ]; }; then\n')

# Якоря белого списка sostav модели (П-1/П-2 арбитража 130): ветви REPLACE/PASS/отказа.
WL_REPLACE = (
    '          -q|--quiet|--no-quiet|-v|--verbose|--no-verbose|--porcelain|--no-porcelain|-n|--dry-run|--no-dry-run)\n'
    '            PROBE_POST+=( --no-verify ) ;;\n')
WL_PASS = (
    '          --all|--no-all|--branches|--no-branches|--mirror|--no-mirror|--tags|--no-tags|--follow-tags|--no-follow-tags|--atomic|--no-atomic|--thin|--no-thin|--progress|--no-progress|--prune|--no-prune|--signed|--no-signed|--force-with-lease|--no-force-with-lease|--force-if-includes|--no-force-if-includes|--recurse-submodules|--no-recurse-submodules|-f|--force|--no-force|-d|--delete|--no-delete|-u|--set-upstream|--no-set-upstream|-o|--push-option|--receive-pack|--exec|--repo|--verify|--no-verify|-4|--ipv4|-6|--ipv6)\n'
    '            PROBE_POST+=( "$a" ) ;;\n')
WL_OTKAZ = (
    '          *)\n'
    '            otkaz "(обмен)" "опция не распознана" "$a — гард 130 принимает опции push только в полной форме из перечня И-2"\n'
    '            return 2 ;;\n')

G = 'gitw_teg_130.sh'
GW = 'gitw'
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
    ('s11-071-oslablen', 'c15-071-ne-oslablen', PF,
     PF_ANCHOR, PF_OSLABLEN,
     'чек (2) 071 ослаблен: отсутствующий на цели frozen-тег не блокирует push main'),
    ('s12-hold-kopiya', 'c16-hold-lend-publikaciya', G,
     '    if ! git update-ref -d "$X" "$obj"; then\n',
     '    if false; then\n',
     'hold копирует тег в refs/frozen-hold/, не снимая его из refs/tags'),
    ('s13-done-sudit', 'c10-done', G,
     '        refs/tags/frozen/*) frozen+=',
     '        refs/tags/frozen/*|refs/tags/done/*|refs/tags/id/*) frozen+=',
     'судит теги done/ и id/ как заморозку'),
    ('s14-tolko-contracts', 'c19-plans', G,
     "GRAM='^refs/tags/frozen/(contracts|plans)/", "GRAM='^refs/tags/frozen/(contracts)/",
     'грамматика без plans/'),
    ('s15-vne-grammatiki-dopusk', 'c20-vne-grammatiki', G,
     '    otkaz "$short" "тег вне грамматики" "ожидается frozen/(contracts|plans)/NNN/v"\n    return 2\n',
     '    return 0\n',
     'тег вне грамматики — допуск'),
    ('s16-pozdnij-kryuk', 'c21-push-option-o', GW,
     '      teg130 || exit $?\n      exec "$REAL" "${orig[@]}"\n',
     '      exec "$REAL" "${orig[@]}"\n',
     'гард зовётся только поздним крюком: ранний exec канарейки (значение -o принято за remote) мимо суда'),
    ('s17-bez-globalnyh', 'c30-c-followtags', G,
     '    PRE=( "${ARGS[@]:0:PSI}" ); POST=( "${ARGS[@]:PSI}" )\n',
     '    PRE=( push ); POST=( "${ARGS[@]:PSI}" )\n',
     'dry-run без глобальных флагов gitw (-c push.followTags=true потерян)'),
    ('s18-sudit-istochnik', 'c25-pereimenovanie', G,
     '      case "$to" in\n', '      case "$from" in\n',
     'судит источник refspec, не приёмник на цели'),
    ('s19-bez-force', 'c26-force', G,
     "      ' '|'+'|'*') ;;\n", "      ' '|'*') ;;\n",
     'строки принудительного сдвига (+) вне состава'),
    ('s20-tolko-annotirovannye', 'c29-head-v-teg', G,
     '      commit="$(git rev-parse --verify --quiet "${from}^{commit}" 2>/dev/null || true)"\n',
     '      [ "$(git cat-file -t "$from" 2>/dev/null)" = tag ] || continue\n'
     '      commit="$(git rev-parse --verify --quiet "${from}^{commit}" 2>/dev/null || true)"\n',
     'судит только объекты-теги: HEAD:refs/tags/frozen/… мимо суда'),
    ('s21-publish-bez-otkata', 'c31-publikaciya-do-lenda', G,
     '      git update-ref -d "$X" "$obj" || true\n',
     '      true\n',
     'publish при отказе оставляет тег в refs/tags — тупик ленда возвращается'),
    ('s22-publish-mimo-gitw', 'c31-publikaciya-do-lenda', G,
     '    bash "$SELF_DIR/gitw" push origin "$X"\n',
     '    git push -q origin "$X"\n',
     'publish пушит сырым git мимо гарда'),
    ('s23-publish-ne-snimaet-hold', 'c16-hold-lend-publikaciya', G,
     '    git update-ref -d "$H" "$obj"\n    exit $?\n',
     '    exit 0\n',
     'publish не снимает удержание после публикации'),
    ('s26-sanitiziruet-vsyo', 'c27-mirror', G,
     WL_PASS,
     WL_PASS.replace('PROBE_POST+=( "$a" )', 'PROBE_POST+=( --no-verify )'),
     'замена всех dash-токенов таблицы: состав пробы расходится с обменом (--mirror потерян)'),
    ('s28-chernyj-spisok', 'c42-opt-no-dr', G,
     WL_REPLACE + WL_PASS + WL_OTKAZ,
     '          -q|-v|--q*|--v*|--no-por*|--no-dry*)\n'
     '            PROBE_POST+=( --no-verify ) ;;\n'
     '          *)\n'
     '            PROBE_POST+=( "$a" ) ;;\n',
     'санитайзер круга 3 как есть (чёрный список префиксных семейств): --no-dr вне списка, git 2.43 отменяет пробу и публикует тег'),
    ('s29-sovpadenie-po-prefiksu', 'c45-opt-sokr-dry', G,
     WL_REPLACE,
     '          -q*|--quiet*|--no-quiet*|-v*|--verbose*|--no-verbose*|--porcelain*|--no-porcelain*|-n*|--dry*|--no-dry-run*)\n'
     '            PROBE_POST+=( --no-verify ) ;;\n',
     'белый список с совпадением по префиксу вместо точного: --dry распознаётся как --dry-run, отказа «опция не распознана» нет'),
    ('s30-propuskaet-neizvestnoe', 'c46-opt-neizvestnaya', G,
     WL_OTKAZ,
     '          *)\n'
     '            PROBE_POST+=( "$a" ) ;;\n',
     'неизвестная опция передаётся в пробу вместо отказа: git отвергает сам, класс «состав обмена не читается» вместо «опция не распознана»'),
    ('s31-no-dry-v-pass', 'c35-ne-dry-run', G,
     WL_REPLACE + WL_PASS,
     WL_REPLACE.replace('|-n|--dry-run|--no-dry-run)', '|-n|--dry-run)')
     + WL_PASS.replace('|-6|--ipv6)', '|-6|--ipv6|--no-dry-run)'),
     '--no-dry-run в PASS: проба отменяет dry-run и публикует тег раньше суда'),
    ('s32-q-v-pass', 'c38-tiho-legitimno', G,
     WL_REPLACE + WL_PASS,
     WL_REPLACE.replace('-q|--quiet', '--quiet')
     + WL_PASS.replace('|-6|--ipv6)', '|-6|--ipv6|-q)'),
     '-q в PASS вместо REPLACE: -q глушит porcelain пробы, ложный отказ «состав обмена не читается» на легитимном тихом допуске'),
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

def ensure(path, anchors, why):
    with open(path, encoding='utf-8') as f:
        text = f.read()
    for a in anchors:
        k = text.count(a)
        if k != 1:
            die('%s: якорь встречается %d раз (нужен 1) в %s: %r' % (why, k, path, a[:60]))


def model(sd):
    dst = os.path.join(sd, G)
    shutil.copyfile(os.path.join(HERE, 'model', G), dst)
    os.chmod(dst, 0o755)
    gw = os.path.join(sd, GW)
    with open(gw, encoding='utf-8') as f:
        wired = 'teg130' in f.read()
    if wired:
        # R130-A1: gitw уже несёт проводку предмета — повторная вставка дублировала
        # бы суд; существующая проводка сверяется якорями (ровно 1 раз каждый).
        ensure(gw, (IMPL_FN, IMPL_CALL, IMPL_EARLY, IMPL_LATE), 'проводка 130 уже в gitw, сверка')
        return
    subst(gw, GITW_FN_ANCHOR, GITW_FN_ANCHOR + GITW_FN)
    subst(gw, GITW_EARLY_ANCHOR, GITW_EARLY)
    subst(gw, GITW_LATE_ANCHOR, GITW_LATE + GITW_LATE_ANCHOR)


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
