FAIL

# Ревьюер 995 (CMP-MOB-001), круг 2 из 3

Предмет: PR a3ka/Complior-mob#108, ветка cmp-mob-001/pilot. C=`807e390f4384ff3fe7a6976615533e51e0077ffb` (совпадает с `gh pr view` headRefOid; PR OPEN, mergedAt=null). Предыдущий C=e883d53, B=f86eb28, H-пин в mobile.yml=`7043023712f55adaef8be990e9af88173baa149a`. Frozen-контракт `frozen/contracts/995/1` в 7043023 не менялся (`git diff --quiet` rc0).
Находки с чекбоксами: `/tmp/dev-harness-verify/rev995r2/.review/2026-10-18-02.md` (status: ready). Merge не выполнялся.

## Вердикт по пунктам роли

1. **Область правки: ПРОЙДЕНО.** `git diff --stat e883d53 807e390` даёт 5 файлов: `.github/workflows/mobile.yml`, `mobile/.maestro/rehearsal.yaml`, `mobile/src/api/generated/api-5_8.ts`, `mobile/src/bootstrap/pilot-app.tsx`, `mobile/src/mocks/runtime.ts`. Все пять входят в ЗОНУ implementer. Полный diff f86eb28..807e390 — те же 22 файла круга 1, все в зоне. `git diff --stat f86eb28 807e390 -- mobile/scripts scripts mobile/eslint.config.js STRUCTURE.md AGENTS.md mobile/app.json mobile/src/features/start .github/workflows/mobile-cloud-e2e.yml` пуст: `ci-e2e.sh`, `rehearsal-evidence.sh` и тесты 991 не тронуты.
2. **Сырой вывод: ПРОЙДЕНО.** CI run 39145659866 (headSha 807e390, event pull_request, merge-ref f9b823c). Quality (job 117728849466, attempt 1): все 10 проб H выведены построчно — probe --check-frozen 14/14, runtime 6/6, bundle http sources=7 / mock sources=8, schema `checked=2 runtime=matched`, frozen checked=3 (drift rc=1), admission 4/4, stale 2/2, `types checked=2 schema=matched`, pins B5/B3 rc=0. Дальше Jest `17 passed`, `structure: OK`, doctor `20/20`. Android-e2e attempt 2 (job 117734897850): `995 native rc=0 testcases=3 failed=0`, `rehearsal evidence OK`, Maestro version gate success. Skipped-шагов нет. JUnit attempt 2 (`cf9fa353…`): 3 testcase SUCCESS, failures=0, среди них `991 start action and new-launch reset`. APK `7d1b5750…`. Первая попытка красная — известный флейк adb (Diag995b), не код.
   Мой прогон на disposable R (`/tmp/dev-harness-verify/rev995r2/R` = git clone снимка → 807e390, `npm ci`, `env -u PILOT_DEMO_CODE`, venv с jsonschema 4.26.0), все 10 проб H 7043023 дали rc0: check-frozen 14/14, runtime 6/6, schema matched, frozen_matrix checked=3, transport rc0, admission 4/4, stale 2/2, types matched, pins 2/2, bundle http 7 / mock 8 (24.8 s). После прогонов `git status --short` пуст. Отдельно: `npm run typecheck` rc0, `npm run lint` rc0, Jest `src/features/start` 2 suites / 3 tests rc0.
3. **Проверки не переписаны: ПРОЙДЕНО.** sha256 pilot.yaml `3cda11a9…`, pilot.test.tsx `1ddc77ac…`, source.json `527da5c1…` одинаковы в frozen/995/1, f70b43e4, 7043023 и origin/main. Копии в C (`bootstrap/__tests__/`) байт-равны. В diff круга 2 нет ни одного тестового или фикстурного файла. Новые пробы H (admission/stale/types/pins) — коммит architect в его зоне `pilot_995/`, implementer их не трогал.
4. **Красное предъявлено: ПРОЙДЕНО.** Новые барьеры H на прошлом C (`/tmp/dev-harness-verify/rev995/R` @ e883d53) мой прогон окрасил в красный: stale rc1 (оба кейса, F02.01 / «Ein neuer Code wurde gesendet.»), types rc1 `TYPES_SCHEMA_MISMATCH` (TS2559/TS2578/TS2353), pins rc1 (`REHEARSAL_NAME_CHANGED`, `RELEASE_MODE_UNSET`). На 807e390 все три зелёные. admission на e883d53 зелёный, и это ожидаемо: backdoor был мутантом адверсария, не кодом C. Красное на мутанте — у адверсария. Собственный новый шаг implementer (cleanup) барьером не является.
5. **Атомарность: ПРОЙДЕНО.** Один коммит `807e390` от `implementer <implementer@dev-harness.local>` со ссылкой «995 (CMP-MOB-001)»: починка находок круга 1 одной задачи. Всего в PR 7 коммитов (`gh pr view … commits` = `git log f86eb28..807e390`).
6. **Норма не тронута: ПРОЙДЕНО.** Нормативных документов в diff нет. Текст frozen-контракта неизменен.
7. **Заявленное = сделанному, своей мерой: РАСХОЖДЕНИЯ** (совет S13). Отчёт Impl995Fix6 пишет «9 проб», а перечисляет 10; в CI тоже 10, и комментарий mobile.yml «10 проб» верен. Числа diff_stat против `git diff --numstat`: mobile.yml +21/−8 против +19/−10, api-5_8.ts +10/−6 против +9/−7. «20/20 doctor» и «17/17 Jest» подтверждены CI-логом. Пункт «B1 fixed» опровергнут блокером B1′.

