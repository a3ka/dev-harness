"""К-03б (A2f, слово владельца 22.11 ~12:09): матрица недоступности.

Источник паузы читается ТРЁХЗНАЧНО: ЕСТЬ / НЕТ (замкнутое правило) /
НЕДОСТУПНО → rc 1 PROFIL_NEDOSTUPEN, учёт пуст, override не расходуется.
Одна таблица `matrix_nedostupnosti` — клетка на строку; мир строит
`nedostupnost`, ожидание задаёт столбец «ожидание» (nedostupno|pauza|start).
Префикс n NN сохраняет --domain (r-семья, 19 клеток) без изменения.
"""
import json
import os
import shutil
from pathlib import Path

OVERRIDE = 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 140 PAUZA_VLADELTSA'

# (клетка, оси, форма мира, ожидание). «охр.» — прежнее поведение, guards
# ремонта от перелёта: резолверные формы уже fail-closed на OBJECT; пауза
# и старт не зависят от соседних недоступностей; замкнутое правило НЕТ
# живо и без объявления workflowPaths (FALLBACK-NO-WORKFLOW, next_id.sh).
matrix_nedostupnosti = [
    ('n01-registry-dangling', 'К-03б;реестр=dangling-симлинк;пауза=140',
     'registry-dangling', 'nedostupno'),
    ('n02-registry-cycle', 'К-03б;реестр=цикл-симлинк;пауза=140;охр=резолвер',
     'registry-cycle', 'nedostupno'),
    ('n03-registry-external-symlink', 'К-03б;реестр=симлинк-вне-репо;пауза=140;охр=резолвер',
     'registry-external-symlink', 'nedostupno'),
    ('n04-parent-dangling', 'К-03б;родитель=dangling-симлинк;пауза=140;охр=резолвер',
     'parent-dangling', 'nedostupno'),
    ('n05-parent-cycle', 'К-03б;родитель=цикл-симлинк;пауза=140;охр=резолвер',
     'parent-cycle', 'nedostupno'),
    ('n06-pause-dangling', 'К-03б;пауза=dangling-симлинк;пауза=140',
     'pause-dangling', 'nedostupno'),
    ('n07-pause-cycle', 'К-03б;пауза=цикл-симлинк;пауза=140',
     'pause-cycle', 'nedostupno'),
    ('n08-pause-directory', 'К-03б;пауза=каталог;пауза=140',
     'pause-directory', 'nedostupno'),
    ('n09-pause-chmod000', 'К-03б;пауза=chmod-000;пауза=140;охр=права-ОС',
     'pause-chmod000', 'nedostupno'),
    ('n10-registry-dir-chmod000', 'К-03б;реестр=chmod-000;пауза=140;охр=права-ОС',
     'registry-dir-chmod000', 'nedostupno'),
    ('n11-registry-empty-string', 'К-03б;реестр=пустая-строка;охр=алфавит-резолвера',
     'registry-empty-string', 'nedostupno'),
    ('n12-registry-number', 'К-03б;реестр=число;охр=алфавит-резолвера',
     'registry-number', 'nedostupno'),
    ('n13-registry-array', 'К-03б;реестр=массив;охр=алфавит-резолвера',
     'registry-array', 'nedostupno'),
    ('n14-registry-dotdot', 'К-03б;реестр=точка-точка;охр=побег-резолвера',
     'registry-dotdot', 'nedostupno'),
    ('n15-registry-absolute-outside', 'К-03б;реестр=абсолютный-вне-репо;охр=побег-резолвера',
     'registry-absolute-outside', 'nedostupno'),
    ('n16-contracts-dangling', 'К-03б;контрактовый-реестр=dangling;пауза=140;охр=суд-паузы',
     'contracts-dangling', 'pauza'),
    ('n17-profile-dangling', 'К-03б;запись-профиля=dangling;пауза=140;охр=прежний-К-03б',
     'profile-dangling', 'nedostupno'),
    ('n18-profile-invalid-json', 'К-03б;запись-профиля=битый-JSON;пауза=140;охр=r14',
     'profile-invalid-json', 'nedostupno'),
    ('n19-profile-without-workflowpaths', 'К-03б;профиль=без-workflowPaths;охр=замкнутое-правило-НЕТ',
     'profile-without-workflowpaths', 'start'),
    ('n20-race-chitaem-potom-ischez', 'К-03б;обёртка=cat-удаляет-лист;пауза=140;охр=чтение-без-cat',
     'race', 'pauza'),
    ('n21-registry-regular-file', 'К-03б;реестр=обычный-файл;лист=отсутствует;Б-1=Rev140A2',
     'registry-regular-file', 'nedostupno'),
    ('n22-pause-external-empty', 'К-03б;лист=симлинк-вне-репо;пауза=нет;Б-2=Rev140A2',
     'pause-external-empty', 'nedostupno'),
    ('n23-pause-external-paused', 'К-03б;лист=симлинк-вне-репо;пауза=140;санкция=PAUZA;Б-2=Rev140A2',
     'pause-external-paused', 'nedostupno'),
]

