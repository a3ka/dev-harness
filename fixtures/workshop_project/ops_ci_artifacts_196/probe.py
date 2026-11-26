#!/usr/bin/env python3
"""Батарея 196 «локальное хранилище артефактов CI на станции» (ops/server).

Режимы:
  --model     все клетки против исполнительной модели (fixtures/.../model/) —
              честная реализация обязана быть зелёной;
  --stabs     каждый обманный стаб (stabs/) на НАЗНАЧЕННОМ ему входе обязан
              быть пойман оракулом клетки (Н-39: привязки — здесь, кодом);
  --repo <R>  клетки против реального дерева R (субъекты ops/server/...);
  без флагов  то же, что --repo <корень репо батареи> (суд реального субъекта).

Оракул каждой клетки живёт в ПАМЯТИ проверяющего: ожидания снимаются из мира,
построенного пробой, ДО вызова субъекта; диск субъекта как истина не
перечитывается. Каждый вход красен СВОИМ предъявлением; миры одноразовые,
временные (А-230: никаких приватных trap-каталогов внутри клеток).

rc: 0 — всё зелёное (для --stabs: все обманки пойманы); 1 — красная клетка
или живой стаб; 2 — NOT_IMPLEMENTED (нет файлов семьи/модели, нет корня).
"""
import os
import pwd
import shutil
import stat
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]

CASES = (
    'young-kept', 'old-removed', 'young-inside-file', 'symlink-run-refused',
    'repo-symlink-refused', 'traversal-repo-refused', 'grammar-refused',
    'undeclared-untouched', 'retention-seam', 'root-missing', 'no-home-service-env',
    'install-artifacts', 'install-precondition', 'install-euid-refused',
    'install-repo-symlink-refused', 'install-systemctl-refused',
    'install-roots-preinstalled', 'verify-drift', 'verify-not-installed',
    'verify-roots', 'verify-runner-dropin', 'install-runner-dropin',
    'runner-dropin-absent', 'unit-grammar', 'readme-anchors',
)

# Н-39: привязка обманного стаба к входу, где его дефект НАБЛЮДАМ.
# имя файла в stabs/ → (вид субъекта, клетка-вход)
STUBS = {
    's01_molodost_po_verhnej_papke.sh': ('clean', 'young-inside-file'),
    's02_bez_strazha_symlinkov.sh': ('clean', 'symlink-run-refused'),
    's03_bez_kornja.sh': ('clean', 'repo-symlink-refused'),
    's04_bez_grammatiki.sh': ('clean', 'grammar-refused'),
    's05_vse_repo.sh': ('clean', 'undeclared-untouched'),
    's06_bez_sroka.sh': ('clean', 'young-kept'),
    's07_bez_preduslovija.sh': ('install', 'install-precondition'),
    's08_bez_gruppy.sh': ('install', 'install-artifacts'),
    's09_bez_enable.sh': ('install', 'install-artifacts'),
    's10_bez_persistent.timer': ('unit', 'unit-grammar'),
    's11_slepaja_sverka.sh': ('install', 'verify-drift'),
    's12_chitaet_home.sh': ('clean', 'no-home-service-env'),
    's13_bez_euid_garda.sh': ('install', 'install-euid-refused'),
    's14_skvoz_symlink_repos.sh': ('install', 'install-repo-symlink-refused'),
    's15_glotit_systemctl.sh': ('install', 'install-systemctl-refused'),
    's16_bez_vetki_ne_ustanovleny.sh': ('install', 'verify-not-installed'),
    's17_bez_sverki_kornej.sh': ('install', 'verify-roots'),
    's18_readme_bez_razdela.md': ('readme', 'readme-anchors'),
    's19_slepaja_k_service.sh': ('install', 'verify-drift'),
    's20_slepaja_k_timer.sh': ('install', 'verify-drift'),
    's21_bez_sverki_kornja_beka.sh': ('install', 'verify-roots'),
    's22_ne_ustanovleny_na_chastichnoj.sh': ('install', 'verify-not-installed'),
    's23_bez_vladelca_kornja.sh': ('install', 'verify-roots'),
    's24_poryadok_vkljuchenija_obratnyj.sh': ('install', 'install-artifacts'),
    's25_dropin_ne_stavitsja.sh': ('install', 'install-runner-dropin'),
    's26_dropin_na_koren_beka.sh': ('install', 'install-runner-dropin'),
    's27_dropin_bez_daemon_reload.sh': ('install', 'install-runner-dropin'),
    's28_dropin_bez_junita.sh': ('install', 'runner-dropin-absent'),
    's29_verify_bez_sverki_dropina.sh': ('install', 'verify-runner-dropin'),
    # арбитраж 196-1 (Решение 2): стабы пяти блоков v3 — mk10/mk8/mk6/mk7/mk5
    's30_bez_istochnika_dropina.sh': ('install', 'install-precondition'),
    's31_bez_sverki_bazy.sh': ('install', 'install-roots-preinstalled'),
    's32_bez_vladelca_kornja_moba.sh': ('install', 'verify-roots'),
    's33_verify_dropin_pervogo_junita.sh': ('install', 'verify-runner-dropin'),
    's34_bez_rezhima_kornej.sh': ('install', 'install-roots-preinstalled'),
}

MOB = 'Complior-mob'
DAY = 86400
BACK = 'Complior-back'
# юниты моб-раннера станции (вне репо): drop-in ставится по наличию юнита
RUNNER_UNITS = ('gh-runner-complior', 'gh-runner-complior-2')
README_ANCHORS = (
    '/var/lib/ci-artifacts/',
    'sudo bash ops/server/install.sh artifacts',
    'ci-artifacts-clean.timer',
    'CI_ARTIFACTS_RETENTION_DAYS',
    'владелец `harness`',
    'группа harness',
    'на GitHub артефакты не загружаются',
    'ОТКАЗ:',
    'systemctl disable --now ci-artifacts-clean.timer',
)


def refuse(msg):
    print(f'KRASNO: {msg}', file=sys.stderr)
    sys.exit(2)


def set_age(path, age_s):
    """Возраст записи мира; для символьных ссылок — самой ссылки (не цели)."""
    when = time.time() - age_s
    os.utime(path, (when, when), follow_symlinks=False)


