FAIL

# Ревьюер 995 (CMP-MOB-001), круг 1

Предмет: PR a3ka/Complior-mob#108, ветка cmp-mob-001/pilot. C=`e883d533084099f3abd9472fa2206575188a0030` (`gh pr view` headRefOid), B=`f86eb28`, H-пин в mobile.yml=`f70b43e4e8b2a2b3115f0abda0a34742a9450740`, frozen-тег 995/1=`511f9453f`, blob контракта sha256 `3e0342a1…b7c3`.
Находки с чекбоксами: `/tmp/dev-harness-verify/rev995/.review/2026-10-18-01.md` (status: ready). Merge не выполнялся.

## Вердикт по пунктам роли

1. **Область правки: ПРОЙДЕНО.** `git diff --name-status f86eb28 e883d53` даёт 22 файла, и все они входят в ЗОНУ implementer: workflow, `.maestro/`, jest/metro/package/tsconfig, `src/api/` (включая `generated/`), `src/app/`, `src/auth/`, `src/bootstrap/{pilot-app.tsx,http-runtime.ts,runtime-contract.d.ts,__tests__/}`, `features/auth/`, `features/onboarding/welcome-screen.tsx`, `navigation/pending-intent.ts`, `src/mocks/`. Не тронуты: `mobile/scripts/ci-e2e.sh`, `scripts/rehearsal-evidence.sh`, `eslint.config.js`, `features/start/**` (тесты 991), `mobile-cloud-e2e`, STRUCTURE.md/AGENTS.md (diff --stat пуст). package.json: удалён только inline jest, зависимостей не добавлено, lock не менялся.
2. **Сырой вывод: ПРОЙДЕНО.** CI run 39140382835: headSha=e883d53, event=pull_request. Все шаги quality и android-e2e `success`, skipped нет. Строки лога: probe --check-frozen 14 cases `runs=1 mismatches=0`; runtime 6 cases rc0; `bundle/actual/http rc=0 sources=7`, `mock rc=0 sources=8`; `schema checked=2 runtime=matched`; `frozen/drift: rc=1 FROZEN_BYTES_MISMATCH`, `frozen checked=3`; `995 native rc=0 testcases=3 failed=0`. JUnit из артефакта: 3 testcase SUCCESS, failures=0.
   Свой прогон на disposable R (`/tmp/dev-harness-verify/rev995/R`, npm ci, venv jsonschema 4.26.0, `env -u PILOT_DEMO_CODE`): `probe.py --check-frozen` rc0 (14/14), `runtime_probe.py` rc0 (6/6), `schema_probe.py` rc0, `frozen_matrix.py` rc0 (drift rc1), `transport_probe.py` rc0, `bundle_probe.py` rc0 (http 7 / mock 8 sources, 20.6 s), после него `git status --short` пуст. Jest `src/features/start` 2 suites/3 tests rc0, `npm run typecheck` rc0, `npm run lint` rc0 (structure OK).
3. **Проверки не переписаны: ПРОЙДЕНО.** sha256 pilot.test.tsx `1ddc77ac…`, source.json `527da5c1…`, pilot.yaml `3cda11a9…` совпадают в 511f9453f и f70b43e4, копии в C те же. pilot.yaml в C отсутствует (`.maestro` = rehearsal/start). H-пины 511f→f70b внутри `pilot_995/` различаются только в `maestro_probe.py`, пробы самодостаточны (импортов вне каталога нет). `.maestro/start.yaml`/`rehearsal.yaml` изменены по разрешённой миграции 991, но см. B5.
4. **Красное предъявлено: ПРОЙДЕНО** для новых барьеров implementer. Шаг cmp на копии с дописанным байтом source.json: `cmp: EOF … after byte 2499` → rc1 (без мутации rc0). Guard секрета при пустом env: `PILOT_DEMO_CODE_ABSENT` rc1. Drift пробы H красный и в CI-логе.
5. **Атомарность: ПРОЙДЕНО.** 6 коммитов implementer (`implementer@dev-harness.local`), все с отсылкой к 995: одна задача и её CI-фиксы.
6. **Норма не тронута: ПРОЙДЕНО.**
7. **Заявленное = сделанному, своей мерой: РАСХОЖДЕНИЯ.** В брифе «8 коммитов», по факту 6 (`git rev-list --count f86eb28..e883d53`=6 и `gh pr view … commits|length`=6). В брифе «maestro_probe.py +26/−3», по факту +24/−2 (`git diff --numstat 511f9453f f70b43e4…`). Комментарий в mobile.yml «18 Кейсов, 9 ранеров, 6 схем, 5 типов, 3 кейджа» CI не исполняет: это числа `--matrix`, а CI гоняет 14 / 6 / 2 / 3 (S4).

## Блокеры (полный список, круг 1)

