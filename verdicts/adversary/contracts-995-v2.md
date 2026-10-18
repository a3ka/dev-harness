FAIL

# 995 adversary, круг 2 — новый обход допуска

OBJECT: `807e390f4384ff3fe7a6976615533e51e0077ffb`.

Проверяемый H клонирован на SHA `7043023712f55adaef8be990e9af88173baa149a`. SHA-256 frozen `pilot.yaml`, `pilot.test.tsx`, `source.json` в main и этом H соответственно равны: `3cda11a94ba324fd55cdb9fad039935dbbb1cad8a7719e42aa03c4ff66977e1a`, `1ddc77acc690f30b903b7ef90443ef8f40ec679742e788d9949c9b8099bfe866`, `527da5c11f4d81d96045affd0dcd3c945ccf65240b52bf6930d2992a0685c1da`.

## Контроль находки круга 1 закрыт

Одноразовый мутант `/tmp/dev-harness-verify/adv995r2/mut-backdoor` (копия OBJECT, отдельный `npm ci --no-audit --no-fund` rc0) снова добавил только второй ASCII-допуск `adversary-bypass-code` в `mocks/runtime.ts`. Новый `admission_probe.py --case ADMISSION_FOREIGN_CONSTANT` на нём дал rc1: вместо `auth-invalid` фактически виден `F02.01`. На честном OBJECT этот case был rc0 как часть полного admission-прогона ниже. Значит admission-probe действительно закрывает прежнюю константную лазейку, а не вечно-красен.

## Блокер: U+200B-вариант единственной credential открывает F02.01

Одноразовый мутант: `/tmp/dev-harness-verify/adv995r2/mut-unicode`, копия ровно OBJECT с отдельным `npm ci --no-audit --no-fund` (rc0). Единственное смысловое изменение в `mobile/src/mocks/runtime.ts`: `verify` принимает не только `code === PILOT_DEMO_CODE`, но и `code === `${PILOT_DEMO_CODE}\u200B``. Второе значение отличается хвостовым ZERO WIDTH SPACE, поэтому это неверный код по П2/F03.V01, но он создаёт authenticated-сессию и авторизованный переход F02.01.

Независимый throwaway RNTL-тест загрузил настоящий `src/app/index.tsx` без DI, прошёл First-Run → e-mail → code и ввёл `PILOT_DEMO_CODE + U+200B`. Ожидание `auth-invalid`/отсутствия `F02.01` упало: фактическое дерево содержит `testID="F02.01"` и не содержит `auth-invalid` (Jest rc1). Тест удалён после прогона; мутант сохранён для воспроизведения.

При этом полный запускаемый quality-поднабор нового H на том же неправильном мутанте завершился rc0:

```sh
python3 H/fixtures/workshop_project/pilot_995/probe.py --repo R --check-frozen
python3 H/fixtures/workshop_project/pilot_995/runtime_probe.py --repo R
python3 H/fixtures/workshop_project/pilot_995/bundle_probe.py --repo R
python3 H/fixtures/workshop_project/pilot_995/schema_probe.py --repo R
python3 H/fixtures/workshop_project/pilot_995/frozen_matrix.py --repo R
python3 H/fixtures/workshop_project/pilot_995/transport_probe.py --repo R
python3 H/fixtures/workshop_project/pilot_995/admission_probe.py --repo R
python3 H/fixtures/workshop_project/pilot_995/stale_probe.py --repo R
python3 H/fixtures/workshop_project/pilot_995/types_probe.py --repo R
python3 H/fixtures/workshop_project/pilot_995/pins_probe.py --repo R
```

Наблюдённые итоги: `probe` actual 14 assertions rc0; `runtime` все 6 cases rc0; `bundle` http/mock rc0; `schema checked=2 runtime=matched`; `frozen checked=3`; `transport` rc0; четыре `admission` cases rc0; два `stale` cases rc0; `types checked=2`; оба `pins` rc0.

Также мутант был собран в release APK c `EXPO_PUBLIC_API_MODE=mock`, station SDK и `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`: Gradle `assembleRelease` rc0, SHA-256 APK `4b32192d1748620b9cd90d33611e3a84784896b373ef30b34ef372f606d8c923`. Затем реальный frozen runner выполнен через `sg kvm -c ... maestro_probe.py --repo mut-unicode --apk app-release.apk ...`; наблюдённый результат: `995 native rc=0 testcases=3 failed=0`. Следовательно, и Android/Maestro-барьер остаётся зелёным на реализации с неправильным допуском: frozen flow подаёт только известный ASCII-неверный код, не U+200B-вариант.

Почему это ложная зелень: новые `admission_probe`/`admission.test.tsx` покрывают только foreign ASCII constant, пустую строку, ASCII-префикс и верхний регистр. `runtime.test.tsx` покрывает только demo-code с ASCII `-invalid`, а native frozen flow — другой ASCII-неверный код. Ни одна executable probe не проверяет допустимость невидимого Unicode suffix/prefix/normalization variant. Поэтому тесты доказывают набор частных отказов, но не инвариант `authenticated iff code === PILOT_DEMO_CODE`.

Требуемая правка автора: обобщить проверку допуска до отрицательных credential, которые не являются только заранее известными ASCII-строками — как минимум U+200B suffix/prefix и Unicode-normalization/control variants — в shipped route и native-flow доказательстве. После исправления этот мутант обязан краснеть ровно на admission/negative-auth evidence.

## Позитивный контроль

Честная копия OBJECT `/tmp/dev-harness-verify/adv995r2/honest` после отдельного `npm ci --no-audit --no-fund` прошла тот же полный список десяти H-команд rc0. Тот же независимый RNTL-сценарий с хвостовым U+200B на честном runtime прошёл: `auth-invalid` видим, `F02.01` отсутствует (Jest rc0). Значит это не вечно-красная проверка и не ошибка самой RNTL-постановки.

## Обязательные дополнительные атаки

- **Отказ/инструмент мимо PATH:** `PATH=/usr/bin python3 H/.../maestro_probe.py --device absent-device ...` дал `995 INFRASTRUCTURE: FileNotFoundError`, rc2, а не зелень.
- **Пустой вход:** `maestro_probe.py` с пустым `--code-file` дал `995 INFRASTRUCTURE: RuntimeError`, rc2, а не «нарушений нет».
- **Нейтрализация native evidence:** `native_matrix.py --scratch /tmp/dev-harness-verify/adv995r2` rc0, checked=16. Контроли failed/skipped/missing-png/nonzero дали rc1; missing-report/empty/malformed дали rc2; честные device/ci-сценарии rc0.
- **Правильный ответ на другой вопрос:** `schema_probe` на мутанте подтвердил равенство живых Session/Disclosure fixture (`runtime=matched`), но это не наблюдает предикат `verify`, где расположен обход.
- **Кеш/перезапуск:** статический поиск `AsyncStorage|localStorage|SecureStore|persist|sessionStorage` в shipped `mobile/src` не нашёл пути сохранения сессии; frozen native flow всё равно отдельно проверяет restart. Это не источник данной находки.
- **HTTP/mock release seam и env:** `bundle_probe` на мутанте дал rc0 в http и mock; в shipped source HTTP runtime не импортирует mocks, а runtime не читает `PILOT_DEMO_CODE` из окружения. Эти классы обхода не обнаружены.

Private code files и throwaway RNTL-файлы удалены после прогона. Мутанты остаются исключительно в `/tmp/dev-harness-verify/adv995r2/` для воспроизведения.