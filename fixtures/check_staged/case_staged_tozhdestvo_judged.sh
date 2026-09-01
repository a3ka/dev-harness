# ПРИЧИНА: вне зоны: zz_mid_off.txt
#
# КЛАССОВАЯ фикстура observability-тождества (018 класс-замыкающее усиление, решение
# владельца (б)): печатаемое judged-множество ТОЖДЕСТВЕННО полному staged-множеству.
# F-1..F-4 — одна мета-причина «барьер судит подмножество»; замыкание класса —
# со-локализованная печать каждого судимого зонами пути. Одной сверкой краснеет ЛЮБАЯ
# порча «подмножество»: K=1, фильтр типов, «кроме последнего».
#
# ══ КОНТРАКТ ПЕЧАТИ (единый источник — Н-39; implementer выдаёт ТОЧНО-В-ТОЧЬ) ══
# На КАЖДЫЙ путь, дошедший до зонной точки суда, check_staged печатает строку
#     judged: <путь>
# в stdout, НЕПОСРЕДСТВЕННО ПЕРЕД вызовом zones_match_path, в ТОЙ ЖЕ итерации главного
# цикла — напечатано ⟺ судимо. Свойства формата:
#   * точный префикс `judged: ` — строка извлекается якорем ^judged: , не подстрокой;
#   * <путь> — тот же токен, что получен из staged-чтения, без кавычек/%q, один на строке;
#   * ДОПОЛНИТЕЛЬНАЯ строка: существующий вывод («ok: …», «ОТКАЗ: …») не меняется;
#   * печать ТОЛЬКО в зонной точке: путь, отказанный грамматикой имени (control-символ),
#     до зонной точки не доходит и judged:-строки не получает (он судим грамматикой —
#     case_imja_*); дублей в judging-loop грамматики не добавлять.
#
# НАБЛЮДАЕМЫЙ ВХОД (Н-39: единый источник — эта шапка): staged из ТРЁХ путей разных
# типов, вне-зонный — в СЕРЕДИНЕ (не привязан к позиции):
#   scripts/aa_first.sh  (A, в зоне scripts/)    — лексически первый;
#   zz_mid_off.txt       (D, ВНЕ зоны)           — середина: порча «кроме последнего»
#                                                   СОХРАНЯЕТ отказ середины, но роняет
#                                                   ТОЖДЕСТВО — различима именно сверкой
#                                                   перечней, не пропажей красного;
#   zzz_tail/m_last.sh   (M, в зоне zzz_tail/)   — последний.
# Зон у implementera в подставном контракте ДВЕ (scripts/ И zzz_tail/) — при одной зоне
# scripts/ всякий в-зонный путь лексически предшествует любому вне-зонному (s < z…), и
# «середина» недостижима построением. Порядок staged-чтения лексический:
# scripts/… < zz_… < zzz_…. Автор — implementer, wip-веток нет → страж среза 1 молчит.
#
# ОРАКУЛ — В ПАМЯТИ ПРОВЕРЯЮЩЕГО (правило 8 арбитража oblast-i-porog): полное
# staged-множество снимается в массив из `git diff --cached --name-only -z` ДО вызова
# барьера; диск проверяемого репо как истина после вызова НЕ перечитывается. Сверка
# СТРУКТУРНА: judged-множество извлекается из вывода барьера построчно (якорь ^judged: ,
# самостоятельная строка) и сравнивается с оракулом ТОЖДЕСТВОМ сортированных перечней —
# дубли judged:-строк тоже расходение (контракт: один путь — одна строка).
#
# ЗЕЛЁНЫЙ КОНТРОЛЬ — УСЛОВЕН тождеством: положительный контроль (оба пути в зоне →
# rc 0) вызывается ТОЛЬКО когда красный вызов дал rc 1 с ПРИЧИНОЙ и judged == staged.
# Ослабления, каждое наблюдаемо раннером:
#   * нет печати (HEAD до правки implementer): judged = ∅ ≠ staged → контроля нет →
#     «нет положительного контроля» — стартовое красное этой фикстуры (правило 3:
#     красное предъявлено своим стартовым состоянием, доклад фиксирует его дословно);
#   * порча «подмножество» (K=1 / фильтр AM / «кроме последнего»): перечень расходится
#     → контроля нет либо красное не предъявлено → FAIL расхождением перечня.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# ── тождественный репо: 3 пути, вне-зонный в СЕРЕДИНЕ, ДВЕ зоны implementer ─────
IDENT="$WORK/repo_ident"
mkdir -p "$IDENT/contracts" "$IDENT/verdicts/critic" "$IDENT/scripts" "$IDENT/zzz_tail"
{
  printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
  printf 'ЗОНА implementer: scripts/\n'
  printf 'ЗОНА implementer: zzz_tail/\n'
} > "$IDENT/contracts/001-x.md"
printf 'accept\nвердикт критика\n' > "$IDENT/verdicts/critic/contracts-001-v1.md"
printf 'исходный файл в зоне\n'   > "$IDENT/scripts/a.sh"
printf 'файл середины — вне зоны\n' > "$IDENT/zz_mid_off.txt"
printf 'основание для M-записи\n' > "$IDENT/zzz_tail/m_last.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$IDENT"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$IDENT" config user.name implementer
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$IDENT" config user.email implementer@local
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$IDENT" config commit.gpgsign false
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$IDENT" config core.hooksPath /dev/null
g "$IDENT" add -A
g "$IDENT" commit -q -m 'основание: контракт с двумя зонами, базы для D и M'
g "$IDENT" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
# staged: A (зона, первый) · D (вне зоны, СЕРЕДИНА) · M (зона, последний)
stage "$IDENT" scripts/aa_first.sh 'добавление в зоне — первый путь'
g "$IDENT" rm -q -- zz_mid_off.txt                                   # D вне зоны — середина
printf 'правка основания в зоне zzz_tail' >> "$IDENT/zzz_tail/m_last.sh"
g "$IDENT" add -- zzz_tail/m_last.sh                                 # M в зоне — последний