# ── миры ──────────────────────────────────────────────────────────────────────
class World:
    def __init__(self):
        self.dir = Path(tempfile.mkdtemp(prefix='ops196-'))
        self.journals = {}

    def close(self):
        shutil.rmtree(self.dir, ignore_errors=True)

    def path(self, *parts):
        return self.dir.joinpath(*parts)

    def write_shims(self, users=(), groups=(), euid=0, systemctl='ok',
                    stat_owners=(), dropin_probes=()):
        # stat_owners — конфигурация владельцев корней для stat-шима
        # (вердикт v2, совет а): строки «<путь> TAB <владелец:группа>»;
        # формат %U:%G читается из неё, %a — реальный stat (режим не врёт);
        # dropin_probes — drop-in'ы моб-раннера: маркер daemon-reload пишет
        # по КАЖДОМУ, существовал ли файл на момент reload (И-9е: reload
        # ПОСЛЕ установки drop-in; в конфигурации 11 наблюдаемы оба)
        bin_dir = self.path('bin')
        bin_dir.mkdir(exist_ok=True)
        # журналы швов создаются ДО прогона: любые chown/chmod субъекта
        # наблюдаемы журналом с пустого состояния (РЕШЕНИЕ 3.2 арбитра)
        for jname in ('chown', 'chmod', 'systemctl'):
            self.journals[jname] = self.path(f'{jname}.journal')
            self.journals[jname].write_text('')
        users_cfg = self.path('known-users')
        groups_cfg = self.path('known-groups')
        users_cfg.write_text('\n'.join(users) + '\n')
        groups_cfg.write_text('\n'.join(groups) + '\n')
        stat_cfg = self.path('stat-owners')
        stat_cfg.write_text(
            ''.join(f'{p}\t{og}\n' for p, og in stat_owners))
        # systemctl='fail-reload'/'fail-enable' — шим, отказывающий на
        # daemon-reload/enable (И-9д: именованные отказы включения)
        if systemctl == 'fail-reload':
            ctl_tail = '[ "$1" = "daemon-reload" ] && exit 1\nexit 0\n'
        elif systemctl == 'fail-enable':
            ctl_tail = '[ "$1" = "enable" ] && exit 1\nexit 0\n'
        else:
            ctl_tail = 'exit 0\n'
        shims = {
            # id -u → euid (умолчание 0): euid-гард субъекта проходится
            # непривилегированным тест-миром (прецедент fix_090, клетка Н-216);
            # euid=1 — вход «не-root прогон» клетки install-euid-refused
            'id': (
                '#!/bin/bash\n'
                f'[ "$1" = "-u" ] && {{ echo {euid}; exit 0; }}\n'
                'exec /usr/bin/id "$@"\n'
            ),
            'chown': (
                '#!/bin/bash\n'
                f'printf \'%s\\n\' "chown $*" >>"{self.journals["chown"]}"\nexit 0\n'
            ),
            # chmod-шим (арбитраж 196-1, РЕШЕНИЕ 3.2): ЖУРНАЛ + настоящий
            # exec — реальный chmod при создании и дрейфе остаётся
            # исполняемым (не no-op), а ЛЮБОЙ chmod по корням наблюдаем
            # журналом: одного неизменного конечного режима недостаточно
            'chmod': (
                '#!/bin/bash\n'
                f'printf \'%s\\n\' "chmod $*" >>"{self.journals["chmod"]}"\n'
                'exec /usr/bin/chmod "$@"\n'
            ),
            'systemctl': (
                '#!/bin/bash\n'
                f'printf \'%s\\n\' "systemctl $*" >>"{self.journals["systemctl"]}"\n'
                + ''.join(
                    'if [ "$1" = "daemon-reload" ]; then\n'
                    f'  if [ -f "{p}" ]; then m=yes; else m=no; fi\n'
                    f'  printf \'daemon-reload-dropin={p}:%s\\n\' "$m" >>"{self.journals["systemctl"]}"\n'
                    'fi\n'
                    for p in dropin_probes)
                + ctl_tail
            ),
            'getent': (
                '#!/bin/bash\n'
                f'db="$1"; name="$2"\n'
                f'case "$db" in\n'
                f'  passwd) grep -Fxq -- "$name" "{users_cfg}" || exit 2 ;;\n'
                f'  group)  grep -Fxq -- "$name" "{groups_cfg}" || exit 2 ;;\n'
                f'  *) exit 2 ;;\n'
                f'esac\n'
                f'printf \'%s:x:1:1::/:/bin/false\\n\' "$name"\nexit 0\n'
            ),
            # stat-шим (вердикт v2, совет а): форма модели stat -c FMT -- PATH;
            # %U:%G — из конфигурации мира (chown в шов-мире — шим журнала,
            # реальный stat соврал бы о владельце), прочие форматы — честный
            # stat: режим %a всегда реален, дрейф режима наблюдаем файлово
            'stat': (
                '#!/bin/bash\n'
                'orig=("$@")\n'
                '[ "$1" = "-c" ] || exec /usr/bin/stat "${orig[@]}"\n'
                'fmt="$2"\n'
                'path="${orig[$(( ${#orig[@]} - 1 ))]}"\n'
                'if [ "$fmt" = "%U:%G" ] && [ -n "$path" ]; then\n'
                f'  og="$(awk -F\'\\t\' -v p="$path" \'$1 == p {{ print $2 }}\' "{stat_cfg}" 2>/dev/null)" || og=""\n'
                '  if [ -n "$og" ]; then\n'
                '    printf \'%s\\n\' "$og"\n'
                '    exit 0\n'
                '  fi\n'
                'fi\n'
                'exec /usr/bin/stat "${orig[@]}"\n'
            ),
        }
        for name, text in shims.items():
            p = bin_dir / name
            p.write_text(text)
            p.chmod(0o755)
        return bin_dir

    def journal(self, name):
        p = self.journals[name]
        return p.read_text().splitlines() if p.exists() else []

    def run(self, argv, env, cwd=None, home=True):
        # home=False — среда systemd-юнита root без HOME (грабель Н-217):
        # честный чистильщик обязан работать и в ней
        merged = dict(os.environ)
        merged.update(env)
        merged['PATH'] = env['PATH']
        merged['HOME'] = str(self.path('home'))
        if not home:
            merged.pop('HOME', None)
        proc = subprocess.run(argv, cwd=cwd or str(self.dir), env=merged,
                              stdin=subprocess.DEVNULL,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              text=True, timeout=120)
        return proc.returncode, proc.stdout, proc.stderr


def mk_run(root, repo, name, age_dir, files):
    """Прогон <run>/<имя-артефакта>/файл; возрасты заданы явно."""
    run_dir = root / repo / name
    for sub, age_sub, fname, age_file in files:
        sub_dir = run_dir / sub
        sub_dir.mkdir(parents=True, exist_ok=True)
        f = sub_dir / fname
        f.write_bytes(b'evidence\n')
        set_age(f, age_file)
        set_age(sub_dir, age_sub)
    set_age(run_dir, age_dir)
    return run_dir


# ── субъекты ─────────────────────────────────────────────────────────────────
class Subjects:
    """Откуда брать файлы субъекта: модель / реальное дерево / обманный стаб."""

    def __init__(self, kind, repo_root=None, stub=None):
        self.kind = kind
        self.repo_root = Path(repo_root).resolve() if repo_root else None
        self.stub = stub

    def clean(self):
        if self.kind == 'model':
            return HERE / 'model' / 'ci-artifacts-clean'
        if self.kind == 'stub':
            return HERE / 'stabs' / self.stub
        p = self.repo_root / 'ops/server/root/ci-artifacts-clean'
        return p if p.exists() else None

    def install(self):
        if self.kind == 'model':
            return ['bash', str(HERE / 'model' / 'install-artifacts.sh')]
        if self.kind == 'stub':
            return ['bash', str(HERE / 'stabs' / self.stub)]
        p = self.repo_root / 'ops/server/install.sh'
        return ['bash', str(p)] if p.exists() else None

    def install_modes(self):
        """(режим установки, режим сверки) — имена подкоманд субъекта."""
        if self.kind == 'repo':
            return 'artifacts', 'verify'
        return 'artifacts', 'verify-artifacts'

    def unit(self, which):
        if self.kind == 'model':
            return HERE / 'model' / f'ci-artifacts-clean.{which}'
        if self.kind == 'stub' and which == 'timer':
            return HERE / 'stabs' / self.stub
        if self.kind == 'stub':
            return HERE / 'model' / f'ci-artifacts-clean.{which}'
        p = self.repo_root / f'ops/server/root/systemd/ci-artifacts-clean.{which}'
        return p if p.exists() else None

    def readme(self):
        if self.kind == 'model':
            return HERE / 'model' / 'README-ops-server.md'
        if self.kind == 'stub':
            return HERE / 'stabs' / self.stub
        p = self.repo_root / 'ops/server/README.md'
        return p if p.exists() else None

    def src_ops(self, world):
        """Каталог-источник OPS_SERVER_SRC: root/ci-artifacts-clean, юниты и
        drop-in моб-раннера (gh-runner-complior-ci-artifacts.conf)."""
        if self.kind == 'repo':
            return self.repo_root / 'ops/server'
        src = world.path('ops-server')
        (src / 'root/systemd').mkdir(parents=True)
        shutil.copyfile(HERE / 'model' / 'ci-artifacts-clean', src / 'root/ci-artifacts-clean')
        shutil.copyfile(HERE / 'model' / 'ci-artifacts-clean.service',
                        src / 'root/systemd/ci-artifacts-clean.service')
        shutil.copyfile(HERE / 'model' / 'ci-artifacts-clean.timer',
                        src / 'root/systemd/ci-artifacts-clean.timer')
        shutil.copyfile(HERE / 'model' / 'gh-runner-complior-ci-artifacts.conf',
                        src / 'root/gh-runner-complior-ci-artifacts.conf')
        if self.kind == 'stub' and self.stub.endswith('.timer'):
            shutil.copyfile(HERE / 'stabs' / self.stub,
                            src / 'root/systemd/ci-artifacts-clean.timer')
        return src


def no_subject(name):
    return False, f'субъект отсутствует: {name}'

def install_missing(rc, err):
    """До реализации install.sh не знает подкоманду artifacts — честное красное."""
    if 'NOT_IMPLEMENTED: использование' in err:
        return f'субъект отсутствует: install.sh artifacts (rc={rc})'
    return f'rc={rc}, stderr: {err.strip()[:300]}'


def src_ops_missing(subj, w, rel):
    """Одноразовая копия OPS_SERVER_SRC без одного источника (РЕШЕНИЕ 3.2
    арбитра): предъявленный репозиторий не mutilруется — для repo-субъекта
    ops/server копируется целиком в мир, у модели/стаба файл удаляется в
    уже одноразовой копии мира."""
    src = subj.src_ops(w)
    if subj.kind == 'repo':
        dst = w.path('ops-server-copy')
        shutil.copytree(src, dst, symlinks=True)
        (dst / rel).unlink()
        return dst
    (src / rel).unlink()
    return src


def subject_writes(w, runner_units=()):
    """Записи субъекта в целевых деревьях после отказа «до записей»
    (РЕШЕНИЕ 3.2): корень артефактов ЦЕЛИКОМ (база, корни, пустые
    каталоги), sbin-адресат, новые записи ETC_DST (юниты, .d-каталоги)
    сверх сотворённых миром юнитов-раннеров, любые chown/chmod.
    Подготовка мира и журналы швов записями субъекта не считаются."""
    wrote = []
    ciart = w.path('var/lib/ci-artifacts')
    if ciart.exists():
        wrote.append(f'создан корень артефактов: {ciart}')
    sbin = w.path('sbin')
    if sbin.exists():
        wrote.append(f'создан sbin: {sbin}')
    etc = w.path('etc/systemd/system')
    if etc.exists():
        allowed = {f'{u}.service' for u in runner_units}
        for child in sorted(p.name for p in etc.iterdir()):
            if child not in allowed:
                wrote.append(f'создан etc-адресат: {etc / child}')
    for jname in ('chown', 'chmod'):
        wrote.extend(w.journal(jname))
    return wrote



