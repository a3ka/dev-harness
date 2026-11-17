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
# 125-А1 (решение 3, зависимый регресс): режим выбирается ТОЛЬКО ключом CLI --avto;
# унаследованные из окружения служебные переменные режима не действуют
unset S125_AVTO S125_SEV_ZAPIS 2>/dev/null || true
MA= ME= PA= PE= AVTO=
while [ $# -gt 0 ]; do
  case "$1" in
    --main-argv) MA=${2-}; shift ;;
    --main-env) ME=${2-}; shift ;;
    --project-argv) PA=${2-}; shift ;;
    --project-env) PE=${2-}; shift ;;
    --avto) AVTO=${2-}; shift ;;
    *) printf 'НЕЧЕМ-ПРОВЕРИТЬ kljuch-neizvesten\n'; exit 2 ;;
  esac
  shift
done
if [ -n "$AVTO" ]; then
  # 125 v2 И-10 «автосверка одной командой»: факты обеих сторон — ЗАПИСЬ лаунчера (И-9),
  # не /proc живого PID и не дерево проекта. Здесь только адресация и пригодность записи;
  # суждение полей — тот же код ниже (файл-режим без этих переменных неизменен).
  # Базис PSTATE — та же env-цепочка, что у лаунчера: HARNESS_SCRATCH → XDG_STATE_HOME →
  # $HOME/.local/state; сверку и дверь запускают с ОДНИМ базисом (норма оркестратора).
  # Перечень причин rc 2 замкнут: kljuch-neizvesten koren-otsutstvuet projectid-vne-klassa
  # fakty-osnovnoj-net fakty-proekta-net fakty-proekta-chuzhie sev-fakty-povverzdeny.
  [ -z "$MA$ME$PA$PE" ] || { printf 'НЕЧЕМ-ПРОВЕРИТЬ kljuch-neizvesten\n'; exit 2; }
  FAKTY5=$(python3 - "$AVTO" <<'PYAVTO'
import json, os, re, sys
koren = sys.argv[1]
def otkaz(p):
    print("НЕЧЕМ-ПРОВЕРИТЬ " + p); sys.exit(2)
def godny(d, rezhim, nuzhen_sev=False):
    # 125-А1 (решение 5): комплект читается из ОДНОГО поколения — каноническое имя
    # session-exec разрешается realpath ОДИН раз, все файлы судятся из разрешённого
    # каталога; смесь поколений читателем не собирается
    d = os.path.realpath(d)
    fa, fe, fm = (os.path.join(d, x) for x in ("argv", "env", "meta"))
    if not all(os.path.isfile(x) and os.path.getsize(x) > 0 for x in (fa, fe, fm)):
        return None
    try:
        meta = json.load(open(fm))
    except Exception:
        return None
    if not isinstance(meta, dict) or meta.get("rezhim") != rezhim:
        return None
    env = {}
    for ln in open(fe).read().split("\n"):
        if "=" in ln:
            k, v = ln.split("=", 1); env.setdefault(k, v)
    if not env.get("HOME", "").startswith("/") or not env.get("PWD", "").startswith("/"):
        return None
    # 125-А1 (решение 6): отсутствующий/пустой sev.json — непригодность КОМПЛЕКТА
    # (fakty-proekta-net); sev-fakty-povverzdeny — только существующая непустая,
    # но неразбираемая/вне схемы запись, и она судится ПОСЛЕ принадлежности
    if nuzhen_sev:
        fs = os.path.join(d, "sev.json")
        if not os.path.isfile(fs) or os.path.getsize(fs) == 0:
            return None
    return d, fa, fe, meta
seh = os.environ.get("HARNESS_SESSION_HOME", "")
if not seh.startswith("/"):
    otkaz("fakty-osnovnoj-net")
moj = godny(os.path.join(seh, "session-exec"), "main")
if moj is None:
    otkaz("fakty-osnovnoj-net")
if not os.path.isdir(koren):
    otkaz("koren-otsutstvuet")
# 125-А1 (решение 6): projectId — ЕДИНЫЙ с лаунчером источник (резолвер 054):
# репо-слой harness.project.json → projectLayer.profilePath → слой проекта .projectId;
# предложенный проектом произвольный путь доверенным не объявляется
pid = None
layer_root = os.environ.get("HARNESS_PROJECT_LAYER_ROOT") or koren
try:
    rj = json.load(open(os.path.join(koren, "harness.project.json")))
    pl = rj.get("projectLayer") if isinstance(rj, dict) else None
    rel = pl.get("profilePath") if isinstance(pl, dict) else None
    if isinstance(rel, str) and rel and not rel.startswith("/") and ".." not in rel.split("/"):
        if rel.startswith("./"):
            rel = rel[2:]
        pid = json.load(open(os.path.join(layer_root, rel))).get("projectId")
except Exception:
    pid = None
if not isinstance(pid, str) or not re.fullmatch(r"[a-z0-9][a-z0-9_-]*", pid):
    otkaz("projectid-vne-klassa")
baza = (os.environ.get("HARNESS_SCRATCH") or os.environ.get("XDG_STATE_HOME")
        or os.path.join(os.environ.get("HOME", ""), ".local/state"))
pdir = os.path.join(baza, "dev-harness-projects", pid, "session-exec")
tvoj = godny(pdir, "project", nuzhen_sev=True)
if tvoj is None:
    otkaz("fakty-proekta-net")
if tvoj[3].get("projectId") != pid:
    otkaz("fakty-proekta-chuzhie")
fsev = os.path.join(tvoj[0], "sev.json")
shema = False
try:
    zap = json.load(open(fsev))
    shema = isinstance(zap, dict) and all(
        isinstance(v, dict) and set(v) == {"sha-istochnik", "sha-kopija"}
        and all(re.fullmatch(r"[0-9a-f]{64}", str(x)) for x in v.values())
        for v in zap.values())
except Exception:
    shema = False
if not shema:
    otkaz("sev-fakty-povverzdeny")
print(moj[1]); print(moj[2]); print(tvoj[1]); print(tvoj[2]); print(fsev)
PYAVTO
) || { printf '%s\n' "$FAKTY5"; exit 2; }
  MA=$(printf '%s\n' "$FAKTY5" | sed -n 1p)
  ME=$(printf '%s\n' "$FAKTY5" | sed -n 2p)
  PA=$(printf '%s\n' "$FAKTY5" | sed -n 3p)
  PE=$(printf '%s\n' "$FAKTY5" | sed -n 4p)
  S125_SEV_ZAPIS=$(printf '%s\n' "$FAKTY5" | sed -n 5p)
  export S125_SEV_ZAPIS S125_AVTO=1
