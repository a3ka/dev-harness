FAIL

# Ревьюер 995 (CMP-MOB-001), круг 3 из 3 (последний)

Предмет: PR a3ka/Complior-mob#108, ветка cmp-mob-001/pilot. C=`e44dfd0952754541cb8eb5273f156c37682d89b0`: совпадает с `gh pr view` headRefOid; PR OPEN, mergedAt=null, 8 коммитов. Предыдущий C=807e390, B=f86eb28. H-пин в mobile.yml: `0c0c38eddc1eb8e6109bc5cb9e78daef366dd063`, предок origin/main.
Находки с чекбоксами: `/tmp/dev-harness-verify/rev995r3/.review/2026-10-18-03.md` (status: ready). Merge не выполнялся. По капу docs/owner/2026-10-18-tri-slota.md §3 FAIL на круге 3 означает стоп 995 и передачу консультанту.

## Вердикт по пунктам роли

1. **Область правки: ПРОЙДЕНО.** `git diff --stat 807e390f e44dfd0` даёт ровно 2 файла: `.github/workflows/mobile.yml` (+8/−6) и `mobile/src/bootstrap/pilot-app.tsx` (+4). Оба в ЗОНЕ implementer. Полный `f86eb28..e44dfd0` — 22 файла, все в ЗОНЕ. Пустой diff f86eb28..e44dfd0 по `mobile/scripts scripts mobile/eslint.config.js STRUCTURE.md AGENTS.md mobile/app.json mobile/src/features/start .github/workflows/mobile-cloud-e2e.yml` означает, что `ci-e2e.sh`, `rehearsal-evidence.sh` и тесты 991 не тронуты.
2. **Сырой вывод: ПРОЙДЕНО.** CI run 39155176798: headSha e44dfd0, event pull_request, conclusion success. Не-success шагов нет.
   - quality: probe --check-frozen 14 `actual/*` rc=0, admission-family `rc=0 family_size=860 static=0 dynamic=0`, 22 ячейки stale-table rc=0, bundle http sources=7 / mock sources=8, `schema checked=2 runtime=matched`, `frozen checked=3`, `types checked=2 schema=matched`, Jest `17 passed`, `structure: OK`, doctor `20/20`.
   - android-e2e: H checkout на `0c0c38ed…`, `995 native rc=0 testcases=3 failed=0`, `rm -rf /tmp/impl995-pilot-private-39155176798-1`, `rehearsal evidence OK`.
   - Мой прогон: disposable R = `/tmp/dev-harness-verify/rev995r3/R` (clone снимка → e44dfd0, npm ci, `env -u PILOT_DEMO_CODE`, venv jsonschema 4.26.0), скрипт `run_probes.sh`, логи `probes/`. Все 12 проб H 0c0c38ed дали rc=0, суммарные строки те же, что в CI. После прогона `git status --short` пуст.
3. **Проверки не переписаны: ПРОЙДЕНО.** sha256 pilot.yaml `3cda11a9…`, pilot.test.tsx `1ddc77ac…`, source.json `527da5c1…` одинаковы в frozen/995/1, 0c0c38ed и origin/main. `git diff --stat frozen/contracts/995/1 0c0c38ed` по контракту и трём frozen-файлам пуст. Копии в C байт-равны H (`cmp` rc0). В e44dfd0 нет тестов и фикстур. Новые пробы H (4 файла, +847) — коммит `architect995transfer <architect@dev-harness.local>` в зоне `pilot_995/`.
4. **Красное предъявлено: ПРОЙДЕНО.** На 807e390 (`rev995r2/R`) `stale_table_probe` даёт rc1: BEGIN_REBEGIN, VERIFY_RETURN, RESEND_RETURN, GETSESSION_RETURN. На мутантах `admission_family_probe` даёт rc1: mut-backdoor `static=1 dynamic=0`, mut-unicode `static=1 dynamic=1`. На 807e390 и e44dfd0 он даёт rc0 (backdoor/unicode были мутантами, не кодом C). Новый барьер implementer-а в этом круге не вводился.
5. **Атомарность: ПРОЙДЕНО.** Один коммит e44dfd0 от `implementer <implementer@dev-harness.local>` со ссылкой «995 (CMP-MOB-001)».
6. **Норма не тронута: ПРОЙДЕНО.** Нормативных документов в diff нет.
7. **Заявленное = сделанному, своей мерой: РАСХОЖДЕНИЯ.**
   - «12 проб подключены»: подтверждено (probe.py + 11 строк в шаге quality; комментарий «12» верен).
   - «22 перехода × 5 портов»: мой подсчёт — 22 `it`, из них 20 ячеек переходов и 2 живых контроля, то есть 20 из 25 пар (S20).
   - «860 мутаций»: probe печатает `family_size=860`. Пересчёт семейства иной командой я не делал: [INFERENCE] 860 взято из вывода пробы.
   - Заявление «B1′ закрыт обобщённо» опровергнуто блокером B1″.

## Статус блокеров круга 2

- B1′: закрыт в части отложенных ответов (репро круга 1 и круга 2: 5 passed; 4 красные ячейки H на 807e390 зелёные на e44dfd0). Своей мерой перечислены все 5 await-точек `pilot-app.tsx`: begin:101, verify:114, Promise.all:120, resend:139 охраняются проверкой поколения, после recover:159 состояние не меняется. Перечислены и все места, где challenge заменяется или отменяется: handleDemoEntry, handleChangeEmail, handleReturn, unmount. Поколение поднимают все три обработчика, но состояние challenge сбрасывает только handleChangeEmail. Отсюда B1″.
- Q1/B4 First-Run: закрыт словом владельца 2026-10-18 ~18:40 UTC, Complior-mob#109. Не блокирует.