# ── клетки чистильщика ────────────────────────────────────────────────────────
def clean_env(world, root, repos=f'{MOB} {BACK}', retention='7'):
    return {
        'CI_ARTIFACTS_ROOT': str(root),
        'CI_ARTIFACTS_RETENTION_DAYS': retention,
        'CI_ARTIFACTS_REPOS': repos,
        'PATH': f'{world.path("bin")}:/usr/bin:/bin',
    }


def cell_young_kept(subj):
    w = World()
    try:
        w.write_shims()
        root = w.path('var/lib/ci-artifacts')
        run1 = mk_run(root, MOB, '101-1', 120, [('screens', 120, 'a.png', 120)])
        run2 = mk_run(root, BACK, '202-2', 120, [('apk', 120, 'app.apk', 120)])
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)], clean_env(w, root))
        if rc != 0:
            return False, f'rc={rc}, stderr: {err.strip()[:200]}'
        if not run1.exists() or not run2.exists():
            return False, 'молодой прогон удалён'
        if 'ОТКАЗ' in err:
            return False, f'отказ на честном входе: {err.strip()[:200]}'
        if f'ci-artifacts: репо {MOB}: удалено 0, хранится 1' not in out:
            return False, f'сводка без хранения: {out.strip()[:200]}'
        return True, ''
    finally:
        w.close()


def cell_old_removed(subj):
    w = World()
    try:
        w.write_shims()
        root = w.path('var/lib/ci-artifacts')
        old = 7 * DAY + 7200
        run1 = mk_run(root, MOB, '303-1', old, [('screens', old, 'a.png', old)])
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)], clean_env(w, root))
        if rc != 0:
            return False, f'rc={rc}, stderr: {err.strip()[:200]}'
        if run1.exists():
            return False, 'старый прогон хранится'
        if f'удалено: {run1}' not in out:
            return False, 'нет строки удаления прогона'
        if 'удалено 1, хранится 0' not in out:
            return False, f'сводка не сходится: {out.strip()[:200]}'
        return True, ''
    finally:
        w.close()


def cell_young_inside_file(subj):
    w = World()
    try:
        w.write_shims()
        root = w.path('var/lib/ci-artifacts')
        old = 7 * DAY + 7200
        run1 = mk_run(root, MOB, '404-1', old, [('screens', old, 'late.png', 120)])
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)], clean_env(w, root))
        if rc != 0:
            return False, f'rc={rc}, stderr: {err.strip()[:200]}'
        if not run1.exists():
            return False, 'прогон удалён при молодом файле внутри'
        return True, ''
    finally:
        w.close()


def cell_symlink_run_refused(subj):
    w = World()
    try:
        w.write_shims()
        root = w.path('var/lib/ci-artifacts')
        old = 7 * DAY + 7200
        run_old = mk_run(root, MOB, '505-1', old, [('screens', old, 'a.png', old)])
        outside = w.path('outside')
        secret = outside / 'secret.png'
        outside.mkdir(parents=True)
        secret.write_bytes(b'secret\n')
        link = root / MOB / '606-1'
        link.symlink_to(outside, target_is_directory=True)
        set_age(link, old)
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)], clean_env(w, root))
        if rc != 1:
            return False, f'rc={rc} (ожидался отказ 1)'
        if 'ОТКАЗ: прогон — символьная ссылка' not in err:
            return False, f'нет именованного отказа на ссылку-прогон: {err.strip()[:200]}'
        if not link.exists():
            return False, 'символьная ссылка-прогон удалена'
        if not secret.exists():
            return False, 'цель ссылки повреждена'
        if run_old.exists():
            return False, 'старый прогон не удалён из-за ссылки (очистка встала)'
        return True, ''
    finally:
        w.close()


def cell_repo_symlink_refused(subj):
    w = World()
    try:
        w.write_shims()
        root = w.path('var/lib/ci-artifacts')
        old = 7 * DAY + 7200
        run_mob = mk_run(root, MOB, '808-1', old, [('screens', old, 'a.png', old)])
        outside = w.path('outside-store')
        outside_run = outside / '707-1'
        outside_run.mkdir(parents=True)
        (outside_run / 'evidence.txt').write_bytes(b'x\n')
        set_age(outside_run / 'evidence.txt', old)
        set_age(outside_run, old)
        back_link = root / BACK
        back_link.symlink_to(outside, target_is_directory=True)
        set_age(back_link, old)
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)], clean_env(w, root))
        if rc != 1:
            return False, f'rc={rc} (ожидался отказ 1)'
        if f'ОТКАЗ: репо не каталог: {back_link}' not in err:
            return False, f'нет именованного отказа на репо-ссылку: {err.strip()[:200]}'
        if not outside_run.exists():
            return False, 'удаление вышло за корень через ссылку-репо'
        if run_mob.exists():
            return False, 'честное репо моба не вычищено'
        return True, ''
    finally:
        w.close()


def cell_traversal_repo_refused(subj):
    w = World()
    try:
        w.write_shims()
        root = w.path('var/lib/ci-artifacts')
        old = 7 * DAY + 7200
        run1 = mk_run(root, MOB, '909-1', old, [('screens', old, 'a.png', old)])
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)],
                             clean_env(w, root, repos=f'{MOB} ../..'))
        if rc != 1:
            return False, f'rc={rc} (ожидался отказ 1)'
        if 'ОТКАЗ: недопустимое имя репо: ../..' not in err:
            return False, f'нет именованного отказа на ../..: {err.strip()[:200]}'
        if not run1.exists():
            return False, 'при недопустимом имени репо что-то удалено'
        return True, ''
    finally:
        w.close()


def cell_grammar_refused(subj):
    w = World()
    try:
        w.write_shims()
        root = w.path('var/lib/ci-artifacts')
        old = 7 * DAY + 7200
        stray = root / MOB / 'manual-upload'
        stray.mkdir(parents=True)
        (stray / 'x.txt').write_bytes(b'x\n')
        set_age(stray / 'x.txt', old)
        set_age(stray, old)
        run_ok = mk_run(root, MOB, '111-1', old, [('screens', old, 'a.png', old)])
        run_file = root / MOB / '777-8'
        run_file.write_bytes(b'not a dir\n')
        set_age(run_file, old)
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)], clean_env(w, root))
        if rc != 1:
            return False, f'rc={rc} (ожидался отказ 1)'
        if f'имя прогона вне грамматики <число>-<число>: {stray}' not in err:
            return False, f'нет отказа на имя вне грамматики: {err.strip()[:200]}'
        if f'ОТКАЗ: прогон не каталог: {run_file}' not in err:
            return False, f'нет отказа «прогон не каталог»: {err.strip()[:200]}'
        if not stray.exists():
            return False, 'каталог вне грамматики удалён'
        if run_ok.exists():
            return False, 'валидный старый прогон не удалён'
        return True, ''
    finally:
        w.close()


def cell_undeclared_untouched(subj):
    w = World()
    try:
        w.write_shims()
        root = w.path('var/lib/ci-artifacts')
        old = 7 * DAY + 7200
        web_run = mk_run(root, 'Complior-web', '222-1', old, [('screens', old, 'a.png', old)])
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)], clean_env(w, root))
        if rc != 0:
            return False, f'rc={rc}, stderr: {err.strip()[:200]}'
        if not web_run.exists():
            return False, 'необъявленный каталог репо вычищен'
        if 'Complior-web' in out:
            return False, 'необъявленное репо упомянуто в сводке'
        return True, ''
    finally:
        w.close()


def cell_retention_seam(subj):
    subject = subj.clean()
    if subject is None:
        return no_subject('ops/server/root/ci-artifacts-clean')
    for retention, must_exist in (('7', True), ('2', False)):
        w = World()
        try:
            w.write_shims()
            root = w.path('var/lib/ci-artifacts')
            age = 3 * DAY
            run1 = mk_run(root, MOB, '606-1', age, [('screens', age, 'a.png', age)])
            rc, out, err = w.run([str(subject)], clean_env(w, root, retention=retention))
            if rc != 0:
                return False, f'срок {retention}: rc={rc}, stderr: {err.strip()[:200]}'
            if run1.exists() != must_exist:
                return False, (f'срок {retention}: прогон '
                               f'{"хранится" if run1.exists() else "удалён"} вопреки шву')
        finally:
            w.close()
    return True, ''


def cell_root_missing(subj):
    w = World()
    try:
        w.write_shims()
        nope = w.path('no-such-root')
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)], clean_env(w, nope))
        if rc != 1:
            return False, f'rc={rc} (ожидался отказ 1)'
        if f'ОТКАЗ: корень не каталог: {nope}' not in err:
            return False, f'нет отказа на отсутствующий корень: {err.strip()[:200]}'
        return True, ''
    finally:
        w.close()



def cell_no_home_service_env(subj):
    """Грабель Н-217: systemd-юнит root приходит БЕЗ HOME — чистильщик не
    имеет права читать HOME ни в одной ветке (orch-peak падал на этом)."""
    w = World()
    try:
        w.write_shims()
        root = w.path('var/lib/ci-artifacts')
        old = 7 * DAY + 7200
        run_old = mk_run(root, MOB, '121-1', old, [('screens', old, 'a.png', old)])
        run_young = mk_run(root, MOB, '131-1', 120, [('apk', 120, 'app.apk', 120)])
        subject = subj.clean()
        if subject is None:
            return no_subject('ops/server/root/ci-artifacts-clean')
        rc, out, err = w.run([str(subject)], clean_env(w, root), home=False)
        if rc != 0:
            return False, f'без HOME rc={rc}, stderr: {err.strip()[:200]}'
        if run_old.exists() or not run_young.exists():
            return False, 'без HOME семантика очистки сломалась'
        return True, ''
    finally:
        w.close()

