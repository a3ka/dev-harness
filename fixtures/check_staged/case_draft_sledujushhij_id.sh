# ПРИЧИНА: вне зоны
#
# Контракт 019, Н-72 (расширение владельца ~14:00): ПЕРВЫЙ коммит draft-контракта
# следующего свободного номера (contracts/<next>-*.md, next — следующий свободный
# номер класса CONTRACT по next_id БЕЗ резерва тега) пускается под автором
# architect ДО заморозки: зоны нового контракта живут в его собственном файле и
# неактивны до заморозки (самоссылка), поэтому до 019 страж отбивал «вне зоны»
# даже архитектору — авторство пачки (измерено на 017: контракт-файл сажал
# владелец-канал 0e6b5f7, авторство «Alex K» вместо architect).
#
# Входы (Н-39 — по коду; серийные входы одного case — А-32). Правка по FAIL
# адверсария 019 (bf46774): константный стаб next_id_peek «002» проходил прежнюю
# редакцию — draft-пуск был пинован единственным значением 002 (тот же класс,
# что блокер критика :119 на октале: rc-последовательность съезжку значения не
# отличала). Теперь — ПИН ЗНАЧЕНИЕМ (прецедент И-5):
#
#   * ПИН (первый вызов case — до любого ожидаемо-красного, А-73: раннер не судит
#     rc самой фикстуры, assert обязан ранить ДО красного кандидата): репо с
#     ЗАНЯТЫМ 019 (contracts/019-base.md на HEAD — источник 3 кода
#     next_id_peek: git ls-tree HEAD; тег выдачи id/* не ставится, чтобы не
#     мешать охране ниже), architect зонирован и в contracts/ → staged
#     contracts/020-draft.md (max+1) → rc 0 СО СТРОКОЙ draft-пропуска: только она
#     отличает пропуск по draft-ветви от пропуска по зоне. Зона, покрывающая
#     draft-путь, выбрана НАРОЧНО: стаб-константа «002» и здесь даёт rc 0 (зоны
#     пускают), но БЕЗ строки — красный от стаба не становится «законным»
#     красным кандидатом раннера, различие ловится ПИНОМ, а не кодом возврата.
#   * ПИН-ДОПОЛНЕНИЕ: в том же репо staged contracts/002-draft.md — номер
#     свободен, но НЕ следующий (следующий 020) → rc 0 БЕЗ строки draft-пропуска:
#     peek обязан вернуть max+1, а не «любой свободный».
#   * серийные входы «по одному источнику» (правка 2 по FAIL круга 2: head-only
#     стаб peek проходил scoped-case — максимум читался только из CONTRACT-файлов
#     на HEAD): занятый 019 живёт РОВНО В ОДНОМ из четырёх источников
#     next_id_max_for_class (Н-39 — границы по коду, не по этой прозе):
#       1. тег выдачи refs/tags/id/CONTRACT/019 (источник 1: for-each-ref
#          refs/tags/id/<КЛАСС>/);
#       2. имя ссылки refs/heads/wip/019/istochnik (источник 2: for-each-ref
#          refs/heads refs/remotes, первая цепочка цифр имени; хвост НЕ architect
#          — иначе страж 018 «ветка, не main» откажет раньше draft-ветви);
#       4. достижимая история: contracts/019-udaljon.md закоммичен и удалён
#          (источник 4: git log --all --diff-filter=A).
#     Источник 3 (файлы на HEAD) — вход BUSY выше. В каждом входе остальные
#     источники чисты; staged 020-draft под architect с доп-зоной contracts/ →
#     rc 0 СО строкой draft-пропуска. Head-only стаб на таких репо даёт rc 0
#     БЕЗ строки — ассерт валит фикстуру ДО красного кандидата (А-73), scoped-прогон
#     краснеет «барьер остался зелёным на обманном дереве».
#   * зелёный контроль (существующий вход 019): virgin-репо (занят только 001),
#     architect (зонирован в plans/) стадит contracts/002-draft.md → rc 0.
#     Стоит ПОСЛЕ пинов: в до-019-коде этот вход красен и не имеет права стать
#     красным кандидатом раньше пина.
#   * охрана «судья не создаёт тег id/*» (мера не меняет предмет) — по всем
#     репо, где под architect УЖЕ прогнан судья: стаб-/reserve-тег занял бы номер
#     и изменил предмет, который проверяется. Судит ОТСУТСТВИЕ НОВЫХ тегов id/
#     после прогона (снимок ДО вызова против снимка ПОСЛЕ — правило 8: ожидание
#     в памяти проверяющего), а НЕ отсутствие вообще: вход «источник-тег» сам
#     несёт id/CONTRACT/019 по построению (правка 2).
#   * красное-серийное: занят 019, staged contracts/021-draft.md (соседний
#     НЕ-следующий) под architect → «вне зоны» ДО и ПОСЛЕ 019 (охрана от
#     переусердия draft-ветви: соседний номер зонным судом не отвернётся сам).
#   * красное-охрана (существующий вход): тот же класс пути у ЧУЖОГО автора
#     (implementer) → «вне зоны» ДО и ПОСЛЕ 019.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# Локальные ассерты (снимок id-тегов — в ПАМЯТИ проверяющего, ДО вызова субъекта;
# правило 8). Ассерты стоят ДО первого ожидаемо-красного вызова $BARRIER — после
# него раннер rc фикстуры не судит (А-73).
id_tags_of() {  # <корень> — снимок id-тегов выдачи репо
  git -C "$1" for-each-ref --format='%(refname)' 'refs/tags/id/'
}
assert_no_new_id_tags() {  # <корень> <снимок-до> — новых id-тегов быть не должно
  local novye
  novye="$(comm -13 <(printf '%s\n' "$2" | sort) <(printf '%s\n' "$(id_tags_of "$1")" | sort))"
  if [ -n "${novye//$'\n'/}" ]; then
    printf 'ОТКАЗ: судья создал тег выдачи id/* — мера изменила предмет (%s): %s\n' "$1" "$novye" >&2
    exit 1
  fi
}
assert_draft_propushhen() {  # <чем занят 019> <вывод барьера> — строка draft-ветви обязательна
  if ! printf '%s\n' "$2" | grep -Fq '(draft next-id пропущен под architect)'; then
    printf 'ОТКАЗ: draft 020 при занятом 019 (%s) пропущен НЕ по draft-ветви — peek не назвал следующий номер из этого источника (стаб?): %s\n' "$1" "$2" >&2
    exit 1
  fi
}

