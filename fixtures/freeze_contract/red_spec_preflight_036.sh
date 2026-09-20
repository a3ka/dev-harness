#!/usr/bin/env bash
# Красное предъявление 036, ветвь класс-гейта заморозки (г5: «заморозка красного
# черновика» — freeze обязан отказывать ДО тега и реестра, зеркало doc-preflight 027).
#
# Каталог ОТКРЫТ для architect (живая матрица круга 1, Б2); файл ложится ТЕМ ЖЕ
# коммитом, что и контракт. Прямой запуск — red_* вне case_*-глоба раннера (А-82).
#
# ВОРОТА — все конец-в-конец через НАСТОЯЩИЙ scripts/freeze_contract.sh на toy
# (оракул в памяти предъявления: теги/отказ сняты до вызова; диск проверяемого
# после попытки не перечитывается как истина — только как след попытки):
#   г5  отрицательный (боль круга 1 Б2): черновик с env-красной пробой (выход 2,
#        посторонний вывод) при заявленной предметной фразе + вердикт accept →
#        freeze rc 1, отказ несёт «spec-preflight 036», список тегов frozen/*
#        ПУСТ и реестр не записан (отказ атомарен);
#   г5б зелёный: честная проба rc 1 с совпавшей фразой → freeze rc 0, тег
#        frozen/contracts/001/1 жив, реестр записан (позитив-контроль писателя);
#   г5в отрицательный В2-вход (совет круга 1): расходящийся замер → freeze rc 1,
#        тега нет — вызов только части spec-preflight не проходит за полное
#        подключение;
#   г5г отрицательный В3-вход (совет круга 1): v2-перенос зоны без СПАСЕНО при
#        живом frozen/1 → freeze rc 1, тега v2 нет;
#   стаб с5 «freeze-печатает-но-не-гейтит» ловится здесь ПОВЕДЕНЧЕСКИ: живой тег
#        на красном черновике = ОТКАЗ именем с5 (построение заглушки не нужно —
#        дефект наблюдаем ровно на входе г5 как «тег записан»).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/check_spec_ready.sh"
FRZ="$REPO/scripts/freeze_contract.sh"
[ -f "$SUBJ" ] || { printf 'ПРЕДМЕТ 036 НЕ РЕАЛИЗОВАН: класс-гейт заморозки (spec-preflight) — %s отсутствует на дереве\n' "$SUBJ" >&2; exit 1; }
[ -f "$FRZ" ] || { printf 'NOT_IMPLEMENTED: субъект заморозки %s не найден\n' "$FRZ" >&2; exit 2; }

. "$HERE/_repo.sh"   # g, commit_all, put_verdict, make_repo — помощники семьи

WORK="$(mktemp -d "${TMPDIR:-/tmp}/g5_036.XXXXXX")"
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

# ── г5: env-красная проба при заявленной фразе; вердикт accept уже в make_repo ─
T5="$WORK/g5"; make_repo "$T5"
write_contract "$T5" '- `bash p_env.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА Г5'
printf 'echo чужое окружение >&2; exit 2\n' > "$T5/p_env.sh"
commit_all "$T5" 'черновик с env-красной пробой'

# ── г5б: честная предметная красная ───────────────────────────────────────────
T5B="$WORK/g5b"; make_repo "$T5B"
write_contract "$T5B" '- `bash p_ok.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА Г5Б'
printf 'echo ПРЕДМЕТНАЯ ФРАЗА Г5Б >&2; exit 1\n' > "$T5B/p_ok.sh"
commit_all "$T5B" 'честный черновик'

# ── г5в: расходящийся замер (заявлено 2, файлов 3) ────────────────────────────
T5V="$WORK/g5v"; make_repo "$T5V"
mkdir -p "$T5V/probes"
write_contract "$T5V" 'замер: `ls probes/g*.sh | wc -l` = 2 census probes/g*.sh'
printf 'x\n' > "$T5V/probes/g1.sh"; printf 'x\n' > "$T5V/probes/g2.sh"; printf 'x\n' > "$T5V/probes/g3.sh"
commit_all "$T5V" 'черновик с расходящимся замером'