# ── клетки установки ─────────────────────────────────────────────────────────
def install_env(w, src_ops, users=('toymob', 'toyback'), groups=('toygroup',),
                euid=0, systemctl='ok', back_owner_stat='toyback:toygroup',
                mob_owner_stat='toymob:toygroup', base_owner_stat='root:root',
                runner_units=()):
    # stat-конфигурация мира: владельцы корней «как их поставила установка»;
    # *_owner_stat — раунды дрейфа владельца/группы корня (verify-roots) и
    # расходящегося существующего корня (install-roots-preinstalled); пара
    # базы — конфигурируема (арбитраж 196-1: константа root:root в probe не
    # давала отрицательного базового входа); runner_units — юниты-раннеры
    # станции (вне репо): мир сотворяет их файлы в ETC_DST, установщик видит
    # их наличием (И-9е)
    ciart = w.path('var/lib/ci-artifacts')
    etc = w.path('etc/systemd/system')
    dropin_probes = []
    if runner_units:
        etc.mkdir(parents=True, exist_ok=True)
        for unit in runner_units:
            (etc / f'{unit}.service').write_text(
                '# мир 196: юнит моб-раннера станции (вне репо)\n'
                '[Service]\n'
                'User=harness\n'
                'ProtectSystem=strict\n'
                'ReadWritePaths=/var/lib/ci-runner /tmp\n'
                'PrivateTmp=yes\n'
            )
        # маркеры daemon-reload — по drop-in'у КАЖДОГО наличествующего юнита
        # (в конфигурации 11 наблюдаемы оба: ранний выход после первого
        # юнита не прикрывается — РЕШЕНИЕ 2 арбитража 196-1)
        for unit in RUNNER_UNITS:
            if unit in runner_units:
                dropin_probes.append(
                    etc / f'{unit}.service.d' / 'ci-artifacts.conf')
    w.write_shims(users=users, groups=groups, euid=euid, systemctl=systemctl,
                  stat_owners=((ciart / MOB, mob_owner_stat),
                               (ciart / BACK, back_owner_stat),
                               (ciart, base_owner_stat)),
                  dropin_probes=dropin_probes)
    return {
        'PATH': f'{w.path("bin")}:/usr/bin:/bin',
        'OPS_SERVER_SRC': str(src_ops),
        'OPS_SERVER_SBIN_DST': str(w.path('sbin')),
        'OPS_SERVER_ETC_DST': str(etc),
        'OPS_SERVER_CI_ARTIFACTS': str(ciart),
        'OPS_SERVER_CI_ARTIFACTS_MOB_OWNER': 'toymob',
        'OPS_SERVER_CI_ARTIFACTS_BACK_OWNER': 'toyback',
        'OPS_SERVER_CI_ARTIFACTS_GROUP': 'toygroup',
        'OPS_SERVER_MOB_TMP': str(w.path('mob-runner')),
        'OPS_SERVER_MOB_TMP_OWNER': pwd.getpwuid(os.getuid()).pw_name,
        'OPS_SERVER_SYSTEMCTL': 'systemctl',
    }


def install_core_files(w, src_ops):
    """Реальному install.sh verify нужны базовые адресаты 074 на месте."""
    bin_dst = w.path('usr-bin')
    bin_dst.mkdir(exist_ok=True)
    sbin = w.path('sbin')
    etc = w.path('etc/systemd/system')
    sbin.mkdir(parents=True, exist_ok=True)
    etc.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src_ops / 'user/orch-loop', bin_dst / 'orch-loop')
    (bin_dst / 'orch-loop').chmod(0o755)
    shutil.copyfile(src_ops / 'root/orch-peak', sbin / 'orch-peak')
    (sbin / 'orch-peak').chmod(0o755)
    for u in sorted((src_ops / 'root/systemd').iterdir()):
        if u.name in ('ci-artifacts-clean.service', 'ci-artifacts-clean.timer',
                      'ci-runner-tmp-clean.service', 'ci-runner-tmp-clean.timer'):
            continue
        shutil.copyfile(u, etc / u.name)
        (etc / u.name).chmod(0o644)
    # verify теперь проверяет также независимо установленный mob-tmpdir.
    # Это предусловие мира 196, не результат проверяемой artifacts-установки.
    # Сохраняем все раунды D1/D2: исправный соседний предмет не маскирует их.
    for unit, leaf, source in (
        (RUNNER_UNITS[0], 'tmp1', 'gh-runner-complior-tmpdir.conf'),
        (RUNNER_UNITS[1], 'tmp2', 'gh-runner-complior-2-tmpdir.conf'),
    ):
        if (etc / f'{unit}.service').exists():
            tmp = w.path('mob-runner', leaf)
            tmp.mkdir(parents=True, exist_ok=True)
            tmp.chmod(0o700)
            drop = etc / f'{unit}.service.d'
            drop.mkdir(exist_ok=True)
            shutil.copyfile(src_ops / 'root' / source, drop / 'tmpdir.conf')
    return bin_dst


def cell_install_artifacts(subj):
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops)
        ciart = w.path('var/lib/ci-artifacts')
        prefix = subj.install()
        if prefix is None:
            return no_subject('ops/server/install.sh')
        if subj.kind == 'stub' and subj.stub == 's11_slepaja_sverka.sh':
            return no_subject('install.sh artifacts (стаб s11 не реализует установку)')
        # оракул снят ДО вызова субъекта (РЕШЕНИЕ 3.2 арбитра): ожидаемые
        # байты — из модели-спеки, в память ДО w.run (не после)
        want_clean = (HERE / 'model/ci-artifacts-clean').read_bytes()
        want_svc = (HERE / 'model/ci-artifacts-clean.service').read_bytes()
        want_tmr = (HERE / 'model/ci-artifacts-clean.timer').read_bytes()
        rc, out, err = w.run(prefix + ['artifacts'], env)
        mob_root = ciart / MOB
        back_root = ciart / BACK
        clean_dst = w.path('sbin/ci-artifacts-clean')
        svc_dst = w.path('etc/systemd/system/ci-artifacts-clean.service')
        tmr_dst = w.path('etc/systemd/system/ci-artifacts-clean.timer')
        if rc != 0:
            return False, install_missing(rc, err)
        if clean_dst.read_bytes() != want_clean or stat.S_IMODE(clean_dst.stat().st_mode) != 0o755:
            return False, 'скрипт не установлен байт-в-байт (755)'
        if svc_dst.read_bytes() != want_svc or stat.S_IMODE(svc_dst.stat().st_mode) != 0o644:
            return False, 'юнит service не установлен байт-в-байт (644)'
        if tmr_dst.read_bytes() != want_tmr or stat.S_IMODE(tmr_dst.stat().st_mode) != 0o644:
            return False, 'юнит timer не установлен байт-в-байт (644)'
        # база B × создание (матрица РЕШЕНИЯ 2): режим 0755 и chown root:root
        # наблюдаются, а не выводятся из свойств service-юнита
        if stat.S_IMODE(ciart.stat().st_mode) != 0o755:
            return False, f'режим базы {oct(stat.S_IMODE(ciart.stat().st_mode))} != 0755'
        chown = w.journal('chown')
        for want in (
            f'chown root:root -- {clean_dst}',
            f'chown root:root -- {svc_dst}',
            f'chown root:root -- {tmr_dst}',
            f'chown root:root -- {ciart}',
            f'chown toymob:toygroup -- {mob_root}',
            f'chown toyback:toygroup -- {back_root}',
        ):
            if want not in chown:
                return False, f'нет владельца: {want} (журнал: {"; ".join(chown)})'
        if stat.S_IMODE(mob_root.stat().st_mode) != 0o2750:
            return False, f'режим корня моба {oct(stat.S_IMODE(mob_root.stat().st_mode))} != 2750'
        if stat.S_IMODE(back_root.stat().st_mode) != 0o2750:
            return False, f'режим корня бэка {oct(stat.S_IMODE(back_root.stat().st_mode))} != 2750'
        sysctl = w.journal('systemctl')
        if 'systemctl daemon-reload' not in sysctl:
            return False, 'нет systemctl daemon-reload'
        if 'systemctl enable --now ci-artifacts-clean.timer' not in sysctl:
            return False, 'нет enable --now ci-artifacts-clean.timer'
        # И-9д: «daemon-reload, ЗАТЕМ enable» — порядок двух строк журнала
        # (вердикт v2, совет в; мутация mj: обмен порядка роняет клетку)
        if sysctl.index('systemctl daemon-reload') \
                > sysctl.index('systemctl enable --now ci-artifacts-clean.timer'):
            return False, 'enable раньше daemon-reload (И-9д: «затем»)'
        if 'установлено: ci-artifacts' not in out:
            return False, f'нет строки установки: {out.strip()[:200]}'
        return True, ''
    finally:
        w.close()