BINDINGS = {
    's99-pauza-r': ['n01-registry-dangling', 'n06-pause-dangling',
                    'n08-pause-directory'],
    's100-pauza-L': ['n01-registry-dangling'],
    's101-pauza-second': ['n01-registry-dangling', 'n06-pause-dangling'],
    's102-pauza-race': ['n20-race-chitaem-potom-ischez'],
    's103-pauza-warn': ['n01-registry-dangling', 'n06-pause-dangling'],
    's104-pauza-all': ['r12-noauthor-adversary', 'r13-noauthor-critic'],
    # Адресные мутации Rev140A2; m11 уже совпадает с s100-предикатом.
    's105-pauza-m1-net-vmesto-nedostupno': ['n01-registry-dangling',
                                         'n06-pause-dangling'],
    's106-pauza-m2-dangling-kak-pauza': ['n06-pause-dangling'],
    's107-pauza-m3-sudja-po-klassu': ['r12-noauthor-adversary',
                                    'r13-noauthor-critic'],
    's108-pauza-m4a-net-kak-nedostupno': ['n19-profile-without-workflowpaths'],
    's109-pauza-m4b-prochitan-net-kak-nedostupno': ['k03b07-profil-valid-symlink-bez-pauzy'],
    's110-pauza-m6a-nedostupno-continue': ['n21-registry-regular-file',
                                        'n22-pause-external-empty'],
    's111-pauza-m6b-nedostupno-kak-pauza': ['n21-registry-regular-file',
                                         'n22-pause-external-empty'],
    's112-pauza-m6c-nedostupno-override': ['n21-registry-regular-file',
                                        'n23-pause-external-paused'],
    's113-pauza-m8-list-vne-repo': ['n22-pause-external-empty',
                                  'n23-pause-external-paused'],
    's114-pauza-m9-bez-prava-obhoda': ['n10-registry-dir-chmod000'],
    's115-pauza-m10-roditel-ne-katalog': ['n21-registry-regular-file'],
}

