FAIL
OBJECT=6d17dac3774aecebb973dfc7dfcc768b26b4a86d

# Вердикт adversary — контракт 999, круг 2

## БЛОКЕР — начальное системное reduced motion игнорируется

`mobile/src/bootstrap/tab-shell.tsx:51-59` вызывает `AccessibilityInfo.isReduceMotionEnabled()` синхронно и принимает результат только если `typeof initial === 'boolean'`. В используемой версии React Native API объявлен и реализован как `isReduceMotionEnabled(): Promise<boolean>`. Поэтому настоящий начальный ответ ОС `Promise.resolve(true)` всегда сводится к `false`: после холодного запуска при включённом системном reduced motion shell показывает `shell-faden` и запускает анимацию, пока не придёт отдельное событие `reduceMotionChanged`.

**Обход:** это сам OBJECT; frozen-пробы передают порт `reducedMotion={true}` напрямую и не моделируют начальный Promise API. Поэтому `nav_probe.py` и его матрица зелёные при невыполненном требовании владельца «при системной настройке reducedMotion анимаций нет НИГДЕ».

Свой RNTL-свидетель в моём клоне подменял `AccessibilityInfo.isReduceMotionEnabled` на `Promise.resolve(true)`, монтировал `TabShell` без порта и ждал исчезновения `shell-faden`:

```text
npx jest --ci --runInBand adversary-system-reduced-motion.test.tsx
rc=1
Received: <View ... testID="shell-faden" />
```

Позитивный контроль: в том же клоне я заменил только чтение на асинхронное `AccessibilityInfo.isReduceMotionEnabled().then(setEnabled)` с прежней подпиской. Тот же свидетель стал зелёным, `rc=0`. Это доказывает, что краснота относится именно к пропущенному Promise-ответу, а не к вечно-красному свидетелю.

## Целенаправленные мутанты и положительные контроли

* **Отсутствие default-анимации (86a6b977-класс):** свидетель шпионит за `Animated.timing` при переключении вкладки без reducedMotion. На OBJECT `rc=0`. Мутант в своём клоне заменил `Animated.timing(...)` на no-op `{ start, stop }`; свидетель дал `rc=1` (`Expected number of calls: >= 1, Received: 0`). Значит default-анимация на OBJECT действительно есть и свидетель её различает.
* **Router bypass (7d35f0b2-класс):** свидетель монтирует реальные адаптеры `src/app/index.tsx` и `src/app/(tabs)/vorgaenge.tsx`, проверяя соответственно `section-start` без Back и `section-vorgaenge` с Back при `returnTo=start`. На OBJECT `rc=0`. Мутант заменил корневой маршрут на `PilotApp`; свидетель дал `rc=1`, потому что `section-start` отсутствует, а поверхность содержит `demo-indicator` и `first-run-continue`. Это закрывает именно обход «shell существует, но / его не достигает» на адаптере `/`; адаптер `/vorgaenge` передаёт `initialSection` и `returnSection`.
* Свидетель достигнутых reducedMotion-состояний на OBJECT `rc=0`: вкладки (включая выбранную), повторный вход/возврат из profile и deeplink-возврат не показывают `shell-faden`, не вызывают `Animated.timing`, а вкладки не `disabled`. Отдельно event `reduceMotionChanged(true)` убирает faden (`rc=0`). Это не исправляет блокер начального системного чтения.

## Сырые rc и прочая проверка

* `nav_probe.py --repo R` — `rc=0` (238 клеток).
* `ui_probe.py --repo R` — `rc=0` (18 клеток).
* `shell_static_probe.py --repo R` — `rc=0` (6 клеток).
* `copy_probe.py --repo R` — `rc=0` (51 клетка).
* `nav_probe.py --repo R --matrix` — `rc=0`: honest зелёный; все 20 мутантов дали named RED, `unexpected_red=none`.
* H-пин в `mobile.yml` — `c9f680b4d9fd2e7eec24524c172343a70d2d8aae`; `git ls-tree` подтвердил, что этот коммит содержит и `fixtures/workshop_project/nav_999`, и `pilot_995`. В диффе workflow сохранён `android-e2e`, а пин 995 заменён тем же H, не удалён.
* Изменённые пути OBJECT находятся в объявленной implementer-зоне.

Не запускались по ограничению: Android/Gradle, Maestro, полный CI и GitHub checks. Попытка `renderRouter` по настоящему каталогу `src/app` не дала поведенческого результата: штатный Jest config не транспилирует `expo-router` в этом тестовом окружении (`Unexpected token` при загрузке `Slot`); это не подменялось выводом о маршруте. Вместо этого выполнен приведённый выше RNTL-свидетель реальных route-адаптеров.
