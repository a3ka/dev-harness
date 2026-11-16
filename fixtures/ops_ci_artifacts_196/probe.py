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
import shutil
import stat
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent

CASES = (
    'young-kept', 'old-removed', 'young-inside-file', 'symlink-run-refused',
    'repo-symlink-refused', 'traversal-repo-refused', 'grammar-refused',
    'undeclared-untouched', 'retention-seam', 'root-missing', 'no-home-service-env',
    'install-artifacts', 'install-precondition', 'install-euid-refused',
    'install-repo-symlink-refused', 'install-systemctl-refused',
    'verify-drift', 'verify-not-installed', 'verify-roots',
    'unit-grammar', 'readme-anchors',
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
}

MOB = 'Complior-mob'
DAY = 86400
BACK = 'Complior-back'
README_ANCHORS = (
    '/var/lib/ci-artifacts/',
    'sudo bash ops/server/install.sh artifacts',
    'ci-artifacts-clean.timer',
    'CI_ARTIFACTS_RETENTION_DAYS',
    'группа harness',
    'на GitHub артефакты не загружаются',
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

    def write_shims(self, users=(), groups=(), euid=0, systemctl='ok'):
        bin_dir = self.path('bin')
        bin_dir.mkdir(exist_ok=True)
        self.journals['chown'] = self.path('chown.journal')
        self.journals['systemctl'] = self.path('systemctl.journal')
        users_cfg = self.path('known-users')
        groups_cfg = self.path('known-groups')
        users_cfg.write_text('\n'.join(users) + '\n')
        groups_cfg.write_text('\n'.join(groups) + '\n')
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
            'systemctl': (
                '#!/bin/bash\n'
                f'printf \'%s\\n\' "systemctl $*" >>"{self.journals["systemctl"]}"\n'
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
        self.repo_root = Path(repo_root) if repo_root else None
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
        """Каталог-источник OPS_SERVER_SRC с root/ci-artifacts-clean и юнитами."""
        if self.kind == 'repo':
            return self.repo_root / 'ops/server'
        src = world.path('ops-server')
        (src / 'root/systemd').mkdir(parents=True)
        shutil.copyfile(HERE / 'model' / 'ci-artifacts-clean', src / 'root/ci-artifacts-clean')
        shutil.copyfile(HERE / 'model' / 'ci-artifacts-clean.service',
                        src / 'root/systemd/ci-artifacts-clean.service')
        shutil.copyfile(HERE / 'model' / 'ci-artifacts-clean.timer',
                        src / 'root/systemd/ci-artifacts-clean.timer')
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
                euid=0, systemctl='ok'):
    w.write_shims(users=users, groups=groups, euid=euid, systemctl=systemctl)
    return {
        'PATH': f'{w.path("bin")}:/usr/bin:/bin',
        'OPS_SERVER_SRC': str(src_ops),
        'OPS_SERVER_SBIN_DST': str(w.path('sbin')),
        'OPS_SERVER_ETC_DST': str(w.path('etc/systemd/system')),
        'OPS_SERVER_CI_ARTIFACTS': str(w.path('var/lib/ci-artifacts')),
        'OPS_SERVER_CI_ARTIFACTS_MOB_OWNER': 'toymob',
        'OPS_SERVER_CI_ARTIFACTS_BACK_OWNER': 'toyback',
        'OPS_SERVER_CI_ARTIFACTS_GROUP': 'toygroup',
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
        if u.name in ('ci-artifacts-clean.service', 'ci-artifacts-clean.timer'):
            continue
        shutil.copyfile(u, etc / u.name)
        (etc / u.name).chmod(0o644)
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
        rc, out, err = w.run(prefix + ['artifacts'], env)
        mob_root = ciart / MOB
        back_root = ciart / BACK
        clean_dst = w.path('sbin/ci-artifacts-clean')
        svc_dst = w.path('etc/systemd/system/ci-artifacts-clean.service')
        tmr_dst = w.path('etc/systemd/system/ci-artifacts-clean.timer')
        # оракул снят ДО вызова: ожидаемые байты берутся из модели-спеки
        want_clean = (HERE / 'model/ci-artifacts-clean').read_bytes()
        want_svc = (HERE / 'model/ci-artifacts-clean.service').read_bytes()
        want_tmr = (HERE / 'model/ci-artifacts-clean.timer').read_bytes()
        if rc != 0:
            return False, install_missing(rc, err)
        if clean_dst.read_bytes() != want_clean or stat.S_IMODE(clean_dst.stat().st_mode) != 0o755:
            return False, 'скрипт не установлен байт-в-байт (755)'
        if svc_dst.read_bytes() != want_svc or stat.S_IMODE(svc_dst.stat().st_mode) != 0o644:
            return False, 'юнит service не установлен байт-в-байт (644)'
        if tmr_dst.read_bytes() != want_tmr:
            return False, 'юнит timer не установлен байт-в-байт'
        chown = w.journal('chown')
        for want in (
            f'chown root:root -- {clean_dst}',
            f'chown root:root -- {svc_dst}',
            f'chown root:root -- {tmr_dst}',
            f'chown toymob:toygroup -- {mob_root}',
            f'chown toyback:toygroup -- {back_root}',
        ):
            if want not in chown:
                return False, f'нет владельца корня: {want} (журнал: {"; ".join(chown)})'
        if stat.S_IMODE(mob_root.stat().st_mode) != 0o2775:
            return False, f'режим корня моба {oct(stat.S_IMODE(mob_root.stat().st_mode))} != 2775'
        if stat.S_IMODE(back_root.stat().st_mode) != 0o2775:
            return False, f'режим корня бэка {oct(stat.S_IMODE(back_root.stat().st_mode))} != 2775'
        sysctl = w.journal('systemctl')
        if 'systemctl daemon-reload' not in sysctl:
            return False, 'нет systemctl daemon-reload'
        if 'systemctl enable --now ci-artifacts-clean.timer' not in sysctl:
            return False, 'нет enable --now ci-artifacts-clean.timer'
        if 'установлено: ci-artifacts' not in out:
            return False, f'нет строки установки: {out.strip()[:200]}'
        return True, ''
    finally:
        w.close()


def cell_install_precondition(subj):
    w = World()
    try:
        src_ops = subj.src_ops(w)
        # toyback НЕ в известных пользователях — предусловие обязано отказать
        env = install_env(w, src_ops, users=('toymob',))
        prefix = subj.install()
        if prefix is None:
            return no_subject('ops/server/install.sh')
        if subj.kind == 'stub' and subj.stub == 's11_slepaja_sverka.sh':
            return no_subject('install.sh artifacts (стаб s11 не реализует установку)')
        rc, out, err = w.run(prefix + ['artifacts'], env)
        wrote = [p for p in (
            w.path('sbin/ci-artifacts-clean'),
            w.path('etc/systemd/system/ci-artifacts-clean.service'),
            w.path('etc/systemd/system/ci-artifacts-clean.timer'),
            w.path('var/lib/ci-artifacts/Complior-mob'),
            w.path('var/lib/ci-artifacts/Complior-back'),
        ) if p.exists()]
        if rc != 1:
            return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'rc={rc} (ожидался отказ 1), записано: {wrote}'
        if 'ОТКАЗ: нет пользователя: toyback' not in err:
            return False, f'нет именованного отказа о пользователе: {err.strip()[:300]}'
        if wrote:
            return False, f'отказ не ДО записей: {wrote}'
        return True, ''
    finally:
        w.close()


def cell_verify_drift(subj):
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops)
        prefix = subj.install()
        if prefix is None:
            return no_subject('ops/server/install.sh')
        _, verify_mode = subj.install_modes()
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
        target = w.path('sbin/ci-artifacts-clean')
        target.write_bytes(target.read_bytes() + b'drift\n')
        rc, out, err = w.run(prefix + [verify_mode], env)
        if rc != 1:
            return False, f'сверка слепа к дрейфу: rc={rc}, out: {out.strip()[:200]}'
        if 'расхождение' not in err or 'ci-artifacts-clean' not in err:
            return False, f'сверка не назвала файл: {err.strip()[:300]}'
        return True, ''
    finally:
        w.close()

def cell_install_euid_refused(subj):
    """И-9(а): не-root прогон artifacts — отказ ДО записей (шим id → 1)."""
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops, euid=1)
        prefix = subj.install()
        if prefix is None:
            return no_subject('ops/server/install.sh')
        rc, out, err = w.run(prefix + ['artifacts'], env)
        wrote = [p for p in (
            w.path('sbin/ci-artifacts-clean'),
            w.path('etc/systemd/system/ci-artifacts-clean.service'),
            w.path('etc/systemd/system/ci-artifacts-clean.timer'),
            w.path('var/lib/ci-artifacts/Complior-mob'),
            w.path('var/lib/ci-artifacts/Complior-back'),
        ) if p.exists()]
        if rc != 1:
            return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'rc={rc} (ожидался отказ 1), записано: {wrote}'
        if 'ОТКАЗ: artifacts-часть требует euid 0' not in err:
            return False, f'нет именованного отказа euid: {err.strip()[:300]}'
        if wrote:
            return False, f'euid-отказ не ДО записей: {wrote}'
        return True, ''
    finally:
        w.close()