def nedostupnost(m, p, forma):
    """Мир: валидный профиль за симлинком записи, реестр .x/reg с паузой
    140, резервный registry/ пуст (демаркация: пауза — только в .x/reg);
    затем применяется ОДНА форма недоступности."""
    wt, br, _ = m.worktree('140', kontrakty=[
        ('fajl', '140-fixture.md', 'КЛАСС РИСКА: обычный\n')])
    puti = dict(contracts='contracts', verdicts='.profile/verdicts',
                fixtures='.profile/fixtures', registry='.x/reg')
    for otn in puti.values():
        (m.repo / otn).mkdir(parents=True, exist_ok=True)
    (m.repo / '.profile/project.json').write_text(json.dumps(dict(
        schemaVersion=1, version='1', projectId='toy140', workspaceId='toy',
        defaults={})) + '\n')
    profil = dict(schemaVersion=1, repoId=p.REPO_ID, language='bash',
                  projectLayer=dict(version='1',
                                    profilePath='.profile/project.json'),
                  workflowPaths=dict(puti))
    if forma == 'registry-empty-string':
        profil['workflowPaths']['registry'] = ''
    elif forma == 'registry-number':
        profil['workflowPaths']['registry'] = 42
    elif forma == 'registry-array':
        profil['workflowPaths']['registry'] = ['.x/reg']
    elif forma == 'registry-dotdot':
        profil['workflowPaths']['registry'] = '../outside'
    elif forma == 'registry-absolute-outside':
        profil['workflowPaths']['registry'] = str(m.root / 'vne-repo-abs')
    (m.repo / '.profile/profile.json').write_text(json.dumps(profil) + '\n')
    vhod = m.repo / 'harness.project.json'
    vhod.symlink_to('.profile/profile.json')
    reg = m.repo / '.x/reg'
    pauza = reg / 'pauzy.tsv'
    pauza.write_text('140\t2026-11-21\tвладелец\tпозже\n')
    assert not (m.repo / 'registry/pauzy.tsv').exists()
    if forma == 'registry-dangling':
        shutil.rmtree(reg)
        reg.symlink_to('gone')
    elif forma == 'registry-cycle':
        shutil.rmtree(reg)
        reg.symlink_to('reg')
    elif forma == 'registry-external-symlink':
        vne = m.root / 'vne-repo'
        shutil.move(str(reg), str(vne))
        reg.symlink_to(vne)
    elif forma == 'parent-dangling':
        shutil.rmtree(m.repo / '.x')
        (m.repo / '.x').symlink_to('gone')
    elif forma == 'parent-cycle':
        shutil.rmtree(m.repo / '.x')
        (m.repo / '.x').symlink_to('.x')
    elif forma == 'pause-dangling':
        pauza.unlink()
        pauza.symlink_to('gone')
    elif forma == 'pause-cycle':
        pauza.unlink()
        pauza.symlink_to('pauzy.tsv')
    elif forma == 'pause-directory':
        pauza.unlink()
        pauza.mkdir()
    elif forma == 'registry-regular-file':
        shutil.rmtree(reg)
        reg.write_text('обычный файл вместо каталога реестра\n')
    elif forma in ('pause-external-empty', 'pause-external-paused'):
        vne = m.root / 'vne-repo-pauzy.tsv'
        vne.write_text(pauza.read_text() if forma == 'pause-external-paused'
                       else '')
        pauza.unlink()
        pauza.symlink_to(vne)
    elif forma == 'pause-chmod000':
        pauza.chmod(0)
    elif forma == 'registry-dir-chmod000':
        reg.chmod(0)
    elif forma == 'contracts-dangling':
        (reg / 'contracts.tsv').symlink_to('gone')
    elif forma == 'profile-dangling':
        (m.repo / '.profile/profile.json').unlink()
    elif forma == 'profile-invalid-json':
        vhod.unlink()
        vhod.write_text('{broken')
    elif forma == 'profile-without-workflowpaths':
        vhod.unlink()
        vhod.write_text(json.dumps(dict(
            schemaVersion=1, repoId=p.REPO_ID, language='bash',
            projectLayer=dict(version='1',
                              profilePath='.profile/project.json'))) + '\n')
    return vhod, reg, pauza, wt, br


def dobavit(K, p):
    def register(name, axes, fn):
        K[name] = dict(osi=axes, run=fn)


    def kejs(m, door, forma, ozhidanie):
        vhod, reg, pauza, wt, br = nedostupnost(m, p, forma)
        stroki = ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br]
        if ozhidanie == 'nedostupno':
            # санкция владельца присутствует и обязана НЕ расходоваться:
            # отказ недоступности случается до разбора PAUZA-override
            stroki.append(OVERRIDE)
        privjazka = None
        if forma == 'race':
            bindir = m.root / 'bin'
            bindir.mkdir(exist_ok=True)
            obmanka = bindir / 'cat'
            obmanka.write_text(
                '#!/bin/bash\n'
                'for a in "$@"; do\n'
                '  if [ "$a" = "%s" ]; then\n'
                '    /usr/bin/rm -f -- "$a"\n'
                '    echo "обманка: пауза исчезла между проверкой и чтением" >&2\n'
                '    exit 1\n'
                '  fi\n'
                'done\n'
                'exec /usr/bin/cat "$@"\n' % pauza)
            obmanka.chmod(0o755)
            star = p.GIT_ENV['PATH']
            p.GIT_ENV['PATH'] = str(bindir) + ':' + star
            privjazka = star
        try:
            if forma == 'pause-chmod000':
                if os.access(pauza, os.R_OK, effective_ids=True):
                    print('SKIP n09-pause-chmod000: chmod 000 не запрещает чтение '
                          'текущему uid=%d' % os.geteuid())
                    return []
            if forma == 'registry-dir-chmod000':
                if os.access(reg, os.X_OK, effective_ids=True):
                    print('SKIP n10-registry-dir-chmod000: chmod 000 не запрещает '
                          'обход текущему uid=%d' % os.geteuid())
                    return []
            sobytie = m.sobytie('matrix-nedostupnosti.json', [p.item(
                'architect', 'Matrix140', stroki, isolated=True)])
            before = p.snimok_fajlov(m.sost)
            r = p.sudit(door, m, sobytie)
        finally:
            if privjazka is not None:
                p.GIT_ENV['PATH'] = privjazka
            # Включая SKIP/исключение: rmtree должен обойти мир n10 (С-8).
            if forma == 'registry-dir-chmod000':
                reg.chmod(reg.stat().st_mode | 0o700)
            if forma == 'pause-chmod000':
                pauza.chmod(pauza.stat().st_mode | 0o600)
        if ozhidanie == 'start':
            return [p.k_rc(r, 0, 'замкнутое-правило-НЕТ'),
                    None if 'PUSCHEM Matrix140 dev-harness/140 (rabochij/architect)'
                    in r.stdout.splitlines() else 'нет собственной строки PUSCHEM',
                    p.k_chislo_startov(m, 'учёт', 1),
                    p.k_stroka(m, 'START-при-отсутствии-паузы', subjectId='140',
                               holder='Matrix140', isolated=True),
                    p.k_zanyat(m, '140', 'Matrix140', 'занятие')]
        prichina = 'PROFIL_NEDOSTUPEN' if ozhidanie == 'nedostupno' \
            else 'PAUZA_VLADELTSA'
        return [p.k_rc(r, 1, 'недоступность=' + forma),
                None if any(line.startswith('ОТКАЗ: ' + prichina + ':')
                            for line in r.stderr.splitlines())
                else 'нет самостоятельной строки отказа ' + prichina,
                p.k_net_startov(m, 'отказ-без-START/override'),
                None if p.snimok_fajlov(m.sost) == before
                else 'отказ изменил состояние']

    for imja, osi, forma, ozhidanie in matrix_nedostupnosti:
        register(imja, osi,
                 lambda m, d, f=forma, o=ozhidanie: kejs(m, d, f, o))