# ── пин ЗНАЧЕНИЕМ (источник 3: файл на HEAD): занят 019 → следующий 020 ───────
BUSY="$WORK/repo_draft_zanjat019"
make_repo_busy019 "$BUSY" contracts/
set_author "$BUSY" architect
busy_id0="$(id_tags_of "$BUSY")"
stage "$BUSY" contracts/020-draft.md 'черновик контракта 020 — занят 019, следующий 020'
out="$("$BARRIER" "$BUSY" || true)"
assert_draft_propushhen 'файл contracts/019-base.md на HEAD' "$out"

# ── пин-дополнение: свободный, но НЕ следующий (002 при занятом 019) ───────────
g "$BUSY" reset -q   # снять 020 из индекса: судится только 002
stage "$BUSY" contracts/002-draft.md '002 свободен, но следующий — 020'
out="$("$BARRIER" "$BUSY" || true)"
if printf '%s\n' "$out" | grep -Fq '(draft next-id пропущен под architect)'; then
  printf 'ОТКАЗ: draft-ветвь пустила 002 при занятом 019 — peek вернул не max+1: %s\n' "$out" >&2
  exit 1
fi
assert_no_new_id_tags "$BUSY" "$busy_id0"

# ── пин источник 1 (теги выдачи): 019 занят ТОЛЬКО тегом id/CONTRACT/019 ──────
TEGSRC="$WORK/repo_draft_istochnik_teg"
make_repo_busy019_teg "$TEGSRC" contracts/
set_author "$TEGSRC" architect
teg_id0="$(id_tags_of "$TEGSRC")"
stage "$TEGSRC" contracts/020-draft.md 'черновик 020 — номер занят тегом выдачи, не файлом'
out="$("$BARRIER" "$TEGSRC" || true)"
assert_draft_propushhen 'тег id/CONTRACT/019' "$out"
assert_no_new_id_tags "$TEGSRC" "$teg_id0"