## Блокеры (полный список, круг 3)

- **B1″ — класс B1/B1′. Нарушены инв. 3 «Sent только после confirmed resend; countdown только из достоверного retryAfterSeconds» и инв. 2 «смена e-mail инвалидирует … результаты старого challenge».**
  - Что происходит: `handleReturn` (:162–165) и `handleDemoEntry` (:104/:108) не сбрасывают `sent`/`waitSeconds`/`invalid`/`code` старого challenge. Уже применённые результаты resend и verify старого challenge показываются для нового.
  - Репро: `/tmp/dev-harness-verify/rev995r3/rev3-carry.test.tsx` на e44dfd0 даёт `Tests: 5 failed, 1 passed`.
  - На отгружаемом runtime без props: resend(one) → no-access → return → two → demo-entry → «Ein neuer Code wurde gesendet.». resend(two) не вызывался.
  - С retryAfterSeconds=30: для two `auth-cooldown` «… in 30 Sekunden …».
  - После verify(one, неверный): для two `auth-invalid` «Ungültiger Code».
  - Контроль через `auth-change-email` зелёный.
  - H/RNTL/CI на этих путях зелёные.
  - Починка в одну строку (сброс этих полей в handleDemoEntry:108) даёт 56/56 passed вместе с frozen pilot.test.tsx и тестами H. Мера выполнена во временной копии, копия восстановлена.
  - Моя починка круга 2 была неполной; это записано в находках.

## Советы (не блокируют) и вопросы

S17 — resend×resend: более старый ответ перезаписывает countdown (60 → 30), EDGE_RESEND_OUT_OF_ORDER. S18 — verify в полёте × no-access на том же challenge открывает F02 с экрана F03.04. S19 — `auth-unavailable` без действия возврата. S20 — счёт ячеек таблицы. Повторы: S12 (ложные комментарии), S15 (ре-пины не в issue #5, тело PR называет 511f9453f), S13, S14, S16, S1–S3, S5–S8, S10, S11. Репро S17–S19: `/tmp/dev-harness-verify/rev995r3/rev3-edge.test.tsx`, 3 failed на e44dfd0.

## §Предмет

Android mock cold launch → First-Run → F03.01 → F03.02 → F02.01 с ролью AI и Demo: РЕАЛИЗОВАН. Основания: Maestro native `testcases=3 failed=0`, frozen 14/14, runtime 6/6. DIRECT unknown/incomplete не открывает Start: frozen `DIRECT_*` rc0. Один PR, без Merge. Не исполнены инварианты 2/3 на пути возврата (B1″), поэтому предмет не принят целиком.

## Cognitive-only сверки

- П4.1–П4.4: без изменений с круга 2, OK. Файлы api/auth/mocks/runtime/features в e44dfd0 не менялись. Тестового ответвления нет. `model.tsx`/`runtime-model.ts` не скопированы. Допуск — одна ветвь `code === PILOT_DEMO_CODE` (mocks/runtime.ts), admission-family `static=0`.
- mobile.yml: H checkout ×2 на буквальном `0c0c38ed…`. cmp до npm test. 12 проб с `--repo` disposable R. Release `EXPO_PUBLIC_API_MODE: mock`. PRIVATE_FILE удаляется под `if: always()`. Гейты rehearsal-evidence и Maestro version не тронуты.
- UX175 F03.A01/A02 synthetic: backend PASS не заявлен, SYNTHETIC/NOT_RUN сохранены. Обязательство «no stale» нарушено на пути B1″.
- ПРОВОДКА: новых каналов в diff нет.

## 050 — паразитная сложность (артефакты diff круга 3)

- `pilot-app.tsx`, handleDemoEntry: `+= 1` + захват поколения + проверка после await (+3). (1) Инв. 2/4, stale-ответ begin. (2) Ref-счётчик явен в коде, в выводе не виден. (3) 1 файл, число не выросло. (4) Интерфейс не менялся. (5) Потребитель — H stale_table BEGIN_REBEGIN (красна на 807e390). ESSENTIAL.
- `pilot-app.tsx`, handleReturn `+= 1` (+1). (1) Инв. 2/4, путь возврата. (2) То же. (3) 1. (4) —. (5) Потребители — VERIFY/RESEND/GETSESSION_RETURN. ESSENTIAL, но неполно: B1″ — сброс состояния отсутствует.
- mobile.yml, 2 строки проб, ре-пин ×2, имя шага и комментарий. (1) §Пины: CI исполняет пробы H из буквального пина. (2) Disposable R уже был, нового состояния нет. (3) SHA в 2 местах, как раньше. (4) —. (5) Потребитель — шаг quality. ESSENTIAL. Имя шага, разросшееся до перечня 11 проб, дублирует тело шага — совет.

## Артефакты ревью

- Репро B1″: `/tmp/dev-harness-verify/rev995r3/rev3-carry.test.tsx`. Советы: `rev3-edge.test.tsx`.
- Пробы: `run_probes.sh`, `probes/*.log`.
- R: `rev995r3/R` @ e44dfd0, `git status` пуст. R2 (репро и временная починка): `rev995r3/R2` @ e44dfd0, `git status` пуст.
- H: `rev995r3/H` @ 0c0c38ed.
- Снимок c995j3 не изменялся (`git status` пуст, HEAD e44dfd0). Основной чекаут dev-harness не трогался (`git status` пуст).
