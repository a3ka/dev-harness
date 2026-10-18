accept

# Ревьюер 995 (CMP-MOB-001): микро-круг по мандату консультанта

Мандат: форк `forks/n995-krug3-stop.md`, вариант (А). Один прогон, проверяется только B1″, замороженные меры H, область правки и сырой вывод. Новые находки вне класса идут советами.

Предмет: PR a3ka/Complior-mob#108, ветка cmp-mob-001/pilot.
- C = `d2304e21c5e0a15b70567b1343f81f4899d98b65`. Совпадает с `gh pr view 108` headRefOid. PR OPEN, mergedAt=null, 9 коммитов.
- Предыдущая голова: e44dfd09.
- H = `03d0b80c98f54b9f305f52fa6f599264a44427d6`. Это предок origin/main.

Блокеров нет, поэтому файл находок `.review/2026-10-18-05.md` не создаётся. Советы перечислены ниже. Merge я не выполнял.

## (1) B1″ закрыт обобщённо: ПРОЙДЕНО

**Код C, своей мерой по `git show d2304e21:mobile/src/bootstrap/pilot-app.tsx`.**
- Один хелпер `resetChallenge` (:89–92) делает две вещи: `verifyGeneration += 1` и `setFlow({...createInitialAuthFlow(), email: current.email})`. Тем самым сбрасываются code, challenge, sent, waitSeconds, invalid, session, disclosure и unavailableReason.
- Хелпер вызывается первой строкой из каждого обработчика, отменяющего challenge: handleDemoEntry:107, handleChangeEmail:157, handleNoAccess:163, handleReturn:172.
- `+= 1` нигде, кроме хелпера, не встречается (grep: одно вхождение, :90). `createInitialAuthFlow` используется только в useState:83 и в хелпере. Дублей сброса нет.
- Других путей в кадр F03.01 нет. `auth-demo-entry` есть только в EmailFrame (auth-screen.tsx:119). В email-кадр ведут три пути: first-run (начальное состояние), change-email и return; последние два проходят через хелпер.
- handleChangeEmail после хелпера дополнительно очищает e-mail (:158). Это прежнее поведение смены e-mail, а не дубль сброса.

**Репро круга 3 и моя обобщённая матрица** (`rev4-matrix.test.tsx`, независима от ячеек H).
- Матрица: 4 грязных поля {sent, cooldown, invalid, code} × 2 пути выхода {change-email, no-access→return} × 2 варианта следующего e-mail {тот же, новый} = 16 ячеек. К ним добавлены 2 ячейки shipped runtime без props, сохранение e-mail при return и живой контроль.
- Каждая ячейка проверяет: нет Sent/cooldown/invalid, поле code пустое, следующий verify идёт в НОВЫЙ challenge, открывается F02.01.
- Прогон: `run_matrix.sh` (jest, `EXPO_PUBLIC_API_MODE=mock`, без `PILOT_DEMO_CODE`):

| Голова | rev3-carry + rev4-matrix |
|---|---|
| C d2304e21 | `Tests: 26 passed, 26 total` |
| e44dfd09 | `Tests: 14 failed, 12 passed, 26 total`: красны все 5 REV3_* и все 9 return-ячеек REV4; change-ячейки зелёные, так и должно быть |
| мутант M10 (хелпер без сброса полей) | `Tests: 24 failed, 2 passed` |

## (2) Область правки: ПРОЙДЕНО

- `git diff --stat e44dfd09 d2304e21`: 2 файла, +19/−10.
  - `.github/workflows/mobile.yml`: 2 строки `ref:`.
  - `mobile/src/bootstrap/pilot-app.tsx`.
- Оба пути дословно есть в «ЗОНА implementer» frozen `contracts/995…md` (§Зоны, строка 95).
- `git diff --stat f86eb28 d2304e21 -- scripts mobile/scripts mobile/eslint.config.js STRUCTURE.md AGENTS.md mobile/app.json mobile/src/features/start .github/workflows/mobile-cloud-e2e.yml` пуст. Значит, `mobile/scripts/ci-e2e.sh` и `rehearsal-evidence.sh` не тронуты.
- Весь diff f86eb28..d2304e21 — 22 файла, тот же набор, что в круге 3.
- Коммит один, автор `implementer <implementer@dev-harness.local>`, ссылается на «995 (CMP-MOB-001)».

