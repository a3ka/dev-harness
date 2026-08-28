#!/usr/bin/env bash
# Дрилл: проверяет ветвь rc=2 механизма 1 (барьер check_nabludenia.sh) —
# существующий нечитаемый файл обязан дать rc=2 И строку «нечем проверить: <файл>».
#
# Контракт 015, механизм 1 / rc=2-ветвь (арбитраж 3, спор 3; прецедент 005):
# раннер трактует любой rc=2 барьера как NOT_IMPLEMENTED (охрана фикстур). Поэтому
# ветвь инварианта 4 предъявляется дриллом, а красное дрилла — подставным барьером,
# который существующий нечитаемый файл «не замечает» (печатает «неприменимо» с rc=0).
#
# Шаги дрилла:
#   1. Зелёный контроль: $WORK/scripts/check_nabludenia.sh (настоящий или подменённый
#      фикстурой стабом). Если файла нет — копируем настоящего.
#   2. chmod 000 NABLIUDENIA.md → требуется rc=2 + строка «нечем проверить: <файл>».
#   3. Если субъект — подменённый стабом (определяется по отсутствию маркера
#      настоящего барьера) — фиксируем «нечитаемое сочтено отсутствующим» (rc=1).
#
# ФИКСТУРА: $WORK/scripts/check_nabludenia.sh подменён стабом → дрилл красен.
# ПРЯМОЙ ПРОГОН (probe): $WORK = $REPO; SUBJECT = настоящий → SUBJECT_IS_STUB=0 →
# проверка реальной ветви rc=2 → rc=0.
#
#   bash scripts/drill_nabludenia_nechitaemo.sh
#
# Коды возврата: 0 — зелёный контроль пройден И rc=2-ветвь поймана,
# 1 — стаб-барьер пропустил нечитаемое как «неприменимо»,
# 2 — нечем проверить (нет bash/chmod/под root).
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTARIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Самоизоляция при прямом запуске из репо. Дрилл вычисляет WORK по СВОЕМУ пути
# (dirname(dirname(реального пути))) — BARRIER_ROOT дриллу не подскажешь, он читает
# себя. Прямой прогон: WORK = корень репо, и зелёная ветвь
#   cat > "$WORK/NABLIUDENIA.md"
# ПЕРЕЗАПИСЫВАЕТ живой файл (измерено: md5 5495b49f… → 677352a7…, 1664 строк → 1;
# CI «дерево изменилось: ./NABLIUDENIA.md»). Раннер/фикстура копируют дрилл в
# <корень>/scripts/, и WORK дрилла оказывается внутри игрушки — .git там нет.
# Детект репо: $WORK/.git существует. Поведение фикстуры НЕ задевается (там .git
# в WORK по построению нет — игрушка в /tmp).
if [ -n "${DRILL_NECHITAEMO_SBX:-}" ] && [ -d "${DRILL_NECHITAEMO_SBX}" ]; then
  # Перезапуск из родительской песочницы: родитель поставил env-маркер и exec'нул
  # нас. exec не наследует trap родителя, потому ставим свой: очистить песочницу.
  # shellcheck disable=SC2064
  trap 'rm -rf "$DRILL_NECHITAEMO_SBX"' EXIT
fi

command -v bash >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }
command -v chmod >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет chmod\n' >&2; exit 2; }
command -v id >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет id\n' >&2; exit 2; }

if [ "$(id -u)" -eq 0 ]; then
  printf 'NOT_IMPLEMENTED: под root chmod 000 не даёт нечитаемости — окружение мешает\n' >&2
  exit 2
fi

fails=0
ok()   { printf '  ok   %s\n' "$*" >&2; }
bad()  { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }

# WORK = каталог скрипта-песочницы. Раннер копирует дрилл в $WORK/scripts/ через
# BARRIER_ROOT; тогда $WORK от path дрифта = родитель скрипта = каталог фикстуры.
# Прямой прогон: $WORK = $REPO.
REAL="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || printf '%s' "$0")"
WORK="$(dirname "$(dirname "$REAL")")"

