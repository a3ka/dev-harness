#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ субъекта scripts/check_project_session.sh (контракт 125, зона architect).
# Сверяет ФАКТЫ двух запусков omp — основной сессии (дев-вход, дом зоны dev) и сессии
# проекта (ОТДЕЛЬНЫЙ дом $PSTATE/home, 055 И-2) — по замкнутому перечню полей. Факт
# запуска = argv (по строке на элемент) и env (KEY=VALUE) — формат стаба-omp 105.
#   --main-argv F --main-env F --project-argv F --project-env F
# stdout — РОВНО строки «РАСХОЖДЕНИЕ <поле>», по одной на каждое фактическое расхождение,
# в порядке перечня, и никаких других (посторонняя причина = ложный диагноз).
# rc 0 — расхождений нет; rc 1 — есть; rc 2 — «НЕЧЕМ-ПРОВЕРИТЬ <причина>».
# Перечень сева сверяется ПОБАЙТНО (sha256) и только обычным файлом ВНЕ дома dev
# (ссылка или жёсткая ссылка = запись проекта в dev); agent.db — симлинк W8 на базу dev; живое
# состояние dev недостижимо из дома проекта: каждый путь дома (обход входит в каталоги-ссылки)
# разрешается realpath ПОЛНОСТЬЮ и не лежит под каталогом агента dev и не является его предком
# (кроме симлинка agent.db W8 и путей перечня сева — их судят свои поля); ни один файл дома
# не делит inode с файлом каталога агента dev; нет побайтной копии непустого файла живого
# состояния ПОД ЛЮБЫМ именем в любом месте дома проекта. Содержимое не печатается.
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
for f in "$MA" "$ME" "$PA" "$PE"; do
  [ -n "$f" ] && [ -s "$f" ] || { printf 'НЕЧЕМ-ПРОВЕРИТЬ fakty-otsutstvuyut\n'; exit 2; }
done
exec python3 - "$MA" "$ME" "$PA" "$PE" <<'PY'
import hashlib, os, stat, sys
POLYA = ["dom", "profil", "config-yml", "models-db", "skill-descriptions-db", "agent-db",
         "ne-sessii", "agenty", "pravila", "politika", "model", "instrumenty",
         "rasshireniya", "podtverzhdeniya"]
SEV = (("config-yml", "config.yml"), ("models-db", "models.db"), ("skill-descriptions-db", "skill-descriptions.db"))
NIKOGDA = ("sessions", "history.db", "blobs", "terminal-sessions", "custom-session-files")
RULES_HDR = "## Правила, каждое из которых уже стоило время"
def nechem(p):
    print("НЕЧЕМ-ПРОВЕРИТЬ " + p); sys.exit(2)
def fakty(fa, fe):
    with open(fa) as h: argv = h.read().split("\n")
    if argv and argv[-1] == "": argv.pop()
    env = {}
    with open(fe) as h:
        for ln in h.read().split("\n"):
            if "=" in ln:
                k, v = ln.split("=", 1); env.setdefault(k, v)
    if not env.get("HOME", "").startswith("/") or not env.get("PWD", "").startswith("/"):
        nechem("home-ili-cwd-otsutstvuet")
    return argv, env
def vals(argv, flag):
    return [argv[i + 1] for i in range(len(argv) - 1) if argv[i] == flag]
def odin(argv, flag):
    v = vals(argv, flag); return v[0] if v else None
def rp(p):
    return os.path.realpath(p) if p and os.path.exists(p) else None
def sha(p):
    with open(p, "rb") as h: return hashlib.sha256(h.read()).hexdigest()
def tekst(p):
    if not p or not os.path.isfile(p): return None
    with open(p) as h: return h.read()
def pod(p, koren):
    return p is not None and koren is not None and (p == koren or p.startswith(koren + os.sep))
def nabor(dirs, suffix):
    out = {}
    for d in dirs:
        if not os.path.isdir(d): continue
        for root, _, files in os.walk(d):
            for f in files:
                if f.endswith(suffix):
                    full = os.path.join(root, f)
                    out[os.path.relpath(full, d)] = sha(full)
    return out
