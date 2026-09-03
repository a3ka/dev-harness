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
#       2. имена ссылок — ОБЕ половины перечисления источника 2 (for-each-ref
#          refs/heads refs/remotes, первая числовая компонента имени; правка 3 по FAIL
#          круга 4: стаб без refs/remotes проходил вход «ветка»
#          константно-инвариантно): refs/heads/wip/<занятый>/istochnik И
#          refs/remotes/origin/wip/<занятый>/only-remote — ОТДЕЛЬНЫМИ входами
#          (половины изолированы; хвосты НЕ architect — иначе страж 018
#          «ветка, не main» откажет раньше draft-ветви);
#       4. достижимая история: contracts/019-udaljon.md закоммичен и удалён
#          (источник 4: git log --all --diff-filter=A).
#     Источник 3 (файлы на HEAD) — вход BUSY выше. В каждом входе остальные
#     источники чисты; staged 020-draft под architect с доп-зоной contracts/ →
#     rc 0 СО строкой draft-пропуска. Head-only стаб на таких репо даёт rc 0
#     БЕЗ строки — ассерт валит фикстуру ДО красного кандидата (А-73), scoped-прогон
#     краснеет «барьер остался зелёным на обманном дереве».
#   * фильтры классов (порог круга 5: половины перечислений — целиком, один
#     проход): вход «чужой класс» — занятый номер живёт только в артефактах
#     класса PLAN (тег id/PLAN/<занятый> — фильтр источника 1;
#     plans/<занятый>-x.md на HEAD — фильтр источника 3; plans/<занятый>-udaljon.md
#     в истории — фильтр источника 4). Честный peek для CONTRACT видит максимум 001
#     → staged 002-draft пропущен ПО draft-ветви (строка есть); стаб, расширивший
#     перечисление за пределы класса, называет max+1 → строки нет → ассерт валит
#     фикстуру ДО красного кандидата (тот же А-73-контур, зеркально серийным входам).
#   * грамматика разбора (правка 4 по FAIL круга 5: два константно-инвариантных
#     стаба проходили все входы выше — оси, объявленные в аудите правки 3
#     осознанным остатком, закрыты здесь входами ПРЕДСТАВИТЕЛЬНО; полнота по
#     грамматическим осям НЕ заявляется и не может быть заявлена — арбитраж
#     fa0d354, см. ГРАНИЦУ РЕШЁТКИ ниже):
#       - якорь тега: id/CONTRACT/<занятый>a — честный разбор id/[^/]+/([0-9]+)$
#         суффикс после цифр НЕ матчит (номер не занят); стаб без конечного
#         якоря считает <занятый> → следующее у стаба max+1 ≠ 002 у честного →
#         расхождение наблюдается на ЭТОМ входе (Н-39);
#       - первая числовая КОМПОНЕНТА имени ссылки (каноническая грамматика
#         fa0d354; прежняя формулировка — «первая цепочка цифр»):
#         refs/remotes/origin/wip/<занятый>/x/<вторая> (две числовые
#         компоненты; вторая — VTORAJA_NOMER, производная 10#-арифметикой от
#         параметра); честный берёт первую → staged <max+1> по draft-ветви;
#         стаб последней компоненты называет <вторая>+1 → строки нет → ассерт;
#       - базовое имя, ветка rc 1: contracts/<занятый>-2026-x.md (цифра за
#         дефисом — безномерное, источник 3/4 НЕ считает) → честный максимум 001,
#         staged 002-draft по draft-ветви; стаб, принимающий дату за номер,
#         называет max+1 → строки нет → ассерт;
#       - базовое имя, ветка rc 2: contracts/<занятый в четыре цифры>-x.md —
#         parse_artifact_basename ставит ARTIFACT_NUMBER и при неправильном
#         формате, номер СЧИТАЕТСЯ → честный максимум <занятый>, staged <max+1>
#         по draft-ветви; стаб «ровно три цифры» отбрасывает файл → 002 →
#         строки нет → ассерт.
#     Каждый вход изолирует СВОЮ ось (остальные источники чисты), поэтому каждый
#     стаб круга 5 и обе до-того-неотличимые оси базового имени краснеют НА СВОЁМ
#     входе, а не по первой красной точке объединённого case.
#   * подкласс выбора числовой КОМПОНЕНТЫ конформной ссылки (правка 5 по FAIL
#     круга 7: стаб «компонента после wip/» проходил все входы выше и расходился
#     с честной ПЕРВОЙ компонентой на конформном зеркале refs/remotes/007/wip/137/only
#     с числовым именем remote). Закрыт ПЕРЕЧИСЛЕНИЕМ функций выбора по коду (Н-39:
#     [[ =~ ]] в next_id.sh:269 берёт левое совпадение = ПЕРВАЯ компонента — честное
#     правило): first (честная), last, max, min, after-wip, N-я. На конформном
#     пространстве числовых компонент НЕ БОЛЬШЕ ДВУХ (wip/<NNN>/<роль> + одно имя
#     remote — spawn_agent.sh:111-125, имя remote — один компонент пути), поэтому
#     функции схлопываются: {last, after-wip, N-я при N=2} — компонента после wip/;
#     max; min; N≥3 конформных входов с тремя числовыми компонентами не имеет и
#     расходиться на конформном входе не может (демаркация ниже). ДВА входа с
#     компонентами <z-1> и <z> в двух ориентациях СОВМЕСТНО различают честную first
#     с КАЖДОЙ альтернативой:
#       - KOMP1 refs/remotes/<z-1>/wip/<z>/only — первая МЕНЬШЕ: честный следующий
#         <z>, стабы last/after-wip/N-я/max называют <z>+1 → строки нет → ассерт
#         (А-73); min совпадает с честной — ловится KOMP2;
#       - KOMP2 refs/remotes/<z>/wip/<z-1>/only — первая БОЛЬШЕ: честный следующий
#         <z>+1, стабы last/after-wip/N-я/min называют <z> → строки нет → ассерт;
#         max совпадает с честной — ловится KOMP1.
#     Компоненты — существующие производные М-1 (VTORAJA_NOMER, ZANJATYJ_NOMER);
#     новых точек выведения нет.
#   * зелёный контроль (существующий вход 019): virgin-репо (занят только 001),
#     architect (зонирован в plans/) стадит contracts/002-draft.md → rc 0.
#     Стоит ПОСЛЕ пинов: в до-019-коде этот вход красен и не имеет права стать
#     красным кандидатом раньше пина.
#   * охрана «судья не создаёт тег id/*» (мера не меняет предмет) — по всем
#     репо, где под architect УЖЕ прогнан судья: стаб-/reserve-тег занял бы номер
#     и изменил предмет, который проверяется. Судит ОТСУТСТВИЕ НОВЫХ тегов id/
#     после прогона (снимок ДО вызова против снимка ПОСЛЕ — правило 8: ожидание
#     в памяти проверяющего), а НЕ отсутствие вообще: вход «источник-тег» сам
#     несёт id/CONTRACT/019 по построению (правка 2), вход «якорь тега» —
#     id/CONTRACT/019a с мусорным суффиксом (правка 4; снимок ДО его видит).
#   * красное-серийное: занят 019, staged contracts/021-draft.md (соседний
#     НЕ-следующий) под architect → «вне зоны» ДО и ПОСЛЕ 019 (охрана от
#     переусердия draft-ветви: соседний номер зонным судом не отвернётся сам).
#   * красное-охрана (существующий вход): тот же класс пути у ЧУЖОГО автора
#     (implementer) → «вне зоны» ДО и ПОСЛЕ 019.
#
# ── ГРАНИЦА РЕШЁТКИ (М-2 арбитража fa0d354: блок «РЕШЁТКА ЗАКРЫТА ЦЕЛИКОМ» ────
# снят как недоказуемый — п. 1 вердикта). Оси ПЕРЕЧИСЛЕНИЯ конечны — их число
# задано структурой кода next_id_max_for_class — и закрыты входами (арбитраж
# ebc57db: структурная слабость без ключования на литералы фикстуры — законная
# добыча судьи, закрывается входами):
#   источники: 1 — TEGSRC; 2, локальная половина — VETSRC; удалённая половина —
#     REMSRC (правка 3); 3 — BUSY; 4 — ISTSRC; половины изолированы ОТДЕЛЬНЫМИ
#     входами;
#   фильтры классов: источник 1 (refs/tags/id/<КЛАСС>/), источник 3 (pathspec),
#     источник 4 (awk-префикс) — CHUZHSRC (занятость видна только стабу,
#     расширившему фильтр за пределы класса CONTRACT);
#   арифметика max+1 — BUSY (значение) и ADJ (соседний max+2); константа и
#     off-by-one ловятся теми же входами; октальная канарейка — дефолт 019 (М-1
#     ebc57db, замер 3); рекурсия ls-tree источника 3 оси НЕ образует — всякий
#     файл HEAD попадал в достижимую историю добавлением, и источник 4 (полные
#     пути) видит его и без рекурсии.
# Оси ГРАММАТИКИ разбора конечными НЕ являются: пространство правил извлечения
# числа не перечислимо конечным набором входов (fa0d354 п. 1 — диагональный
# аргумент ebc57db, поднятый с уровня значений на уровень грамматик); эти оси
# пинованы входами ПРЕДСТАВИТЕЛЬНО, полнота НЕ заявляется и не может быть
# заявлена конечной фикстурой; заявление «закрыто целиком» по грамматическим
# осям в шапках конечных фикстур запрещено (fa0d354, М-2). Статусы входов
# правки 4 (fa0d354 п. 5):
#   DATG, CHETYRE — пинуют ДОКУМЕНТИРОВАННЫЙ разделяемый контракт
#     parse_artifact_basename (специфицированная область, полноправные пины);
#   TEGSUFF, PERVAJA — детекторы изменений в неспецифицированной области:
#     новых результатов не порождают, при легитимной смене грамматики автор
#     вправе обновить их без упрёка в ослаблении барьера.
# Подкласс выбора компоненты ВНУТРИ грамматических осей конечен и закрыт
# ПЕРЕЧИСЛЕНИЕМ (правка 5, FAIL круга 7): на конформном пространстве ≤2 числовых
# компонент любая функция выбора либо всегда берет ПЕРВУЮ (тождественна честной —
# конформного расхождения нет, по демаркации ниже не контрпример), либо хотя бы в
# одной ориентации пары — ВТОРУЮ, и краснеет на входе этой ориентации (KOMP1/KOMP2).
# Это не заявление «решётка закрыта целиком» (запрещено выше): перечисление касается
# ТОЛЬКО подкласса выбора компоненты и опирается на конформную границу ≤2 числовых
# компонент (wip/<NNN>/<роль> + одно имя remote). Полнота остальных грамматических
# осей НЕ заявляется (fa0d354 п. 1).
# ВАЛИДНОСТЬ КОНТРПРИМЕРА — два условия ВМЕСТЕ, обязательное правило будущих
# кругов (fa0d354 п. 3): (i) константная инвариантность (ebc57db — параметр
# CHECK_STAGED_ZANJATYJ_NOMER) И (ii) расхождение с честной реализацией на
# КОНФОРМНОМ входе. Конформные формы порождает сама система: теги
# id/<КЛАСС>/<NNN>, ровно %03d, без суффиксов (next_id.sh:447); ссылки
# wip/<NNN>/<роль> с %03d и нечисловой ролью и их refs/remotes-зеркала
# (spawn_agent.sh:122); файлы <NNN>-<slug>.md по документированной грамматике
# parse_artifact_basename. Расхождение ТОЛЬКО на неконформном входе (тег 137a,
# ссылка wip/137/x/042 с числовой «ролью», x137x, цепочки не из трёх цифр) —
# неспецифицированная область: не FAIL и не «повтор причины», нового
# результата не образует.
#
# ГРАНИЦА КЛАССА И ОСТАТОЧНЫЙ РИСК (М-2 арбитража contracts-019-pinovanie-peek,
# ebc57db): класс реализаций, ключующихся на литералы фикстуры, конечной
# детерминированной фикстурой не ловится по построению; демаркация — критерий
# константной инвариантности, вердикт
# verdicts/arbitration/contracts-019-pinovanie-peek.md
#
# М-1 того же арбитража: занятый номер — ПАРАМЕТР. Единственная точка подстановки —
# строка чтения CHECK_STAGED_ZANJATYJ_NOMER ниже; дефолт 019 СОХРАНЁН (октальная
# канарейка, замер 3 арбитража: наивный разбор $((019+1)) умирает на дефолте).
# Подстановка — окружением команды прогона, файлы не правятся:
#   CHECK_STAGED_ZANJATYJ_NOMER=137 bash scripts/verify_antiplacebo.sh . \
#     --scope check_staged/case_draft_sledujushhij_id
# Допустимые значения: три цифры, 002…998 (999 запрещён: max+1 вышел бы за формат
# трёх цифр). Производные max+1/max+2 вычисляются 10#-арифметикой от параметра,
# литералы производных запрещены. Вторая числовая компонента GRM2 (VTORAJA_NOMER) —
# та же дисциплина: производная <занятый>-1, точка выведения ОДНА (М-1-зона),
# построители её не перевыводят. Без подстановки прогон дословно прежний.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# ── М-1: занятый номер — параметр (ЕДИНСТВЕННАЯ точка подстановки) ────────────
# Производные — только 10#-арифметикой от ZANJATYJ_NOMER: литерал производной
# дал бы стабу вторую точку ключования, и параметр перестал бы быть единым.
ZANJATYJ_NOMER="${CHECK_STAGED_ZANJATYJ_NOMER:-019}"
case "$ZANJATYJ_NOMER" in
  [0-9][0-9][0-9]) ;;
  *) printf 'ОТКАЗ: занятый номер «%s» — не три цифры (М-1: 002…998)\n' "$ZANJATYJ_NOMER" >&2
     exit 1 ;;
