#!/usr/bin/env bash
# Красная клетка 992-Р-1 (вердикт verdicts/review/contracts-992-v1.md, FAIL):
# git ls-tree без --full-tree понимает pathspec ОТНОСИТЕЛЬНО cwd, а предполёт
# наследует cwd вызывающего (scripts/gitw зовёт предполёт без cd) — push из
# подкаталога видел «пустое дерево», package.json с ключами check:* не находился
# и все четыре npm-чека молча пропускались (rc0 «чеки неприменимы») вместо
# rc1-отказа. До правки клетка красна (пропуск воспроизводится живьём),
# после правки (ls-tree --full-tree) — зелена.
#
# Форма — как у клеток B-preflight-* fail_closed_992.py: одноразовый репозиторий,
# полный предмет (НЕ фрагмент), ls-remote — детерминированный сетевой шов,
# npm-стаб зажигается ТОЛЬКО на check-ключах (остальное — реальный npm),
# hit-файл — свидетельство доставки дефекта, не оракул приёмки. Отличие входа:
# предмет исполняется из ПОДКАТАЛОГА репозитория (cwd ≠ корень) — существующие
# клетки поголовно шли из корня, потому пропуск и жил.
#
# Прямой запуск (А-82, red_* вне case_*-глоба раннера):
#   bash fixtures/freeze_contract/red_preflight_podkatalog_992.sh [путь-к-предмету]
# Без аргумента предмет — scripts/ живого дерева; аргументом предъявляют красноту
# ДО правки на блобе без --full-tree, не трогая клетку:
#   git show <до-правки>:scripts/gitw_preflight_071.sh > /tmp/pf && \
#     bash fixtures/freeze_contract/red_preflight_podkatalog_992.sh /tmp/pf
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="${1:-$REPO/scripts/gitw_preflight_071.sh}"
[ -f "$SUBJ" ] || { printf '992-Р1: предмет отсутствует: %s\n' "$SUBJ" >&2; exit 1; }
command -v git      >/dev/null 2>&1 || { printf '992-Р1: окружение без git\n' >&2; exit 1; }
command -v npm      >/dev/null 2>&1 || { printf '992-Р1: окружение без npm\n' >&2; exit 1; }
command -v python3  >/dev/null 2>&1 || { printf '992-Р1: окружение без python3\n' >&2; exit 1; }
ORIG_PATH="$PATH"
GITBIN="$(command -v git)"
NPMBIN="$(command -v npm)"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r992p1.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

# ── одноразовый репозиторий: В КОРНЕ package.json с ЧЕТЫРЬМЯ ключами check:* ──
T="$WORK/repo"
git init -q -b main "$T"
G() { git -C "$T" -c user.name=Фикстура -c user.email=fixture@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }
mkdir -p "$T/nested" "$WORK/bin"
printf 'файл подкаталога\n' > "$T/nested/file.txt"
cat > "$T/package.json" <<'PKGEOF'
{
  "name": "fixture-r992p1",
  "version": "0.0.0",
  "scripts": {
    "check:nabludenia": "exit 0",
    "check:ci-parity": "exit 0",
    "check:ceilings": "exit 0",
    "check:ids": "exit 0"
  }
}
PKGEOF
G add -A
G commit -qm 'fixture: package.json с check-ключами в корне'
TIP="$(G rev-parse HEAD)"

# ── швы: ls-remote — сеть-стаб (форма клеток B-preflight-*), npm — дефект
# зажигается только на check-ключах и только по FC_FAULT=1; прочие вызовы —
# реальному бинарю.
cat > "$WORK/bin/git" <<'EOF'
#!/usr/bin/env python3
import os, sys
a = sys.argv[1:]
if 'ls-remote' in a:
    if '--tags' not in a:
        print(os.environ['R992_TIP'] + '\trefs/heads/main')
    sys.exit(0)
os.execv(os.environ['R992_GIT'], [os.environ['R992_GIT']] + a)
EOF
cat > "$WORK/bin/npm" <<'EOF'
#!/usr/bin/env python3
import os, sys
a = sys.argv[1:]
if a[:1] == ['run'] and os.environ.get('FC_FAULT') == '1':
    open(os.environ['FC_HIT'], 'a').write('hit\n')
    sys.exit(3)
os.execv(os.environ['R992_NPM'], [os.environ['R992_NPM']] + a)
EOF
chmod 755 "$WORK/bin/git" "$WORK/bin/npm"

# ── прогон предмета из ПОДКАТАЛОГА (cwd ≠ корень — сам вход клетки) ──────────
run_subject() { # run_subject <fc_fault>: rc предмета, вывод — $WORK/out
  ( cd "$T/nested" && FC_FAULT="$1" FC_HIT="$WORK/hit" TMPDIR="$WORK" \
      R992_TIP="$TIP" R992_GIT="$GITBIN" R992_NPM="$NPMBIN" \
      PATH="$WORK/bin:$ORIG_PATH" \
      GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
      bash "$SUBJ" 'https://github.com/fixture/fixture.git' HEAD:main ) >"$WORK/out" 2>&1
}

fail=0

# контроль: чеки зелёные → rc0 «ПРЕДПОЛЁТ: чисто» (не «неприменимы» — ключи-то есть)
run_subject 0; crc=$?
if [ "$crc" -eq 0 ] && grep -q 'gitw ПРЕДПОЛЁТ: чисто' "$WORK/out"; then cok=1; else
  cok=0; fail=$((fail+1))
  printf '  КОНТРОЛЬ (cwd=nested, чеки зелёные): rc=%s — ожидался rc0 «ПРЕДПОЛЁТ: чисто»\n' "$crc"
  sed 's/^/    /' "$WORK/out"
fi

# дефект: первый чек красный → rc1 именованный отказ, НЕ rc0-пропуск
rm -f "$WORK/hit"
run_subject 1; frc=$?
if [ -f "$WORK/hit" ]; then hit=1; else hit=0; fi
if [ "$frc" -eq 1 ] \
   && grep -q 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек красный: check:nabludenia' "$WORK/out" \
   && [ "$hit" -eq 1 ] \
   && ! grep -q 'чеки неприменимы' "$WORK/out"; then fok=1; else
  fok=0; fail=$((fail+1))
  printf '  ДЕФЕКТ (cwd=nested, чек красный): rc=%s hit=%s — ожидался rc1 «чек красный», не rc0-пропуск\n' "$frc" "$hit"
  sed 's/^/    /' "$WORK/out"
fi

printf 'B-preflight-podkatalog: control_rc=%s fault_rc=%s oracle=%s hit=%s accepted=%s\n' \
  "$crc" "$frc" "$fok" "$hit" "$(( cok && fok ))"
printf 'cases=1 observations=2 failures=%s\n' "$fail"
[ "$fail" -eq 0 ]
