#!/usr/bin/env bash
# НЕ БАРЬЕР: инструмент оркестратора — сверщик «сессия проекта = основная + слой проекта»;
# её приёмка — красная батарея fixtures/workshop_project/sessii_125/red_sessii_125.sh (контракт 125 §ПРОВОДКА).
# scripts/check_project_session.sh — сверщик «сессия проекта = основная сессия + слой
# проекта» (контракт 125, И-3). Судит ФАКТЫ двух запусков omp: основной сессии
# (дев-вход, дом зоны dev) и сессии проекта (отдельный дом `$PSTATE/home`, 055 И-2).
#
# CLI: --main-argv F --main-env F --project-argv F --project-env F
#   Формат фактов — стаб-omp 105: argv по строке на элемент, env `KEY=VALUE`
#   с абсолютными HOME и PWD. Дом профиля — `<HOME>/.omp/profiles/<профиль>/agent`.
#
# Перечень полей (порядок = порядок печати, перечень замкнут):
#   dom profil config-yml models-db skill-descriptions-db agent-db ne-sessii
#   agenty pravila politika model instrumenty rasshireniya podtverzhdeniya
#
# stdout — РОВНО строки «РАСХОЖДЕНИЕ <поле>», по одной на каждое ФАКТИЧЕСКОЕ
# расхождение, в порядке перечня, и никаких других: посторонняя причина — ложный
# диагноз (AGENTS.md п.7). Причина каждого поля:
#   dom                — дом сессии проекта не отдельный (тот же или вложен в дом dev,
#                        либо дом dev вложен в него);
#   profil              — профиль сессии проекта ≠ профиля основной;
#   config-yml / models-db / skill-descriptions-db
#                      — перечень сева (028) в доме проекта НЕ побайтная копия файла
#                        зоны dev: ссылка, жёсткая ссылка, путь под домом dev, другое
#                        содержимое (дрейф) или файла нет; файла нет в dev — не причина;
#   agent-db           — не симлинк W8 (058) на базу агентов dev;
#   ne-sessii           — живое состояние dev (`sessions/ history.db blobs/
#                        terminal-sessions/ custom-session-files/`) достижимо из дома
#                        проекта: целью ссылки (любой глубины, цепочкой, относительной,
#                        через каталог-ссылку), предком каталога агента dev, жёсткой
#                        ссылкой (inode, в т.ч. на пустой файл) либо побайтной копией
#                        непустого файла ПОД ЛЮБЫМ именем в любом месте дома;
#   agenty              — раскладка ролей не равна основной (по sha256 карты .md);
#   pravila             — промпт сессии проекта не несёт правил основной (база плюс
#                        секция правил её AGENTS.md) — слой проекта их не отменяет;
#   politika            — первый `--config` сессии проекта ≠ политика основной
#                        (проектный путь omp при cwd = установка);
#   model / instrumenty / rasshireniya / podtverzhdeniya
#                      — значения argv сессии проекта ≠ основной (набор `-e` основной
#                        входит в набор сессии проекта; отсутствие `--approval-mode` =
#                        always-ask, как у входа без `--yolo`).
#
# rc 0 — расхождений нет (stdout пуст);
# rc 1 — есть расхождения (по строке на поле, в порядке перечня);
# rc 2 — нечем проверить: stdout «НЕЧЕМ-ПРОВЕРИТЬ <причина>» — неизвестный ключ,
#       пустой/отсутствующий файл фактов, не абсолютные HOME/PWD, у основной сессии
#       нет профиля/дома/файла профиля/флага/политики.
#
# Содержимое файлов НЕ печатается: диагноз — о фактах, не о байтах.
set -u
MA= ME= PA= PE=
while [ $# -gt 0 ]; do
  case "$1" in
    --main-argv) MA=${2-}; shift ;;
    --main-env) ME=${2-}; shift ;;
    --project-argv) PA=${2-}; shift ;;
    --project-env) PE=${2-}; shift ;;
    *) printf 'НЕЧЕМ-ПРОВЕРИТЬ kljuch-neizvesten\n'; exit 2 ;;
  esac
  shift
done
for _f in "$MA" "$ME" "$PA" "$PE"; do
  [ -n "$_f" ] && [ -s "$_f" ] || { printf 'НЕЧЕМ-ПРОВЕРИТЬ fakty-otsutstvuyut\n'; exit 2; }
done
exec python3 - "$MA" "$ME" "$PA" "$PE" <<'PY'
import hashlib, os, stat, sys

POLYA = ["dom", "profil", "config-yml", "models-db", "skill-descriptions-db", "agent-db",
         "ne-sessii", "agenty", "pravila", "politika", "model", "instrumenty",
         "rasshireniya", "podtverzhdeniya"]
SEV = (("config-yml", "config.yml"), ("models-db", "models.db"),
       ("skill-descriptions-db", "skill-descriptions.db"))
AGENTDB = "agent.db"
NIKOGDA = ("sessions", "history.db", "blobs", "terminal-sessions", "custom-session-files")
ZAGOLOVOK_PRAVIL = "## Правила, каждое из которых уже стоило время"


