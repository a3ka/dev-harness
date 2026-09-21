#!/usr/bin/env bash
# Красное предъявление 038 v3, ветвь ПРОВОДКИ consumers-гейта в заморозку:
# freeze обязан позвать check_consumers ПОСЛЕ spec-preflight (036) и ДО
# doc-preflight (027)/тега; красный = rc 1 «ОТКАЗ: потребители 116 красны:
# <первая причина>», отказ атомарен — тег/реестр не тронуты (контракт 038
# §Freeze-верификация потребителей, «Проводка в freeze» + точка done 6а).
#
# v3: п3 — покрытие ТОЛЬКО пробой исполнения (Б1: ЗОНА-строки не засчитываются);
# маппинг — ФАЙЛ-НА-ПАРУ scripts/consumers.d/*.tsv, три писателя-минимума (Б3),
# census-замер «cat … | wc -l = N census …» согласован обеими мерами (файлы =
# строки = пары). Вторая обязательная точка гейта — шаг 6а done_contract.sh
# (Б2); здесь предъявлена freeze-точка, done-точку предъявляет D-семья.
#
# Каталог ОТКРЫТ для architect (зона 027-architect; каталожный прецедент
# 036-Б1: red-файлы ложатся в УЖЕ покрытом каталоге). Файл ложится ТЕМ ЖЕ
# коммитом, что и v3 контракта 038. Прямой запуск — red_* вне case_*-глоба
# раннера (А-82). До реализации предмета прогон красен ОТСУТСТВИЕМ гейта
# (034-паттерн): сам прогон — живое свидетельство, не пропуск.
#
# ВОРОТА — конец-в-конец через НАСТОЯЩИЙ scripts/freeze_contract.sh на toy
# (оракул в памяти предъявления: теги/реестр сняты ДО вызова; диск проверяемого
# после попытки не перечитывается как истина — только как след попытки):
#   п3   писатель scripts/writer.sh тронут в окне frozen/1..HEAD, потребитель
#        fixtures/reader.sh не покрыт ПРОБОЙ (строки ПОТРЕБИТЕЛЬ нет; замер
#        несётся — красит именно п3, не п1) → freeze rc 1, отказ несёт
#        «потребители 116» и «нет ПОТРЕБИТЕЛЬ-пробы», тега v2 нет, реестр
#        байт-в-байт нетронут;
#   п3-проба  v2 несёт ПОТРЕБИТЕЛЬ-строку с КРАСНОЙ пробой (rc 1) → freeze
#        rc 1, отказ несёт «ПОТРЕБИТЕЛЬ-проба красна» (правило 8: гейт
#        ИСПОЛНЯЕТ пробу, наличие строки ≠ верификация);
#   vacuous  писатель вне окна (после frozen/1 тронут только черновик) →
#        freeze rc 0, тег frozen/contracts/001/2 жив (позитив-контроль:
#        вечно-красный гейт неотличим от работающего);
#   стабы ловятся ПОВЕДЕНЧЕСКИ: «freeze-печатает-но-не-гейтит» — живой тег v2
#   на непокрытом писателе (ворота п3); «гейт-после-тега» — тронутый реестр
#   при отказе (снимок ДО вызова, правило 8).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd -P)"
FRZ="$REPO/scripts/freeze_contract.sh"
SUBJ="$REPO/scripts/check_consumers.sh"
[ -f "$FRZ" ] || { printf 'NOT_IMPLEMENTED: субъект заморозки %s не найден\n' "$FRZ" >&2; exit 2; }
[ -f "$SUBJ" ] || { printf 'ПРЕДМЕТ 038 НЕ РЕАЛИЗОВАН: гейт потребителей %s отсутствует на дереве — отсутствие гейта и есть честный красный (034-паттерн)\n' "$SUBJ" >&2; exit 1; }

. "$HERE/_repo.sh"   # g, commit_all, put_verdict, make_repo — помощники семьи

