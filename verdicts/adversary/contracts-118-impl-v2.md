FAIL
OBJECT=9c1aeea57cb441e2904436ca6daf5158c7acc122

# Вердикт adversary — реализация 118, круг 2

## Основание FAIL

**Блокеров: 1.** B1 не закрыт: production-маршрут `/start` выдаёт TabShell
для **просроченной** формально корректной `Session`. Это состояние прямо
покрывается закрытым заданием как `stale`: все шесть обязательных полей
`Session` присутствуют, `principal_ref` непуст, но `expires_at` находится в
прошлом. `isSessionPayload()` проверяет лишь типы/непустой `principal_ref`,
а `useOnboardingSession()` превращает любой такой fulfilled payload в W1A.
`(tabs)/[section].tsx` при W1A монтирует `TabShell` до любого пути
First-Run → demo → Erstinformation → continue.

**Названный обход (блокирует):** пользователь с истёкшей сессией открывает
production Expo Router `/start`. `getSession()` возвращает:

```ts
{
  principal_ref: 'expired-principal',
  display_name: 'Expired',
  auth_time: '2000-01-01T00:00:00Z',
  expires_at: '2000-01-01T00:01:00Z',
  locale: 'de-DE',
  disclosure_requirements: [],
}
```

Вместо First-Run без Start фактически монтируются `shell-safe-area`,
`section-start` и `start-screen`. Независимая атакующая проба требовала
`first-run-continue` и отсутствие `start_tabs`; она красная:

```text
FAIL src/bootstrap/__tests__/adversary-expired-session.test.tsx
✕ B1 attack: expired formal Session must not authorize direct /start
Unable to find an element with testID: first-run-continue
...
testID="section-start"
testID="start-screen"
```

Это не «чужой demo-context» как недоказуемая семантика: истекший
`expires_at` — наблюдаемое не-W1A/stale состояние того же контракта
`Session`, в котором критерий допуска к Start выполнен ошибочно.

## B1–B3

| Блокер | Статус | Подтверждение |
|---|---|---|
| B1: `(tabs)/[section]` не обходит допуск | **НЕ ЗАКРЫТ** | Истёкшая формально валидная Session → `/start` монтирует TabShell (названный обход выше). Остальные атакованные malformed/refused состояния закрыты. |
| B2: fulfilled пустой/мусорный session fail-closed | закрыт | `isSessionPayload()` требует все 6 полей и непустой `principal_ref`; самостоятельная RNTL-батарея из 6 payload дала W0/First-Run без Start. |
| B3: `!erstinformation.yaml` ловится provenance-проверкой | закрыт | После удаления строки проверка вернула rc=1 с `CONFIG_BEZ_ISKLJUCHENIJA`; честный контроль с абсолютным `--repo` — rc=0. |

### Граница «формально все шесть полей, но чужой demo-context»

Совет, не самостоятельный второй блокер: тип `Session` не содержит
provenance/demo/admission claim. Поэтому фальшивый payload со всеми шестью
полями неотличим от разрешённого demo payload на данном шве. Однако истёкшая
сессия уже даёт конкретное отличимое неразрешённое состояние (`expires_at` в
прошлом) и блокирует B1.

## Мутации круга 1

| Мутация | Результат |
|---|---|
| W0/current принудительно ведёт к Start | красный, rc=1 |
| stale трактуется как current | красный, rc=1 |
| continue пропускает null | красный, rc=1 |
| admission кэшируется на mount | красный, rc=1 |
| `entry.onboarding=complete` становится источником допуска | красный, rc=1 |
| `authenticated:true` становится источником допуска | красный, rc=1 |
| demo-различитель инвертирован | красный, rc=1 |
| `onIdentityInput` не вызывается | красный, rc=1 |
| `onIdentityInput` получает устаревший e-mail | красный, rc=1 |
| W1A зашит в `app/index.tsx` | красный, rc=1 |
| Г0 F03 сломан (`paddingTop: 48 → 0`) | красный, rc=1 |
| remount `completed-entry` ведёт в Start | красный, rc=1 |
| из config удалено `!erstinformation.yaml` | красный, rc=1 `CONFIG_BEZ_ISKLJUCHENIJA` |

Сырой итог 12 кодовых мутаций:

```text
w0_start RED rc=1
stale_as_current RED rc=1
continue_null RED rc=1
cached_admission RED rc=1
entry_source RED rc=1
authenticated_source RED rc=1
demo_inverted RED rc=1
identity_omitted RED rc=1
identity_stale RED rc=1
literal_root RED rc=1
g0_broken RED rc=1
remount_start RED rc=1
session_any_fulfilled RED rc=1
```

## Дополнительные B1/B2 атаки

Маршрутная батарея (11/11) проверила: `start` + rejected,
`vorgaenge` + null, `schutz` + `{}`, `post` + мусор, массив section;
а также `start/`, `START`, `(tabs)/start`, `start?x=1`, `start#hash` и
unknown segment. Во всех этих случаях TabShell не смонтирован. Это не
отменяет найденный expired-session обход.

B2-батарея (6/6) подтвердила W0/First-Run без Start для:
`undefined`, `null`, `{}`, `{musor:'x'}`, частичного payload с 5 из 6
обязательных полей и `principal_ref: ''`.

## Позитивные контроли, регресс и замеры

Исполнено на disposable-копии; временные атакующие тесты и мутационные
скрипты удалены после замеров, изменённые продуктовые файлы побайтно
сверены с исходной копией.

```text
npx jest start-route-dopusk root-session kompozicija --runInBand
PASS 3 suites, 45 tests

npm test -- --runInBand
Test Suites: 10 passed, 10 total
Tests:       92 passed, 92 total

npm run typecheck
> tsc --noEmit
rc=0

CI-конфигурация lint (пачки/stand-in/.harness вынесены как в workflow)
> node scripts/check-structure.cjs && eslint . --max-warnings=0
structure: OK (repository inventory; external trees excluded)
rc=0

118 H=/tmp/dev-harness-verify/Impl118m/h118
red_erstinformation_118.sh --model
rc=0; CASE chestnyj-ekran ok; 16 KADR, каждый 1.000 >= 0.600
red_erstinformation_118.sh --stabs
rc=0; s43_config_propuskaet.py ... KRASEN; SVJAZI 37

честная product provenance-проверка (абсолютный --repo)
rc=0

мутация удаления !erstinformation.yaml
PRICHINA CONFIG_BEZ_ISKLJUCHENIJA mobile/.maestro/config.yaml без !erstinformation.yaml
rc=1
```

Проверка абсолютного `--repo` соответствует workflow: он намеренно передаёт
`$PWD`, поскольку checker запускает stand-in с `cwd=repo/mobile`; его
документированный комментарий фиксирует, что относительный `--repo .`
даёт rc=127. Это fail-closed шум, не обход B3.

`git diff --stat origin/main..OBJECT`: 32 files, `+7540/-19`; все имена в
зоне implementer 118. Для `.github/workflows/mobile.yml` наблюдалось
`120 insertions(+), 1 deletion(-)`: deletion только заменяет описание шага
выноса пачек, добавлены вынос 118 и новый шаг 118; шаги 107/117 не
переписаны.
