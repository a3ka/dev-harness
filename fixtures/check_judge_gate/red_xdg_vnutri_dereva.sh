#!/usr/bin/env bash
# Красное предъявление 3/6 контракта 028 (блокер 1 вердикта критика v1:
# дефолтный XDG-канал способен увести HOME внутрь чекаута ПОД ДРУГИМ ИМЕНЕМ —
# наблюдено критиком: <корень>/state-inside-028/dev-harness-sessions/<hash8>/…).
#
# ПРИВЯЗКА К ВЕТВЯМ КОДА (Н-39): ветка — блок разрешения ZONE лаунчера workshop
# (сегодня :45; после предмета — каноническая проверка РЕЗУЛЬТАТА разрешения
# для любого источника). ДВА входа одного класса «запись снаружи, канонический
# результат внутри»:
#   (а) env -u HARNESS_SCRATCH XDG_STATE_HOME=<корень>/xdg-vnutri-028 — прямой;
#   (б) XDG_STATE_HOME=<внешний симлинк> → <корень>/xdg-cel-028 — симлинк.
#
# Честная реализация на ОБОИХ входах: именованный отказ с подстрокой
# «внутри стерегомого дерева», rc≠0, ДО создания каталогов, ДО export HOME,
# ДО exec — omp не запускается, манифест путей всего дерева не растёт.
#
# СТАБ, который предъявление ловит: «дефолт по формуле без канон-проверки» —
# модель критика v1: внешний HARNESS_SCRATCH обслуживается честно, явный
# внутренний отказывается, а XDG/дефолт не проверяется вовсе. Дефект наблюдаем
# РОВНО на этих входах: рантайм-дом возникает ВНУТРИ дерева (наблюдение —
# манифест путей всего дерева, инвариант 3, не имя .zones). На входах
# предъявлений 1–2 этот стаб ведёт себя как честный.
#
# Прогоны ДО предмета — из одноразового клона (лаунчер сегодня игнорирует
# XDG_STATE_HOME и пишет .zones в дерево); после предмета — в живом дереве.
# Ожидание сегодня: rc 1 именованный. После: rc 0.
# Коды возврата: 0 — оба входа отвергнуты до всего; 1 — именованный отказ пробы.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
SUBJ="$REPO/workshop"

[ -f "$SUBJ" ] || {
  printf 'ОТКАЗ: лаунчер отсутствует — workshop (клон неполон?)\n' >&2
  exit 1
}

WORK="$(mktemp -d /tmp/red028-xdg.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK" "$REPO/xdg-vnutri-028" "$REPO/xdg-cel-028"' EXIT

# PATH-подставной omp (объявлен здесь, прецедент А-156): фиксирует запуск и
# HOME, ничего больше не делает. Честная реализация его НЕ запускает.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/omp" <<'EOS'
#!/usr/bin/env bash
printf 'OMP_SHIM_RAN HOME=%s PWD=%s ARGS=%s\n' "$HOME" "$PWD" "$*" >> "${OMP_SHIM_LOG:?}"
exit 0
EOS
chmod +x "$WORK/bin/omp"

# Герметичность require_metering (workshop:115-133): непустых значений достаточно.
export ZAI_API_KEY=dummy-probe
export METERING_PROXY_URL=http://127.0.0.1:1
export METERING_PROXY_TOKEN=dummy-probe
export MINIMAX_API_KEY=dummy-probe
export OMP_SHIM_LOG="$WORK/omp-shim.log"

P_OTKAZ='внутри стерегомого дерева'
fail() { printf 'ОТКАЗ %s: %s\n' "$1" "$2" >&2; exit 1; }

# Вход: <метка> <значение XDG_STATE_HOME>. Четыре контроля на вход.
vhod() {
  local METKA="$1" XDG="$2" OUT RC NOVY
  find "$REPO" -printf '%y %p\n' | LC_ALL=C sort > "$WORK/tree.do"
  rm -f "$WORK/omp-shim.log"
  OUT="$WORK/out-$METKA.log"
  env -u HARNESS_SCRATCH PATH="$WORK/bin:$PATH" XDG_STATE_HOME="$XDG" \
    bash "$SUBJ" >"$OUT" 2>&1
  RC=$?
  grep -qF -- "$P_OTKAZ" "$OUT" \
    || fail "otkaz-ne-predjavlen-$METKA" "workshop rc=$RC, подстроки «$P_OTKAZ» нет — источник, канонически разрешающийся внутрь дерева, принят молча (стаб «дефолт без канон-проверки» жив). Вывод: $(head -c 500 "$OUT")"
  [ "$RC" -ne 0 ] \
    || fail "uspekh-vmesto-otkaza-$METKA" "отказ напечатан, но workshop вышел rc=0 — успех для вызывающей автоматики. Вывод: $(head -c 400 "$OUT")"
  [ ! -f "$WORK/omp-shim.log" ] \
    || fail "omp-zapuschen-$METKA" "подставной omp запущен ($(head -1 "$WORK/omp-shim.log")) — отказ стоит после exec"
  find "$REPO" -printf '%y %p\n' | LC_ALL=C sort > "$WORK/tree.posle"
  NOVY="$(comm -13 "$WORK/tree.do" "$WORK/tree.posle")"
  [ -z "$NOVY" ] \
    || fail "novye-puti-$METKA" "дерево выросло: $NOVY — рантайм-дом возник ВНУТРИ чекаута (причина Н-98 под другим именем)"
  printf '  ok   вход %s: именованный отказ rc=%s до создания/подмены/exec, дерево не выросло\n' "$METKA" "$RC" >&2
}

# (а) XDG прямо внутрь корня (цель не существует — честный отказ ДО её создания).
vhod prjamoj "$REPO/xdg-vnutri-028"

# (б) симлинк, записанный ВНЕ дерева и разрешающийся внутрь существующей цели.
mkdir -p "$REPO/xdg-cel-028"
ln -s "$REPO/xdg-cel-028" "$WORK/xdg-link"
vhod simlink "$WORK/xdg-link"

printf 'red_xdg_vnutri_dereva: оба источника (прямой XDG внутрь + внешний симлинк внутрь) — именованный отказ rc≠0 до всего, дерево не растёт\n' >&2
exit 0
