# Каркас красных проб жнеца ./tmp (контракт 026, правка-2 по пяти блокерам критика v1).
#
# Имя НЕ case_*.sh и НЕ red_*.sh намеренно: сам каркас пробой не считается, в
# мета-прогон verify_antiplacebo не попадает и в счёт «7» не входит (прецедент _repo.sh).
#
# ДВА РЕЖИМА, один двоичный контракт вызова «$BARRIER --root …»:
#  * мета-прогон: WORK/BARRIER/REPO назначает проверяющий (verify_antiplacebo);
#  * прямой прогон (`bash fixtures/gc_agent_branches/<проба>.sh`): проба назначает
#    их сама — поэтому каждая проба красна на текущем HEAD БЕЗ раннера (Б1: красное —
#    закоммиченный и исполненный факт, а не обещание в прозе контракта).
if [ -z "${WORK:-}" ]; then
  REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/zhnets026.XXXXXX")"
  BARRIER="$REPO/scripts/gc_agent_branches.sh"
  trap 'chmod -R u+w "$WORK" 2>/dev/null || true; rm -rf "$WORK"' EXIT
fi

# Возраст записи — lstat САМОЙ записи (инвариант 5): touch по эпохе, не «-10 days».
vozrast_dnej() {  # <путь> <дней назад>
  touch -d "@$(( $(date +%s) - 86400 * $2 ))" -- "$1"
}
vozrast_chasov() {  # <путь> <часов назад>
  touch -d "@$(( $(date +%s) - 3600 * $2 ))" -- "$1"
}

# Герметичный git в игрушке (прецедент _repo.sh: gpgsign/hooksPath/конфиги в /dev/null).
zgi() {  # <корень> <git-аргументы…>
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# Игрушка под пробы жнеца: ЖИВОЙ контракт 026 (файл в дереве, done/contracts/026/* НЕТ),
# тег done/contracts/021/1, tmp/ в .gitignore — условие различимости источника:
# с --exclude-standard tmp/ пуст ПО ПОСТРОЕНИЮ, без него записи видны (замер exp1,
# 2026-09-16). TRACKED-записи под tmp кладутся вызывающей пробой через `zgi add -f`.
zhnec_igrushka() {  # <корень>
  local r="$1"
  mkdir -p "$r/contracts" "$r/tmp"
  printf 'tmp/\n' > "$r/.gitignore"
  printf '# игрушечная копия контракта 026 для красных проб жнеца ./tmp\n' \
    > "$r/contracts/026-zhnec-tmp.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  zgi "$r" add -- .gitignore contracts/026-zhnec-tmp.md
  zgi "$r" commit -q -m 'игрушка: контракт 026 жив, tmp/ игнорируется'
  zgi "$r" tag done/contracts/021/1
}
