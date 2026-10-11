#!/usr/bin/env bash
# Стаб-пак 079 (Н-39: привязка стабов к входам — ЗДЕСЬ, в коде, не в прозе
# контракта). Каждый обманный стаб — мини-субъект или точечная порча копии
# субъекта, подставляемая в тою-мир клетки (генератор --gen, parity --parity,
# нормализатор блока --normalizator, чек --check-sub, дверь --dver), и
# прогоняется на входе, где его дефект НАБЛЮДАЕМ: клетка обязана быть КРАСНОЙ.
# Диффпроба: на входе, где дефект не наблюдаем, стаб ведёт себя как честный.
# rc стаб-пака: 0 — все стабы пойманы и все диффпробы зелёны; 1 — пропуск; 2 —
# нечем проверить (мир/носитель не построен — НЕ зелёное).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
FAM="$ROOT/fixtures/pokrytie_083_088_079"
for f in red_gen_otkazy_079.sh red_parity_reestr_079.sh red_istochnik_incr_079.sh red_dver_getent_079.sh; do
  [ -f "$FAM/$f" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$FAM/$f" >&2; exit 2; }
done
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }

POJMANO=0; PROPUSHENO=0; DIFFKRASNO=0
SCR="$(mktemp -d "${TMPDIR:-/tmp}/pokrytie079-stub.XXXXXX")" || exit 2
trap 'rm -rf -- "$SCR"' EXIT

# прогон клетки со стабом → 0 стаб пойман (клетка красна); 1 пропуск (зелена);
# диффпроба → 0 стаб как честный; 1 нет. Оба счётчика печатаются поимённо.
zapest() { printf 'стаб-пак 079: %s\n' "$*"; }

# ── д1: генератор принимает нерезолвящийся реестр ─────────────────────────────
cat > "$SCR/gen-d1.sh" <<'EOF'
#!/usr/bin/env bash
# мини-субъект: не проверяет резолв, пишет фиксированные блоки, всегда rc 0
set -uo pipefail
ROOT="."
MODE="" ; TOY="."
while [ "$#" -gt 0 ]; do case "$1" in --check|--write) MODE="$1"; shift ;; --root) TOY="$2"; shift 2 ;; *) shift ;; esac; done
y="$TOY/.github/workflows/ci.yml"
python3 - "$y" <<'PY'
import sys, io
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s = s.replace('# BEGIN GENERATED CI JOBS (083)\n', '# BEGIN GENERATED CI JOBS (083)\n          - lane: l1\n            keys: vse\n')
s = s.replace('# BEGIN GENERATED CI SHARDS (083)\n', '# BEGIN GENERATED CI SHARDS (083)\n          - shard: ap1\n            keys: vse\n')
open(p, 'w', encoding='utf-8').write(s)
PY
exit 0
EOF
out="$(bash "$FAM/red_gen_otkazy_079.sh" "$ROOT" Р1-нерезолв --gen "$SCR/gen-d1.sh" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && grep -q 'КРАСНО: Р1-нерезолв:' <<<"$out" && grep -q 'ЗЕЛЕНО: Р1-нерезолв/контроль' <<<"$out"; then
  POJMANO=$((POJMANO+1)); zapest "д1 пойман: Р1-нерезолв красна (rc 0/файлы тронуты), контроль-конформ у д1 зелёный (диффпроба)"
elif [ "$rc" -eq 0 ]; then
  PROPUSHENO=$((PROPUSHENO+1)); zapest "д1 ПРОПУЩЕН: Р1-нерезолв зелёна при стабе-«принимальщике»"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д1 сломан не своим дефектом (rc=$rc): $out"
fi