def cell_install_repo_symlink_refused(subj):
    """И-9(г): предсозданная символьная ссылка на месте корня репо — отказ,
    ссылка и цель нетронуты, chown по ссылке не было."""
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops)
        ciart = w.path('var/lib/ci-artifacts')
        ciart.mkdir(parents=True)
        outside = w.path('outside-store')
        outside.mkdir()
        (outside / 'evidence.txt').write_bytes(b'target\n')
        mob_root = ciart / MOB
        mob_root.symlink_to(outside, target_is_directory=True)
        prefix = subj.install()
        if prefix is None:
            return no_subject('ops/server/install.sh')
        rc, out, err = w.run(prefix + ['artifacts'], env)
        if rc != 1:
            return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'rc={rc} (ожидался отказ 1), stderr: {err.strip()[:200]}'
        if f'ОТКАЗ: репо — символьная ссылка: {mob_root}' not in err:
            return False, f'нет именованного отказа на ссылку-репо: {err.strip()[:300]}'
        if not mob_root.is_symlink():
            return False, 'установка сняла ссылку-репо'
        if not (outside / 'evidence.txt').exists():
            return False, 'цель ссылки-репо повреждена'
        if f'chown toymob:toygroup -- {mob_root}' in w.journal('chown'):
            return False, 'установка тронула ссылку-репо chown'
        return True, ''
    finally:
        w.close()


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
    «ci-artifacts: не установлены», это не расхождение."""
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops)
        prefix = subj.install()
        if prefix is None:
            return no_subject('ops/server/install.sh')
        _, verify_mode = subj.install_modes()
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
        return True, ''
    finally:
        w.close()


def cell_verify_roots(subj):
    """И-10: сверка корней — после установки chmod 0755 корня моба
    verify обязан rc 1 «ОТКАЗ: расхождение ci-artifacts: <путь>»."""
    w = World()
    try:
        src_ops = subj.src_ops(w)
        env = install_env(w, src_ops)
        prefix = subj.install()
        if prefix is None:
            return no_subject('ops/server/install.sh')
        _, verify_mode = subj.install_modes()
        if subj.kind == 'repo':
            env['OPS_SERVER_BIN_DST'] = str(install_core_files(w, src_ops))
        rc, out, err = w.run(prefix + ['artifacts'], env)
        if rc != 0:
            return False, install_missing(rc, err) if 'NOT_IMPLEMENTED: использование' in err else f'установка для мира дрейфа корня не зелёная: rc={rc}, {err.strip()[:300]}'
        mob_root = w.path('var/lib/ci-artifacts/Complior-mob')
        os.chmod(mob_root, 0o755)
        rc, out, err = w.run(prefix + [verify_mode], env)
        if rc != 1:
            return False, f'сверка не смотрит корни: rc={rc}, out: {out.strip()[:200]}'
        if f'ОТКАЗ: расхождение ci-artifacts: {mob_root}' not in err:
            return False, f'сверка не назвала корень: {err.strip()[:300]}'
        return True, ''
    finally:
        w.close()


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
    'verify-drift': cell_verify_drift,
    'verify-not-installed': cell_verify_not_installed,
    'verify-roots': cell_verify_roots,
    'unit-grammar': cell_unit_grammar,
    'readme-anchors': cell_readme_anchors,
}


def check_family():
    for p in ('model/ci-artifacts-clean', 'model/install-artifacts.sh',
              'model/ci-artifacts-clean.service', 'model/ci-artifacts-clean.timer',
              'model/README-ops-server.md'):
        if not (HERE / p).exists():
            refuse(f'нет файла семьи: {p}')
    stubs = sorted(q.name for q in (HERE / 'stabs').iterdir())
    if len(stubs) != len(STUBS):
        refuse(f'стабов в stabs/ {len(stubs)}, привязок {len(STUBS)}: {stubs}')
    for name in stubs:
        if name not in STUBS:
            refuse(f'стаб без привязки: {name}')
    if len(CASES) != 21:
        refuse(f'клеток {len(CASES)}, ожидалось 21')


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