## Статус блокеров круга 1 (по существу)

- B1: закрыт на двух путях круга 1 (мой `rev-stale.test.tsx` 2 passed; H stale rc0 после, rc1 до). **Класс не обобщён — B1′.**
- B2: закрыт. Digest/DocumentDeliveryProof/Disclosure.digest по схеме, обязательные поля Session/Disclosure совпадают, каст удалён. Расположение рукописных типов в `generated/` — совет S16.
- B3: закрыт: `EXPO_PUBLIC_API_MODE: mock` в шаге release-APK. Maestro на release APK проходит mock-путь с demo-кодом.
- B4: закрыто то, что в зоне implementer: отладочной строки нет (frozen pilot.yaml/pilot.test.tsx на неё не опираются, grep пуст, CI зелёный), бейдж Demo ниже статус-бара (padding 48). First-Run «Weiter» вместо wordmark/promise/CTA и нативный Splash — **открытый вопрос владельцу Q1**, блокером implementer-а не считается.
- B5: закрыт. Имя testcase восстановлено и в yaml, и в JUnit CI.
- B6: закрыт. Копии checkout нет, `--repo` и `--apk` указывают на workspace, DISPOSABLE_REQUIRED не сработал (в maestro_probe его нет, CI rc0). PRIVATE_FILE удаляется под `if: always()` (лог attempt 2).

## Блокеры (полный список, круг 2)

- **B1′ — повтор класса B1 (инварианты 2/4: отложенные результаты старого challenge после смены e-mail; безопасный возврат ко входу).** Поколение увеличивается только в `handleChangeEmail`. `handleReturn` его не увеличивает. `handleDemoEntry` не проверяет поколение после `await begin`. Репро `/tmp/dev-harness-verify/rev995r2/rev2-stale.test.tsx` на 807e390 → `Tests: 3 failed`: (a) REV2_RETURN_SESSION — no-access→return→two, затем verify(one) authenticated открывает `F02.01` для неподтверждённого two; (b) REV2_RETURN_RESEND — «Ein neuer Code wurde gesendet.» для нового challenge от resend(one); (c) REV2_BEGIN_RACE — поздний begin(one) перезаписывает challenge, и `verify` вызывается с `one@example.invalid`. Кап §3 требует обобщённой починки повторного класса. Мера осуществимости: +3 строки (поколение в `handleDemoEntry` с проверкой после await и `+= 1` в `handleReturn`) дают 19/19 на rev2 + rev-stale + frozen pilot.test.tsx и rc0 у H stale/admission/runtime. Правка была временной, R возвращён к 807e390.

## Советы (не блокируют) и вопрос владельцу

S12 — ложные комментарии про `entry`/testID в pilot-app и «R/.harness» в android-e2e (повтор класса S4). S13 — счёт в отчёте implementer. S14 (архитектору) — stale_probe не покрывает пути return/begin, pins B3 не сверяет значение. S15 (оркестратору) — ре-пин 7043023 не записан в issue #5, тело PR называет 511f9453f. S16 — рукописные типы в `generated/`. S1–S3, S5–S8, S10, S11 круга 1 не изменились. Q1 — First-Run/Splash против D2.2.5.1 (владелец).

## Cognitive-only сверки