# ── д2: генератор пишет «как получилось» (наивная раздача) ────────────────────
cat > "$SCR/gen-d2.sh" <<'EOF'
#!/usr/bin/env bash
# мини-субъект: раздаёт ключи ПО ПОРЯДКУ парами в lane, баланс не считает
set -uo pipefail
TOY="."
while [ "$#" -gt 0 ]; do case "$1" in --root) TOY="$2"; shift 2 ;; *) shift ;; esac; done
keys="$(awk -F'\t' '$1=="step"{printf "%s ", $2}' "$TOY/registry/ci-steps.tsv")"
K="$(awk -F'\t' '$1=="lanes"{print $2}' "$TOY/registry/ci-steps.tsv")"
y="$TOY/.github/workflows/ci.yml"
python3 - "$y" "$keys" "$K" <<'PY'
import sys
p, keys, K = sys.argv[1], sys.argv[2].split(), int(sys.argv[3])
s = open(p, encoding='utf-8').read()
per = (len(keys) + K - 1) // K
block = ''.join(f'          - lane: l{i+1}\n            keys: {" ".join(keys[i*per:(i+1)*per])}\n' for i in range(K))
s = s.replace('# BEGIN GENERATED CI JOBS (083)\n', '# BEGIN GENERATED CI JOBS (083)\n' + block)
open(p, 'w', encoding='utf-8').write(s)
PY
exit 0
EOF
out="$(bash "$FAM/red_gen_otkazy_079.sh" "$ROOT" Р1-баланс --gen "$SCR/gen-d2.sh" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && grep -q 'КРАСНО: Р1-баланс:' <<<"$out" && grep -q 'как получилось' <<<"$out"; then
  POJMANO=$((POJMANO+1)); zapest "д2 пойман: Р1-баланс красна «как получилось» (наивная пара 200 больше границы 185)"
elif [ "$rc" -eq 0 ]; then
  PROPUSHENO=$((PROPUSHENO+1)); zapest "д2 ПРОПУЩЕН: Р1-баланс зелёна при наивной раздаче"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д2 сломан не своим дефектом (rc=$rc): $out"
fi
# диффпроба д2: реестр 12×10 — наивная раздача в границе, стаб как честный
D="$SCR/d2-diff"; mkdir -p "$D/registry" "$D/.github/workflows" "$D/scripts" "$D/fixtures"
cp "$ROOT/fixtures/pokrytie_083_088_079/../pokrytie_083_088_079/.gitkeep" "$D/" 2>/dev/null || true
{ printf 'lanes\t6\n'; for i in $(seq 1 12); do printf 'step\tk%s\t10\tnpm run check:alpha\n' "$i"; done; } > "$D/registry/ci-steps.tsv"
cat > "$D/package.json" <<'EOF'
{ "name": "toy", "scripts": { "check:alpha": "bash fixtures/alpha.sh" } }
EOF
printf '#!/usr/bin/env bash\nexit 0\n' > "$D/fixtures/alpha.sh"
cat > "$D/.github/workflows/ci.yml" <<'EOF'
name: ci
on: [push]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      # BEGIN GENERATED CI JOBS (083)
      # END GENERATED CI JOBS (083)
EOF
bash "$SCR/gen-d2.sh" --root "$D"; rcd=$?
mx=$(sed -n '/BEGIN GENERATED CI JOBS/,/END GENERATED CI JOBS/p' "$D/.github/workflows/ci.yml" | grep -c 'keys: [^ ]')
load=$(sed -n '/BEGIN GENERATED CI JOBS/,/END GENERATED CI JOBS/p' "$D/.github/workflows/ci.yml" | grep 'keys:' | awk '{print NF-1}' | sort -rn | head -1)
# граница: total=120, K=6, maxw=10 → ceil(120/6)+10=30; наивная пара ключей=20 ≤ 30
if [ "$rcd" -eq 0 ] && [ "${load:-99}" -le 3 ]; then   # ≤3 ключей на lane; вес = ключей×10 ≤ 30
  POJMANO=$((POJMANO+1)); zapest "д2-диффпроба: 12×10 — наивная раздача в границе (2 ключа/lane = 20 сек ≤ 30), стаб как честный"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д2-диффпроба красна (rc=$rcd, ключей на lane=${load:-нет}): стаб сломан не своим дефектом"
fi

# ── д3: parity игнорирует реестр (ДОреестровая форма) ─────────────────────────
python3 - "$ROOT/scripts/verify_ci_parity.sh" "$SCR/par-d3.sh" <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
s = open(src, encoding='utf-8').read()
old = 'if [ -f "$ROOT/registry/ci-steps.tsv" ]; then'
assert s.count(old) == 1, f'носитель реестрового прохода: {s.count(old)} вхождений'
open(dst, 'w', encoding='utf-8').write(s.replace(old, 'if false; then'))
PY
[ -f "$SCR/par-d3.sh" ] || { printf 'NOT_IMPLEMENTED: д3 не построен\n' >&2; exit 2; }
out="$(bash "$FAM/red_parity_reestr_079.sh" "$ROOT" Р2-реестр --parity "$SCR/par-d3.sh" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && grep -q 'КРАСНО: Р2-реестр:' <<<"$out" && grep -q 'check:alpha' <<<"$out"; then
  POJMANO=$((POJMANO+1)); zapest "д3 пойман: Р2-реестр красна, именует check:alpha (реестр проигнорирован)"
