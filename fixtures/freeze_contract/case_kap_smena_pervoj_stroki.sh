# ПРИЧИНА: кап кругов
#
# Н-57 (контракт 013 §Предмет Б): круг = смена ПЕРВОЙ СТРОКИ вердикта, а не коммит
# файла. Три ложных капа (011; 012/1 circles=4 при реальных 2; 012/2 circles=6)
# посчитали технический шум — rewrite тела, D/re-A, R100-переименование — кругами
# судейства; каждый стоил эскалации к владельцу без спора.
#
# Ветви — 3 вызова барьера; обманные стабы привязаны к входу, где их дефект НАБЛЮДАЕМ:
# 1. зелёный контроль (ОТДЕЛЬНОЕ дерево repo-kontrol): v1 accept, одно событие →
#    заморозка v1 → 0. Отдельность не декоративна: accept-событие контроля не должно
#    входить в таймлайн ветви 2, иначе сжатый таймлайн [accept, FAIL, accept] = 3
#    триггерил бы кап и ПОСЛЕ правки;
# 2. серия шума на v2 (модель живой истории 012/1+2, отдельное дерево repo-shum):
#    A FAIL (круг 1) → M того же FAIL (правка тела) → D → re-A того же FAIL →
#    R100-переименование внутри глоба → A accept (круг 2). СЕЙЧАС: 6 коммитов по
#    глобу ≥ 3 → ложный кап, rc 1 — красное предъявлено. ПОСЛЕ §Б: события
#    [FAIL, FAIL, FAIL, accept] → сжатый [FAIL, accept] = 2 → rc 0.
#    Коммит «правка тела при той же первой строке» ОБЯЗАТЕЛЕН: без него счёт
#    A/M-коммитов (стаб Р2) неотличим от счёта событий. Стаб «считает появления
#    файлов, а не смены» красен ровно на re-A того же FAIL; стаб «считает коммиты»
#    (текущий код) красен на самой серии;
# 3. охранная (то же дерево): реальные круги на v3 (FAIL→accept) поверх истории
#    ветви 2 → сжатый таймлайн [FAIL, accept, FAIL, accept] = 4 ≥ 3 → rc 1 ВСЕГДА,
#    и до, и после правки (стаб «не считает ничего» красен ровно здесь).
#
# Ручной тег frozen/contracts/001/1 в repo-shum ставит версию ожидаемого вердикта
# (v2) без заведённого v1-файла: его accept-событие не входит в таймлайн — та же
# отдельность, что и у ветви 1. Живой прецедент ручного тега — каркас
# fixtures/check_zones/_repo.sh. Вызов ветви 2 несёт `|| true`: код возврата пишет
# СЕРВЕР канала, а фикстуре нужно дойти до охранной ветви 3.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"

RA="$WORK/repo-kontrol"
make_repo "$RA"
"$BARRIER" contracts/001-x.md "контроль: один круг, один вердикт" "$RA"

RB="$WORK/repo-shum"
mkdir -p "$RB/contracts" "$RB/verdicts/critic" "$RB/tmp"
printf 'предмет, критерий готовности, РАБОТА НЕ РАЗДАЁТСЯ: кодификация\n' > "$RB/contracts/001-x.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$RB"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$RB" config user.name Фикстура
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$RB" config user.email fixture@local
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$RB" config commit.gpgsign false
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$RB" config core.hooksPath /dev/null
commit_all "$RB" 'основание'
g "$RB" tag -a frozen/contracts/001/1 -m 'v1 утверждена до истории вердиктов'

put_verdict "$RB" 2 FAIL
commit_all "$RB" 'круг 1: v2 FAIL'
printf 'FAIL\nдругое тело вердикта, первая строка та же\n' > "$RB/verdicts/critic/contracts-001-v2.md"
commit_all "$RB" 'правка тела без смены первой строки'
g "$RB" rm -q verdicts/critic/contracts-001-v2.md
commit_all "$RB" 'удаление v2: форма, не содержание'
put_verdict "$RB" 2 FAIL
commit_all "$RB" 're-A v2 с тем же FAIL'
g "$RB" mv verdicts/critic/contracts-001-v2.md verdicts/critic/contracts-001-v2x.md
commit_all "$RB" 'R100-переименование внутри глоба'
put_verdict "$RB" 2 accept
commit_all "$RB" 'круг 2: v2 accept'
"$BARRIER" contracts/001-x.md "шум — не круг: смена первой строки одна" "$RB" || true

put_verdict "$RB" 3 FAIL
commit_all "$RB" 'реальный круг: v3 FAIL'
put_verdict "$RB" 3 accept
commit_all "$RB" 'реальный круг: v3 accept'
"$BARRIER" contracts/001-x.md "реальные круги — кап на месте" "$RB"