WORK="$(mktemp -d "${TMPDIR:-/tmp}/consumers_038.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

LAST_OUT=''; LAST_RC=0
run_freeze() {  # <каталог> <причина>
  LAST_OUT="$(bash "$FRZ" contracts/001-x.md "$2" "$1" 2>&1)"; LAST_RC=$?
}
tags() { g "$1" tag -l 'frozen/*' | sort; }

write_contract() {  # <каталог> <тело после «## Приёмка»>
  local r="$1" body="$2"
  printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\n%s\n' "$body" > "$r/contracts/001-x.md"
}

# Замер-строка v3 (Б3): census считает ФАЙЛЫ (3 пары = 3 файла), команда —
# строки; грамматика 036-В2 исполняет её на заморозке toy-носителя — счёт
# обязан быть честным (3), иначе toy-freeze v1 упадёт раньше предъявления.
CENSUS='замер: `cat scripts/consumers.d/*.tsv | wc -l` = 3 census scripts/consumers.d/*.tsv'

# База семьи: маппинг файл-на-пару — ТРИ писателя-минимума (writer под тестом +
# два созвучных, чьи пары к живым читателям), пробы живут, всё закоммичено.
seed_consumers() {  # <каталог> <фраза-честной-пробы>
  local r="$1" phrase="$2"
  mkdir -p "$r/scripts/consumers.d" "$r/fixtures"
  printf 'scripts/writer.sh\tfixtures/reader.sh\n' > "$r/scripts/consumers.d/writer.sh__reader_sh.tsv"
  printf 'scripts/libw.sh\tscripts/spawner.sh\n'     > "$r/scripts/consumers.d/libw.sh__spawner_sh.tsv"
  printf 'scripts/donew.sh\tscripts/speccer.sh\n'    > "$r/scripts/consumers.d/donew.sh__speccer_sh.tsv"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/writer.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/libw.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/donew.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/spawner.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/speccer.sh"
  printf '# consumer fixture\n' > "$r/fixtures/reader.sh"
  printf '#!/usr/bin/env bash\necho %s >&2; exit 1\n' "$phrase" > "$r/p_ok.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/probe_green.sh"
  printf '#!/usr/bin/env bash\nexit 1\n' > "$r/probe_bad.sh"
}

# ── п3: писатель в окне, потребитель не покрыт пробой ────────────────────────
T1="$WORK/p3"; make_repo "$T1"; seed_consumers "$T1" 'FRAZA-P3'
# v1: писатель создан в v1-окне (первая версия — окна нет, vacuous) — контракт
# тем не менее несёт зелёную ПОТРЕБИТЕЛЬ-пробу (честная основа)
write_contract "$T1" "- \`bash p_ok.sh\` → красная: FRAZA-P3

$CENSUS

ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_green.sh"
commit_all "$T1" 'v1: pisatel pokryt zeljonoj probou'
run_freeze "$T1" 'v1 chestno'
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: подготовка п3: freeze v1 дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
# v2: правка писателя В ОКНЕ, проба снята (замер несётся — красит п3, не п1)
put_verdict "$T1" 2 accept
printf '#!/usr/bin/env bash\n# pravka pisatelja v okne\nexit 0\n' > "$T1/scripts/writer.sh"
write_contract "$T1" "- \`bash p_ok.sh\` → красная: FRAZA-P3

$CENSUS"
commit_all "$T1" 'v2: pisatel bez pokrytija'
REG_SNAP="$(cat "$T1/registry/contracts.tsv" 2>/dev/null || true)"   # снимок ДО вызова

# ── п3-проба: покрытие строкой с КРАСНОЙ пробой ───────────────────────────────
T2="$WORK/p3p"; make_repo "$T2"; seed_consumers "$T2" 'FRAZA-P3P'
write_contract "$T2" "- \`bash p_ok.sh\` → красная: FRAZA-P3P