## (3) Проверки не переписаны под код: ПРОЙДЕНО

- `git log 0c0c38ed..03d0b80c -- fixtures/workshop_project/pilot_995 contracts/995…` даёт ровно один коммит: `03d0b80c architect995transfer <architect@dev-harness.local>`.
- Изменены только `stale_table.test.tsx` и `stale_table_probe.py`. Их sha256 байт-равны `wip/995/architect-exh@849c5f51b` (автор `architect`): `661cd77a8cc4bbdc` и `7d6b85535327640a`.
- Implementer H не трогал: в коммите C нет файлов H, тестов и фикстур.
- Frozen-байты одинаковы в frozen/contracts/995/1, на пине 03d0b80c и в origin/main:

| Файл | sha256 |
|---|---|
| pilot.yaml | `3cda11a9…` |
| pilot.test.tsx | `1ddc77ac…` |
| source.json | `527da5c1…` |
| контракт | `3e0342a1…` |

## (4) Пробы H на новом пине: ПРОЙДЕНО

**Все 12 проб на C.** Disposable R = `rev995r4/R` @ d2304e21, скрипт `run_probes.sh`, логи `probes/`.
- probe.py --check-frozen, runtime, bundle, schema, frozen_matrix, transport, admission, stale, types, pins, admission_family, stale_table: **все rc=0**.
- admission-family: `rc=0 family_size=860 static=0 dynamic=0`.
- stale_table: 36 строк rc=0, 0 строк rc=1.
- `git status` R после прогона пуст.
- Счёт 36 сверен своей мерой: в тесте 36 литералов `it('995 table …`, в CASES 36 элементов.

**stale_table на e44dfd09** (`rev995r4/Re`): `rc=1`, красных ровно 7. Это VERIFY_NO_ACCESS, GETSESSION_NO_ACCESS, RESEND_NO_ACCESS и RECORD_NOACCESS_RETURN_{SENT,COOLDOWN,INVALID,CODE}. Заявление «7 красных» подтверждено.

**Мутанты C** (`mutants.py`, копия `Rm`, после каждого мутанта `git checkout`, итоговый status пуст):

| Мутант | rc | Красные ячейки |
|---|---|---|
| M01 demo без хелпера | 1 | BEGIN_REBEGIN |
| M03 change-email без хелпера | 1 | VERIFY_CHANGE_EMAIL_EARLY |
| M05 no-access без хелпера | 1 | VERIFY_NO_ACCESS, GETSESSION_NO_ACCESS |
| M09 хелпер без bump | 1 | 14 ячеек |
| M10 хелпер без сброса полей | 1 | 4 RECORD_* |
| M11 / M12 / M13 / M14 хелпер оставляет sent / waitSeconds / invalid / code | 1 | ровно своя RECORD_* |
| M19 новый `handleStray` с setFlow | 1 | SENTRY_HANDLERS |
| M02/M04/M06/M08 bump-only в одном обработчике; M07 return без хелпера; M16 и M17 пары bump-only; M15 хелпер сохраняет challenge | 0 | — |

Почему мутанты с rc=0 эквивалентны, а не являются дырой: сброс в автомате переопределён. Вход в email-кадр уже сброшен соседним обработчиком, `challenge` перезаписывается каждым ответом begin до кадра code, а return достижим только после no-access. Удаление одного вызова поведенчески не наблюдаемо, и моя матрица на этих мутантах тоже ничего не ловит. Для handleReturn это объявлено в комментарии архитектора, строки 25–29.

## (5) Пин H во всех checkout: ПРОЙДЕНО

- В `.github/` ровно два `repository: a3ka/dev-harness`: mobile.yml:35–36 (quality) и :111–112 (android-e2e). Оба `ref: 03d0b80c98f54b9f305f52fa6f599264a44427d6`.
- `0c0c38ed` в дереве не осталось.

## Сырой вывод CI: ПРОЙДЕНО