elif [ "$rc" -eq 0 ]; then
  PROPUSHENO=$((PROPUSHENO+1)); zapest "д3 ПРОПУЩЕН: Р2-реестр зелёна без реестрового прохода"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д3 сломан не своим дефектом (rc=$rc): $out"
fi
# диффпроба д3: мир без реестровых npm-шагов (alpha покрыта блоком) — стаб как честный (rc 0)
outd="$(bash "$FAM/red_parity_reestr_079.sh" "$ROOT" Р2-реестр/диф --parity "$SCR/par-d3.sh" 2>&1)"; rcd=$?
if [ "$rcd" -eq 0 ]; then
  POJMANO=$((POJMANO+1)); zapest "д3-диффпроба: мир с покрытием блоком — д3 зелёный, как честный"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д3-диффпроба красна (rc=$rcd): $outd"
fi

# ── д4: parity при наличии реестра молча зелен ────────────────────────────────
cat > "$SCR/par-d4.sh" <<'EOF'
#!/usr/bin/env bash
# мини-субъект: реестр есть → rc 0 без суда; иначе честный
R="${1:-.}"
if [ -f "$R/registry/ci-steps.tsv" ]; then exit 0; fi
H="$(dirname "$0")/verify_ci_parity_chestnyj.sh"
exec bash "$H" "$@"
EOF
cp -- "$ROOT/scripts/verify_ci_parity.sh" "$SCR/verify_ci_parity_chestnyj.sh"
out="$(bash "$FAM/red_parity_reestr_079.sh" "$ROOT" Р2-область --parity "$SCR/par-d4.sh" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && grep -q 'КРАСНО: Р2-область:' <<<"$out"; then
  POJMANO=$((POJMANO+1)); zapest "д4 пойман: Р2-область красна (молчаливый rc 0 у «покрывателя всего»)"
elif [ "$rc" -eq 0 ]; then
  PROPUSHENO=$((PROPUSHENO+1)); zapest "д4 ПРОПУЩЕН: Р2-область зелёна при молчаливом стабе"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д4 сломан не своим дефектом (rc=$rc): $out"
fi
outd="$(bash "$FAM/red_parity_reestr_079.sh" "$ROOT" Р2-реестр --parity "$SCR/par-d4.sh" 2>&1)"; rcd=$?
if [ "$rcd" -eq 0 ]; then
  POJMANO=$((POJMANO+1)); zapest "д4-диффпроба: конформный мир — д4 зелёный, как честный"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д4-диффпроба красна (rc=$rcd): $outd"
fi

# ── д5: parity судит реестровые shard-строки, не блок (нормализатор) ─────────
cat > "$SCR/norm-d5.sh" <<'EOF'
#!/usr/bin/env bash
# нормализатор: переписывает keys: блока SHARDS под shard-строку РЕЕСТРА
d="$1"
reestr="$(awk -F'\t' '$1=="shard"{print $3}' "$d/registry/ci-steps.tsv")"
python3 - "$d/.github/workflows/ci.yml" "$reestr" <<'PY'
import sys
p, keys = sys.argv[1], sys.argv[2]
s = open(p, encoding='utf-8').read()
old = '            keys: shard_a\n'
assert s.count(old) == 1, f'keys-строка блока: {s.count(old)} вхождений'
open(p, 'w', encoding='utf-8').write(s.replace(old, f'            keys: {keys}\n'))
PY
EOF
out="$(bash "$FAM/red_parity_reestr_079.sh" "$ROOT" Р2-шарды --normalizator "$SCR/norm-d5.sh" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && grep -q 'КРАСНО: Р2-шарды:' <<<"$out"; then
  POJMANO=$((POJMANO+1)); zapest "д5 пойман: Р2-шарды красна (суд по реестру: FAIL именует shard_a, не shard_b)"
elif [ "$rc" -eq 0 ]; then
  PROPUSHENO=$((PROPUSHENO+1)); zapest "д5 ПРОПУЩЕН: Р2-шарды зелёна при суде по реестровым строкам"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д5 сломан не своим дефектом (rc=$rc): $out"
fi
outd="$(bash "$FAM/red_parity_reestr_079.sh" "$ROOT" Р2-реестр --normalizator "$SCR/norm-d5.sh" 2>&1)"; rcd=$?
if [ "$rcd" -eq 0 ]; then
  POJMANO=$((POJMANO+1)); zapest "д5-диффпроба: конформный мир (блок==реестр) — нормализатор no-op, зелёный"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д5-диффпроба красна (rc=$rcd): $outd"
