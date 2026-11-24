accept
OBJECT=bc4dba3a45f3ffce9d609854e03e0ba9f68ab4bf
СУД: репо=dev-harness; предмет=212; роль=critic; вызов=2 (scoped); фаза=v1; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=archive/212/critic-v1-fail-a44db4a2fb; класс риска=рисковый

Суд ограничен тремя прежними блоками, их дельтой и зависимым регрессом. Автор OBJECT — architect; судья — critic. Назначение apex-sol = gpt-terra в config/agent_models.json. Окончательную сверку фактической сессии по трассе и дополнение записи HANDOFF делает оркестратор.

## Закрытие блоков вызова 1

Б-1 закрыт: contracts/212-replace-posle-lenda.md:29, модель usage и n03 согласованы с mint_line: отсутствующий --nnn — rc 1 с usage, негодное значение — rc 2 NOT_IMPLEMENTED. --model проверил n03 и неконформные значения.

Б-2 закрыт: contracts/212-replace-posle-lenda.md:35-36 допускает край без LF и требует неизменности чужих байтов. Свой toy-origin с живой дверью, строкой 986 посередине, двумя чужими строками после неё и последней без LF: rc 0, полный полученный манифест равен предснимку с одной заменой. Чужая строка с CRLF — неконформна по инварианту 5: rc 1, HEAD и байты неизменны. Адресный st41 красен на r17 и r18.

Б-3 закрыт: contracts/212-replace-posle-lenda.md:35 требует грамматику всего манифеста и байтовую проверку NUL до substitution. st42 красен отдельно на r20/r21/r22, st43 на r19; r19 сравнивает полный stderr. Дополнительный мир с табуляторами вместо пробелов вокруг стрелки: rc 1, пустой stdout, именованный отказ о строке №3, HEAD и байты неизменны.

Атака выполнена командой `TMPDIR="$PWD/.scratch-crit212b" python3 .scratch-crit212b/attack.py` (rc 0), в отдельных toy-мирах. Сырые определяющие поля вывода: `middle rc 0 ... bytes_expected True unchanged False head_unchanged False`; `tab rc 1 stdout b'' ... unchanged True head_unchanged True`; `foreign-crlf rc 1 stdout b'' ... unchanged True head_unchanged True`; `st41-awk-dobavljaet-lf r17-chuzhij-hvost-bez-lf red True`; `st41-awk-dobavljaet-lf r18-stroka-n-poslednjaja-bez-lf red True`; `st42-grammatika-udalena r20-manifest-crlf red True`; `st42-grammatika-udalena r21-manifest-lishnie-polja red True`; `st42-grammatika-udalena r22-manifest-pustaja-stroka red True`; `st43-nul-udalen r19-manifest-nul red True`. Для st41 r17 наблюдались отказ двери и отсутствие коммита, r18 — несовпадение побайтового манифеста. st42 на r20/r21 дал неверный диагноз, на r22 совершил коммит; st43 дал лишний stderr. Это адресные существующие стабы, не новые ветви в контракте.

С пинованным VALIDATE_STD_SHELLCHECK: `--repo .` rc 1 `SUBJEKT 212: SUBJECT_ABSENT .`; `--model` rc 0 `MODEL 212: KLETKI 28 KRASNYH 0`; `--stabs` rc 0 `STABY 212: SVJAZI 76 ZHIVYH 0`; `--sintaksis` rc 0 `SINTAKSIS OK (bash -n: 44; пинованный shellcheck честных носителей: 2)`; `pre_critic` rc 0 `КРИТИК: дверь зелёная`; `check_sdacha --run` rc 0 `СДАЧА: лист зелёный (двери=13 карта=17/17 дельта=6)`. Все 16 адресов прошлого суда входят в source.json.stab_vhod и проверены отдельными связями --stabs. Отдельно spec_ready, ids, ceilings, provodka --grammar, precision_gate, threat_model, predposylki, gen_ci_steps --check: каждый rc 0.

## Карта классов

К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0
К-02: чисто — вход слово владельца 22.11 и задание post-land REPLACE
К-03: чисто — вход двери 031 и 049 остаются неизменными
К-04: чисто — check_precision_gate rc 0 и зоны контракта
К-05: чисто — вход CLI инвариант 1 и n03 против n01 проверены --model rc 0
К-06: чисто — вход отказ сети r14 и пинованный shellcheck
К-07: чисто — вход отдельный toy-мир с незавершённым чужим хвостом и живой дверью rc 0
К-08: чисто — --stabs rc 0 и 76 адресных связей
К-09: чисто — входы r19–r22 и отдельный табулированный реестр
К-10: чисто — вход r19 и байтовое сравнение stderr в probe212.py
К-11: чисто — вход предснимок и ожидаемые объекты хранятся до вызова
К-12: чисто — вход настоящие git и check_staged в toy-мире
К-13: н/п — предмет не объявляет секретных входов
К-14: чисто — вход r17 и r18 вместе с собственным миром без LF
К-15: чисто — --model 28/0 и --stabs 76/0
К-16: чисто — вход класс права и безопасность и граница модели угроз
К-17: н/п — отдельные операции и схемы модели 188 не заявлены

## Блоки

Нет.

## НЕ ЗАЩИЩАЕТ

Вердикт не разрешает историческую пару 208, не меняет доверие к произвольному телу pre-commit и не является судом реализации. Конечная батарея не доказывает эквивалентность произвольной программы; ловцы — adversary и reviewer реализации.