# ── пин источник 2 (имена ссылок): 019 занят ТОЛЬКО веткой wip/019/istochnik ──
VETSRC="$WORK/repo_draft_istochnik_vetka"
make_repo_busy019_vetka "$VETSRC" contracts/
set_author "$VETSRC" architect
vetka_id0="$(id_tags_of "$VETSRC")"
stage "$VETSRC" contracts/020-draft.md 'черновик 020 — номер занят именем ссылки, не файлом'
out="$("$BARRIER" "$VETSRC" || true)"
assert_draft_propushhen 'ветка wip/019/istochnik' "$out"
assert_no_new_id_tags "$VETSRC" "$vetka_id0"

# ── пин источник 4 (история): 019 закоммичен и удалён, HEAD чист ───────────────
ISTSRC="$WORK/repo_draft_istochnik_istorija"
make_repo_busy019_istorija "$ISTSRC" contracts/
set_author "$ISTSRC" architect
istorija_id0="$(id_tags_of "$ISTSRC")"
stage "$ISTSRC" contracts/020-draft.md 'черновик 020 — номер занят историей, не HEAD'
out="$("$BARRIER" "$ISTSRC" || true)"
assert_draft_propushhen 'contracts/019-udaljon.md в достижимой истории' "$out"
assert_no_new_id_tags "$ISTSRC" "$istorija_id0"

# ── зелёный контроль: virgin-репо, следующий свободный — 002 ───────────────────
GREEN="$WORK/repo_draft_architekt"
make_repo_archzone "$GREEN"
set_author "$GREEN" architect
green_id0="$(id_tags_of "$GREEN")"
stage "$GREEN" contracts/002-draft.md 'черновик контракта 002 — авторство пачки architect'
"$BARRIER" "$GREEN" || true                  # ожидание: rc 0 (draft next-id пущен под architect)
assert_no_new_id_tags "$GREEN" "$green_id0"

# ── красное-серийное: соседний НЕ-следующий (021 при занятом 019) ───────────────
ADJ="$WORK/repo_draft_sosednij"
make_repo_busy019 "$ADJ"
set_author "$ADJ" architect
stage "$ADJ" contracts/021-draft.md '021 — не следующий (следующий 020): судится зонами'
"$BARRIER" "$ADJ" || true                    # ожидание: rc 1 «вне зоны» (до и после 019)

# Охрана id/* для этого репо — живой прогон (после красного кандидата механикой
# раннера не судится, А-73; оставлена для прямого запуска фикстуры руками).
if git -C "$ADJ" for-each-ref --format='%(refname)' 'refs/tags/id/' | grep -q .; then
  printf 'ОТКАЗ: судья зарезервировал номер тегом id/* — мера изменила предмет (%s)\n' "$ADJ" >&2
  exit 1
fi

# ── красное-охрана: тот же класс пути у чужого автора — зонный отказ ────────────
RED="$WORK/repo_draft_chuzhoj_avtor"
make_repo_archzone "$RED"
set_author "$RED" implementer
stage "$RED" contracts/002-chuzhoj.md 'draft-путь не архитектора — судится зонами'
"$BARRIER" "$RED" || true                    # ожидание: rc 1 «вне зоны» (до и после 019)