# ── стабы (Н-39: якоря — литералы [D63] ремонта модели) ─────────────────────
_BLOK_TRIO = '''  if [ -e "$f" ] || [ -L "$f" ]; then
    l="$(readlink -f -- "$f" 2>/dev/null)" || return 2
    case "$l" in "$koren"/*) ;; *) return 2 ;; esac
    [ -f "$l" ] || return 2
    [ -r "$l" ] || return 2
    f="$l"
  else
    d="${f%/*}"
    while [ "$d" != "$koren" ]; do
      case "$d" in
        /) return 2 ;;
      esac
      if [ -L "$d" ]; then return 2; fi
      if [ -d "$d" ]; then
        [ -x "$d" ] || return 2
      elif [ -e "$d" ]; then
        return 2
      fi
      d="${d%/*}"
    done
    return 1
  fi
'''

_CIKL_PAUZY = '''    if na_pauze "$psv"; then
      :
    else
      case "$?" in
        1) continue ;;
        *) otp PROFIL_NEDOSTUPEN "путь реестра паузы предмета $psv не удостоверен" ;;
      esac
    fi
'''


def mutacii(z):
    return {
        's99-pauza-r': lambda t: z(t, _BLOK_TRIO,
                                    '''  [ -r "$f" ] || return 1
'''),
        's100-pauza-L': lambda t: z(t, '''      if [ -L "$d" ]; then return 2; fi
''', ''),
        's101-pauza-second': lambda t: z(t, _CIKL_PAUZY, '''    if [ -r "$(reestr_put "$REPO" pauzy.tsv)" ] && grep -q "$(printf '^%s\\t' "$psv")" "$(reestr_put "$REPO" pauzy.tsv)"; then
      :
    else
      continue
    fi
'''),
        's102-pauza-race': lambda t: z(t, '''  done < "$f"
  return 1
}''', '''  done < <(cat "$f")
  return 1
}'''),
        's103-pauza-warn': lambda t: z(t,
            '        *) otp PROFIL_NEDOSTUPEN "путь реестра паузы предмета $psv не удостоверен" ;;',
            '''        *) printf 'ПРЕДУПРЕЖДЕНИЕ: PROFIL_NEDOSTUPEN: путь реестра паузы предмета %s не удостоверен\\n' "$psv" >&2; continue ;;'''),
        's104-pauza-all': lambda t: z(t, '''  while IFS='|' read -r pidx _ _ psv pobj _ _ _ _; do
    [ -n "$psv" ] || continue
    if na_pauze "$psv"; then''', '''  while IFS='|' read -r pidx agent _ psv pobj _ _ _ _; do
    [ -n "$psv" ] || continue
    case "$agent" in critic|adversary) otp PROFIL_NEDOSTUPEN "ошибка профиля" ;; esac
    if na_pauze "$psv"; then'''),
        's105-pauza-m1-net-vmesto-nedostupno': lambda t: z(
            t, _BLOK_TRIO, _BLOK_TRIO.replace('return 2', 'return 1')),
        's106-pauza-m2-dangling-kak-pauza': lambda t: z(
            t, '    [ -f "$l" ] || return 2\n',
            '    [ -e "$l" ] || return 0\n'
            '    [ -f "$l" ] || return 2\n'),
        's107-pauza-m3-sudja-po-klassu': lambda t: z(
            t, '''  while IFS='|' read -r pidx _ _ psv pobj _ _ _ _; do
    [ -n "$psv" ] || continue
    if na_pauze "$psv"; then''', '''  while IFS='|' read -r pidx _ _ psv pobj _ _ pklass _; do
    [ -n "$psv" ] || continue
    [ "$pklass" != sudja ] || otp PROFIL_NEDOSTUPEN "стаб m3: судья по классу"
    if na_pauze "$psv"; then'''),
        's108-pauza-m4a-net-kak-nedostupno': lambda t: z(
            t, _BLOK_TRIO, _BLOK_TRIO.replace(
                '    return 1\n  fi\n', '    return 2\n  fi\n')),
        's109-pauza-m4b-prochitan-net-kak-nedostupno': lambda t: z(
            t, '  done < "$f"\n  return 1\n}',
            '  done < "$f"\n  return 2\n}'),
        's110-pauza-m6a-nedostupno-continue': lambda t: z(
            t, _CIKL_PAUZY, _CIKL_PAUZY.replace(
                '        *) otp PROFIL_NEDOSTUPEN "путь реестра паузы предмета $psv не удостоверен" ;;',
                '        *) continue ;;')),
        's111-pauza-m6b-nedostupno-kak-pauza': lambda t: z(
            t, _CIKL_PAUZY, _CIKL_PAUZY.replace(
                '        *) otp PROFIL_NEDOSTUPEN "путь реестра паузы предмета $psv не удостоверен" ;;',
                '        *) otp PAUZA_VLADELTSA "стаб m6b: недоступность как пауза" ;;')),
        's112-pauza-m6c-nedostupno-override': lambda t: z(
            t, _CIKL_PAUZY, _CIKL_PAUZY.replace(
                '        *) otp PROFIL_NEDOSTUPEN "путь реестра паузы предмета $psv не удостоверен" ;;',
                '        *) : ;;')),
        's113-pauza-m8-list-vne-repo': lambda t: z(
            t, '    case "$l" in "$koren"/*) ;; *) return 2 ;; esac\n', ''),
        's114-pauza-m9-bez-prava-obhoda': lambda t: z(
            t, '        [ -x "$d" ] || return 2\n',
            '        : # стаб m9: право обхода не проверяется\n'),
        's115-pauza-m10-roditel-ne-katalog': lambda t: z(
            t, '      elif [ -e "$d" ]; then\n        return 2\n', ''),
    }