def cell_install_precondition(subj):
    """И-9(б): предусловия ДО записей — каждому отсутствию СВОЙ раунд
    (матрица РЕШЕНИЯ 2 арбитража 196-1): три учётные записи (владелец моба,
    владелец бэка, группа — прочие предусловия исправны) и четыре источника
    (скрипт, service, timer, drop-in); drop-in-источник — при наличествующем
    раннере И без раннеров: предусловие безусловно (mk10). «До записей» —
    не создано НИЧЕГО в целевых деревьях (включая одну базу/пустой
    каталог/drop-in) и ни одного chown/chmod; исчезающий источник готовится
    в одноразовой копии OPS_SERVER_SRC, предъявленный репозиторий нетронут
    (РЕШЕНИЕ 3.2)."""
    prefix = subj.install()
    if prefix is None:
        return no_subject('ops/server/install.sh')
    if subj.kind == 'stub' and subj.stub == 's11_slepaja_sverka.sh':
        return no_subject('install.sh artifacts (стаб s11 не реализует установку)')
    # три раунда getent: отсутствует одна учётная запись, прочее исправно
    for label, env_kwargs, want_err in (
        ('нет владельца моба', {'users': ('toyback',)},
         'ОТКАЗ: нет пользователя: toymob'),
        ('нет владельца бэка', {'users': ('toymob',)},
         'ОТКАЗ: нет пользователя: toyback'),
        ('нет группы', {'groups': ()}, 'ОТКАЗ: нет группы: toygroup'),
    ):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            env = install_env(w, src_ops, **env_kwargs)
            rc, out, err = w.run(prefix + ['artifacts'], env)
            if rc != 1:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'{label}: rc={rc} (ожидался отказ 1)'
            if want_err not in err:
                return False, f'{label}: нет именованного отказа: {err.strip()[:300]}'
            wrote = subject_writes(w)
            if wrote:
                return False, f'{label}: отказ не ДО записей: {wrote[:6]}'
        finally:
            w.close()
    # пять раундов источников: четыре адресата S + безусловность
    # drop-in-предусловия при отсутствии юнитов раннера
    for label, rel, runner in (
        ('нет скрипта', 'root/ci-artifacts-clean', ()),
        ('нет service-юнита', 'root/systemd/ci-artifacts-clean.service', ()),
        ('нет timer-юнита', 'root/systemd/ci-artifacts-clean.timer', ()),
        ('нет drop-in-источника (раннер есть)',
         'root/gh-runner-complior-ci-artifacts.conf', RUNNER_UNITS[:1]),
        ('нет drop-in-источника (раннеров нет)',
         'root/gh-runner-complior-ci-artifacts.conf', ()),
    ):
        w = World()
        try:
            src_ops = src_ops_missing(subj, w, rel)
            env = install_env(w, src_ops, runner_units=runner)
            rc, out, err = w.run(prefix + ['artifacts'], env)
            if rc != 1:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'{label}: rc={rc} (ожидался отказ 1)'
            want = f'ОТКАЗ: нет источника: {src_ops / rel}'
            if want not in err:
                return False, f'{label}: нет именованного отказа: {err.strip()[:300]}'
            wrote = subject_writes(w, runner_units=runner)
            if wrote:
                return False, f'{label}: отказ не ДО записей: {wrote[:6]}'
        finally:
            w.close()
    return True, ''


def cell_verify_drift(subj):
    """И-10: «все три сверяются sha256» — каждому адресату СВОЙ раунд дрейфа
    (вердикт v2, mh): скрипт, service-юнит, timer-юнит; каждый ждёт rc 1
    «ОТКАЗ: расхождение <путь>» с именем файла."""
    prefix = subj.install()
    if prefix is None:
        return no_subject('ops/server/install.sh')
    _, verify_mode = subj.install_modes()
    for rel, marker in (
        ('sbin/ci-artifacts-clean', 'ci-artifacts-clean'),
        ('etc/systemd/system/ci-artifacts-clean.service',
         'ci-artifacts-clean.service'),
        ('etc/systemd/system/ci-artifacts-clean.timer',
         'ci-artifacts-clean.timer'),
    ):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            env = install_env(w, src_ops)
            if subj.kind == 'repo':
                # реальный verify сверяет и базовые адресаты — ставим их из источника
                env['OPS_SERVER_BIN_DST'] = str(install_core_files(w, src_ops))
            # Н-39: стаб s11 не реализует установку — мир ставится ЧЕСТНОЙ моделью,
            # обманке отдан только этап сверки (её дефект там и наблюдаем)
            install_prefix = prefix
            if subj.kind == 'stub' and subj.stub == 's11_slepaja_sverka.sh':
                install_prefix = ['bash', str(HERE / 'model' / 'install-artifacts.sh')]
            rc, out, err = w.run(install_prefix + ['artifacts'], env)
            if rc != 0:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'установка для мира дрейфа не зелёная: rc={rc}, {err.strip()[:300]}'
            target = w.path(rel)
            target.write_bytes(target.read_bytes() + b'drift\n')
            rc, out, err = w.run(prefix + [verify_mode], env)
            if rc != 1:
                return False, f'сверка слепа к дрейфу {marker}: rc={rc}, out: {out.strip()[:200]}'
            if 'расхождение' not in err or marker not in err:
                return False, f'сверка не назвала файл {marker}: {err.strip()[:300]}'
        finally:
            w.close()
    return True, ''

def cell_install_euid_refused(subj):
    """И-9(а): не-root прогон artifacts — отказ ДО записей (шим id → 1).
    «Без единой записи» (РЕШЕНИЕ 3.2) — ни одного целевого дерева субъекта
    (база, корни, sbin-адресат, юниты, .d-каталоги) и ни одного chown/chmod."""
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops, euid=1)
        prefix = subj.install()
        if prefix is None:
            return no_subject('ops/server/install.sh')
        rc, out, err = w.run(prefix + ['artifacts'], env)
        if rc != 1:
            return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'rc={rc} (ожидался отказ 1)'
        if 'ОТКАЗ: artifacts-часть требует euid 0' not in err:
            return False, f'нет именованного отказа euid: {err.strip()[:300]}'
        wrote = subject_writes(w)
        if wrote:
            return False, f'euid-отказ не ДО записей: {wrote[:6]}'
        return True, ''
    finally:
        w.close()


def cell_install_repo_symlink_refused(subj):
    """И-9(г): предсозданная символьная ссылка на месте корня репо — отказ,
    ссылка и цель нетронуты, chown/chmod через неё нет. Каждому корню
    (моб, бэк) — свой раунд (матрица РЕШЕНИЯ 2 арбитража 196-1)."""
    prefix = subj.install()
    if prefix is None:
        return no_subject('ops/server/install.sh')
    for repo_name in (MOB, BACK):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            env = install_env(w, src_ops)
            ciart = w.path('var/lib/ci-artifacts')
            ciart.mkdir(parents=True)
            # мир предсоздаёт родителя как станция: 0755 (umask теста не решает)
            os.chmod(ciart, 0o755)
            outside = w.path('outside-store')
            outside.mkdir()
            (outside / 'evidence.txt').write_bytes(b'target\n')
            link_root = ciart / repo_name
            link_root.symlink_to(outside, target_is_directory=True)
            rc, out, err = w.run(prefix + ['artifacts'], env)
            if rc != 1:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'{repo_name}: rc={rc} (ожидался отказ 1), stderr: {err.strip()[:200]}'
            if f'ОТКАЗ: репо — символьная ссылка: {link_root}' not in err:
                return False, f'{repo_name}: нет именованного отказа на ссылку-репо: {err.strip()[:300]}'
            if not link_root.is_symlink():
                return False, f'{repo_name}: установка сняла ссылку-репо'
            if not (outside / 'evidence.txt').exists():
                return False, f'{repo_name}: цель ссылки-репо повреждена'
            for jname in ('chown', 'chmod'):
                if any(str(link_root) in line for line in w.journal(jname)):
                    return False, f'{repo_name}: установка тронула ссылку-репо {jname}'
        finally:
            w.close()
    return True, ''


def cell_install_systemctl_refused(subj):
    """И-9(д): отказывающий systemctl — rc 1 с именованной фразой;
    отсутствующий бинарь шва — rc 2 NOT_IMPLEMENTED."""
    prefix = subj.install()
    if prefix is None:
        return no_subject('ops/server/install.sh')
    for mode, want_err in (
        ('fail-reload', 'ОТКАЗ: systemctl daemon-reload'),
        ('fail-enable', 'ОТКАЗ: ci-artifacts-clean.timer не включён'),
    ):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            env = install_env(w, src_ops, systemctl=mode)
            rc, out, err = w.run(prefix + ['artifacts'], env)
            if rc != 1:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'{mode}: rc={rc} (ожидался отказ 1), stderr: {err.strip()[:200]}'
            if want_err not in err:
                return False, f'{mode}: нет именованного отказа: {want_err}; stderr: {err.strip()[:300]}'
        finally:
            w.close()
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops)
        env['OPS_SERVER_SYSTEMCTL'] = 'netu-systemctl-196'
        rc, out, err = w.run(prefix + ['artifacts'], env)
        if rc != 2:
            return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'нет бинаря systemctl: rc={rc} (ожидался 2), stderr: {err.strip()[:200]}'
        if 'NOT_IMPLEMENTED: нет netu-systemctl-196' not in err:
            return False, f'нет NOT_IMPLEMENTED о бинаре: {err.strip()[:300]}'
        return True, ''
    finally:
        w.close()


