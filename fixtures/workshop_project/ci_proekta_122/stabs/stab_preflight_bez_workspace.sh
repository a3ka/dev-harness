#!/usr/bin/env bash
# МУТАНТ (Н-39; v+1, слово владельца 2026-11-18, OWNER-BATCH-1118 №2): честная модель
# ci_preflight минус ОДНА строка с маркером МУТАЦИЯ-122:workspace-podstanovka — точное
# выражение ${{ github.workspace }} не отображается на корень внутренней копии (уходит в
# путь/текст/env литералом).
# Наблюдаемое расхождение (ровно эти клетки): p9-wd-workspace и p9-wd-defaults-workflow
# (каталога с буквальным именем выражения нет — working-directory-otsutstvuet вместо rc 0),
# p9-wd-defaults-pereopredelenie (то же), p9-ws-v-run и p9-ws-v-env (bash bad substitution /
# пустой тест — shag-upal вместо rc 0), p9-forma-mobile (первый же шаг — otsutstvuet),
# p9-wd-dotdot-vne-kopii и p9-wd-simlink-pobeg (otsutstvuet вместо vne-kopii),
# p10-uses-ne-suditsa (wd литералом — otsutstvuet вместо rc 0).
# Маркер не ровно один раз — rc 2 ORACLE_TAMPERED (мутант не применён; молчаливой
# копии модели не бывает).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:workspace-podstanovka'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'ORACLE_TAMPERED: mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