def jakor_bez_pauzy():
    """Якорь s15-bez-pauzy: восстановленное тело na_pauze после [D63]
    (без строки объявления функции); стабильная замена прежнего якоря
    «[ -r ] || return 1», ушедшего из модели вместе с дефектом К-03б."""
    return ('  koren="$(cd "$REPO" 2>/dev/null && pwd -P)" || return 2\n'
            + _BLOK_TRIO
            + '''  while IFS= read -r l; do
    case "$l" in '#'*|'') continue ;; esac
    [ "${l%%$'\\t'*}" = "$1" ] && return 0
  done < "$f"
  return 1
''')


if __name__ == '__main__':
    import subprocess
    import sys
    import tempfile
    root = Path(__file__).resolve().parents[3]
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    import probe as p
    dver = root / 'scripts/zamok_predmeta.sh'
    model = Path(__file__).resolve().parent / 'model/zamok_predmeta.sh'
    for imja, _osi, forma, ozhidanie in matrix_nedostupnosti:
        for subjekt in (dver, model):
            with tempfile.TemporaryDirectory(prefix='a2f-') as d:
                m = p.Mir(d)
                vhod, reg, pauza, wt, br = nedostupnost(m, p, forma)
                stroki = ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br]
                if ozhidanie == 'nedostupno':
                    stroki.append(OVERRIDE)
                sobytie = m.sobytie('m.json', [p.item(
                    'architect', 'Matrix140', stroki, isolated=True)])
                try:
                    r = p.sudit(subjekt, m, sobytie)
                    print('%s %s rc=%d stdout=%r stderr=%r ledger=%r' % (
                        subjekt.name, forma, r.returncode, r.stdout,
                        r.stderr, m.ledg()), flush=True)
                finally:
                    if forma == 'pause-chmod000':
                        pauza.chmod(pauza.stat().st_mode | 0o600)
                    if forma == 'registry-dir-chmod000':
                        reg.chmod(reg.stat().st_mode | 0o700)
