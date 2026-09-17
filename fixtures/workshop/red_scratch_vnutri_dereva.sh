#!/usr/bin/env bash
# Красное предъявление 1/4 контракта 028 (структурный фикс судимого дерева, Н-98).
#
# ПРИВЯЗКА К ВЕТВЕ КОДА (Н-39: стабы к ветвям привязывает architect по коду):
# ветка — блок разрешения ZONE лаунчера workshop (сегодня :45 ZONE="$HERE/.zones/dev";
# после предмета — блок HARNESS_SCRATCH с именованным отказом ДО export HOME :437/:502
# и ДО exec :465/:546). Вход: ЯВНЫЙ HARNESS_SCRATCH, указывающий ВНУТРЬ корня
# репозитория, из которого запущен workshop. Честная реализация на этом входе:
# die-отказ с пиннутой подстрокой «внутри стерегомого дерева», rc 1, КАТАЛОГ НЕ
# СОЗДАН, .zones в дереве НЕ создан, omp НЕ запущен (PATH-подставной omp фиксирует
# факт своего запуска — живая сессия не спавнится).
#
# СТАБЫ, которые предъявление ловит (два, оба — РОВНО на этом входе):
# «молча принять in-root HARNESS_SCRATCH» — ветки отказа нет (сегодняшний HEAD:
# ручка вовсе не читается), HOME молча уходит в дерево. И «отказ текстом с
# кодом 0» (блокер 2 вердикта критика v1): ветка печатает отказ и выходит 0 —
# текст есть, вызывающая автоматика получает УСПЕХ; потому предъявление
# проверяет КОД отказа (rc≠0), а не только текст. На внешнем HARNESS_SCRATCH
# (проба 2) оба стаба ведут себя как честный — краснота там не требуется.
#
# Прогоны ДО предмета — из одноразового клона (лаунчер сегодня доходит до exec
# и пишет в дерево); после предмета — в живом дереве.
# Ожидание сегодня (нет предмета): rc 1 именованный. После предмета: rc 0.
# Коды возврата: 0 — отказ предъявлен, код ненулевой, и он до всего; 1 — отказ пробы.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/workshop"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: лаунчер отсутствует — workshop (клон неполон?)\n' >&2
  exit 1
}

WORK="$(mktemp -d /tmp/red028-inroot.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT

# PATH-подставной omp: объявлен здесь (прецедент А-156 — подставной объявлен в
# закоммиченном исходнике); фиксирует запуск и HOME, НИЧЕГО больше не делает.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/omp" <<'EOS'
#!/usr/bin/env bash
printf 'OMP_SHIM_RAN HOME=%s PWD=%s\n' "$HOME" "$PWD" >> "${OMP_SHIM_LOG:?}"
exit 0
EOS
chmod +x "$WORK/bin/omp"

P_OTKAZ='внутри стерегомого дерева'
INROOT_SCRATCH="$REPO/scratch-vnutri-028"

# Герметичность require_metering (workshop:115-133): непустые значения достаточно,
# проверка живого прокси в сессии НЕ идёт (это не --check-metering). Заглушки не
# печатаются и наружу не идут.
export ZAI_API_KEY=dummy-probe
export METERING_PROXY_URL=http://127.0.0.1:1
export METERING_PROXY_TOKEN=dummy-probe
export MINIMAX_API_KEY=dummy-probe
export OMP_SHIM_LOG="$WORK/omp-shim.log"
# Манифест путей всего дерева ДО запуска (инвариант 3: наблюдение — всё дерево,
# не имя .zones).
find "$REPO" -printf '%y %p\n' | LC_ALL=C sort > "$WORK/tree.do"

OUT="$WORK/out.log"
env PATH="$WORK/bin:$PATH" HARNESS_SCRATCH="$INROOT_SCRATCH" \
  bash "$SUBJ" >"$OUT" 2>&1
RC=$?

fail() { printf 'ОТКАЗ %s: %s\n' "$1" "$2" >&2; exit 1; }

# 1. Именованный отказ предъявлен.
grep -qF -- "$P_OTKAZ" "$OUT" \
  || fail 'отказ-не-предъявлен' "workshop rc=$RC, подстроки «$P_OTKAZ» нет в выводе — стаб «молча принять» жив (ветка блока ZONE отсутствует). Вывод: $(head -c 600 "$OUT")"
# 2. Код отказа — НЕ ноль (блокер 2 вердикта v1: «printf + exit 0» — успех для автоматики).
[ "$RC" -ne 0 ] \
  || fail 'uspekh-vmesto-otkaza' "workshop напечатал отказ, но вышел rc=0 — модель «отказ текстом с кодом 0» жива: вызывающая автоматика принимает успех. Вывод: $(head -c 400 "$OUT")"
# 3. Отказ ДО создания: каталог скратча не создан.
[ ! -e "$INROOT_SCRATCH" ] \
  || fail 'скратч-создан-до-отказа' "$INROOT_SCRATCH существует — отказ пришёл ПОСЛЕ создания"
# 4. Дерево НЕ выросло НИ ОДНИМ путём (манифест всего дерева, не только .zones).
find "$REPO" -printf '%y %p\n' | LC_ALL=C sort > "$WORK/tree.posle"
NOVY="$(comm -13 "$WORK/tree.do" "$WORK/tree.posle")"
[ -z "$NOVY" ] \
  || fail 'novye-puti-v-dereve' "дерево выросло до/вместо отказа: $NOVY — HOME ушёл в дерево до отказа"
# 5. omp не запущен (отказ до exec).
[ ! -f "$WORK/omp-shim.log" ] \
  || fail 'omp-zapuschen' "подставной omp запущен (HOME=$(sed 's/.*HOME=//' "$WORK/omp-shim.log")) — отказ стоит после exec"

printf 'red_scratch_vnutri_dereva: отказ «%s» с кодом %s предъявлен до создания/подмены/exec, дерево не выросло\n' "$P_OTKAZ" "$RC" >&2
exit 0