$CENSUS

ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_green.sh"
commit_all "$T2" 'v1: pisatel pokryt'
run_freeze "$T2" 'v1 chestno'
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: подготовка п3-пробы: freeze v1 дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
put_verdict "$T2" 2 accept
printf '#!/usr/bin/env bash\n# pravka pisatelja v okne\nexit 0\n' > "$T2/scripts/writer.sh"
write_contract "$T2" "- \`bash p_ok.sh\` → красная: FRAZA-P3P

$CENSUS

ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_bad.sh"
commit_all "$T2" 'v2: pokrytie krasnoj probou'

# ── vacuous: писатель вне окна ────────────────────────────────────────────────
T3="$WORK/vac"; make_repo "$T3"; seed_consumers "$T3" 'FRAZA-VAC'
write_contract "$T3" "- \`bash p_ok.sh\` → красная: FRAZA-VAC

$CENSUS

ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_green.sh"
commit_all "$T3" 'v1: pisatel pokryt'
run_freeze "$T3" 'v1 chestno'
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: подготовка vacuous: freeze v1 дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
put_verdict "$T3" 2 accept
write_contract "$T3" "- \`bash p_ok.sh\` → красная: FRAZA-VAC

$CENSUS"
commit_all "$T3" 'v2: tolko chernovik'

# ── предъявление ──────────────────────────────────────────────────────────────
run_freeze "$T1" 'zamorozka nepokrytogo pisatelja'
[ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: ворота п3: rc %s, ожидался 1\nвывод:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf '%s\n' "$LAST_OUT" | grep -Fq 'потребители 116' || { printf 'ОТКАЗ: ворота п3: отказ не назвал потребителей 116:\n%s\n' "$LAST_OUT" >&2; exit 1; }
printf '%s\n' "$LAST_OUT" | grep -Fq 'не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы' || { printf 'ОТКАЗ: ворота п3: отказ не назвал причину п3 дословно:\n%s\n' "$LAST_OUT" >&2; exit 1; }
[ -z "$(g "$T1" tag -l 'frozen/contracts/001/2')" ] || { printf 'ОТКАЗ: ворота п3 (стаб freeze-печатает-но-не-гейтит): тег v2 записан после отказа\n' >&2; exit 1; }
[ "$(cat "$T1/registry/contracts.tsv" 2>/dev/null || true)" = "$REG_SNAP" ] || { printf 'ОТКАЗ: ворота п3: отказ не атомарен — реестр тронут\n' >&2; exit 1; }
printf 'ворота п3: freeze отказал до тега и реестра именем потребителей 116 (отказ атомарен)\n' >&2

run_freeze "$T2" 'zamorozka s krasnoj probou potrebitelja'
[ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: ворота п3-пробы: rc %s, ожидался 1\nвывод:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf '%s\n' "$LAST_OUT" | grep -Fq 'ПОТРЕБИТЕЛЬ-проба красна' || { printf 'ОТКАЗ: ворота п3-пробы: отказ не назвал красную пробу:\n%s\n' "$LAST_OUT" >&2; exit 1; }
[ -z "$(g "$T2" tag -l 'frozen/contracts/001/2')" ] || { printf 'ОТКАЗ: ворота п3-пробы: тег v2 записан после отказа\n' >&2; exit 1; }
printf 'ворота п3-пробы: красная ПОТРЕБИТЕЛЬ-проба отвергнута концом-в-конец, тега нет\n' >&2

run_freeze "$T3" 'zamorozka vacuous'
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: ворота vacuous: писатель вне окна, но freeze дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
g "$T3" rev-parse -q --verify 'refs/tags/frozen/contracts/001/2' >/dev/null || { printf 'ОТКАЗ: ворота vacuous: тег frozen/contracts/001/2 не жив\n' >&2; exit 1; }
printf 'ворота vacuous: писатель вне окна — freeze rc 0, тег v2 жив (позитив-контроль)\n' >&2
exit 0
