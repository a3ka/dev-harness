FAIL
OBJECT=90a8e7bab0419fdd37e3d81b5e5b552fe3cd2fad
МОДЕЛЬ-ФАКТ: openai-codex/gpt-6-sol; независимо от автора architect (задание). `git rev-parse HEAD HEAD^{tree}` → `90a8e7bab0419fdd37e3d81b5e5b552fe3cd2fad`, `5dd55fa9de39297292cf3502061d3c80d314c563`. Все мутации только в одноразовых копиях `Critic118v2r2/{product,harness-probe,repo}`; OBJECT не менялся.

## Блокеры — два класса

БЛОКИРУЕТ contracts/118-erstinformation.md:29-30,40,42-43 — production-критерий срока по-прежнему достаточен без fail-closed **при действии**. `sud_production_srok` ищет `Date.parse(`, `expires_at`, `Date.now()` на одной строке, даже в комментарии; проверяет имена 11 клеток в исходнике, а не их исполнение. Пин-клетка «между mount и действием» делает принудительный `view.rerender(<TabRoute />)` ПОСЛЕ истечения вместо пользовательского press БЕЗ ререндера. Render-time-допуск поэтому проходит все 11 исполняемых клеток, а просроченная Session всё равно получает Erstinformation при последующем demo press.
ОБХОД: продукт a28065655 + разрешённый expires_at=2099 во всех трёх носителях и H. В старый `onboarding-session.tsx` добавлен только комментарий `// Date.parse(expires_at) > Date.now()`, 11 настоящих тестов импортируют Root и TabRoute через `@pilot/runtime`, но весь `describe` помечен `.skip`: provenance-checker rc 0, CI-эквивалент `npm test` rc 0, **11 skipped**. При снятии `.skip` старый крючок красен: 7 failed/4 passed, в том числе expired `/start` показывает `section-start` вместо `first-run-continue`. Ещё более строгий обход БЕЗ skip: крючок проверяет `Date.parse(expires_at) > Date.now()` при каждом рендере (не при действии), checker rc 0, все 11 тестов rc 0; когда срок проходит после рендера F03 и перед `auth-demo-entry` без ререндера, одноразовая дополнительная RNTL-клетка видит `erstinfo_gate_null` вместо W0 (rc 1). ЗАКРЫВАЕТ КЛАСС: реально исполняемые обязательные клетки и пресечение допуска после истечения между последним рендером и нажатием, на действительном production Root/TabRoute, плюс невозможность green при закомментированном gate или пропущенных Jest-клетках.

БЛОКИРУЕТ contracts/118-erstinformation.md:40,59,63 — требование владельца «ТОЛЬКО session.expires_at», сохранение `auth_time` **ПОБАЙТНО**, невозможно доказать разницей объектов `json.loads`: одновременная текстовая правка auth_time без изменения декодированного значения не является дифом для `sud_odin_razreshennyj_kljuch`.
ОБХОД: в трёх носителях (H `pilot_995/source.json`, продуктовые bootstrap source и mocks) заменить байты `"auth_time": "2026-10-14T00:00:00Z"` на `"auth_time": "\\u0032026-10-14T00:00:00Z"`, оставив expires_at=2099. Декодированный auth_time прежний, но изменение запрещённого поля побайтно налицо; checker rc 0, schema 995 rc 0, frozen_matrix 995 rc 0, H/product cmp сохраняется. ЗАКРЫВАЕТ КЛАСС: байтовый диф каждого носителя относительно исходного допускает замену текстового представления ТОЛЬКО `session.expires_at`; значение JSON после парсинга не служит доказательством сохранения байтов других полей.

АРБИТР: независимый arbiter по контракту 118 v2 — второй FAIL по причинам круга 1 (production-ось срока; одно разрешённое поле). Предмет спора — достаточны ли проверки, если они пропускают render-time/skip и побайтовую правку auth_time; зелёные обходы предъявлены. Автор контракта — сторона, не судья; арбитраж не равен accept.

## Команды и сырые наблюдения атак