def pravila_osnovnoj(prompt, cwd):
    base = tekst(prompt)
    if base is None: return None
    rules = []
    ag = tekst(os.path.join(cwd, "AGENTS.md"))
    if ag is not None:
        lines = ag.split("\n")
        if RULES_HDR in lines:
            i = lines.index(RULES_HDR); rules = [lines[i]]
            for ln in lines[i + 1:]:
                if ln.startswith("## "): break
                rules.append(ln)
    return (base, tuple(l for l in rules if l.strip()))
def pravila_dostavleny(m, prompt):
    t = tekst(prompt)
    if t is None or m is None: return False
    base, rules = m
    lines = set(t.split("\n"))
    return t.startswith(base) and all(r in lines for r in rules)
ma, me = fakty(sys.argv[1], sys.argv[2]); pa, pe = fakty(sys.argv[3], sys.argv[4])
mprof, pprof = odin(ma, "--profile"), odin(pa, "--profile")
mhome, phome = rp(me["HOME"]), rp(pe["HOME"])
if mprof is None: nechem("osnovnaya-bez-profil")
if mhome is None: nechem("osnovnaya-bez-dom")
MA_ = os.path.join(me["HOME"], ".omp/profiles", mprof, "agent")
PA_ = os.path.join(pe["HOME"], ".omp/profiles", pprof or "", "agent")
for pole, name in SEV[:2] + (("agent-db", "agent.db"),):
    if not os.path.isfile(os.path.join(MA_, name)): nechem("osnovnaya-bez-" + pole)
for flag, pole in (("--model", "model"), ("--tools", "instrumenty"), ("--append-system-prompt", "pravila")):
    if odin(ma, flag) is None: nechem("osnovnaya-bez-" + pole)
ras = set()
# dom: отдельный дом проекта — ни тот же, ни вложенный в дом dev (и наоборот)
if phome is None or pod(phome, mhome) or pod(mhome, phome): ras.add("dom")
if pprof != mprof: ras.add("profil")
for pole, name in SEV:
    m, p = os.path.join(MA_, name), os.path.join(PA_, name)
    if not os.path.isfile(m):
        if os.path.lexists(p): ras.add(pole)
        continue
    if os.path.islink(p) or not os.path.isfile(p) or pod(rp(p), mhome) or os.path.samefile(p, m) or sha(p) != sha(m):
        ras.add(pole)
m_adb, p_adb = os.path.join(MA_, "agent.db"), os.path.join(PA_, "agent.db")
if not (os.path.islink(p_adb) and rp(p_adb) == rp(m_adb)): ras.add("agent-db")
# ne-sessii: живое состояние dev — по ЦЕЛИ ССЫЛКИ и по СОДЕРЖИМОМУ, под любым именем во всём доме проекта
# ДОСТИЖИМОСТЬ: каждый путь дома проекта (обход входит в каталоги-ссылки, защита от циклов) разрешается
# realpath ПОЛНОСТЬЮ (все промежуточные ссылки и родители); путь под каталогом агента dev ЛИБО его предок
# (сам каталог, профиль, дом dev, …) — живое состояние достижимо. Исключения: ровно симлинк agent.db W8
# и пути перечня сева (их судят свои поля). ИНОД: файл дома проекта, делящий inode с файлом каталога
# агента dev (жёсткая ссылка, в т.ч. на пустой). СОДЕРЖИМОЕ: побайтная копия непустого файла живого состояния.
zhivoe = [os.path.realpath(os.path.join(MA_, n)) for n in NIKOGDA]
koren_dev = os.path.realpath(MA_)
def predok(a, b): return a == b or b.startswith(a.rstrip(os.sep) + os.sep)
def k_dev(r): return predok(koren_dev, r) or predok(r, koren_dev)
def razreshit(q): return os.path.realpath(q)
iskl = {os.path.join(PA_, n) for _, n in SEV}
profili = os.path.join(pe["HOME"], ".omp", "profiles")
def w8(q, r): # ровно симлинк <дом проекта>/.omp/profiles/<профиль>/agent/agent.db на базу агентов dev (058)
    return (os.path.islink(q) and r == rp(m_adb) and os.path.basename(q) == "agent.db"
            and os.path.basename(os.path.dirname(q)) == "agent" and os.path.dirname(os.path.dirname(os.path.dirname(q))) == profili)