def cell_verify_not_installed(subj):
    """И-10: ни один адресат не установлен — verify rc 0 со строкой
    «ci-artifacts: не установлены», это не расхождение; частичная установка
    (только скрипт, оборвана после первой копии — вердикт v2, mf) —
    rc 1 «ОТКАЗ: расхождение <путь>» на отсутствующем юните и НЕ «не
    установлены». Каждому состоянию — свой раунд."""
    prefix = subj.install()
    if prefix is None:
        return no_subject('ops/server/install.sh')
    _, verify_mode = subj.install_modes()
    # раунд 1: пустая установка
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops)
        if subj.kind == 'repo':
            # базовые адресаты 074 на месте — «не установлены» относится
            # только к тройке ci-artifacts
            env['OPS_SERVER_BIN_DST'] = str(install_core_files(w, src_ops))
        rc, out, err = w.run(prefix + [verify_mode], env)
        if rc != 0:
            return False, f'verify на пустой установке красный: rc={rc}, stderr: {err.strip()[:300]}'
        if 'ci-artifacts: не установлены (sudo bash ops/server/install.sh artifacts)' not in out:
            return False, f'субъект отсутствует: install.sh verify (ветка «не установлены» ci-artifacts), out: {out.strip()[:200]}'
        if 'расхождение' in err:
            return False, f'пустая установка названа расхождением: {err.strip()[:200]}'
    finally:
        w.close()
    # раунд 2: частичная установка — установлен только скрипт
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops)
        if subj.kind == 'repo':
            env['OPS_SERVER_BIN_DST'] = str(install_core_files(w, src_ops))
        sbin = w.path('sbin')
        sbin.mkdir(parents=True, exist_ok=True)
        # оракул: байты скрипта — из источника субъекта; расхождение —
        # только отсутствующие юниты
        shutil.copyfile(src_ops / 'root/ci-artifacts-clean',
                        sbin / 'ci-artifacts-clean')
        (sbin / 'ci-artifacts-clean').chmod(0o755)
        rc, out, err = w.run(prefix + [verify_mode], env)
        if rc != 1:
            return False, f'частичная установка не расхождение: rc={rc}, out: {out.strip()[:200]}'
        if 'ci-artifacts: не установлены' in out:
            return False, 'частичная установка названа «не установлены»'
        svc = w.path('etc/systemd/system/ci-artifacts-clean.service')
        if 'расхождение' not in err or str(svc) not in err:
            return False, f'сверка не назвала отсутствующий юнит: {err.strip()[:300]}'
        # раунды 3–8: остальные векторы присутствия тройки F (матрица
        # РЕШЕНИЯ 2 арбитража 196-1): частичные миры — от полной установки
        # (корни и прочие зависимости исправны), каждый ждёт rc 1 с именем
        # действительно отсутствующего файла и БЕЗ «не установлены»; 111 —
        # положительный контроль «сверка 3/3»
        for vector, expect in (
            ('001', 'sbin/ci-artifacts-clean'),
            ('010', 'sbin/ci-artifacts-clean'),
            ('011', 'sbin/ci-artifacts-clean'),
            ('101', 'etc/systemd/system/ci-artifacts-clean.service'),
            ('110', 'etc/systemd/system/ci-artifacts-clean.timer'),
            ('111', None),
        ):
            w = World()
            try:
                src_ops = subj.src_ops(w)
                env = install_env(w, src_ops)
                if subj.kind == 'repo':
                    env['OPS_SERVER_BIN_DST'] = str(install_core_files(w, src_ops))
                # Н-39: стабам, не реализующим установку, мир ставится
                # честной моделью (тот же приём, что verify-drift)
                install_prefix = prefix
                if subj.kind == 'stub':
                    install_prefix = ['bash', str(HERE / 'model' / 'install-artifacts.sh')]
                rc, out, err = w.run(install_prefix + ['artifacts'], env)
                if rc != 0:
                    return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'вектор {vector}: мир не установлен: rc={rc}, {err.strip()[:300]}'
                rels = ('sbin/ci-artifacts-clean',
                        'etc/systemd/system/ci-artifacts-clean.service',
                        'etc/systemd/system/ci-artifacts-clean.timer')
                for digit, rel in zip(vector, rels):
                    if digit == '0':
                        w.path(rel).unlink()
                rc, out, err = w.run(prefix + [verify_mode], env)
                if expect is None:
                    if rc != 0 or 'ci-artifacts: сверка 3/3' not in out:
                        return False, f'вектор 111: rc={rc}, out: {out.strip()[:200]}'
                else:
                    if rc != 1:
                        return False, f'вектор {vector}: rc={rc} (ожидался 1), out: {out.strip()[:200]}'
                    if 'ci-artifacts: не установлены' in out:
                        return False, f'вектор {vector}: частичная установка названа «не установлены»'
                    if 'расхождение' not in err or str(w.path(expect)) not in err:
                        return False, f'вектор {vector}: сверка не назвала отсутствующий файл: {err.strip()[:300]}'
            finally:
                w.close()
        return True, ''
    finally:
        w.close()


def cell_verify_roots(subj):
    """И-10: корни репо — каждому корню и каждому свойству СВОЙ раунд
    (матрица РЕШЕНИЯ 2 арбитража 196-1; v2: mg/me, v3: mk6): шесть дрейфов
    (режим/владелец/группа × моб/бэк) и два отсутствующих корня при полной
    исправной тройке F; каждый ждёт rc 1 «ОТКАЗ: расхождение ci-artifacts:
    <путь>» с именем корня. Режим — реальный chmod (наблюдаем файлово),
    владелец/группа — stat-конфигурацией мира (шим %U:%G, оси независимы:
    во «владельце» правильна группа, в «группе» правильный владелец)."""
    prefix = subj.install()
    if prefix is None:
        return no_subject('ops/server/install.sh')
    _, verify_mode = subj.install_modes()
    for drift, repo_name, env_kwargs in (
        ('режим моба', MOB, {}),
        ('режим бэка', BACK, {}),
        ('владелец моба', MOB, {'mob_owner_stat': 'toyback:toygroup'}),
        ('владелец бэка', BACK, {'back_owner_stat': 'toymob:toygroup'}),
        ('группа моба', MOB, {'mob_owner_stat': 'toymob:netu-gruppy'}),
        ('группа бэка', BACK, {'back_owner_stat': 'toyback:netu-gruppy'}),
    ):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            env = install_env(w, src_ops, **env_kwargs)
            if subj.kind == 'repo':
                env['OPS_SERVER_BIN_DST'] = str(install_core_files(w, src_ops))
            rc, out, err = w.run(prefix + ['artifacts'], env)
            if rc != 0:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'установка для мира дрейфа корня не зелёная: rc={rc}, {err.strip()[:300]}'
            root = w.path('var/lib/ci-artifacts') / repo_name
            if drift.startswith('режим'):
                os.chmod(root, 0o755)
            # владелец/группа: дрейф уже в stat-конфигурации мира (шим %U:%G)
            rc, out, err = w.run(prefix + [verify_mode], env)
            if rc != 1:
                return False, f'сверка не смотрит корни ({drift}): rc={rc}, out: {out.strip()[:200]}'
            if f'ОТКАЗ: расхождение ci-artifacts: {root}' not in err:
                return False, f'сверка не назвала корень ({drift}): {err.strip()[:300]}'
        finally:
            w.close()
    # два раунда отсутствующего корня при полной исправной F (матрица
    # РЕШЕНИЯ 2, «создание» × verify): сверка обязана отказать именем корня
    for repo_name in (MOB, BACK):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            env = install_env(w, src_ops)
            if subj.kind == 'repo':
                env['OPS_SERVER_BIN_DST'] = str(install_core_files(w, src_ops))
            rc, out, err = w.run(prefix + ['artifacts'], env)
            if rc != 0:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'установка для мира отсутствующего корня не зелёная: rc={rc}, {err.strip()[:300]}'
            root = w.path('var/lib/ci-artifacts') / repo_name
            shutil.rmtree(root)
            rc, out, err = w.run(prefix + [verify_mode], env)
            if rc != 1:
                return False, f'сверка слепа к отсутствию корня {repo_name}: rc={rc}, out: {out.strip()[:200]}'
            if f'ОТКАЗ: расхождение ci-artifacts: {root}' not in err:
                return False, f'сверка не назвала отсутствующий корень {repo_name}: {err.strip()[:300]}'
        finally:
            w.close()
    return True, ''


def cell_readme_anchors(subj):
    """И-11: раздел README «Локальные артефакты CI (контракт 196)» существует
    и несёт якорные строки («содержит», не «ровно N тем» — прецедент 074-к6)."""
    doc = subj.readme()
    if doc is None:
        return no_subject('ops/server/README.md')
    header = '## Локальные артефакты CI (контракт 196)'
    lines = doc.read_text().splitlines()
    head_idx = None
    for i, ln in enumerate(lines):
        if ln == header:
            head_idx = i
            break
    if head_idx is None:
        return False, f'субъект отсутствует: ops/server/README.md (раздел «{header}»)'
    body = []
    for ln in lines[head_idx + 1:]:
        if ln.startswith('## '):
            break
        body.append(ln)
    section = '\n'.join(body)
    for anchor in README_ANCHORS:
        if anchor not in section:
            return False, f'раздел 196 не несёт якорь: {anchor}'
    return True, ''