- **B1 — нарушение инвариантов 2/3: отложенные результаты старого challenge не инвалидируются.** Фрагмент: `pilot-app.tsx` `handleResend` (без поколения) и `handleVerify`, где поколение проверяется только до `await Promise.all([getSession(), getDisclosure()])`. Конформное воспроизведение (порты как в frozen-тесте, deferred-ответы, адреса `.invalid`): `/tmp/dev-harness-verify/rev995/rev-stale.test.tsx`, `npx jest` → `Tests: 2 failed`.
  (a) REV_STALE_RESEND: найден `Ein neuer Code wurde gesendet.` для нового challenge при resend, подтверждённом для `one@example.invalid`.
  (b) REV_STALE_SESSION: `Received: <View … testID="F02.01">`, то есть F02 открыт для неподтверждённого `two@example.invalid`.
  Frozen EMAIL_STALE покрывает только отложенный verify, поэтому пробы зелёные.
- **B2 — П4.1 / STRUCTURE.md:63,161: выдуманные типы в `src/api/generated/`.** `Digest` объявлен как объект `{sha256?}`, в схеме это строка `^sha256:[0-9a-f]{64}$`. `DocumentDeliveryProof` объявлен как `{channel?, at?, recipient?}`, в схеме 7 обязательных полей и `additionalProperties:false`. Комментарий называет источником mock-5_8.json и «OpenAPI generator», хотя типы рукописные; `generated/` по STRUCTURE.md «не править вручную». В mocks/runtime.ts из-за этого стоит `as unknown as`. Мера: схемо-верные `Digest = string` и `DocumentDeliveryProof` по схеме дают `tsc --noEmit` rc0 вместе с frozen-тестами, то есть исправление возможно.
- **B3 — §Шов «release CI явно задаёт mock» / STRUCTURE.md:164.** В шаге «Сборка release-APK» нет `EXPO_PUBLIC_API_MODE`; `metro.config.js` по умолчанию выбирает mock для любой сборки, включая release.
- **B4 — инвариант 2 «Splash/First-Run следует D2.2.5.1» (cognitive-only, ловить должен ревьюер).** CI PNG `pilot-first-run.png` (`89b9f8e3…`): белый экран с одной кнопкой «Weiter». В эталоне `screens/First-Run.png`: wordmark, promise и CTA «Anmelden oder Konto erstellen» (`ui.first_run.enter_f03`, тот же текст, что у source.json `frame.F03.01.title`). «Weiter» нет ни в source.json, ни в D2.2.5.1. На всех экранах видна отладочная строка `DIRECT · unknown` (`sourceMark`). Бейдж «Demo» перекрывает часы статус-бара (PNG first-run/restart/rehearsal). Splash: в JS его нет; нативный splash — дефолт B (`app.json` #208AEF), он вне ЗОНЫ, это вопрос владельцу.
- **B5 — §Пины «rehearsal.yaml сохраняет имя testcase».** Имя `991 start action and new-launch reset` заменено, в JUnit CI testcase называется `991 rehearsal — First-Run → …`. Гейт rehearsal-evidence сверяет `file`, поэтому остался зелёным, но обязательство контракта нарушено.
- **B6 — §Пины `--repo C` / 050 ACCIDENTAL.** android-e2e копирует workspace в `/tmp/dev-harness-verify/impl995-r2-<run>-<attempt>` (порядка 3.7G, мера `du -sh` эквивалентного R) и запускает раннер с `--repo` на копию. Ни копия, ни `/tmp/impl995-pilot-private-*/code` не удаляются; раннер self-hosted (`gh-runner-complior.service`, PrivateTmp=yes), поэтому состояние копится от прогона к прогону. Контракт этого свойства не требует. Более простая форма `--repo ${{ github.workspace }}` + абсолютный APK из workspace + удаление PRIVATE_FILE под `if: always()` проходит те же строки приёмки.

## Советы (не блокируют)

S1–S11 — в файле находок: литерал `getDisclosure('example')`, Demo-метка вне mock composition, место отказа неизвестного mode, ложные комментарии, мёртвые экспорты, удалённый посторонний комментарий, строки вне source.json (факт: copy-signoff CMP-MOB-089 вне объёма), расширение Locale/AuthStatus, вынужденное frozen-тестом (архитектору; мера `tsc` rc2), ре-пин H не записан в issue #5 и тело PR (оркестратору), игнорируемый `recover()`, `mv .harness` в quality.

## Cognitive-only чек-лист П4 и прочие сверки

- П4.1 ApiClient: FAIL (B2). П4.2 AuthProvider в `src/auth/`, Demo-реализации там нет: OK. П4.3 `mocks/runtime.ts` и `http-runtime.ts` аннотированы `{auth: AuthProvider; api: ApiClient}`: OK. П4.4 раскладка F03/F02/pending-intent: OK.
- Тестового ответвления в production нет: `process.env` читают только метро/jest-конфиги и проверки mode в двух runtime; `NODE_ENV`, `JEST`, `__DEV__`, `console`, `fetch` в `src/` не встречаются. `model.tsx`/`runtime-model.ts` не скопированы.
- Секреты: `demo-code.ts` = `'synthetic-verification-value'` = synthetic `secret` frozen-теста, это не секрет. `secrets.PILOT_DEMO_CODE` подключён только в шаге «H-pин приватного кода». В CI-логе (314531 байт) литерал встречается 0 раз. Скан артефактов maestro-out: совпадений нет. Поле кода в PNG пустое (`secureTextEntry`).
- mobile.yml: H checkout с буквальным SHA `f70b43e4…`, ре-пин санкционирован форком n995-maestro-env (вариант Б, ОТВЕЧЕНО). cmp стоит до npm test; пробы H идут в disposable R под `/tmp/dev-harness-verify`. `--out ${{ github.workspace }}/mobile/maestro-out` совпадает с upload `mobile/maestro-out` и cwd гейта. Гейт rehearsal-evidence и Maestro version gate не тронуты.
- UX175 F03.A01/A02 synthetic: backend PASS нигде не заявлен, evidence несёт метку SYNTHETIC, pendingIntent не исполняется (REPLAY rc0), статус backend NOT_RUN. Дефект stale-перехода — B1.
- ПРОВОДКА: контракт потребляет действующую норму оркестратора (done_contract); новых каналов в diff нет.

## 050 — паразитная сложность (вопросы 1–5 по каждому артефакту)

- `metro.config.js` resolveRequest: (1) §Шов, alias Metro; (2) mode из env, виден в bundle_probe; (3) 2 файла (metro+jest) в паре, так требует контракт; (4) интерфейс 1 env на всю работу выбора; (5) потребитель — bundle_probe/CI. ESSENTIAL, но B3 (дефолт для release).
- `jest.config.js`: (1) §Шов «Jest выбирает те же файлы»; (2) env, явно; (3) пара с metro; (4) мелкий, но обязательный; (5) npm test. ESSENTIAL.
- `api/api-client.ts`: (1) П4.1; (2) нет; (3) 1; (4) 2 метода; (5) типы pilot-app/runtime. ESSENTIAL.
- `api/generated/api-5_8.ts`: (1) типы Session/Disclosure; (2) нет; (3) 1, но рассинхрон со схемой; (4) лишние выдуманные типы; (5) typecheck. ESSENTIAL по свойству, форма дефектна (B2).
- `auth/auth-provider.ts`: (1) порт Auth; (2) нет; (3) 1; (4) 4 метода; (5) runtime и pilot-app. ESSENTIAL (расширение типов вынуждено, S8).
- `bootstrap/runtime-contract.d.ts`, `bootstrap/http-runtime.ts`, `mocks/runtime.ts`, `mocks/demo-code.ts`, `mocks/pilot-responses.json`: (1) §Шов / инвариант 5; (2) mode-проверки в обоих runtime, явный throw; (3) 3–4 файла на свойство mode, рост по контракту; (4) по одному экспорту `runtime`; (5) bundle/runtime/schema_probe. ESSENTIAL.
- `bootstrap/pilot-app.tsx`: (1) PilotApp-шов; (2) frame/flow/поколение, состояние неполное (B1); (3) 1; (4) 3 порта; (5) frozen-тест и root. ESSENTIAL. Лишние экспорты `F02_TEST_ID`/`AuthFlowState` (S5) ACCIDENTAL, не блокируют.
- `features/auth/auth-screen.tsx`, `features/onboarding/welcome-screen.tsx`: (1) F03/F02; (2) нет; (3) 1–2; (4) props-only; (5) frozen-тест/Maestro. ESSENTIAL. `copyKey` — ACCIDENTAL (S5).
- `navigation/pending-intent.ts`: (1) pending-intent как данные; (2) нет; (3) 1; (4) `PendingIntent` используется, `NavigationEntry`/`directEntry` — нет; (5) только тип PendingIntent. Частично ACCIDENTAL (S5).
- Семья `bootstrap/__tests__/{pilot.test.tsx,source.json}`: (1) байты H; (2) нет; (3) H↔C, cmp в CI; (4) —; (5) quality. ESSENTIAL.
- mobile.yml, H checkout ×2, cmp, шаги проб: (1) §Пины; (2) каталоги `/tmp/dev-harness-verify/impl995-r-*` (hosted, эфемерные); (3) SHA пина в 2 местах; (5) CI. ESSENTIAL.
- mobile.yml, шаг «Вынести H»: (2) состояние `impl995-h-*`, только побочный эффект; более простая форма — `rm -rf`. ACCIDENTAL, совет S11 (hosted, вреда нет).
- mobile.yml, R2-копия и PRIVATE_FILE: (2) ~3.7G и файл кода, состояние видно только побочным эффектом и не удаляется. ACCIDENTAL, блокер B6.
- `.maestro/start.yaml`, `rehearsal.yaml`: (1) миграция 991; (5) cloud/android-e2e, гейт. ESSENTIAL, но B5.

## Артефакты ревью

- Репро B1: `/tmp/dev-harness-verify/rev995/rev-stale.test.tsx`. В R тест удалён, R возвращён к C (`git status --short` пуст, HEAD e883d53).
- CI-артефакты: `/tmp/dev-harness-verify/rev995/ci-artifacts/maestro-34a1b391…-39140382835-1/` (report.xml sha256 `4ac72094…`).
- Красное cmp: `/tmp/dev-harness-verify/rev995/cmpred/`.