fi

# ── д6: чек с ЧАСТНОЙ копией грамматики (по четырём чекам) ────────────────────
for chk in check_charter check_zones check_ids check_protected; do
  D6="$SCR/d6-$chk"
  cp -- "$ROOT/scripts/$chk.sh" "$D6" || { printf 'NOT_IMPLEMENTED: нет %s\n' "$chk.sh" >&2; exit 2; }
  cp -- "$ROOT/scripts/lib_incr.sh" "$SCR/lib_incr_private_$chk.sh"
  python3 - "$D6" "$chk" <<'PY'
import sys
p, chk = sys.argv[1], sys.argv[2]
s = open(p, encoding='utf-8').read()
forms = [
    ('. "$SELF_DIR/lib_incr.sh"', '. "$SELF_DIR/lib_incr_private.sh"'),
    ('. "$(dirname "${BASH_SOURCE[0]}")/lib_incr.sh"', '. "$(dirname "${BASH_SOURCE[0]}")/lib_incr_private.sh"'),
]
for old, new in forms:
    if s.count(old) == 1:
        open(p, 'w', encoding='utf-8').write(s.replace(old, new))
        break
else:
    sys.exit(f'носитель source-строки lib_incr.sh не найден в {chk}')
PY
  if [ $? -ne 0 ]; then printf 'NOT_IMPLEMENTED: д6/%s не построен\n' "$chk" >&2; exit 2; fi
  mkdir -p "$SCR/priv-$chk/scripts"
  cp -- "$D6" "$SCR/priv-$chk/scripts/$chk.sh"
  cp -- "$ROOT/scripts/lib_incr.sh" "$SCR/priv-$chk/scripts/lib_incr_private.sh"
  # частная копия — немутированная: подмена чека ЦЕЛИКОМ (каталог scripts)
  out="$(bash "$FAM/red_istochnik_incr_079.sh" "$ROOT" "Р3-источник/$chk" --check-sub "$SCR/priv-$chk/scripts" 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && grep -q "КРАСНО: Р3-источник/$chk" <<<"$out" && grep -q 'переизобретение' <<<"$out"; then
    POJMANO=$((POJMANO+1)); zapest "д6/$chk пойман: маркер из ЧАСТНОЙ копии, не из мутированной библиотеки"
  elif [ "$rc" -eq 0 ]; then
    PROPUSHENO=$((PROPUSHENO+1)); zapest "д6/$chk ПРОПУЩЕН: клетка зелёна при частной грамматике"
  else
    DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д6/$chk сломан не своим дефектом (rc=$rc): $out"
  fi
done

# ── д6ф: чек source'ит библиотеку, но несёт ЧАСТНУЮ побайтовую копию ──────────
# ЛЮБОЙ функции lib_incr.sh поверх source (арбитраж 079: класс «частная
# исполняемая копия функции поверх source»). Множество функций читается из
# живой библиотеки по якорю «^<имя>() {» (ноль — rc 2 стаб-пака, не тихо);
# тело вырезается побайтово и внедряется сразу после source-строки чека.
# Ловится РОДОВЫМ носителем (iii) клетки: подменённая функция не оставляет
# следа — красное поимённо ровно по ней (ровно одно «не вызвана честным
# путём» в прогоне). Диффпроба встроена: прогон клетки начинается с
# немутированного входа (rc 0 + маркер), побайтовая копия на немутированной
# библиотеке ведёт себя как честная; стаб, ломающий честное поведение, даёт
# «вход недействителен», а не поимённое красное.
FN_SPISOK="$(grep -o '^[a-zA-Z_][a-zA-Z0-9_]*() {' "$ROOT/scripts/lib_incr.sh" | sed 's/() {//')"
[ -n "$FN_SPISOK" ] || { printf 'NOT_IMPLEMENTED: функции по якорю ^<имя>() { не найдены в lib_incr.sh\n' >&2; exit 2; }
for fn in $FN_SPISOK; do
for chk in check_charter check_zones check_ids check_protected; do
  D6F="$SCR/d6f-$fn-$chk"
  cp -- "$ROOT/scripts/$chk.sh" "$D6F" || { printf 'NOT_IMPLEMENTED: нет %s\n' "$chk.sh" >&2; exit 2; }
  python3 - "$D6F" "$ROOT/scripts/lib_incr.sh" "$fn" <<'PY'