def parse_units(text):
    sections = {}
    current = None
    for line in text.splitlines():
        if line.startswith('[') and line.endswith(']'):
            current = line[1:-1]
            sections[current] = {}
            continue
        if current and '=' in line:
            k, v = line.split('=', 1)
            sections[current][k] = v
    return sections


def cell_unit_grammar(subj):
    svc = subj.unit('service')
    tmr = subj.unit('timer')
    if svc is None:
        return no_subject('ops/server/root/systemd/ci-artifacts-clean.service')
    if tmr is None:
        return no_subject('ops/server/root/systemd/ci-artifacts-clean.timer')
    s = parse_units(svc.read_text())
    if s.get('Service', {}).get('Type') != 'oneshot':
        return False, 'service не oneshot'
    if s.get('Service', {}).get('ExecStart') != '/usr/local/sbin/ci-artifacts-clean':
        return False, f'ExecStart не адрес установки: {s.get("Service", {}).get("ExecStart")}'
    t = parse_units(tmr.read_text())
    if t.get('Timer', {}).get('OnCalendar') != '*-*-* 04:30:00 Asia/Singapore':
        return False, f'OnCalendar не расписание 196 (04:30 Asia/Singapore): {t.get("Timer", {}).get("OnCalendar")!r}'
    if t.get('Timer', {}).get('Persistent') != 'true':
        return False, 'таймер не Persistent=true: пропущенная за простоем чистка не навёрстывается'
    if t.get('Install', {}).get('WantedBy') != 'timers.target':
        return False, 'WantedBy не timers.target'
    return True, ''



def cell_install_roots_preinstalled(subj):
    """И-9(г): корни станции уже созданы оператором (база B root:root 0755,
    моб/бэк M/K 2750 с владельцами швов) — установщик принимает их
    идемпотентно: rc 0, НИ ОДНОГО chown ИЛИ chmod по любому из трёх корней
    (РЕШЕНИЕ 3.2: одного неизменного конечного режима недостаточно —
    наблюдаются журналы обоих швов), байты и метаданные имеющегося
    содержимого не изменены. Расходящийся существующий корень — rc 1
    «ОТКАЗ: существующий корень расходится: <путь>» без переформатирования;
    ДЕВЯТЬ отдельных раундов (матрица РЕШЕНИЯ 2): режим/владелец/группа ×
    база/моб/бэк, оси независимы, изолировано ОДНО нарушение."""
    prefix = subj.install()
    if prefix is None:
        return no_subject('ops/server/install.sh')
    # раунд 1: B/M/K существуют и верны — идемпотентный приём
    w = World()
    try:
        src_ops = subj.src_ops(w)
        ciart = w.path('var/lib/ci-artifacts')
        mob_root = ciart / MOB
        back_root = ciart / BACK
        ciart.mkdir(parents=True)
        seeded = {}
        for path in (ciart, mob_root, back_root):
            path.mkdir(exist_ok=True)
            seed = path / 'operator-file'
            seed.write_bytes(b'operator evidence\n')
            seeded[path] = (seed, b'operator evidence\n',
                            seed.stat().st_mtime_ns)
        os.chmod(ciart, 0o755)
        os.chmod(mob_root, 0o2750)
        os.chmod(back_root, 0o2750)
        env = install_env(w, src_ops)
        rc, out, err = w.run(prefix + ['artifacts'], env)
        if rc != 0:
            return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'существующие верные корни не приняты: rc={rc}, stderr: {err.strip()[:300]}'
        roots = (ciart, mob_root, back_root)
        for jname in ('chown', 'chmod'):
            for line in w.journal(jname):
                for root in roots:
                    if str(root) in line:
                        return False, f'идемпотентность: {jname} по корню: {line}'
        for path, want_mode in ((ciart, 0o755), (mob_root, 0o2750), (back_root, 0o2750)):
            if stat.S_IMODE(path.stat().st_mode) != want_mode:
                return False, f'идемпотентность: режим существующего корня дрейфнул: {path}'
        for path, (seed, want_bytes, want_mtime) in seeded.items():
            if not seed.exists() or seed.read_bytes() != want_bytes \
                    or seed.stat().st_mtime_ns != want_mtime:
                return False, f'идемпотентность: содержимое существующего корня изменено: {seed}'
        if 'установлено: ci-artifacts' not in out:
            return False, f'нет строки установки: {out.strip()[:200]}'
    finally:
        w.close()
    # раунды 2–10: девять расходящихся миров — одно нарушение на адресат
    # (B×режим/владелец/группа, M×…, K×…; v3: mk5 режим бэка, mk8 база)
    for label, target, env_kwargs, drift_mode in (
        ('режим базы', 'base', {}, 0o700),
        ('владелец базы', 'base', {'base_owner_stat': 'toymob:toygroup'}, None),
        ('группа базы', 'base', {'base_owner_stat': 'root:toygroup'}, None),
        ('режим моба', MOB, {}, 0o755),
        ('владелец моба', MOB, {'mob_owner_stat': 'toyback:toygroup'}, None),
        ('группа моба', MOB, {'mob_owner_stat': 'toymob:netu-gruppy'}, None),
        ('режим бэка', BACK, {}, 0o755),
        ('владелец бэка', BACK, {'back_owner_stat': 'toymob:toygroup'}, None),
        ('группа бэка', BACK, {'back_owner_stat': 'toyback:netu-gruppy'}, None),
    ):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            ciart = w.path('var/lib/ci-artifacts')
            mob_root = ciart / MOB
            back_root = ciart / BACK
            ciart.mkdir(parents=True)
            os.chmod(ciart, 0o755)
            for path in (mob_root, back_root):
                path.mkdir()
                os.chmod(path, 0o2750)
            drift_root = ciart if target == 'base' else ciart / target
            if drift_mode is not None:
                os.chmod(drift_root, drift_mode)
            env = install_env(w, src_ops, **env_kwargs)
            rc, out, err = w.run(prefix + ['artifacts'], env)
            if rc != 1:
                return False, f'расходящийся корень ({label}) принят: rc={rc}'
            if f'ОТКАЗ: существующий корень расходится: {drift_root}' not in err:
                return False, f'нет именованного отказа о корне ({label}): {err.strip()[:300]}'
            if drift_mode is not None \
                    and stat.S_IMODE(drift_root.stat().st_mode) != drift_mode:
                return False, f'расходящийся корень ({label}) молча переформатирован'
            for jname in ('chown', 'chmod'):
                if any(str(drift_root) in line for line in w.journal(jname)):
                    return False, f'расходящийся корень ({label}) тронут {jname}'
        finally:
            w.close()
    return True, ''


def cell_install_runner_dropin(subj):
    """И-9(е): drop-in'ы моб-раннера по наличию юнита — конфигурации
    присутствия 10/01/11 (00 — клетка runner-dropin-absent; матрица
    РЕШЕНИЯ 2 арбитража 196-1): каждому присутствующему юниту его D —
    байт-в-байт из репо-источника (ровно ReadWritePaths на корень моба),
    0644 root:root, ДО daemon-reload — маркер журнала шима по КАЖДОМУ
    drop-in'у, в 11 наблюдаемы ОБА (ранний выход после первого юнита не
    прикрывается); отсутствующему юниту .d-каталог не создаётся."""
    prefix = subj.install()
    if prefix is None:
        return no_subject('ops/server/install.sh')
    if subj.kind == 'stub' and subj.stub == 's11_slepaja_sverka.sh':
        return no_subject('install.sh artifacts (стаб s11 не реализует установку)')
    want = (HERE / 'model/gh-runner-complior-ci-artifacts.conf').read_bytes()
    for units in ((RUNNER_UNITS[0],), (RUNNER_UNITS[1],), tuple(RUNNER_UNITS)):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            env = install_env(w, src_ops, runner_units=units)
            rc, out, err = w.run(prefix + ['artifacts'], env)
            if rc != 0:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'{"+".join(units)}: rc={rc}, stderr: {err.strip()[:300]}'
            etc = w.path('etc/systemd/system')
            for unit in units:
                dropin = etc / f'{unit}.service.d' / 'ci-artifacts.conf'
                if not dropin.exists():
                    return False, f'drop-in не установлен при юните {unit}'
                if dropin.read_bytes() != want:
                    return False, f'drop-in {unit} не байт-в-байт с источником (ReadWritePaths на корень моба)'
                if stat.S_IMODE(dropin.stat().st_mode) != 0o644:
                    return False, f'drop-in {unit} не 0644: {oct(stat.S_IMODE(dropin.stat().st_mode))}'
                if f'chown root:root -- {dropin}' not in w.journal('chown'):
                    return False, f'drop-in {unit} без root:root (журнал chown: {"; ".join(w.journal("chown"))})'
                if f'daemon-reload-dropin={dropin}:yes' not in w.journal('systemctl'):
                    return False, f'daemon-reload не после установки drop-in {unit} (маркер журнала)'
            for unit in RUNNER_UNITS:
                if unit not in units and (etc / f'{unit}.service.d').exists():
                    return False, f'drop-in-каталог юниту без юнита: {unit}'
        finally:
            w.close()
    return True, ''