- П4.1 ApiClient: OK. `getSession(): Promise<Session>`, `getDisclosure(id): Promise<Disclosure>`, типы по компонентам схемы, без `unknown`/`any` (у `home_widget_snapshot?: unknown` поле необязательное, это совет из круга 1). П4.2 AuthProvider в `src/auth/`, Demo там нет: OK. П4.3 `mocks/runtime.ts` и `http-runtime.ts` аннотированы `{auth: AuthProvider; api: ApiClient}`: OK. П4.4 раскладка: OK.
- Тестового ответвления нет: `process.env` читают только конфиги и проверка mode в runtime. `model.tsx`/`runtime-model.ts` не скопированы.
- Секрет: литерал в maestro-out attempt 1 и 2 не найден (grep находит его только в APK, где это ожидаемый synthetic demo-code mock-бандла). `secrets.PILOT_DEMO_CODE` используется только в шаге PRIVATE_FILE, umask 077, файл удаляется. Поле кода на PNG `rehearsal-after` пустое.
- mobile.yml: H checkout ×2 с буквальным `7043023712f5…`. cmp стоит до npm test. 4 новые пробы подключены в quality с `--repo` disposable R. Release env задан. android-e2e работает с `--repo` workspace. Cleanup PRIVATE_FILE под `if: always()`. Гейты rehearsal-evidence и Maestro version не тронуты.
- UX175 F03.A01/A02 synthetic: backend PASS не заявлен, SYNTHETIC/NOT_RUN сохранены. Обязательство «no stale» нарушено на путях B1′.
- ПРОВОДКА: новых каналов в diff нет. Контракт потребляет действующую норму оркестратора.

## 050 — паразитная сложность (артефакты diff круга 2)

- `pilot-app.tsx`, проверки поколения после await (+3 строки): (1) инв. 2/3 «смена e-mail инвалидирует отложенные»; (2) ref-счётчик явен в коде, в выводе не виден; (3) 1 файл, число не выросло; (4) интерфейс не менялся; (5) потребители — H stale_probe и frozen EMAIL_STALE. ESSENTIAL, но неполно (B1′).
- `pilot-app.tsx`, `void entry;` + комментарий (замена sourceMark): (1) порт entry требует шов, использование — нет; (2) состояния нет; (3) 1; (4) порт принимается и игнорируется; (5) frozen-тест передаёт entry. Удаление строки — упрощение. Комментарий ложен: ACCIDENTAL, совет S12.
- `pilot-app.tsx`, padding 48/16/16: (1) B4 (статус-бар); (2) нет; (3) 1; (4) —; (5) PNG. ESSENTIAL для видимости бейджа.
- `api-5_8.ts`, новые формы Digest/DDP: (1) П4.1; (2) нет; (3) 1 (+ types_probe H); (4) типы, без поведения; (5) typecheck, types_probe. ESSENTIAL.
- `mocks/runtime.ts`, удалён каст: упрощение.
- mobile.yml, `env: EXPO_PUBLIC_API_MODE: mock`: (1) §Шов «release CI явно задаёт mock»; (2) env явно в шаге; (3) 1 место; (4) —; (5) pins_probe B3. ESSENTIAL.
- mobile.yml, 4 строки проб H: (1) §Пины (CI исполняет пробы H из пина), закрытие находок круга 1 через H; (2) общий disposable R; (3) SHA в 2 местах, как раньше; (4) —; (5) quality. ESSENTIAL.
- mobile.yml, шаг `Cleanup private code file`: (1) §Пины «PRIVATE_FILE вне checkout/artifacts», B6; (2) убирает состояние, путь явен в аргументе; (3) путь PRIVATE_FILE в 3 строках (создание, вызов, удаление; было 2), рост вынужден удалением; (4) —; (5) нет потребителя-проверки, но устраняет накопление на self-hosted раннере. ESSENTIAL.
- mobile.yml, удалённая R2-копия: сложность уменьшилась (−1 каталог состояния ~3.7G).
- `.maestro/rehearsal.yaml`, имя: восстановление обязательства §Пины.

## Артефакты ревью

- Репро B1′: `/tmp/dev-harness-verify/rev995r2/rev2-stale.test.tsx`. Репро круга 1: `/tmp/dev-harness-verify/rev995/rev-stale.test.tsx`. R: `/tmp/dev-harness-verify/rev995r2/R` (HEAD 807e390, `git status` пуст). Снимок c995j2 не изменялся (`git status` пуст, HEAD 807e390).
- H: `/tmp/dev-harness-verify/rev995r2/H` @ 7043023. CI-артефакты: `/tmp/dev-harness-verify/rev995r2/ci/art/` (run 39145659866, attempts 1 и 2).
