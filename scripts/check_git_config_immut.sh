#!/usr/bin/env bash
# Детектор неизменяемости общего .git/config (контракт 081, И-4).
# НЕ БАРЬЕР: детектор зовётся церемонией с наблюдаемым rc (прецедент 024),
# красные/стабы/проба живут вне case-глоба в семейном каталоге
# fixtures/ops_server/ мета-барьера ops/server/install.sh.
#
# Зачем. Запирание .git/config ядром ФС (chattr +i) держит не-root записи
# под EPERM; детектор ловит СНЯТИЕ атрибута и ОБХОД через extensions.worktreeConfig
# (нога (б): extension переносит identity/config по-worktree в config.worktree,
# минуя неизменяемость; нога (б2): форензика остаточного config.worktree-файла,
# появление которого и есть признак включения/обхода).
#
# КАК ЗОВЁТСЯ. Ровно один аргумент — абсолютный корень основного чекаута.
#   bash scripts/check_git_config_immut.sh <абс-корень>
#   IMMUT_LSATTR_BIN=<путь> bash scripts/check_git_config_immut.sh <абс-корень>
# (шов IMMUT_LSATTR_BIN — инвариант 6 074: при шве умолчание lsattr не читается).
# Относительный путь ⇒ rc 1 «корень обязан быть абсолютным» (прецедент 024).
#
# Ноги в порядке (а)→(б)→(б2) с коротким замыканием; детектор печатает РОВНО
# ОДНУ именованную причину — ПЕРВУЮ по этому порядку. На объединённом входе
# (атрибут снят ∧ extension=true) — только «+i отсутствует» (клетка D6);
# на (атрибут стоит ∧ extension=true ∧ config.worktree) — только
# «extensions.worktreeConfig» (клетка D7).
#
# Выходы:
#   0 — зелён: +i есть ∧ extension off ∧ ни одного config.worktree;
#   1 — именованный отказ (одна из 5 причин ниже);
#   2 — NOT_IMPLEMENTED: lsattr недоступен.
set -uo pipefail

# ── аргумент и швы ──────────────────────────────────────────────────────────
if [ $# -ne 1 ]; then
  printf 'ОТКАЗ: детектор требует ровно один аргумент — абсолютный корень чекаута\n' >&2
  exit 1
fi
ROOT="$1"
case "$ROOT" in
  /*) ;;
  *)  printf 'ОТКАЗ: корень обязан быть абсолютным: %s\n' "$ROOT" >&2; exit 1 ;;
esac

# Шов lsattr (инвариант 6 074): при заданном шве умолчание lsattr не читается.
if [ -n "${IMMUT_LSATTR_BIN+x}" ]; then
  LSATTR="$IMMUT_LSATTR_BIN"
else
  LSATTR="lsattr"
fi

# ── структура чекаута ───────────────────────────────────────────────────────
[ -d "$ROOT/.git" ] && [ -f "$ROOT/.git/config" ] \
  || { printf 'ОТКАЗ: не основной чекаут — %s\n' "$ROOT" >&2; exit 1; }
CFG="$ROOT/.git/config"

# ── (а) lsattr: флаг i на config ───────────────────────────────────────────
# Шов в форме И-4: `$IMMUT_LSATTR_BIN "<файл>"` — ровно один аргумент, без `--`
# (CFG всегда абсолютный). Отклонение от формы = шов не в форме контракта →
# батарея даёт rc 2 «lsattr недоступен» на честном шве, а не rc 0/1 по делу.
lsattr_out="$("$LSATTR" "$CFG" 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: lsattr недоступен (%s)\n' "$LSATTR" >&2; exit 2; }
# Вывод — одна строка «<флаги> <путь>» (e2fsprogs-стиль: ----i--------e------- …).
# Судья — символ 'i' в поле флагов ДО первого пробела. Берём первый токен awk'ом,
# чтобы не спутать 'i' в флагах с 'i' в пути.
flags="$(printf '%s\n' "$lsattr_out" | awk 'NR==1{print $1; exit}')"
case "$flags" in
  *i*) ;;  # стоит
  *)    printf 'ОТКАЗ: +i отсутствует на %s\n' "$CFG" >&2; exit 1 ;;
esac

# ── (б) extensions.worktreeConfig ──────────────────────────────────────────
# git config --local --type=bool --get <key> возвращает «true»/«false» в stdout;
# при отсутствии ключа rc 1 и пустой stdout — НЕ ошибка детектора.
wtc="$(git -C "$ROOT" config --local --type=bool --get extensions.worktreeConfig 2>/dev/null || true)"
case "$wtc" in
  true) printf 'ОТКАЗ: extensions.worktreeConfig включён (обход +i через config.worktree)\n' >&2; exit 1 ;;
  *)    ;;
esac

# ── (б2) форензика config.worktree: основной + linked worktree ─────────────
# Замер: без extension эти файлы НЕ создаются; наличие = форензика включения
# или остаточного обхода. Обе локации (прецедент 081 §И-4, критика Б3).
if [ -f "$ROOT/.git/config.worktree" ]; then
  printf 'ОТКАЗ: config.worktree существует — %s\n' "$ROOT/.git/config.worktree" >&2; exit 1
fi
if [ -d "$ROOT/.git/worktrees" ]; then
  for w in "$ROOT"/.git/worktrees/*/config.worktree; do
    [ -f "$w" ] || continue
    printf 'ОТКАЗ: config.worktree существует — %s\n' "$w" >&2; exit 1
  done
fi

# ── зелён ───────────────────────────────────────────────────────────────────
exit 0