import re, sys
chk_path, lib_path, fn = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(chk_path, encoding='utf-8').read()
lib = open(lib_path, encoding='utf-8').read()
m = re.search(r'^' + re.escape(fn) + r'\(\) \{.*?^\}\n', lib, re.M | re.S)
assert m, 'функция %s не найдена в lib_incr.sh (якорь ^%s() { .. ^})' % (fn, fn)
forms = ['. "$SELF_DIR/lib_incr.sh"', '. "$(dirname "${BASH_SOURCE[0]}")/lib_incr.sh"']
for old in forms:
    if s.count(old) == 1:
        s = s.replace(old, old + '\n# мутант 079 д6ф: частная побайтовая копия функции %s — второй источник грамматики\n' % fn + m.group(0))
        break
else:
    sys.exit('source-строка lib_incr.sh не найдена в %s' % chk_path)
open(chk_path, 'w', encoding='utf-8').write(s)
PY
  if [ $? -ne 0 ]; then printf 'NOT_IMPLEMENTED: д6ф/%s/%s не построен\n' "$fn" "$chk" >&2; exit 2; fi
  out="$(bash "$FAM/red_istochnik_incr_079.sh" "$ROOT" "Р3-источник/$chk" --check-sub "$D6F" 2>&1)"; rc=$?
  nkr="$(grep -c 'не вызвана честным путём' <<<"$out" || true)"
  if [ "$rc" -eq 1 ] && [ "$nkr" -eq 1 ] && grep -q "КРАСНО: Р3-источник/$chk/след: функция $fn не вызвана честным путём" <<<"$out"; then
    POJMANO=$((POJMANO+1)); zapest "д6ф/$fn/$chk пойман: частная копия $fn поверх source — след не содержит ровно её, красное поимённо"
  elif [ "$rc" -eq 0 ]; then
    PROPUSHENO=$((PROPUSHENO+1)); zapest "д6ф/$fn/$chk ПРОПУЩЕН: клетка зелёна при частной копии $fn"
  else
    DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д6ф/$fn/$chk сломан не своим дефектом (rc=$rc, «не вызвана» строк: ${nkr:-нет}): $out"
  fi
done
done

# ── д7: дверь подставляет $HOME при пустом getent вместо отказа ───────────────
cat > "$SCR/dver-d7.sh" <<'EOF'
#!/usr/bin/env bash
# мини-дверь: пустой getent → uh=$HOME (глоб пуст) → нога (1) пройдена → (а)
set -uo pipefail
uh="$(getent passwd "$(id -un)" | cut -d: -f6)"
[ -n "$uh" ] || uh="$HOME"
R="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
h="$(git -C "$R" rev-parse HEAD 2>/dev/null)" || { printf 'NOT_IMPLEMENTED: не репозиторий\n' >&2; exit 2; }
o="$(git -C "$R" rev-parse origin/main 2>/dev/null)"
if [ "$h" != "$o" ]; then
  printf 'ОТКАЗ: HEAD расходится с origin/main\n' >&2
  exit 1
fi
exit 0
EOF
out="$(bash "$FAM/red_dver_getent_079.sh" "$ROOT" Р4-getent --dver "$SCR/dver-d7.sh" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && grep -q 'КРАСНО: Р4-getent:' <<<"$out"; then
  POJMANO=$((POJMANO+1)); zapest "д7 пойман: Р4-getent красна (rc 1 (а) вместо rc 2 NOT_IMPLEMENTED)"
elif [ "$rc" -eq 0 ]; then
  PROPUSHENO=$((PROPUSHENO+1)); zapest "д7 ПРОПУЩЕН: Р4-getent зелёна при подстановке \$HOME"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д7 сломан не своим дефектом (rc=$rc): $out"
fi
outd="$(bash "$FAM/red_dver_getent_079.sh" "$ROOT" Р4-норма --dver "$SCR/dver-d7.sh" 2>&1)"; rcd=$?
if [ "$rcd" -eq 0 ]; then
  POJMANO=$((POJMANO+1)); zapest "д7-диффпроба: Р4-норма — д7 ведёт себя как честный (rc 1 (а), маркера нет)"
else
  DIFFKRASNO=$((DIFFKRASNO+1)); zapest "д7-диффпроба красна (rc=$rcd): $outd"
fi

printf 'стаб-пак 079: поймано %d, пропущено %d, диффпроб-красных %d\n' "$POJMANO" "$PROPUSHENO" "$DIFFKRASNO"
[ "$PROPUSHENO" -eq 0 ] || exit 1
[ "$DIFFKRASNO" -eq 0 ] || exit 1
[ "$POJMANO" -gt 0 ] || exit 2
exit 0