def cell_runner_dropin_absent(subj):
    """И-9(е), негативная пара: юнитов-раннеров нет — drop-in не ставится
    ни одному (ни одного .d-каталога), установка остаётся зелёной: отсутствие
    раннера на станции — не ошибка установки."""
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops)
        prefix = subj.install()
        if prefix is None:
            return no_subject('ops/server/install.sh')
        rc, out, err = w.run(prefix + ['artifacts'], env)
        if rc != 0:
            return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'rc={rc}, stderr: {err.strip()[:300]}'
        etc = w.path('etc/systemd/system')
        for unit in RUNNER_UNITS:
            if (etc / f'{unit}.service').exists():
                return False, f'мир сотворил юнит-раннер сам: {unit}'
            ddir = etc / f'{unit}.service.d'
            if ddir.exists():
                return False, f'drop-in-каталог без юнита-раннера: {ddir}'
        if 'установлено: ci-artifacts' not in out:
            return False, f'нет строки установки: {out.strip()[:200]}'
        return True, ''
    finally:
        w.close()


def cell_verify_runner_dropin(subj):
    """И-10: условная сверка drop-in'ов моб-раннера — канонический мир ОБА
    юнита (mk7 вердикта v3: одиночный мир первого юнита прикрывал ранний
    выход после него): каждому D1/D2 × дрейф/отсутствие СВОЙ раунд при
    исправном другом D — rc 1 «ОТКАЗ: расхождение <путь>» с именем;
    положительные контроли всех четырёх конфигураций 00/10/01/11 — rc 0
    «сверка 3/3» (отсутствие юнита не требует его drop-in)."""
    prefix = subj.install()
    if prefix is None:
        return no_subject('ops/server/install.sh')
    _, verify_mode = subj.install_modes()
    for unit, drift_kind in (
        (RUNNER_UNITS[0], 'bytes'), (RUNNER_UNITS[0], 'missing'),
        (RUNNER_UNITS[1], 'bytes'), (RUNNER_UNITS[1], 'missing'),
    ):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            env = install_env(w, src_ops, runner_units=RUNNER_UNITS)
            if subj.kind == 'repo':
                env['OPS_SERVER_BIN_DST'] = str(install_core_files(w, src_ops))
            # Н-39: стаб не реализует установку честно — мир ставит модель,
            # обманке отдан только этап сверки (дефект наблюдаем там)
            install_prefix = prefix
            if subj.kind == 'stub':
                install_prefix = ['bash', str(HERE / 'model' / 'install-artifacts.sh')]
            rc, out, err = w.run(install_prefix + ['artifacts'], env)
            if rc != 0:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'установка для мира дрейфа drop-in не зелёная: rc={rc}, {err.strip()[:300]}'
            etc = w.path('etc/systemd/system')
            dropin = etc / f'{unit}.service.d' / 'ci-artifacts.conf'
            if not dropin.exists():
                # честная установка обязана поставить drop-in при юните
                return False, f'установка не поставила drop-in при юните {unit} (И-9е)'
            if drift_kind == 'bytes':
                dropin.write_bytes(dropin.read_bytes() + b'drift\n')
            else:
                dropin.unlink()
            rc, out, err = w.run(prefix + [verify_mode], env)
            if rc != 1:
                return False, f'сверка слепа к {drift_kind} drop-in {unit}: rc={rc}, out: {out.strip()[:200]}'
            if 'расхождение' not in err or str(dropin) not in err:
                return False, f'сверка не назвала drop-in {unit} ({drift_kind}): {err.strip()[:300]}'
        finally:
            w.close()
    # положительные контроли четырёх конфигураций U (матрица РЕШЕНИЯ 2):
    # исправные D при присутствующих юнитах, отсутствие юнита — не расхождение
    for units in ((), (RUNNER_UNITS[0],), (RUNNER_UNITS[1],), tuple(RUNNER_UNITS)):
        w = World()
        try:
            src_ops = subj.src_ops(w)
            env = install_env(w, src_ops, runner_units=units)
            if subj.kind == 'repo':
                env['OPS_SERVER_BIN_DST'] = str(install_core_files(w, src_ops))
            install_prefix = prefix
            if subj.kind == 'stub':
                install_prefix = ['bash', str(HERE / 'model' / 'install-artifacts.sh')]
            rc, out, err = w.run(install_prefix + ['artifacts'], env)
            if rc != 0:
                return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'установка без дрейфа не зелёная: rc={rc}, {err.strip()[:300]}'
            rc, out, err = w.run(prefix + [verify_mode], env)
            if rc != 0:
                return False, f'исправная конфигурация раннеров ({",".join(units) or "00"}) названа расхождением: rc={rc}, stderr: {err.strip()[:300]}'
            if 'ci-artifacts: сверка 3/3' not in out:
                return False, f'нет строки сверки: {out.strip()[:200]}'
        finally:
            w.close()
    return True, ''

CELLS = {
    'young-kept': cell_young_kept,
    'old-removed': cell_old_removed,
    'young-inside-file': cell_young_inside_file,
    'symlink-run-refused': cell_symlink_run_refused,
    'repo-symlink-refused': cell_repo_symlink_refused,
    'traversal-repo-refused': cell_traversal_repo_refused,
    'grammar-refused': cell_grammar_refused,
    'undeclared-untouched': cell_undeclared_untouched,
    'retention-seam': cell_retention_seam,
    'root-missing': cell_root_missing,
    'no-home-service-env': cell_no_home_service_env,
    'install-artifacts': cell_install_artifacts,
    'install-precondition': cell_install_precondition,
    'install-euid-refused': cell_install_euid_refused,
    'install-repo-symlink-refused': cell_install_repo_symlink_refused,
    'install-systemctl-refused': cell_install_systemctl_refused,
    'install-roots-preinstalled': cell_install_roots_preinstalled,
    'verify-drift': cell_verify_drift,
    'verify-not-installed': cell_verify_not_installed,
    'verify-roots': cell_verify_roots,
    'verify-runner-dropin': cell_verify_runner_dropin,
    'install-runner-dropin': cell_install_runner_dropin,
    'runner-dropin-absent': cell_runner_dropin_absent,
    'unit-grammar': cell_unit_grammar,
    'readme-anchors': cell_readme_anchors,
}


def check_family():
    for p in ('model/ci-artifacts-clean', 'model/install-artifacts.sh',
              'model/ci-artifacts-clean.service', 'model/ci-artifacts-clean.timer',
              'model/README-ops-server.md',
              'model/gh-runner-complior-ci-artifacts.conf'):
        if not (HERE / p).exists():
            refuse(f'нет файла семьи: {p}')
    stubs = sorted(q.name for q in (HERE / 'stabs').iterdir())
    if len(stubs) != len(STUBS):
        refuse(f'стабов в stabs/ {len(stubs)}, привязок {len(STUBS)}: {stubs}')
    for name in stubs:
        if name not in STUBS:
            refuse(f'стаб без привязки: {name}')
    if len(CASES) != 25:
        refuse(f'клеток {len(CASES)}, ожидалось 25')


def main():
    args = sys.argv[1:]
    mode = 'repo'
    repo_root = REPO
    if args == ['--model']:
        mode = 'model'
    elif args == ['--stabs']:
        mode = 'stabs'
    elif len(args) == 2 and args[0] == '--repo':
        mode = 'repo'
        repo_root = Path(args[1])
        if not repo_root.exists():
            print(f'NOT_IMPLEMENTED: корень не существует: {repo_root}', file=sys.stderr)
            return 2
    elif args:
        print('использование: probe.py --model|--stabs|--repo <корень>|<без флагов>',
              file=sys.stderr)
        return 2
    check_family()

    if mode in ('model', 'repo'):
        subj = Subjects(mode, repo_root=repo_root)
        green = 0
        red = 0
        for case in CASES:
            ok, msg = CELLS[case](subj)
            if ok:
                green += 1
                print(f'— {case}: OK')
            else:
                red += 1
                print(f'— {case}: KRASNO ({msg})')
        rc = 0 if red == 0 else 1
        print(f'ИТОГ 196: rc={rc} KLETKI={len(CASES)} ZELENYE={green} KRASNYE={red}')
        return rc

    # режим --stabs: каждый стаб на СВОЁМ входе обязан быть пойман
    caught = 0
    alive = 0
    for name in sorted(STUBS):
        _, case = STUBS[name]
        subj = Subjects('stub', stub=name)
        ok, msg = CELLS[case](subj)
        if not ok:
            caught += 1
            print(f'— {name} на входе {case}: POIMAN ({msg})')
        else:
            alive += 1
            print(f'— {name} на входе {case}: ZHIV (клетка зелёная на обманке)')
    rc = 0 if alive == 0 and caught == len(STUBS) else 1
    print(f'ИТОГ 196: rc={rc} OBMANOK={len(STUBS)} POIMANY={caught} ZHIVYH={alive}')
    return rc


if __name__ == '__main__':
    sys.exit(main())