# ── г5г: v2-перенос зоны без СПАСЕНО при живом frozen/1 ───────────────────────
T5G="$WORK/g5g"; make_repo "$T5G"
mkdir -p "$T5G/scripts"
# v1 замораживаем честно: зона implementer на foo+bar, проба честная
write_contract "$T5G" '- `bash p_ok.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА Г5Г'
printf 'echo ПРЕДМЕТНАЯ ФРАЗА Г5Г >&2; exit 1\n' > "$T5G/p_ok.sh"
printf '\n## Исполнители и зоны\nЗОНА implementer: scripts/foo.sh scripts/bar.sh\n' >> "$T5G/contracts/001-x.md"
commit_all "$T5G" 'v1: зона implementer на foo+bar'
run_freeze "$T5G" 'v1 честная'
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: подготовка г5г: freeze v1 честного черновика дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
# v2: зона сужена до bar, СПАСЕНО нет; вердикт v2 accept
write_contract "$T5G" '- `bash p_ok.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА Г5Г'
printf '\n## Исполнители и зоны\nЗОНА implementer: scripts/bar.sh\n' >> "$T5G/contracts/001-x.md"
put_verdict "$T5G" 2 accept
commit_all "$T5G" 'v2: перенос зоны без СПАСЕНО'

# ── предъявление ──────────────────────────────────────────────────────────────
run_freeze "$T5" 'заморозка красного черновика'
[ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: ворота г5: rc %s, ожидался 1\nвывод:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf '%s\n' "$LAST_OUT" | grep -Fq 'spec-preflight 036' || { printf 'ОТКАЗ: ворота г5: отказ не назвал spec-preflight 036:\n%s\n' "$LAST_OUT" >&2; exit 1; }
[ -z "$(tags "$T5")" ] || { printf 'ОТКАЗ: ворота г5 (стаб с5 freeze-печатает-но-не-гейтит): после отказа записаны теги:\n%s\n' "$(tags "$T5")" >&2; exit 1; }
[ ! -f "$T5/registry/contracts.tsv" ] || { printf 'ОТКАЗ: ворота г5: отказ не атомарен — реестр записан\n' >&2; exit 1; }
printf 'ворота г5: freeze отказал до тега и реестра именем spec-preflight 036 (с5 мёртв поведенчески)\n' >&2

run_freeze "$T5B" 'заморозка честного черновика'
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: ворота г5б: честный черновик не заморожен (rc %s):\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
g "$T5B" rev-parse -q --verify 'refs/tags/frozen/contracts/001/1' >/dev/null || { printf 'ОТКАЗ: ворота г5б: тег frozen/contracts/001/1 не жив\n' >&2; exit 1; }
[ -f "$T5B/registry/contracts.tsv" ] || { printf 'ОТКАЗ: ворота г5б: успех не записал реестр (позитив-контроль писателя)\n' >&2; exit 1; }
printf 'ворота г5б: честный черновик заморожен, тег и реестр живы (rc 0)\n' >&2

run_freeze "$T5V" 'заморозка расходящегося замера'
[ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: ворота г5в: rc %s, ожидался 1 (отрицательный В2-вход):\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf '%s\n' "$LAST_OUT" | grep -Fq 'spec-preflight 036' || { printf 'ОТКАЗ: ворота г5в: отказ не назвал spec-preflight 036:\n%s\n' "$LAST_OUT" >&2; exit 1; }
[ -z "$(tags "$T5V")" ] || { printf 'ОТКАЗ: ворота г5в: после отказа записаны теги:\n%s\n' "$(tags "$T5V")" >&2; exit 1; }
printf 'ворота г5в: отрицательный В2-вход отвергнут концом-в-конец, тега нет\n' >&2

run_freeze "$T5G" 'заморозка переноса зоны без СПАСЕНО'
[ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: ворота г5г: rc %s, ожидался 1 (отрицательный В3-вход):\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf '%s\n' "$LAST_OUT" | grep -Fq 'перенос зоны' || { printf 'ОТКАЗ: ворота г5г: отказ не назвал перенос зоны:\n%s\n' "$LAST_OUT" >&2; exit 1; }
[ -z "$(g "$T5G" tag -l 'frozen/contracts/001/2')" ] || { printf 'ОТКАЗ: ворота г5г: тег v2 записан после отказа\n' >&2; exit 1; }
printf 'ворота г5г: отрицательный В3-вход отвергнут концом-в-конец, тега v2 нет\n' >&2
exit 0