def nechem(prichina):
    print("НЕЧЕМ-ПРОВЕРИТЬ " + prichina)
    sys.exit(2)


def fakty(f_argv, f_env):
    """argv — по строке на элемент; env — KEY=VALUE, первое значение ключа побеждает."""
    with open(f_argv) as h:
        argv = h.read().split("\n")
    if argv and argv[-1] == "":
        argv.pop()
    env = {}
    with open(f_env) as h:
        for ln in h.read().split("\n"):
            if "=" in ln:
                k, v = ln.split("=", 1)
                env.setdefault(k, v)
    if not env.get("HOME", "").startswith("/") or not env.get("PWD", "").startswith("/"):
        nechem("home-ili-cwd-otsutstvuyet")
    return argv, env


def znacheniya(argv, flag):
    return [argv[i + 1] for i in range(len(argv) - 1) if argv[i] == flag]


def odino(argv, flag):
    v = znacheniya(argv, flag)
    return v[0] if v else None


def rp(p):
    """realpath существующего пути, иначе None (цель-предок и мёртвая ссылка — не путь)."""
    return os.path.realpath(p) if p and os.path.exists(p) else None


def sha(p):
    with open(p, "rb") as h:
        return hashlib.sha256(h.read()).hexdigest()


def tekst(p):
    if not p or not os.path.isfile(p):
        return None
    with open(p) as h:
        return h.read()


def pod(p, koren):
    """p лежит под koren (koren — предок)."""
    return p is not None and koren is not None and (p == koren or p.startswith(koren + os.sep))


def sha_karty(dirs, suffix):
    """Карта относительных путей .md → sha256 по каталогам (первый каталог побеждает)."""
    out = {}
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for root, _, files in os.walk(d):
            for f in files:
                if f.endswith(suffix):
                    full = os.path.join(root, f)
                    out[os.path.relpath(full, d)] = sha(full)
    return out


def pravila_osnovnoj(prompt, cwd):
    """Промпт основной сессии + непустые строки её секции правил AGENTS.md."""
    base = tekst(prompt)
    if base is None:
        return None
    rules = []
    ag = tekst(os.path.join(cwd, "AGENTS.md"))
    if ag is not None:
        lines = ag.split("\n")
        if ZAGOLOVOK_PRAVIL in lines:
            i = lines.index(ZAGOLOVOK_PRAVIL)
            rules = [lines[i]]
            for ln in lines[i + 1:]:
                if ln.startswith("## "):
                    break
                rules.append(ln)
    return (base, tuple(l for l in rules if l.strip()))


def pravila_dostavleny(main_rules, prompt):
    """Промпт сессии проекта начинается с промпта основной и несёт каждое её правило."""
    t = tekst(prompt)
    if t is None or main_rules is None:
        return False
    base, rules = main_rules
    lines = set(t.split("\n"))
    return t.startswith(base) and all(r in lines for r in rules)


ma, me = fakty(sys.argv[1], sys.argv[2])
pa, pe = fakty(sys.argv[3], sys.argv[4])

mprof, pprof = odino(ma, "--profile"), odino(pa, "--profile")
mhome, phome = rp(me["HOME"]), rp(pe["HOME"])
if mprof is None:
    nechem("osnovnaya-bez-profil")
if mhome is None:
    nechem("osnovnaya-bez-dom")
MA_ = os.path.join(me["HOME"], ".omp/profiles", mprof, "agent")
PA_ = os.path.join(pe["HOME"], ".omp/profiles", pprof or "", "agent")
for pole, name in SEV[:2] + (("agent-db", AGENTDB),):
    if not os.path.isfile(os.path.join(MA_, name)):
        nechem("osnovnaya-bez-" + pole)
for flag, pole in (("--model", "model"), ("--tools", "instrumenty"),
                   ("--append-system-prompt", "pravila")):
    if odino(ma, flag) is None:
        nechem("osnovnaya-bez-" + pole)

ras = set()

# dom: дом сессии проекта — отдельный (вариант А, общий дом, отвергнут контрактом)
if phome is None or pod(phome, mhome) or pod(mhome, phome):
    ras.add("dom")
if pprof != mprof:
    ras.add("profil")

# перечень сева: побайтно, обычным файлом ВНЕ дома dev (ссылка и жёсткая ссылка пишут в dev)
for pole, name in SEV:
    m, p = os.path.join(MA_, name), os.path.join(PA_, name)
    if not os.path.isfile(m):
        if os.path.lexists(p):
            ras.add(pole)
        continue
    if (os.path.islink(p) or not os.path.isfile(p) or pod(rp(p), mhome)
            or os.path.samefile(p, m) or sha(p) != sha(m)):
        ras.add(pole)

# agent.db — ровно симлинк W8 на базу агентов dev (058)
m_adb, p_adb = os.path.join(MA_, AGENTDB), os.path.join(PA_, AGENTDB)
if not (os.path.islink(p_adb) and rp(p_adb) == rp(m_adb)):
    ras.add("agent-db")

