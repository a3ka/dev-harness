FAIL

OBJECT=e883d533084099f3abd9472fa2206575188a0030
H=f70b43e4e8b2a2b3115f0abda0a34742a9450740

## Блокер: неверный код открывает F02.01, хотя весь H зелёный

Построен одноразовый мутант `/tmp/dev-harness-verify/adv995/mut-backdoor` из снимка C. Единственное содержательное изменение — в `mobile/src/mocks/runtime.ts` проверка стала:

```ts
if (code === PILOT_DEMO_CODE || code === 'adversary-bypass-code') {
  return { status: 'authenticated', evidence: 'SYNTHETIC' };
}
```

`adversary-bypass-code` не равен shipped `PILOT_DEMO_CODE` (`synthetic-verification-value`), но открывает F02.01. Это прямое нарушение П2/F03.V01: неверный код создаёт сессию и авторизованный переход.

Воспроизведение ложной зелени:

1. В мутанте `npm ci --no-audit --no-fund` завершился rc0.
2. На том же мутанте следующий полный scoped-набор H завершился rc0:

```sh
python3 fixtures/workshop_project/pilot_995/probe.py --repo /tmp/dev-harness-verify/adv995/mut-backdoor --check-frozen
python3 fixtures/workshop_project/pilot_995/runtime_probe.py --repo /tmp/dev-harness-verify/adv995/mut-backdoor
python3 fixtures/workshop_project/pilot_995/bundle_probe.py --repo /tmp/dev-harness-verify/adv995/mut-backdoor
python3 fixtures/workshop_project/pilot_995/schema_probe.py --repo /tmp/dev-harness-verify/adv995/mut-backdoor
python3 fixtures/workshop_project/pilot_995/frozen_matrix.py --repo /tmp/dev-harness-verify/adv995/mut-backdoor
python3 fixtures/workshop_project/pilot_995/transport_probe.py --repo /tmp/dev-harness-verify/adv995/mut-backdoor
```

Наблюдённые ключевые строки: `probe.py` — все 14 `actual/*` rc=0; `runtime_probe.py` — все шесть actual cases rc=0; bundle http/mock rc=0; `schema checked=2 runtime=matched`; frozen checked=3; transport rc=0.

3. Мутант собран в release APK (`assembleRelease`, rc0), затем настоящий Android/Maestro прогон H также зелёный:

```sh
sg kvm -c '... python3 /home/harness/dev-harness/fixtures/workshop_project/pilot_995/maestro_probe.py \
  --repo /tmp/dev-harness-verify/adv995/mut-backdoor \
  --apk /tmp/dev-harness-verify/adv995/mut-backdoor/mobile/android/app/build/outputs/apk/release/app-release.apk \
  --code-file /tmp/dev-harness-verify/diag995/code \
  --out /tmp/dev-harness-verify/adv995/native-backdoor'
```

Фактический вывод: `995 native rc=0 testcases=3 failed=0`.

4. Независимый throwaway RNTL-тест реально ввёл `adversary-bypass-code` в shipped root route и получил `F02.01` (`PASS`, 1 test). Тест удалён после прогона; мутант сохранён для воспроизведения.

Причина пробоя: оба отрицательных проверки используют только один конкретный неверный литерал: `not-the-demo-value` в `runtime.test.tsx` и `definitely-wrong-000` в frozen `pilot.yaml`. `pilot.test.tsx` также проверяет один `not-the-demo-value`. Они доказывают отказ на этих значениях, но не инвариант «аутентификация iff code === PILOT_DEMO_CODE». `schema_probe`, `bundle_probe`, `frozen_matrix` и `transport_probe` этот предикат не наблюдают. Мутант одновременно проходит release-бандл и реальный Maestro, поэтому это не Jest-only обход.

Требуемая правка автора: добавить независимый отрицательный код (лучше несколько, включая непредусмотренную константу) в shipped-runtime и native-flow доказательство либо иначе проверить единственность допуска. Нынешняя проверка не должна быть принята как доказательство F03.V01.

## Позитивный контроль

Немутировавший C скопирован в `/tmp/dev-harness-verify/adv995/honest`; после `npm ci` тот же scoped-набор шести H-команд выше завершился rc0. Следовательно, барьеры не вечно-красные; находка — именно ложная зелень для неправильного поведения.

## Обязательные дополнительные атаки

- Отказ, выглядящий успехом / инструмент мимо PATH: `PATH=/usr/bin python3 maestro_probe.py --device absent-device ...` дал `995 INFRASTRUCTURE: FileNotFoundError`, rc2; отсутствие Maestro не засчитано успехом.
- Пустой вход: `maestro_probe.py` с пустым `--code-file` дал `995 INFRASTRUCTURE: RuntimeError`, rc2; пустой код не засчитан успехом.
- Нейтрализация native evidence: `native_matrix.py --scratch /tmp/dev-harness-verify/adv995` rc0, checked=16. Контроли failed/skipped/missing-png/nonzero дали rc1, а missing-report/empty/malformed — rc2; честный сценарий — rc0.
- Правильный ответ не на тот вопрос: `schema_probe` в actual-наборе проверил совпадение реально возвращаемых Session/Disclosure со frozen значениями (`runtime=matched`). Это не ловит backdoor в AuthProvider, поскольку он находится до этих полей.
- Зашитая константа: найденный обход именно добавляет вторую зашитую разрешающую константу; H не различает её от единственного разрешённого кода.

## Frozen integrity

Проверены SHA-256 `pilot.yaml`, `pilot.test.tsx`, `source.json` в текущем H, `/tmp/dev-harness-verify/impl995pf/H` и `/tmp/dev-harness-verify/arch995e/clone`: для каждого файла три значения совпали. Соответственно обход не использует замену frozen artifacts.
