FAIL
OBJECT=c56c2c584ef58511a6d9f188ef547c3923f75cce

# Вердикт adversary — реализация 118

## Основание FAIL

Найдены три наблюдаемых обхода допуска/проверки.

1. **`/start` обходит First-Run → demo → Erstinformation → continue.**
   `mobile/src/app/(tabs)/[section].tsx` — production Expo Router route: он принимает
   `section` из URL, сразу рендерит `TabShell initialSection={start}`, не импортирует
   `onboarding-session` и не читает admission/gate. Поэтому открытие `/start` (а также
   табов) даёт Start вне единственного допускаемого пути. Это противоречит замороженной
   семантике 117/118: начальный кадр — First-Run, Start — только после continue при
   `W1A ∧ current`; Scope прямо требует атаковать прямые маршруты.

   **Названный обход:** пользователь с W0, stale/null либо вообще без сессии открывает
   expo-router `/start`; вместо запрета видит production TabShell. Положительный
   контроль существующего route-раннера подтвердил, что direct route реально монтируется:
   `ROUTE_ENTRY_DIRECT_ROUNDTRIP`, `ROUTE_MOUNT_MISSIONS_FROM_RUNTIME`, итог
   `honest 336/336`. Ни composition-проба 118, ни Maestro-flow 118 этот route не
   открывают с W0/null/stale.

2. **Пустой/мусорный успешно завершившийся `getSession()` выдаёт W1A.**
   `useOnboardingSession()` не читает результат `getSession()`: любое fulfilled Promise
   выставляет `read='present'`, после чего пустая identity превращается в
   `DEMO_SESSION_ADMISSION = 'W1A'`. Отказ Promise корректно закрыт в W0, но
   fulfilled `undefined`/`{}` не закрыт.

   **Названный обход:** транспорт/адаптер возвращает пустой или некорректный session
   payload без rejection; пользователь не вводит e-mail, жмёт demo и получает W1A
   вместо fail-closed W0. Одноразовая RNTL-атака на настоящий hook с
   `getSession: async () => undefined` ожидала W0 и наблюдала W1A:

   ```text
   Expected: {"admission": "W0"}
   Received: {"admission": "W1A"}
   ```

   Этот вход указан в Scope («getSession отказ/пусто/мусор»), но его нет в
   `root-session.test.tsx`, `kompozicija.probe.test.tsx` и батарее 118.

3. **Батарея 118 не замечает снятие исключения `erstinformation.yaml` из общего
   Maestro-прогона.** Требуемая изоляция задаётся единственной строкой
   `!erstinformation.yaml` в `mobile/.maestro/config.yaml`. После удаления этой строки
   `proverka_proiskhozdenija.py` вернула rc=0 без вывода: проверка происхождения не
   читает config. При этом config с `flows: ['*']` включает сценарий в общий прогон,
   хотя контракт требует исключение из-за недетерминированного порядка каталога.

   **Названный обход:** убрать `!erstinformation.yaml`; формальный 118 provenance-gate
   остаётся зелёным, хотя обязательное исключение из общего `maestro test .maestro`
   больше не сделано. Эмулятор по ограничению задания отсутствует, поэтому реальный
   Maestro не запускался; зелёная статическая проверка наблюдена.

Все три находки блокируют: первая и вторая дают доступ к защищаемой Start-поверхности
при неразрешённом состоянии, третья оставляет обязательную CI-изоляцию без ловца.

## Промежуточный отчёт (в составе сдачи)

Построены positive controls и 13 мутаций. До новых атак 12 из 13 red; единственная
зелёная — снятие config-исключения. После атаки malformed session обнаружен второй
допусковой обход; затем проверены регрессии и точные pinned probes.

## Мутации

| Мутация | Результат | Чем наблюдалось |
|---|---|---|
| W0/current принудительно становится W1A/Start | красный, rc=1 | `kompozicija.probe.test.tsx` |
| stale трактуется как current | красный, rc=1 | `kompozicija.probe.test.tsx` |
| continue пропускает null/stale | красный, rc=1 | `kompozicija.probe.test.tsx` |
| кэш admission на mount | красный, rc=1 | `kompozicija.probe.test.tsx` |
| `entry.onboarding=complete` — источник admission | красный, rc=1 | `kompozicija.probe.test.tsx` |
| `authenticated:true` — источник admission | красный, rc=1 | `kompozicija.probe.test.tsx` |
| demo-различитель инвертирован | красный, rc=1 | `root-session.test.tsx` |
| `onIdentityInput` не вызывается | красный, rc=1 | `root-session.test.tsx` |
| `onIdentityInput` получает устаревший e-mail | красный, rc=1 | `root-session.test.tsx` |
| W1A зашит в `app/index.tsx` | красный, rc=1 | `root-session.test.tsx` |
| Г0 F03 сломан (paddingTop 48→0) | красный, rc=1 | `kompozicija.probe.test.tsx` |
| remount completed-entry ведёт в Start | красный, rc=1 | `kompozicija.probe.test.tsx` |
| снят `!erstinformation.yaml` | **зелёный, rc=0** | `proverka_proiskhozdenija.py` — обход №3 |

Сырой итог прогона мутаций:

```text
w0_current_start RED rc=1
stale_as_current RED rc=1
continue_null_stale RED rc=1
cached_admission RED rc=1
entry_as_admission RED rc=1
authenticated_as_admission RED rc=1
demo_admission_inverted RED rc=1
identity_callback_omitted RED rc=1
identity_callback_stale RED rc=1
literal_admission_root RED rc=1
g0_broken RED rc=1
remount_completed_start RED rc=1
maestro_flow_in_general_run GREEN rc=0
```

## Позитивные контроли и регрессии

Сырые результаты исполненных проверок:

```text
npx jest src/bootstrap/__tests__/kompozicija.probe.test.tsx \
  src/bootstrap/__tests__/root-session.test.tsx --runInBand
PASS 2 suites, 36 tests

npm test -- --runInBand
Test Suites: 9 passed, 9 total
Tests:       83 passed, 83 total

npm run lint  (после того же временного выноса .harness, 135/118 packs и stand-in,
как в CI)
structure: OK (repository inventory; external trees excluded)

npm run typecheck
rc=0

995 probe.py --check-frozen
995 runs=1 mismatches=0

999 nav/ui/shell_static/copy probes
rc=0; shell static: 6/6; ui: 18/18

108 start_static_probe.py
static 22/22
108 start_probe.py
honest 336/336

111 first_run_static_probe.py / first_run_probe.py
static 16/16
honest 23/23

117 (exact pin 8d3f48b886b180689114f15bc90c8d13bcd8480f)
static 40/40
behavioral 26/26

118 H=1cee32c349c680e41d248977e53e4711ca97f444
--model: rc=0; 16 KADR, each 1.000 >= 0.600
--stabs: rc=0; SVJAZI 36
proverka_proiskhozdenija.py: rc=0
```

`git diff --unified=0 origin/main..OBJECT -- .github/workflows/mobile.yml`
наблюдал: `115 insertions(+), 1 deletion(-)`; единственная deletion — замена строки
выноса пачек, сам шаги 107/117 не переписаны.

Визуальный/эмуляторный smoke не выполнялся: по ограничению задания эмулятора нет;
приведённый зелёный Android CI run 40163830207 остаётся внешним свидетельством.