Run 39165116497: headSha d2304e21, event pull_request, conclusion success. Шагов не-success нет ни в quality, ни в android-e2e. Лог получен через `gh run view --log`.
- **quality:** checkout H `03d0b80c…`, `995 runs=1 mismatches=0` ×3, `995 frozen checked=3`, admission-family `rc=0 family_size=860 static=0 dynamic=0`, stale-table 36 строк rc=0 и 0 строк rc=1, `Tests: 17 passed, 17 total`, `structure: OK`.
- **android-e2e:** checkout H `03d0b80c…`, `995 native rc=0 testcases=3 failed=0`, `rm -rf /tmp/impl995-pilot-private-39165116497-1`, `rehearsal evidence OK`.

## 050 — паразитная сложность (артефакты diff)

- **`resetChallenge` (хелпер, +8).**
  - (1) Требуют инв. 2/3 и условие форка (б): один reset с bump.
  - (2) Новое состояние не вводится. Ref-поколение и flow уже были, сброс виден в коде.
  - (3) Править при изменении того же свойства придётся 1 файл. Мест сброса стало меньше: было 3 bump и `createInitialAuthFlow` в одном обработчике, стал 1 хелпер.
  - (4) Интерфейс: 0 аргументов, без возврата. За ним скрыты bump и сброс 8 полей, модуль глубокий.
  - (5) Потребители: stale_table RECORD_*, *_NO_ACCESS, BEGIN_REBEGIN, *_EARLY.
  - Вывод: ESSENTIAL.
- **4 вызова хелпера и deps `useCallback`.** Это и есть само свойство «из каждого перехода». ESSENTIAL.
- **handleChangeEmail: `setFlow(email: '')`.** (1) Прежняя семантика смены e-mail (раньше её давал `createInitialAuthFlow()`). Без этой строки хелпер сохранил бы старый адрес. ESSENTIAL.
- **mobile.yml, ре-пин ×2.** (1) §Пины. (2)–(4): SHA, как и раньше, стоит в 2 местах. (5) Потребитель — шаги quality и android-e2e. ESSENTIAL.

## Советы (не блокируют; вне класса B1″)

- **S21 (архитектору, мера H).** SENTRY_HANDLERS приписывает строку `setFlow`/`setFrame` последнему увиденному `const handle… = useCallback`. Если новый callback назван не по `handle*`, сторож его не видит. Мутант M18 (`const onStray = useCallback(() => { setFlow(...sent: true) })` перед handleRecover) даёт stale_table `rc=0`, тогда как одноимённый `handleStray` (M19) красит сторож. Это слабость сторожа H, а не дефект C.
- **S22 (архитектору, мера H).** Таблица переносит поля challenge только по одному составному пути no-access→return→re-begin (RECORD_*). Пары «каждый обработчик × каждое поле» (4 × {code, sent, waitSeconds, invalid, challenge, unavailableReason}) отдельными ячейками не представлены, а M15 (сохранение `challenge`) не наблюдаем вовсе. На C поведение полно: моя матрица change и return × 4 поля зелёная, а на M10 красна. Совет касается только буквы условия форка (а).
- **Без изменений с круга 3** (заново не проверялись): S12 (ложные комментарии), S15 (ре-пины в issue #5 и тело PR), S17, S18, S19 и прочие советы предыдущих кругов.
- **S20 снят:** «36 ячеек» совпадает с моим счётом.
- **Q1/B4** закрыт словом владельца (Complior-mob#109) и не блокирует.

## Артефакты ревью (/tmp/dev-harness-verify/rev995r4/)

- `H` @ 03d0b80c.
- `R` @ d2304e21, `Re` @ e44dfd09, `Rm` (мутанты). У всех `git status` пуст.
- `run_probes.sh`, `probes/*.log`.
- `mutants.py`.
- `rev4-matrix.test.tsx` и `run_matrix.sh` (использует `rev995r3/rev3-carry.test.tsx`).
- Снимок `c995j4/mob` не изменялся: status пуст, HEAD d2304e21. Основной чекаут dev-harness не трогался: `git status` пуст.