# ── зелёный репо положительного контроля: оба пути в зоне ──────────────────────
GREEN="$WORK/repo_green"
make_repo "$GREEN"
stage "$GREEN" scripts/g_first.sh 'добавление в зоне'
printf 'правка исходного' >> "$GREEN/scripts/a.sh"
g "$GREEN" add -- scripts/a.sh

# ── оракул в ПАМЯТИ ДО вызова барьера (правило 8) ──────────────────────────────
mapfile -d '' -t STAGED_ORACLE < <(g "$IDENT" diff --cached --name-only -z)

# ── красный вызов: ПРИЧИНА + съём judged-перечня ────────────────────────────────
ident_out="$("$BARRIER" "$IDENT")"; ident_rc=$?
mapfile -t JUDGED < <(printf '%s\n' "$ident_out" | sed -n 's/^judged: //p')
staged_list="$(printf '%s\n' "${STAGED_ORACLE[@]}" | sort)"
judged_list="$(printf '%s\n' "${JUDGED[@]}" | sort)"

if [ "$judged_list" != "$staged_list" ]; then
  printf 'РАСХОЖДЕНИЕ ПЕРЕЧНЯ judged != staged (rc=%d):\n  staged: %s\n  judged: %s\n' \
    "$ident_rc" "$(printf '%s; ' "${STAGED_ORACLE[@]}")" "$(printf '%s; ' "${JUDGED[@]}")" >&2
fi

# положительный контроль — только при доказанном тождестве и красной ПРИЧИНЕ
if [ "$ident_rc" -eq 1 ] && [ "$judged_list" = "$staged_list" ]; then
  "$BARRIER" "$GREEN" || true  # ожидание: rc 0 «ok: staged в зоне автора implementer (2 путь/путей)»
fi