# Прямой прогон из репо: $WORK содержит .git → зелёная ветвь перезапишет
# $WORK/NABLIUDENIA.md. Строим собственную песочницу ВНЕ стерегомого дерева
# (контракт 015:151), копируем себя и настоящего check_nabludenia.sh, exec'уем
# перезапуск оттуда. Env-маркер DRILL_NECHITAEMO_SBX говорит перезапущенному
# процессу поставить trap на очистку (exec trap родителя не наследует).
if [ -d "$WORK/.git" ]; then
  SBX="$(mktemp -d "${TMPDIR:-/tmp}/drill-nabludenia-nechitaemo.XXXXXX")" \
    || { printf 'NOT_IMPLEMENTED: mktemp не смог — песочницу не построить\n' >&2; exit 2; }
  # Страховка на случай, если cp/exec упадут до того, как ребёнок поставит свой trap:
  # exec не наследует trap родителя, но если сам exec вернёт ошибку, родитель
  # продолжает жить — и тогда отработает этот trap.
  # shellcheck disable=SC2064
  trap 'rm -rf "$SBX"' EXIT
  mkdir -p "$SBX/scripts"
  cp "$REAL"  "$SBX/scripts/drill_nabludenia_nechitaemo.sh"
  cp "$HERE/check_nabludenia.sh" "$SBX/scripts/check_nabludenia.sh"
  export DRILL_NECHITAEMO_SBX="$SBX"
  exec bash "$SBX/scripts/drill_nabludenia_nechitaemo.sh"
fi

 mkdir -p "$WORK/scripts"

# Настоящий барьер — рядом с дриллом (в $HERE/scripts/).
BARRIER="$HERE/check_nabludenia.sh"
[ -f "$BARRIER" ] || { printf 'NOT_IMPLEMENTED: рядом нет check_nabludenia.sh\n' >&2; exit 2; }
# Маркер НАСТОЯЩЕГО барьера — уникальная подстрока шапки. Стаб её не несёт.
REAL_MARKER='Барьер грамматики заголовков наблюдений: ОТКРЫТО обязан нести адрес'

# Субъект (барьер для прогона): если файла нет — копируем настоящего. Если есть
# и не содержит маркер настоящего — фикстура подменила стабом.
SUBJECT="$WORK/scripts/check_nabludenia.sh"
SUBJECT_IS_STUB=0
if [ ! -f "$SUBJECT" ]; then
  cp "$BARRIER" "$SUBJECT"
elif ! grep -qF "$REAL_MARKER" "$SUBJECT"; then
  SUBJECT_IS_STUB=1
fi
chmod +x "$SUBJECT"

# Зелёная ветвь: существующий читаемый NABLIUDENIA.md → rc=0.
NAF="$WORK/NABLIUDENIA.md"
cat > "$NAF" <<'EOF'
### Н-1. Боль `ЗАКРЫТО 013`
EOF

out="$WORK/out1.txt"
set +e
bash "$SUBJECT" "$WORK" > "$out" 2>&1
rc=$?
set -e

if [ "$rc" -ne 0 ]; then
  bad "зелёный контроль: барьер вернул rc=$rc на чистом дереве"
  cat "$out" >&2
else
  ok "зелёный контроль: барьер rc=0 на чистом дереве"
fi

# ── ветвь rc=2: chmod 000 существующего файла ─────────────────────────────────
chmod 000 "$NAF"

out="$WORK/out2.txt"
set +e
bash "$SUBJECT" "$WORK" > "$out" 2>&1
rc=$?
set -e

if [ "$SUBJECT_IS_STUB" = 1 ]; then
  # Стаб: должен дать rc=0 с «неприменимо». Если так — стаб пропустил нечитаемое
  # как отсутствующее (это и есть красное).
  chmod 644 "$NAF"
  if [ "$rc" -eq 0 ] && grep -qF 'неприменимо' "$out"; then
    bad "стаб «нечитаемое сочтено отсутствующим» пропустил (это и есть красное)"
    cat "$out" >&2
    exit 1
  else
    ok "стаб пойман на rc=$rc (не пропустил нечитаемое как «неприменимо»)"
    exit 0
  fi
fi

# Реальный: должен дать rc=2 + «нечем проверить: <файл>».
chmod 644 "$NAF"
if [ "$rc" -ne 2 ]; then
  bad "нечитаемое: барьер вернул rc=$rc (требуется 2)"
  cat "$out" >&2
elif ! grep -qF 'нечем проверить: NABLIUDENIA.md' "$out"; then
  bad "нечитаемое: барьер не напечатал «нечем проверить: NABLIUDENIA.md»"
  cat "$out" >&2
else
  ok "нечитаемое: rc=2 + строка «нечем проверить: NABLIUDENIA.md»"
fi

if [ "$fails" -eq 0 ]; then
  printf '  дрилл nabludenia-nechitaemo: ветвь rc=2 поймана\n' >&2
  exit 0
fi
exit 1