fi
for f in "$MA" "$ME" "$PA" "$PE"; do
  [ -n "$f" ] && [ -s "$f" ] || { printf 'НЕЧЕМ-ПРОВЕРИТЬ fakty-otsutstvuyut\n'; exit 2; }
done
exec python3 - "$MA" "$ME" "$PA" "$PE" <<'PY'
import hashlib, json, os, re, stat, sys
POLYA = ["dom", "profil", "config-yml", "models-db", "skill-descriptions-db", "agent-db",
         "ne-sessii", "agenty", "pravila", "politika", "model", "instrumenty",
         "rasshireniya", "podtverzhdeniya"]
SEV = (("config-yml", "config.yml"), ("models-db", "models.db"), ("skill-descriptions-db", "skill-descriptions.db"))
NIKOGDA = ("sessions", "history.db", "blobs", "terminal-sessions", "custom-session-files")
RULES_HDR = "## Правила, каждое из которых уже стоило время"
# 125 v2: в режиме --avto сев судится ЗАПИСЬЮ старта (sev.json лаунчера, И-9) — живой omp
# переписывает свои копии после старта (остаток R15), повторная побайтная сверка живых
# байтов лгала бы; байты копий судит батарея на стаб-мире (b02/b03/b14).
AVTO = os.environ.get("S125_AVTO") == "1"
SEVZAP, SEV_LISHNEE = None, False
if AVTO:
    _z = None
    try:
        _z = json.load(open(os.environ.get("S125_SEV_ZAPIS", ""), "r"))
    except Exception:
        _z = None
    if not isinstance(_z, dict):
        print("НЕЧЕМ-ПРОВЕРИТЬ sev-fakty-povverzdeny"); sys.exit(2)
    SEVZAP = {k: (v["sha-istochnik"], v["sha-kopija"]) for k, v in _z.items()}
    SEV_LISHNEE = bool(set(SEVZAP) - {n for _, n in SEV})
def nechem(p):
    if AVTO: p = "fakty-osnovnoj-net"  # непригодности ядра — сторона основной; причины --avto замкнуты
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
if SEV_LISHNEE: ras.add("ne-sessii")  # запись сева заявляет файл вне перечня — «никогда не сеется»
# dom: отдельный дом проекта — ни тот же, ни вложенный в дом dev (и наоборот)
if phome is None or pod(phome, mhome) or pod(mhome, phome): ras.add("dom")
if pprof != mprof: ras.add("profil")
for pole, name in SEV:
    m, p = os.path.join(MA_, name), os.path.join(PA_, name)
    if not os.path.isfile(m):
        if os.path.lexists(p): ras.add(pole)
        continue
    if AVTO:
        # 125-А1 (решение 3): сев судится записью старта И независимостью файла —
        # ссылка/жёсткая ссылка на dev и путь в дом dev расхождение и в --avto;
        # живые байты НЕ пересматриваются (omp переписывает свои копии после старта — R15)
        if (os.path.islink(p) or not os.path.isfile(p) or pod(rp(p), mhome)
                or os.path.samefile(p, m) or name not in SEVZAP
                or SEVZAP[name][0] != SEVZAP[name][1]):
            ras.add(pole)
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