# ne-sessii: живое состояние dev недостижимо из дома проекта. Три независимые дороги:
#   ЦЕЛЬ — realpath каждого пути дома (обход входит в каталоги-ссылки) не под каталогом
#          агента dev и не является его предком; исключения — симлинк agent.db W8 и пути
#          перечня сева (их судят свои поля);
#   INODE — файл дома проекта, делящий inode с файлом каталога агента dev;
#   СОДЕРЖИМОЕ — побайтная копия НЕПУСТОГО файла живого состояния под любым именем.
zhivoe = [os.path.realpath(os.path.join(MA_, n)) for n in NIKOGDA]
koren_dev = os.path.realpath(MA_)
profili = os.path.join(pe["HOME"], ".omp", "profiles")
iskl = {os.path.join(PA_, n) for _, n in SEV}


def predok(a, b):
    return a == b or b.startswith(a.rstrip(os.sep) + os.sep)


def k_dev(r):
    return predok(koren_dev, r) or predok(r, koren_dev)


def w8(q, r):
    """Ровно симлинк <дом проекта>/.omp/profiles/<профиль>/agent/agent.db на базу dev."""
    return (os.path.islink(q) and r == rp(m_adb) and os.path.basename(q) == AGENTDB
            and os.path.basename(os.path.dirname(q)) == "agent"
            and os.path.dirname(os.path.dirname(os.path.dirname(q))) == profili)


dev_ino = set()
for root, _, files in os.walk(MA_):
    for f in files:
        st = os.lstat(os.path.join(root, f))
        if stat.S_ISREG(st.st_mode):
            dev_ino.add((st.st_dev, st.st_ino))
ssylka, razmery, vidany, obhod = False, {}, set(), [pe["HOME"]]
while obhod:
    d = obhod.pop()
    if os.path.realpath(d) in vidany:
        continue
    vidany.add(os.path.realpath(d))
    try:
        imena = sorted(os.listdir(d))
    except OSError:
        continue
    for f in imena:
        q = os.path.join(d, f)
        r = os.path.realpath(q)
        try:
            st = os.stat(q)
        except OSError:
            st = None
        if q in iskl or w8(q, r):
            if (st is not None and stat.S_ISREG(st.st_mode) and not os.path.islink(q)
                    and st.st_size > 0):
                razmery.setdefault(st.st_size, []).append(q)
            continue
        if k_dev(r):
            ssylka = True
            continue
        if st is None:
            continue
        if stat.S_ISDIR(st.st_mode):
            obhod.append(q)
            continue
        if not stat.S_ISREG(st.st_mode):
            continue
        if (st.st_dev, st.st_ino) in dev_ino:
            ssylka = True
        if st.st_size > 0:
            razmery.setdefault(st.st_size, []).append(q)
dev = set()
for z in zhivoe:
    kand = ([z] if os.path.isfile(z)
            else [os.path.join(root, f)
                  for root, _, files in os.walk(z) for f in files])
    for q in kand:
        if not os.path.islink(q) and os.path.isfile(q) and os.path.getsize(q) in razmery:
            dev.add(sha(q))
if ssylka or (dev and any(sha(q) in dev for qs in razmery.values() for q in qs)):
    ras.add("ne-sessii")

mag = sha_karty([os.path.join(MA_, "agents"), os.path.join(me["PWD"], ".omp/agents")], ".md")
pag = sha_karty([os.path.join(PA_, "agents"), os.path.join(pe["PWD"], ".omp/agents")], ".md")
if any(pag.get(k) != v for k, v in mag.items()):
    ras.add("agenty")
if not pravila_dostavleny(pravila_osnovnoj(odino(ma, "--append-system-prompt"), me["PWD"]),
                         odino(pa, "--append-system-prompt")):
    ras.add("pravila")

# политика: основная грузит её проектным путём omp (cwd = установка); проект — первым --config
cfg = znacheniya(pa, "--config")
mpol = rp(os.path.join(me["PWD"], ".omp/config.yml"))
if mpol is None:
    nechem("osnovnaya-bez-politika")
if rp(cfg[0] if cfg else None) != mpol:
    ras.add("politika")
if odino(pa, "--model") != odino(ma, "--model"):
    ras.add("model")
if odino(pa, "--tools") != odino(ma, "--tools"):
    ras.add("instrumenty")
mext = {rp(e) for e in znacheniya(ma, "-e")}
ed = os.path.join(me["PWD"], ".omp/extensions")
if os.path.isdir(ed):
    mext |= {rp(os.path.join(ed, f)) for f in os.listdir(ed)
             if f.endswith(".ts") and os.path.isfile(os.path.join(ed, f))}
if not mext <= {rp(e) for e in znacheniya(pa, "-e")}:
    ras.add("rasshireniya")
if (odino(pa, "--approval-mode") or "always-ask") != (odino(ma, "--approval-mode") or "always-ask"):
    ras.add("podtverzhdeniya")

for pole in POLYA:
    if pole in ras:
        print("РАСХОЖДЕНИЕ " + pole)
        sys.stderr.write("check_project_session: поле %s расходится\n" % pole)
sys.exit(1 if ras else 0)
PY