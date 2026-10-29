FAIL
OBJECT=16b243bb03b11184d34ad0ca8997c1cd9bdb4612
СУД: repo=dev-harness; предмет=140; фаза=реализация v2; роль=adversary; вызов=1/2; модель-план=openai-codex/gpt-5.6-terra; сессия=Adv140v2; модель-факт=openai-codex/gpt-5.6-terra; SHA=16b243bb03b11184d34ad0ca8997c1cd9bdb4612; предыдущий=нет; исключение=нет.

Кандидат неизменяем: `git cat-file -t 16b243bb03b11184d34ad0ca8997c1cd9bdb4612` → rc=0, `commit`. `git diff --name-only 823c94e3b 16b243bb03b11184d34ad0ca8997c1cd9bdb4612` → rc=0, только `scripts/zamok_predmeta.sh`. Исполнимая часть реализации (строки 65+) равна модели (строки 53+): `diff -q <(sed -n '65,$p' scripts/zamok_predmeta.sh) <(sed -n '53,$p' fixtures/workshop_project/odin_agent_140/model/zamok_predmeta.sh)` → rc=0.

## БЛОКИРУЕТ

БЛОКИРУЕТ — батарея пропускает реализацию, в которой судья ошибочно занимает слот лимита рабочих.

ОБЯЗАТЕЛЬСТВО: инвариант 7 контракта 140 — лимиты 3/3/3 являются лимитами независимых предметов направления; судья не занимает слот рабочего. Судья после yield автора должен быть пропущен при независимых трёх занятых рабочих слотах.

КЛАСС ПРИЧИНЫ: правильный счёт применяется к неверному классу записей (судья включён в лимит рабочих).

СОСТОЯНИЕ: в мире батареи `--sostojanie/--zhurnaly/--repo` есть три живых harness START для 141–143; автор 144 сдал yield, у 144 есть done-тег (поэтому его рабочий слот освобождён), OBJECT критика равен tip `wip/144/avtor`.

ОБХОД: в копии кандидата перед веткой судьи добавлен отказ `LIMIT_GRUPPY`, когда `zhivykh_v_gruppe harness >= CAP_HARNESS`. Команда `bash mutant-judge-cap-valid/fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh` → rc=0, `KLETKI 66 KRASNYH 0`: все 66 клеток приняли неверную реализацию.

Воспроизведение тем же миром батареи (вызов `probe.sudit` передаёт двери `--sostojanie <mktemp>/sost --zhurnaly <mktemp>/zhurnaly/parent1 --repo <mktemp>/repo <event>`): `JUDGE_CAP rc=1 stdout= stderr=ОТКАЗ: LIMIT_GRUPPY: stabil: judge incorrectly consumes harness cap`. Позитивный контроль на OBJECT в заново созданном таком же мире: `CONTROL rc=0 stdout=PUSCHEM Critic144 dev-harness/144 (sudja/critic) stderr=`.

НАБЛЮДЕНИЕ: конкретная неверная ветка достигается и закрывает допустимый суд; батарея её не отличает от реализации OBJECT.

ЗАКРЫВАЮЩЕЕ СВОЙСТВО: отдельная клетка создаёт три живых рабочих предмета одной группы, сданного автора нового done-предмета и судью этого предмета; ожидает rc=0, START судьи и занятие судьи. Та же клетка обязана стать красной при применении лимита к судье.

БЛОКИРУЕТ — батарея пропускает СЛОВО владельца, не привязанное к предмету, и тем самым открывает четвёртый рабочий слот произвольным СЛОВОМ.

ОБЯЗАТЕЛЬСТВО: инвариант 7 контракта 140 — СЛОВО является единственной санкцией сверх лимита для предмета; проверка `slovo_vladelca(<NNN>)` связывает санкцию с repoId и subjectId.

КЛАСС ПРИЧИНЫ: санкция читается из соседней записи/чужого subjectId вместо предмета текущего спавна.

СОСТОЯНИЕ: в мире батареи три живых harness START 141–143, запрос architect для 144, и единственная строка `SLOVO` с тем же repoId, но `subjectId=999`.