- `python3 /tmp/dev-harness-verify/Critic118v2r2/recheck_old.py`: скрипт rc 0, вложенная `python3 mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py --pack mobile/e2e-erstinformation --repo /tmp/dev-harness-verify/Critic118v2r2/product --harness /tmp/dev-harness-verify/Critic118v2r2/harness-probe` (old hook + теста НЕТ) **rc 1**:
```
PRICHINA	PROIZVODSTVO_BEZ_SROKA	нет Date.parse(expires_at) > Date.now() в mobile/src/app/onboarding-session.tsx
PRICHINA	SROK_TESTY_NET	mobile/src/bootstrap/__tests__/session-srok.test.tsx
```
Конкретный свидетель круга 1 теперь красен, но класс имеет другие обманные зелёные состояния.
- `python3 /tmp/dev-harness-verify/Critic118v2r2/attack_skip.py && python3 mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py --pack mobile/e2e-erstinformation --repo /tmp/dev-harness-verify/Critic118v2r2/product --harness /tmp/dev-harness-verify/Critic118v2r2/harness-probe` → rc 0:
```
ATTACK: old production hook remains; all 11 expiry tests skipped; expiry expression only in comment
```
`npm test` (cwd product/mobile) → rc 0:
```
Test Suites: 1 skipped, 10 passed, 10 of 11 total
Tests:       11 skipped, 92 passed, 103 total
```
`python3 /tmp/dev-harness-verify/Critic118v2r2/attack_unsuppress.py && npm test -- src/bootstrap/__tests__/session-srok.test.tsx` → rc 1:
```
CONTROL: same expiry tests enabled; old hook still has expiry expression only in comment
FAIL src/bootstrap/__tests__/session-srok.test.tsx
✕ srok-istekla-koren
✕ srok-istekla-start
✕ srok-rovno-sejchas
✕ srok-nerazborchivaja
✕ srok-mezhdu-mount-dejstviem
✕ srok-pustaja
✕ srok-ranishe-auth-time
Tests:       7 failed, 4 passed, 11 total
```
Полный сырой stderr: artifact://5981.
- `python3 /tmp/dev-harness-verify/Critic118v2r2/attack_render_expiry.py && npm test -- src/bootstrap/__tests__/session-srok.test.tsx` → rc 0:
```
MUTATION: expiry checked on React render, not on press/action; production route gets fixed W1A snapshot until next render
Test Suites: 1 passed, 1 total
Tests:       11 passed, 11 total
```
Та же команда checker из пункта выше → rc 0, stdout пуст. `npm test -- src/bootstrap/__tests__/critic-expiry-action.test.tsx` → rc 1:
```
FAIL src/bootstrap/__tests__/critic-expiry-action.test.tsx
✕ expired after F03 entry render, before demo press must remain W0
expect(received).toBeNull()
Received: <Text ... testID="erstinfo_gate_null">Ihre Rückmeldung nötig</Text>
Tests:       1 failed, 1 total
```
Полный сырой вывод: artifact://6018. Первый черновой запуск этой клетки без `await render` упал из-за тест-харнесса, исправлен до зачтённого замера (не засчитан как доказательство).
- `python3 /tmp/dev-harness-verify/Critic118v2r2/attack_data.py` → rc 0; вывод содержит три `ATTACK auth_time bytes changed` (harness-probe/fixtures/workshop_project/pilot_995/source.json; product/mobile/src/bootstrap/__tests__/source.json; product/mobile/src/mocks/pilot-responses.json), вложенный checker rc 0 с пустым stdout, `schema_probe.py` rc 0 `995 schema checked=2 runtime=matched`, `frozen_matrix.py` rc 0 `995 frozen checked=3`; скрипт возвращает исходные байты в finally.
- `python3 /tmp/dev-harness-verify/Critic118v2r2/attack_oracle.py` → rc 0 скрипта, вложенный `probe.py --model` rc 2:
```
ORACLE_TAMPERED: носитель nositeli/dannye/etalon_995.json
```
Эталон держит старый auth_time=expires_at=2026-10-14T00:00:00Z; дата 2099 разрешена только как diff трёх носителей. Обычная подмена одного эталона ловится, не закрывая побайтовую правку носителей.