esac
case "$((10#$ZANJATYJ_NOMER))" in
  [2-9]|[1-9][0-9]|[1-9][0-9][0-8]) ;;
  *) printf 'ОТКАЗ: занятый номер %s вне диапазона 002…998 (М-1)\n' "$ZANJATYJ_NOMER" >&2
     exit 1 ;;
esac
SLEDUJUSHHIJ_NOMER="$(printf '%03d' "$((10#$ZANJATYJ_NOMER + 1))")"  # max+1
SOSSEDNIJ_NOMER="$(printf '%03d' "$((10#$ZANJATYJ_NOMER + 2))")"    # max+2
# Вторая числовая компонента входа PERVAJA (правка 4): производная <занятый>-1.
# Пин первой компоненты жив, пока следующие номера честного (<занятый>+1) и стаба
# (max(<вторая>, 001)+1) РАЗЛИЧИМЫ — по коду разбора они сходятся ТОЛЬКО при
# равенстве компонент, поэтому вторая обязана быть МЕНЬШЕ занятого (ассерт ниже;
# «больше базы» при неравенстве цепочек несущественно: даже <вторая>=001 даёт
# стабу 002 ≠ <занятый>+1 — проверено по коду в обе ориентации). Ассерт стоит в
# М-1-зоне ДО построения репо: нарушение — отказ до любого входа (А-73).
VTORAJA_NOMER="$(printf '%03d' "$((10#$ZANJATYJ_NOMER - 1))")"  # вторая компонента GRM2
if [ "$((10#$VTORAJA_NOMER))" -ge "$((10#$ZANJATYJ_NOMER))" ]; then
  printf 'ОТКАЗ: вторая цепочка %s не меньше занятого номера %s — пин первой цепочки исчезает (М-1)\n' "$VTORAJA_NOMER" "$ZANJATYJ_NOMER" >&2
  exit 1
fi

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
assert_draft_propushhen() {  # <чем занят номер> <вывод барьера> — строка draft-ветви обязательна
  if ! printf '%s\n' "$2" | grep -Fq '(draft next-id пропущен под architect)'; then
    printf 'ОТКАЗ: draft %s при занятом %s (%s) пропущен НЕ по draft-ветви — peek не назвал следующий номер из этого источника (стаб?): %s\n' "$SLEDUJUSHHIJ_NOMER" "$ZANJATYJ_NOMER" "$1" "$2" >&2
    exit 1
  fi
}

# ── пин ЗНАЧЕНИЕМ (источник 3: файл на HEAD): занят 019 → следующий 020 ───────
BUSY="$WORK/repo_draft_zanjat$ZANJATYJ_NOMER"
make_repo_busy019 "$BUSY" contracts/
set_author "$BUSY" architect
busy_id0="$(id_tags_of "$BUSY")"
stage "$BUSY" "contracts/$SLEDUJUSHHIJ_NOMER-draft.md" "черновик контракта $SLEDUJUSHHIJ_NOMER — занят $ZANJATYJ_NOMER, следующий $SLEDUJUSHHIJ_NOMER"
out="$("$BARRIER" "$BUSY" || true)"
assert_draft_propushhen "файл contracts/$ZANJATYJ_NOMER-base.md на HEAD" "$out"

# ── пин-дополнение: свободный, но НЕ следующий (002 при занятом 019) ───────────
g "$BUSY" reset -q   # снять 020 из индекса: судится только 002
stage "$BUSY" contracts/002-draft.md "002 свободен, но следующий — $SLEDUJUSHHIJ_NOMER"
out="$("$BARRIER" "$BUSY" || true)"
if printf '%s\n' "$out" | grep -Fq '(draft next-id пропущен под architect)'; then
  printf 'ОТКАЗ: draft-ветвь пустила 002 при занятом %s — peek вернул не max+1: %s\n' "$ZANJATYJ_NOMER" "$out" >&2
  exit 1
fi
assert_no_new_id_tags "$BUSY" "$busy_id0"

# ── пин источник 1 (теги выдачи): 019 занят ТОЛЬКО тегом id/CONTRACT/019 ──────
TEGSRC="$WORK/repo_draft_istochnik_teg"
make_repo_busy019_teg "$TEGSRC" contracts/
set_author "$TEGSRC" architect
teg_id0="$(id_tags_of "$TEGSRC")"
stage "$TEGSRC" "contracts/$SLEDUJUSHHIJ_NOMER-draft.md" "черновик $SLEDUJUSHHIJ_NOMER — номер занят тегом выдачи, не файлом"
out="$("$BARRIER" "$TEGSRC" || true)"
assert_draft_propushhen "тег id/CONTRACT/$ZANJATYJ_NOMER" "$out"
assert_no_new_id_tags "$TEGSRC" "$teg_id0"

# ── пин источник 2 (имена ссылок): 019 занят ТОЛЬКО веткой wip/019/istochnik ──
VETSRC="$WORK/repo_draft_istochnik_vetka"
make_repo_busy019_vetka "$VETSRC" contracts/
set_author "$VETSRC" architect
vetka_id0="$(id_tags_of "$VETSRC")"
stage "$VETSRC" "contracts/$SLEDUJUSHHIJ_NOMER-draft.md" "черновик $SLEDUJUSHHIJ_NOMER — номер занят именем ссылки, не файлом"
out="$("$BARRIER" "$VETSRC" || true)"
assert_draft_propushhen "ветка wip/$ZANJATYJ_NOMER/istochnik" "$out"
assert_no_new_id_tags "$VETSRC" "$vetka_id0"

# ── пин источник 2, половина refs/remotes (правка 3 по FAIL круга 4): номер ──
# занят ТОЛЬКО удалённой ссылкой refs/remotes/origin/wip/<занятый>/only-remote.
# Стаб круга 4 (источник 2 без refs/remotes) читает только локальные ветки →
# следующий «002» → draft-ветвь молчит → доп-зона пускает БЕЗ строки → ассерт
# валит фикстуру ДО красного кандидата (А-73), как и head-only стаб выше.
REMSRC="$WORK/repo_draft_istochnik_remote"
make_repo_busy019_remote "$REMSRC" contracts/
set_author "$REMSRC" architect
remote_id0="$(id_tags_of "$REMSRC")"
stage "$REMSRC" "contracts/$SLEDUJUSHHIJ_NOMER-draft.md" "черновик $SLEDUJUSHHIJ_NOMER — номер занят удалённой ссылкой, не локальной веткой"
out="$("$BARRIER" "$REMSRC" || true)"
assert_draft_propushhen "refs/remotes/origin/wip/$ZANJATYJ_NOMER/only-remote" "$out"
assert_no_new_id_tags "$REMSRC" "$remote_id0"

# ── пин источник 4 (история): 019 закоммичен и удалён, HEAD чист ───────────────
ISTSRC="$WORK/repo_draft_istochnik_istorija"
make_repo_busy019_istorija "$ISTSRC" contracts/
set_author "$ISTSRC" architect
istorija_id0="$(id_tags_of "$ISTSRC")"
stage "$ISTSRC" "contracts/$SLEDUJUSHHIJ_NOMER-draft.md" "черновик $SLEDUJUSHHIJ_NOMER — номер занят историей, не HEAD"
out="$("$BARRIER" "$ISTSRC" || true)"
assert_draft_propushhen "contracts/$ZANJATYJ_NOMER-udaljon.md в достижимой истории" "$out"
assert_no_new_id_tags "$ISTSRC" "$istorija_id0"

# ── пин фильтров классов: занятый номер — только в ЧУЖОМ классе (PLAN) ─────────
# (тег id/PLAN/<занятый>, plans/<занятый>-x.md на HEAD, plans/<занятый>-udaljon.md
# в истории). Честный peek для CONTRACT называет 002 → staged 002-draft пропущен
# ПО draft-ветви. Стаб, расширивший перечисление за пределы класса CONTRACT,
# называет max+1 → строки нет → доп-зона пускает без строки → ассерт валит
# фикстуру ДО красного кандидата (А-73).
CHUZHSRC="$WORK/repo_draft_istochnik_chuzhklass"
make_repo_busy019_chuzhklass "$CHUZHSRC" contracts/
set_author "$CHUZHSRC" architect
chuzh_id0="$(id_tags_of "$CHUZHSRC")"
stage "$CHUZHSRC" contracts/002-draft.md "002 — следующий для CONTRACT, когда $ZANJATYJ_NOMER занят чужим классом (PLAN)"
out="$("$BARRIER" "$CHUZHSRC" || true)"
assert_draft_propushhen "чужой класс PLAN: id/PLAN/$ZANJATYJ_NOMER + plans/$ZANJATYJ_NOMER-*.md" "$out"
assert_no_new_id_tags "$CHUZHSRC" "$chuzh_id0"

# ── пин грамматики 1/4, якорь тега (правка 4 по FAIL круга 5): единственная ────
# запись с числом — тег id/CONTRACT/<занятый>a с мусорным суффиксом. Честный
# разбор (id/[^/]+/([0-9]+)$) суффикс после цифр НЕ матчит → максимум 001 →
# staged 002-draft пропущен ПО draft-ветви. Стаб круга 5 без конечного якоря
# считает <занятый> занятым → называет max+1 → строки нет → доп-зона пускает
# без строки → ассерт валит фикстуру ДО красного кандидата (А-73, контур
# CHUZHSRC: номер виден ТОЛЬКО стабу). Тег живёт под refs/tags/id/ с самого
# начала — охрана «нет НОВЫХ id-тегов» видит его в снимке ДО прогона.
TEGSUFF="$WORK/repo_draft_gramm_teg_jakor"
make_repo_busy019_tegsuffiks "$TEGSUFF" contracts/
set_author "$TEGSUFF" architect
tegsuff_id0="$(id_tags_of "$TEGSUFF")"
stage "$TEGSUFF" contracts/002-draft.md "002 — следующий: тег id/CONTRACT/$ZANJATYJ_NOMER a суффиксом номер НЕ занимает"
out="$("$BARRIER" "$TEGSUFF" || true)"
assert_draft_propushhen "тег id/CONTRACT/$ZANJATYJ_NOMER a — якорь разбора суффикс не матчит" "$out"
assert_no_new_id_tags "$TEGSUFF" "$tegsuff_id0"

# ── пин грамматики 2/4, первая числовая КОМПОНЕНТА ссылки (правка 4; статус ────
# fa0d354 п. 5 — детектор изменений в неспецифицированной области): единственная
# запись с числом — удалённая ссылка refs/remotes/origin/wip/<занятый>/x/<вторая>
# с ДВУМЯ числовыми компонентами. Честный разбор берёт ПЕРВУЮ компоненту —
# каноническая грамматика М-1 fa0d354 ((^|/)([0-9]+)(/|$)); прежняя свободная
# (([0-9]+), левое совпадение) на этом входе берёт ту же (замер 5 fa0d354:
# drop-in, вход зелёный под обеими) → staged <max+1> пропущен ПО draft-ветви;
# стаб последней компоненты называет <вторая>+1 → строки нет → ассерт (А-73).
# Хвост ссылки — НЕ architect: страж 018 читает только refs/heads/wip/,
# удалённая ссылка его не будит (как у REMSRC).
PERVAJA="$WORK/repo_draft_gramm_pervaja_cepochka"
make_repo_busy019_dve_cepochki "$PERVAJA" contracts/
set_author "$PERVAJA" architect
pervaja_id0="$(id_tags_of "$PERVAJA")"
stage "$PERVAJA" "contracts/$SLEDUJUSHHIJ_NOMER-draft.md" "черновик $SLEDUJUSHHIJ_NOMER — номер занят ПЕРВОЙ цепочкой wip/$ZANJATYJ_NOMER/x/$VTORAJA_NOMER"
out="$("$BARRIER" "$PERVAJA" || true)"
assert_draft_propushhen "первая цепочка ссылки wip/$ZANJATYJ_NOMER/x/$VTORAJA_NOMER" "$out"
assert_no_new_id_tags "$PERVAJA" "$pervaja_id0"

# ── пин грамматики 3/4, базовое имя rc 1 (правка 4): на HEAD лежит ─────────────
# contracts/<занятый>-2026-x.md — цифра сразу за дефисом, parse_artifact_basename
# возвращает rc 1 (безномерное), источники 3/4 НЕ считают. Честный максимум 001
# → staged 002-draft пропущен ПО draft-ветви; стаб, принимающий дату за номер,
# называет max+1 → строки нет → ассерт (А-73). Зеркально TEGSUFF: расхождение
# наблюдается только на этом входе.
DATG="$WORK/repo_draft_gramm_data_posle_defisa"
make_repo_busy019_data_posle_defisa "$DATG" contracts/
set_author "$DATG" architect
datg_id0="$(id_tags_of "$DATG")"
stage "$DATG" contracts/002-draft.md "002 — следующий: contracts/$ZANJATYJ_NOMER-2026-x.md безномерное (цифра за дефисом)"
out="$("$BARRIER" "$DATG" || true)"
assert_draft_propushhen "contracts/$ZANJATYJ_NOMER-2026-x.md — цифра за дефисом, разбор rc 1" "$out"
assert_no_new_id_tags "$DATG" "$datg_id0"

# ── пин грамматики 4/4, базовое имя rc 2 (правка 4): на HEAD лежит ─────────────
# contracts/<занятый в четыре цифры>-x.md — parse_artifact_basename возвращает
# rc 2 (неправильный формат), но ARTIFACT_NUMBER ставится и номер СЧИТАЕТСЯ
# (код источника 3/4 читает ARTIFACT_NUMBER без различения rc 0/rc 2). Честный
# максимум = <занятый> → staged <max+1> пропущен ПО draft-ветви; стаб «ровно
# три цифры» отбрасывает файл → 002 → строки нет → ассерт (А-73). %04d от
# параметра: цепочка — четыре цифры при ЛЮБОЙ подстановке 002…998.
CHETYRE="$WORK/repo_draft_gramm_chetyre_cifry"
make_repo_busy019_ne_tri_cifry "$CHETYRE" contracts/
set_author "$CHETYRE" architect
chetyre_id0="$(id_tags_of "$CHETYRE")"
stage "$CHETYRE" "contracts/$SLEDUJUSHHIJ_NOMER-draft.md" "черновик $SLEDUJUSHHIJ_NOMER — номер занят четырёхцифровой записью %04d"
out="$("$BARRIER" "$CHETYRE" || true)"
assert_draft_propushhen "четырёхцифровая запись contracts/$(printf '%04d' "$((10#$ZANJATYJ_NOMER))")-x.md — разбор rc 2, номер считается" "$out"
assert_no_new_id_tags "$CHETYRE" "$chetyre_id0"

# ── пин подкласса выбора числовой КОМПОНЕНТЫ (правка 5 по FAIL круга 7): ────────
# конформное зеркало refs/remotes/<R>/wip/<N>/only, ДВЕ числовые компоненты (R, N)
# в двух ориентациях; честная first = R (левое совпадение, next_id.sh:269).
# KOMP1: R=<z-1> < N=<z> → честный следующий <z> (стеджится <z>-draft); стабы
# last/after-wip/N-я/max дают max=<z> → следующий <z>+1 → строки нет → ассерт
# (А-73); min даёт <z-1> → следующий <z> → совпадает с честной, ловится KOMP2.
# KOMP2: R=<z> > N=<z-1> → честный следующий <z>+1 (стеджится <max+1>-draft);
# стабы last/after-wip/N-я/min дают <z> → строки нет → ассерт; max даёт <z>+1 →
# совпадает с честной, ловится KOMP1.
KOMP1="$WORK/repo_draft_komponenta_pervaja_menshe"
make_repo_busy019_komponenta "$KOMP1" "$VTORAJA_NOMER" "$ZANJATYJ_NOMER" contracts/
set_author "$KOMP1" architect
komp1_id0="$(id_tags_of "$KOMP1")"
stage "$KOMP1" "contracts/$ZANJATYJ_NOMER-draft.md" "черновик $ZANJATYJ_NOMER — первая компонента $VTORAJA_NOMER/wip/$ZANJATYJ_NOMER/only, следующая $ZANJATYJ_NOMER"
out="$("$BARRIER" "$KOMP1" || true)"
assert_draft_propushhen "первая компонента ссылки $VTORAJA_NOMER/wip/$ZANJATYJ_NOMER/only" "$out"
assert_no_new_id_tags "$KOMP1" "$komp1_id0"

KOMP2="$WORK/repo_draft_komponenta_pervaja_bolshe"
make_repo_busy019_komponenta "$KOMP2" "$ZANJATYJ_NOMER" "$VTORAJA_NOMER" contracts/
set_author "$KOMP2" architect
komp2_id0="$(id_tags_of "$KOMP2")"
stage "$KOMP2" "contracts/$SLEDUJUSHHIJ_NOMER-draft.md" "черновик $SLEDUJUSHHIJ_NOMER — первая компонента $ZANJATYJ_NOMER/wip/$VTORAJA_NOMER/only, следующая $SLEDUJUSHHIJ_NOMER"
out="$("$BARRIER" "$KOMP2" || true)"
assert_draft_propushhen "первая компонента ссылки $ZANJATYJ_NOMER/wip/$VTORAJA_NOMER/only" "$out"
assert_no_new_id_tags "$KOMP2" "$komp2_id0"

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
stage "$ADJ" "contracts/$SOSSEDNIJ_NOMER-draft.md" "$SOSSEDNIJ_NOMER — не следующий (следующий $SLEDUJUSHHIJ_NOMER): судится зонами"
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