ОБХОД: в копии кандидата из jq-предиката SLOVO удалено `and .subjectId == $n`. `bash mutant-slovo-unscoped/fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh` → rc=0, `KLETKI 66 KRASNYH 0`.

Воспроизведение в отдельном mktemp-мире батареи через `probe.sudit` с фактическими `--sostojanie/--zhurnaly/--repo`: `UNSCOPED rc=0 stdout=PUSCHEM Arch144 dev-harness/144 (rabochij/architect) stderr=`. Тот же мир с дверью OBJECT: `CONTROL rc=1 stdout= stderr=ОТКАЗ: LIMIT_GRUPPY: группа harness: занято 3 из 3 (предмет 144); сверх лимита — только СЛОВО владельца (строка SLOVO)`.

НАБЛЮДЕНИЕ: строка СЛОВО для 999 открывает слот 144, хотя санкции 144 нет; это достижимая ложная зелень и нарушение лимита 3/3/3.

ЗАКРЫВАЮЩЕЕ СВОЙСТВО: отдельная клетка с тремя активными слотами и SLOVO другого subjectId ожидает `LIMIT_GRUPPY`; та же строка для запрашиваемого subjectId ожидает пропуск. Обе проверки идут на реальной поставленной двери безфлагового режима.

## Проведённые атаки и контроли

* Поставленная дверь: `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh` → rc=0, `KLETKI 66 KRASNYH 0`.
* Позитивный контроль честной минимальной реализации: в одноразовой копии модель подставлена в `scripts/zamok_predmeta.sh`; `bash positive-model/fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh` → rc=0, `KLETKI 66 KRASNYH 0`.
* Набор авторских мутаций: `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs` → rc=0, `SVJAZI 60`; все 31 стаба красны, в том числе `x01-vsegda-puschem` на 12 связях.
* Константа harness: `CAP_HARNESS=4` → rc=1, красны `u01-uchet-svod`, `w13-limit-harness`. Константа back: `CAP_BACK=2` → rc=1, красны `u01-uchet-svod`, `w21-limit-back-tri-ok`.
* Порог: `-ge` заменён на `-gt` → rc=1, красны `w13-limit-harness`, `w15-limit-mob-chetyre`, `w22-limit-back-chetyre`.
* Пустой вход: удален отказ `items пуст` → rc=1, красна именованная `g04-bityj-vhod` (вариант пустого массива возвращает rc=0 вместо rc=1/BITYJ_VHOD).
* Нейтрализация освобождения: done не освобождает слот → rc=1, красны `u01-uchet-svod`, `w17-limit-done-osvobozhdaet`; ПАУЗА не освобождает слот → rc=1, красны `u01-uchet-svod`, `w18-limit-pauza-osvobozhdaet`.
* Инструмент вне PATH: `env -i PATH=/not-present HOME=/tmp TMPDIR=/tmp /usr/bin/bash scripts/zamok_predmeta.sh --sudit --sostojanie /tmp --zhurnaly /tmp --repo . /tmp/no-event.json` → rc=2, `NOT_IMPLEMENTED: нет jq`; это fail-closed, не ложный пропуск.
* Синтетическая станционная интеграция (не живой спавн): `bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh` → rc=0, `PROB VSEGO 15 KRASNYH 0`.
* Гигиена: `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` → rc=0, `итог 4/4 классов закрыто`.

## СОВЕТ

СОВЕТ — буквальная константа в back-ветке вместо `$CAP_BACK` (`back) cap=3`) проходит безфлаговую батарею: rc=0, `KLETKI 66 KRASNYH 0`. При действующей норме 3/3/3 наблюдаемого нарушения нет, поэтому это не блокер; однако тест не доказывает, что back-ветвь использует каноническую переменную при следующем изменении капа.

## Не проверено

Живой spawn omp на станции не запускался: это прямо запрещено заданием. Ручные миры создавались только под `/tmp/dev-harness-verify/Adv140v2/` и удалены после наблюдения. Предмет и проверка не изменялись; по прямому ограничению задания push/commit не выполнялись.
