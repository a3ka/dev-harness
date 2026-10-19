accept
OBJECT=504fcafb7f3871155cf2d7e297d3d766d0f098a5

# Вердикт adversary — контракт 999, круг 3

Обхода, который проходит frozen-проверки при невыполненном предмете, не найдено. Проверялись код и исполнимые пробы на отдельном клоне OBJECT; предмет и frozen-пробы не изменялись. В конце `git status --short --untracked-files=all` пуст, `git rev-parse HEAD` вывел `504fcafb7f3871155cf2d7e297d3d766d0f098a5`.

## Закрытие блока круга 2: начальное системное reduced motion

Повторён независимый RNTL-свидетель `adversary-system-reduced-motion.test.tsx` (временный, удалён после прогона). Он подменяет настоящий `AccessibilityInfo.isReduceMotionEnabled()` на `Promise<boolean>` и монтирует `TabShell` без порта `reducedMotion`.

* При `Promise.resolve(true)` отсутствует `shell-faden`; после tab, profile, обоих Back он всё ещё отсутствует, а `Animated.timing` не вызван. Это проверяет начальное чтение и все переходы, а не только статичный первый кадр.
* Позитивный контроль: до разрешения отложенного Promise `false` faden отсутствует; после разрешения появляется и `Animated.timing` вызван. Свидетель не является вечно-зелёным запретом анимации.
* Событие `reduceMotionChanged(true)` после старта с системным `false` убирает faden; все четыре вкладки остаются `disabled !== true` и последняя открывает `section-post`.

Команда на OBJECT:

```text
cd /tmp/dev-harness-verify/Adv999c/mob/mobile
npx jest --ci --runInBand adversary-system-reduced-motion.test.tsx
rc=0; 3 passed
```

Негативный контроль: вместо OBJECT временно установлен точный `tab-shell-before-system-fix.tsx` из моего репро круга 2 (синхронное игнорирование Promise). Та же команда вернула `rc=1`: `shell-faden` найден при `Promise.resolve(true)`, а контроль отложенного `false` также обнаружил преждевременный faden. После восстановления OBJECT тот же свидетель снова вернул `rc=0`. Значит закрытие относится именно к асинхронному системному чтению, не к шуму свидетеля.

## Роутинг `/` и `[section]`

Временный RNTL-свидетель с замоканным только `expo-router/useLocalSearchParams` исполнил реальные адаптеры.

```text
npx jest --ci --runInBand adversary-route-adapter.test.tsx
rc=0; 3 passed
```

Он подтвердил: `/` монтирует `PilotApp` с `first-run-continue`; `/schutz?returnTo=post` монтирует реальный shell в `section-schutz` и Back даёт `section-post`; массивные параметры берут свой первый элемент (`vorgaenge` и `start`), а не соседнее поле. Негативный контроль — временно зашитый `initialSection="start"` в реальном `[section].tsx` — дал `rc=1`, оба случая не нашли ожидаемые `section-schutz`/`section-vorgaenge`; после восстановления OBJECT свидетель снова `rc=0`.

## Frozen-пробы и матрицы

На H=`c9f680b4d9fd2e7eec24524c172343a70d2d8aae` все четыре предметные пробы зелёные:

```text
python3 nav_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob                 rc=0 (238 клеток)
python3 ui_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob                  rc=0 (18 клеток)
python3 shell_static_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob        rc=0 (6 клеток)
python3 copy_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob                rc=0 (51 клетка)
```

Матрицы исполнены именно по коду проб, с честным прогоном и всеми мутантами: `nav_probe.py --matrix` — `rc=0`, 20/20 named RED, `unexpected_red=none`; `ui_probe.py --matrix` — `rc=0`, 18/18; `shell_static_probe.py --matrix` — `rc=0`, 7/7; `copy_probe.py --matrix` — `rc=0`, 5/5. В том числе нейтрализации маршрута `profile/post/schutz`, отключение действий при reduced motion, константный неправильный return, palette/copy/font/deep-link мутанты дают именованную красноту; это не пустой вход и не ложный успех отсутствующего инструмента.

Полный scoped-набор frozen 995 на том же H зелёный (`rc=0`): `probe --check-frozen`, `runtime`, `bundle`, `schema`, `frozen_matrix`, `transport`, `admission`, `stale`, `types`, `pins`, `admission_family`, `stale_table`. Существенные строки: frozen bytes 2/2 сохранены, drift-контроль ожидаемо `rc=1 FROZEN_BYTES_MISMATCH`, `admission-family rc=0 family_size=860`, stale-table включает `VERIFY_NO_ACCESS` и все живые контроли; `types checked=2 schema=matched`.

Сырые команды frozen 995:

```text
cd /tmp/dev-harness-verify/Adv999c/h/fixtures/workshop_project/pilot_995
python3 probe.py --repo /tmp/dev-harness-verify/Adv999c/mob --check-frozen && python3 runtime_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 bundle_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 schema_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 frozen_matrix.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 transport_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 admission_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 stale_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 types_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 pins_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 admission_family_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob && python3 stale_table_probe.py --repo /tmp/dev-harness-verify/Adv999c/mob
rc=0
```

## Советы

Нет блокирующих находок в закрытой границе К1–К4 / П1–П7. Android/Gradle/Maestro и полный CI не запускались по заданному ограничению scoped-проверки.