dev_ino = set()
for root, _, files in os.walk(MA_):
    for f in files:
        s = os.lstat(os.path.join(root, f))
        if stat.S_ISREG(s.st_mode): dev_ino.add((s.st_dev, s.st_ino))
ssylka, razmery, vidany, obhod = False, {}, set(), [pe["HOME"]]
while obhod:
    d = obhod.pop()
    if os.path.realpath(d) in vidany: continue
    vidany.add(os.path.realpath(d))
    try: imena = sorted(os.listdir(d))
    except OSError: continue
    for f in imena:
        q = os.path.join(d, f); r = razreshit(q)
        try: st = os.stat(q)
        except OSError: st = None
        if q in iskl or w8(q, r):
            if st is not None and stat.S_ISREG(st.st_mode) and not os.path.islink(q) and st.st_size > 0:
                razmery.setdefault(st.st_size, []).append(q)
            continue
        if k_dev(r): ssylka = True; continue
        if st is None: continue
        if stat.S_ISDIR(st.st_mode): obhod.append(q); continue
        if not stat.S_ISREG(st.st_mode): continue
        if (st.st_dev, st.st_ino) in dev_ino: ssylka = True
        if st.st_size > 0: razmery.setdefault(st.st_size, []).append(q)
dev = set()
for z in zhivoe:
    kand = [z] if os.path.isfile(z) else [os.path.join(root, f) for root, _, files in os.walk(z) for f in files]
    for q in kand:
        if not os.path.islink(q) and os.path.isfile(q) and os.path.getsize(q) in razmery: dev.add(sha(q))
if ssylka or any(sha(q) in dev for qs in razmery.values() for q in qs if dev):
    ras.add("ne-sessii")
mag = nabor([os.path.join(MA_, "agents"), os.path.join(me["PWD"], ".omp/agents")], ".md")
pag = nabor([os.path.join(PA_, "agents"), os.path.join(pe["PWD"], ".omp/agents")], ".md")
if any(pag.get(k) != v for k, v in mag.items()): ras.add("agenty")
if not pravila_dostavleny(pravila_osnovnoj(odin(ma, "--append-system-prompt"), me["PWD"]), odin(pa, "--append-system-prompt")):
    ras.add("pravila")
# политика: основная грузит её проектным путём omp (cwd = установка); проект — первым --config
cfg = vals(pa, "--config")
mpol = rp(os.path.join(me["PWD"], ".omp/config.yml"))
if mpol is None: nechem("osnovnaya-bez-politika")
if rp(cfg[0] if cfg else None) != mpol: ras.add("politika")
if odin(pa, "--model") != odin(ma, "--model"): ras.add("model")
if odin(pa, "--tools") != odin(ma, "--tools"): ras.add("instrumenty")
mext = {rp(e) for e in vals(ma, "-e")}
ed = os.path.join(me["PWD"], ".omp/extensions")
if os.path.isdir(ed):
    mext |= {rp(os.path.join(ed, f)) for f in os.listdir(ed) if f.endswith(".ts") and os.path.isfile(os.path.join(ed, f))}
if not mext <= {rp(e) for e in vals(pa, "-e")}: ras.add("rasshireniya")
if (odin(pa, "--approval-mode") or "always-ask") != (odin(ma, "--approval-mode") or "always-ask"):
    ras.add("podtverzhdeniya")
for pole in POLYA:
    if pole in ras:
        print("РАСХОЖДЕНИЕ " + pole)
        sys.stderr.write("check_project_session: поле %s расходится\n" % pole)
sys.exit(1 if ras else 0)
PY