## Остальные замеры

- `python3 fixtures/workshop_project/erstinformation_118/probe.py --model` rc 0: все 53 `CASE ... ok` + guard-shag, 16 `KADR ... 1.000 0.600 G OK`. `--stabs` rc 0: `SVJAZI 49`, 0 живых; сырые опорные строки: `STAB s48_srok_samo_forma.py production-srok-udalyon KRASEN`, `STAB s48_srok_samo_forma.py srok-testy-otsutstvujut KRASEN`, `STAB s48_srok_samo_forma.py ci-bez-srok-testov KRASEN`, `STAB s49_dannye_shiroko.py dannye-auth-time-pomenjan KRASEN`, `STAB s49_dannye_shiroko.py dannye-995-auth-time KRASEN`, `STAB s50_krjuchok_tipom.py production-srok-udalyon KRASEN`. source.json: 53 входа, 39 стабов, 49 связей (ранее 46/36/41). Привязки `stab_vhod` по коду.
- `bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh` rc 0 в этом HEAD: 53 `CASE ... ok`, guard-shag ok (шаблон уже присутствует; условие контракта «Дано: нет scripts/ekran_shablon.py» здесь не выполняется). Это НЕ доказательство продукта.
- `bash scripts/pre_critic.sh contracts/118-erstinformation.md` rc 0: `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3`, `КРИТИК: дверь зелёная`. Исправленный `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic118v2r2/repo contracts/118-erstinformation.md` rc 0, пустой вывод; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic118v2r2/repo contracts/118-erstinformation.md` rc 0 `OK`; `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic118v2r2/repo contracts/118-erstinformation.md` rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))`. Первоначально check_provodka вызван с одним аргументом: rc 1 usage, затем исправлен.
- С авторизованным одним изменением expires_at на своей H/product-копии: `runtime_probe.py` rc 0, шесть ветвей SHIPPED_INVALID/SHIPPED_VALID/DEFAULT_VALID/HTTP_UNAVAILABLE/UNKNOWN_MODE/RUNTIME_RESPONSES rc 0; `schema_probe.py` rc 0 `checked=2 runtime=matched`; `bundle_probe.py` rc 0 `http maps=1 sources=29 reasons=[]`, `mock maps=1 sources=31 reasons=[]`; `frozen_matrix.py` rc 0, два preserved=true и намеренный негатив `drift: rc=1 FROZEN_BYTES_MISMATCH`, `checked=3`. 108 `start_static_probe.py`, `start_probe.py` rc 0 `static 22/22`, `honest 336/336`; 111 `first_run_static_probe.py`, `first_run_probe.py` rc 0 `static 16/16`, `honest 23/23`. Android/Maestro не исполнялись.
- Контракт HEAD 90 строк/17261 символ/24930 байт, максимум строки 1198 байт; пин-текст `kontrakt_tekst` 33 строки/2088 символов/2246 байт, максимум 119 байт. Diff frozen 118/1→HEAD: 24 добавления/8 удалений в контракте. Тексты 995 и 108 не тронуты; зоны продукта app/bootstrap/mobile.yml/.maestro/pilot-app сверены с frozen 995/1,108/1,117/3,135/1,118/1; новый mocks назван в зоне implementer и ПЕРЕСЕЧЕНИЕ с 995, данные H меняет отдельно 995-architect. Класс риска «авторизация» + независимый adversary указан. §НЕ ЗАЩИЩАЕТ теперь явно ограничивает provenance только synthetic mock, исключает backend-авторизацию и истёкшую Session: два прежних блока закрыты.

СОВЕТ contracts/118-erstinformation.md:29-30 — 11 клеток содержат `+02:00` offset, но не отдельную клетку даты без временной зоны; задания требует рассмотреть этот класс, не называю без живого обхода ещё одним блокером.
