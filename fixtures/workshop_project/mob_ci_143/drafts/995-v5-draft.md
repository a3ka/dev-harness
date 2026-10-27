# Черновик 995 v5 — фиксированный набор P вместо всего .maestro; e2e-pilot + required-агрегат; общий APK

Контракт 143 (mob-ci-razdelenie), адресная миграция проводки. База: `frozen/contracts/995/4` (текст в main байт-равен
тегу — сверено этой пачкой). Номер версии — по РЕАКТИСТРУ заморозок (фактический frozen-тег), не по заголовку
Markdown. Черновик НЕ является правкой frozen-текста: внедряется только после строки владельца
(все девять черновиков подписываются ОДНИМ разом после merge #124); `РАЗРЕШИЛ-ВЛАДЕЛЬЦ:` архитектор не пишет —
правило 11 (Н-59).

## Дифф относительно frozen (frozen/contracts/995/4)

```diff
--- frozen:995-cmp-mob-001-android-pilot.md
+++ v+1:995-cmp-mob-001-android-pilot.md
@@ -104,9 +104,9 @@
 Quality сохраняет npm test/lint/typecheck/doctor. В `bootstrap/__tests__/pilot.test.tsx` и `source.json` лежат байты H. До npm test CI исполняет `cmp` каждой копии с соответствующим H-файлом; несовпадение останавливает job. Затем в disposable R выполняются `probe.py --check-frozen`, `runtime_probe.py`, `bundle_probe.py`, `schema_probe.py` из H (все с `--repo R`, Python requirements из H). Не переносить Python runtime_probe в mocks: он запускает Jest, а не становится production импортом. Изолированные временные test-каталоги удаляются; существующий CI-тест не перезаписывается. Сверка байтов дополнительно встроена в `--check-frozen`.
 
-Native mobile.yml вызывает из H `python3 fixtures/workshop_project/pilot_995/maestro_probe.py --repo C --apk ABS_APK --code-file PRIVATE_FILE --out C/mobile/maestro-out` вместо прямого ci-e2e. Runner снимает script/legacy flow bytes до исполнения, вызывает существующий ci-e2e в приватном cwd с абсолютным APK и frozen pilot.yaml; script управляет эмулятором, отдельный вызов после его завершения недопустим. В checkout публикуется только redacted maestro-out, затем неизменный rehearsal-evidence gate/upload. PRIVATE_FILE вне checkout/artifacts; output path новый. `native_matrix.py --scratch SCRATCH` → rc0 только при совпадении ROWS/redaction; синтетические APK/PNG не Android evidence.
+Native (v5, 143) задача e2e-pilot вызывает из H `python3 fixtures/workshop_project/pilot_995/maestro_probe.py --repo C --apk ABS_APK --code-file PRIVATE_FILE --out C/mobile/maestro-out` вместо прямого ci-e2e; APK — ОБЩИЙ артефакт единственной сборки build-apk (digest сверен до установки). Runner снимает script и РОВНО фиксированный набор P (pilot.yaml + start.yaml + rehearsal.yaml + cmp-mob-002-tabs.yaml) до исполнения — копирование всего каталога .maestro прекращается (erstinformation/first-run-ekran/vkhod-117-splash/cmp-mob-004-start — задачи своих экранов); вызывает существующий ci-e2e в приватном cwd с абсолютным APK и frozen pilot.yaml; script управляет эмулятором, отдельный вызов после его завершения недопустим. В checkout публикуется только redacted maestro-out, затем неизменный rehearsal-evidence gate/upload. PRIVATE_FILE вне checkout/artifacts; output path новый. `native_matrix.py --scratch SCRATCH` → rc0 только при совпадении ROWS/redaction; синтетические APK/PNG не Android evidence.
 
 Frozen pilot.yaml живёт в H, НЕ в публичной mobile/.maestro: cloud продолжает общие start/rehearsal без кода; полная pilot-проверка — mobile.yml. **Миграция 991:** start.yaml проверяет First-Run/start.png. rehearsal.yaml сохраняет имя testcase и rehearsal-before/after PNG, но действие — First-Run→e-mail→demo-entry→F03.02; после restart незавершённый challenge возвращается к auth-email через First-Run, если показан. Before — до действия, after — после confirmed begin. Pilot отдельно проверяет неверный/успешный код и безопасный restart; bypass route IDs не вводятся.
 
-Без правок остаются component RNTL `features/start/__tests__/start-screen.test.tsx` и `rehearsal.test.tsx`, quality/android-e2e jobs, Maestro version gate, scripts/rehearsal-evidence.sh в обоих workflows; mobile-cloud-e2e не меняется. Дано C; scoped Jest этих component tests + все Maestro flows и rehearsal-evidence gate → rc0; нет rehearsal testcase/PNG → отказ существующего гейта. История 991 не переписывается. Actual C — NOT_RUN.
+Без правок остаются component RNTL `features/start/__tests__/start-screen.test.tsx` и `rehearsal.test.tsx`, quality и required-агрегат android-e2e (143: e2e-pilot входит в needs агрегата), Maestro version gate, scripts/rehearsal-evidence.sh; mobile-cloud-e2e не меняется. Дано C; scoped Jest этих component tests + все Maestro flows и rehearsal-evidence gate → rc0; нет rehearsal testcase/PNG → отказ существующего гейта. История 991 не переписывается. Actual C — NOT_RUN.
 
 Splash/First-Run, визуальное сходство с D2.2.5.1 и немецкий copy — **cognitive-only**: остаточный риск кратковременного/визуального дефекта вне assertions, reviewer сверяет источник и PNG/нативный запуск. Copy signoff остаётся владельцу. RNTL-модель визуальной приёмкой не является.
```

## Изменяемая / сохраняемая норма / красное свидетельство

| Изменяемая норма | Сохраняемая норма | Красное свидетельство |
|---|---|---|
| P копирует весь .maestro (rglob) → фиксированный набор P (4 записи из manifest); шаг runner → задача e2e-pilot + required-агрегат; APK задачи → общий артефакт build-apk с digest | S байт-канон (owned-restart, redaction, публикация живым деревом; байты 0fa425b5… НЕ меняются), пробы, rehearsal/version gate, schema/runtime/bundle — дословно | батарея 143 f01/f02 (P-набор замкнут, двойное владение), s03/s04 (инвентарь), a10/a11 (digest), p01 (ИСПОЛНИТЕЛЬНЫЙ replay набора — после перепина), a17 (digest до установки) |

## ТОЧНАЯ зависимость (блокер 2 критика 143 v1): предшественник cutover 143

Критик 143 v1 показал: F01/F02 судят JSON-КАРТУ, а ИСПОЛНИМЫЙ путь остался общим —
`maestro_probe.py:82-83` (пин 66052cdf) делает rglob всего `mobile/.maestro`, живой
`ci-e2e.sh:168-169` исполняет `maestro test .maestro`; зона implementer 143 НЕ содержит
`maestro_probe.py` ⇒ сужение исполняемого набора — ПРАВКА ЗОНЫ 995, оформлена этой
зависимостью. 995 v5 — ПРЕДШЕСТВЕННИК cutover 143; до его заморозки клетка p01 батареи
143 ОТЛОЖЕНА (NEEDS_PRECEDENT, не зелёная и не красная — место именовано).

Что МЕНЯЕТСЯ в P (зона 995, файл `fixtures/workshop_project/pilot_995/maestro_probe.py`):
1. Источник набора — manifest продукта: P читает `mobile/ci-screens.json` из `--repo`
   и берёт `integracija.fiksirovannyj_nabor` (единственный источник, И-1 контракта 143).
2. Копирование: вместо `rglob('*')` всего каталога P копирует в приватный cwd РОВНО
   флоу из этого перечня, НАЙДЕННЫЕ в `mobile/.maestro`, плюс `mobile/.maestro/config.yaml`
   (пин происхождения 118 — не меняется) и свой `pilot.yaml` из HERE. Отсутствие
   перечисленного флоу в репо продукта — именованный отказ (`FIKSIROVANNYJ_NABOR_NEPOLEN`),
   не тихое сужение.
3. Схема карты: P отвергает карту без `integracija.fiksirovannyj_nabor` (`SKHEMA_KARTY`),
   чтобы набор не мог стать пустым «успехом».

Что НЕ меняется в S: `mobile/scripts/ci-e2e.sh` — байты 995 v4 (sha256
`0fa425b5db4752633c7ea453065503bfa8ecefa67e1bef8a7e66102426897f30`) остаются каноном:
S по-прежнему исполняет `maestro test .maestro` — но `.maestro` в приватном cwd P теперь
содержит ТОЛЬКО фиксированный набор (+config.yaml), набор сужается на стороне P без
правки S. owned-restart, redaction, публикация живым деревом — не тронуты.

Клетки батареи 995: НОВАЯ исполнительная клетка — replay P (копия P + sandbox
`.maestro` со флоу всех экранов + подложный maestro, логирующий argv): Maestro
запрошен РОВНО фиксированный набор (4 флоу, каждый раз), config.yaml флоу не
назначается; негативные входы: нет перечня в карте → `SKHEMA_KARTY`, нет флоу
перечня в репо → `FIKSIROVANNYJ_NABOR_NEPOLEN`. Существующие клетки 995 не меняются.

Новый H-пин: freeze 995/5 → новый SHA харнесса, несущий новый P → workflow
продукта перепинивает H native-шага (в DAG 143 — checkout `.harness`
задачи e2e-pilot; качество остаётся на своём пине проб) → в пачке 143: модель
`mobile.yml` перепиняет тот же ref, носители батареи `nositeli/p-66052cdf.py` →
новые байты P (+пин source.json; `nositeli/ci-e2e-995-4.sh` не меняется), клетка
p01 АКТИВИРУЕТСЯ и обязана ЗЕЛЕНЕТЬ; красная p01 после перепина — стоп cutover.
Стаб `stab_p_rglob_kataloga` (перепин + старый rglob-P) доказывает сегодня, что
активированная p01 ловит rglob — барьер работает, а не заглушка.

ПРОВЕРКА ЖИВЬЁМ (сделана пачкой 143 v2): replay цепочки P(66052cdf)→S(0fa425b5)→
подложный maestro в замкнутом PATH — Maestro запрошен ВСЕ 8 флоу (весь каталог),
т.е. краснота p01 реальна, а не гипотетична; замер в §Сдаче контракта 143.

ОЖИДАЕТСЯ-СЛОВО-ВЛАДЕЛЬЦА: contracts/995-cmp-mob-001-android-pilot.md v5 — P (maestro_probe.py) копирует фиксированный набор P — pilot.yaml, start.yaml, rehearsal.yaml, cmp-mob-002-tabs.yaml — вместо всего каталога .maestro; runtime evidence 995 исполняется задачей e2e-pilot под required-агрегатом android-e2e с общим APK сборки (контракт 143 mob-ci-razdelenie); S, owned-restart, redaction и rehearsal-гейт не меняются.
