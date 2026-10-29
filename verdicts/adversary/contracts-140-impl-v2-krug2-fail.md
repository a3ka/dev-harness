FAIL
OBJECT=24bfc44b71dc19e197dcf409329311bb433e3619
СУД: repo=dev-harness; предмет=140; фаза=реализация v2, повтор после усиления батареи; роль=adversary; вызов=2/2; сессия=Adv140v2b; модель-факт=openai-codex/gpt-5.6-terra. Первичный `git cat-file -t 24bfc44b71dc19e197dcf409329311bb433e3619` → `commit` (rc 0). Объект — усилитель батареи; субъект-дверь взят из 16b243bb03b11184d34ad0ca8997c1cd9bdb4612 в изолированной копии интегрального дерева.

## БЛОКИРУЕТ B1 — чужой локальный done-тег освобождает слот другого repoId

**Обязательство 140.** Инварианты 3 и 7: ключ замка — `(repoId, subjectId)`; единый append-only учёт ограничивает направление 3/3/3, а слот снимают только done/ПАУЗА *предмета данного реестра*. Локальный тег `done/contracts/150/*` реестра `dev-harness` не является done предмета `other-registry/150`.

**Класс причины.** Правильный ответ не на тот вопрос / рассинхронизация `repoId` при подсчёте живых слотов. `zhivye_subekty_gruppy` хранит ключи `repoId/subjectId`, но `zhivykh_v_gruppe` передаёт в `predmet_done` и `na_pauze` только `${s#*/}` и всегда проверяет ТЕКУЩИЙ `--repo`. Поэтому статус `dev-harness/150` применяется к активной строке `other-registry/150`.

**Достижимое состояние и воспроизведение (только mktemp-мир).** Одной дверью на трёх корректных рабочих task-вызовах с `--repo <foreign>` (origin `other-registry`) и worktree-пинами origin `dev-harness` получены три живые START группы `harness`: `other-registry/150`, `/151`, `/152`. Затем в независимом реестре текущего вызова (`dev-harness`) создан только локальный тег `done/contracts/150/1`, а дверь вызвана для четвёртого независимого `dev-harness/153`.

Сырая команда:
```
python3 cross_registry_case.py
```
Наблюдение (rc 0):
```
foreign-150 rc=0
foreign-151 rc=0
foreign-152 rc=0
local rc=0
stdout=PUSCHEM Local153 dev-harness/153 (rabochij/architect)
stderr=
starts=4
```
То есть 4 живых предмета направления harness разрешены при капе 3. Все записи foreign созданы реальными вызовами проверяемой двери, а не вручную подложенным JSONL. `cross_registry_case.py` был одноразовым и удалён после пробы.

**Ложная зелень батареи.** До этой атаки поставленная дверь прошла `W` 69/69 rc 0, а `W --stabs` rc 0 (`SVJAZI 66`, `SUBJEKT_SVJAZI 66`). `probe.py:Mir` фиксирует `REPO_ID='dev-harness'`, а `Mir.start` записывает только этот repoId; среди 69 входов нет двух реестров с совпадающим subjectId и статусом done/ПАУЗА лишь в одном. Поэтому существующий механизм с этим обходом остаётся зелёным.

**ЗАКРЫВАЮЩЕЕ СВОЙСТВО.** В батарее нужна клетка с двумя настоящими `--repo` и общим `--sostojanie`: после трёх живых `other-registry/{150,151,152}` группы harness локальный `dev-harness` done-тег 150 НЕ должен изменить их счёт; запуск `dev-harness/153` обязан закончиться rc 1 `LIMIT_GRUPPY` и не дописать четвёртый START. Реализация должна вычислять done/ПАУЗУ в реестре, соответствующем `repoId` записи, либо консервативно считать запись чужого реестра занятой; она не вправе применять статус текущего `--repo` к другому repoId.

## Подтверждённые закрытия и позитивные контроли

* Честный кандидат (дверь 16b243… + батарея OBJECT) — `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh`: rc 0, `KLETKI 69 KRASNYH 0`.
* `W --model` трижды: rc 0, все 69 CASE `ok` каждый прогон. `W --stabs`: rc 0, 33 стаба, `SVJAZI 66`, `SUBJEKT_SVJAZI 66`, живых стабов 0.
* Нейтрализация прежних блокеров: стаб `s31-sudja-derzhit-slot` даёт rc 1 и ровно `w23-sudja-ne-zanimaet-slot KRASNO`; `s32-slovo-bez-predmeta` даёт rc 1 и ровно `w24-slovo-chuzhogo-predmeta KRASNO`. Остальные 68 клеток в каждой пробе зелёные; w25 остаётся зелёной.
* Регрессия v1: `git checkout HEAD -- scripts/zamok_predmeta.sh && W` → rc 1, ровно 3 красные клетки: `u01-uchet-svod`, `w20-limit-harness-tri-ok`, `w21-limit-back-tri-ok`; затем кандидат восстановлен.
* Порча оракула (`source.json: cap_back 3→4` в копии): `W --model` → rc 2, `ORACLE_TAMPERED: константы source.json != канону батареи`; файл восстановлен.
* Без jq в PATH: `env PATH=/nonexistent /usr/bin/bash scripts/zamok_predmeta.sh --uchet --sostojanie /tmp --zhurnaly /tmp --repo .` → rc 2, `NOT_IMPLEMENTED: нет jq`; отсутствие инструмента не объявлено успехом.
* `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` → rc 0, 4/4 классов закрыты.
* Синтетическая станционная приёмка на копии: `bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh` → rc 0, `PROB VSEGO 15 KRASNYH 0`.
* Исполнимые тела честного кандидата и модели идентичны: `diff -u <(sed -n '65,621p' scripts/zamok_predmeta.sh) <(sed -n '53,609p' fixtures/workshop_project/odin_agent_140/model/zamok_predmeta.sh)` → rc 0, без вывода. Комментарные шапки различаются; семантический код совпадает.

## СОВЕТ

Литерал `cap=3` в отдельной ветви back неотличим от `CAP_BACK` при канонических 3/3/3 и не предъявлен как блокер: это известный остаток, который без варианта канонического cap не имеет наблюдаемого расхождения.

## Вне периметра / не проверено

Не запускался реальный spawn omp и не трогался учёт станции; выполнены только mktemp-миры и синтетическая станционная команда. Sentinel-мутант, знающий точный детерминированный мир батареи, не классифицирован блокером согласно заданной демаркации.
