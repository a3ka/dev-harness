accept
OBJECT=db46d607001e212b2584e78b6907af1bd7c787b4

# Reviewer, микро-круг 999 (CMP-MOB-002), C′ — судья Rev999d

База сравнения: 504fcafb7f3871155cf2d7e297d3d766d0f098a5. Харнесс H: c9f680b4d9fd2e7eec24524c172343a70d2d8aae.
Проверял только то, что входит в Scope: (1) дифф, (2) закрытие Н8, (3) зону. Прочее из accept круга 3 заново не открывал.
Android, Gradle и Maestro не запускал. Находки — `review.md` (открытых нет).

## (1) Область правки — своя мера

- `git diff --numstat 504fcafb db46d607` → `1	0	mobile/.maestro/cmp-mob-002-tabs.yaml`, rc=0. Ровно один файл: одна строка добавлена, ни одна не удалена.
- Добавлена строка `- openLink: complior://start`. Стоит между `launchApp: clearState: true` и `assertVisible: id: shell-tab-start`.
- Раз удалений ноль, остальные assertions, tapOn, takeScreenshot сценария дословно прежние: 6 из `nav-*`, порядок вкладок, профиль, Back.
- `git rev-list --count 504fcafb..db46d607` → `1`. Автор коммита — `implementer <implementer@dev-harness.local>`, родитель 504fcaf, сообщение несёт метку `999 (CMP-MOB-002) round-4 … (Н8)`. Коммит атомарный.
- Нормативных документов в диффе нет. `mobile.yml`, `ci-e2e.sh`, `rehearsal-evidence.sh` и app/исходники не менялись: дифф из одного файла.

## Зона

Взял frozen-блоб `git show 'frozen/contracts/999/1^{commit}:contracts/999-cmp-mob-002-navigatsiya.md'` в клоне h на пине. Строку `ЗОНА implementer:` разобрал своим скриптом и сопоставил её префиксы с путями диффа:
`mobile/.maestro/cmp-mob-002-tabs.yaml -> mobile/.maestro/`. Путь лежит в зоне. Имя сценария по шаблону `cmp-mob-002-<scenario>.yaml` из §Пины.

## (2) Н8 закрыта

**Основание deep link (статично):**
- `mobile/app.json:8` содержит `"scheme": "complior"`.
- Маршрут `mobile/src/app/(tabs)/[section].tsx`: `pick(section)` пропускает только TAB_ORDER и монтирует `<TabShell initialSection={start} …/>`. Для `start` получаем TabShell.
- `app/index.tsx` по-прежнему отдаёт `/` PilotApp 995.
- `@expo/config-plugins/build/android/Scheme.js:41` при prebuild добавляет `expo.scheme` в intent-filter Android. CI собирает APK через `expo prebuild`.
- Expo Router `extractExpoPathFromURL` (`expo-router@57.0.28`, `build/fork/extractPathFromURL.js:108`) превращает `complior://start` в путь `start`.

**renderRouter-эквивалент, исполнен на C′.** Throwaway: `/tmp/dev-harness-verify/Rev999d/evidence/maestro-equiv.test.tsx` + `rr.jest.config.js`, из клона удалены.
- launchApp ≡ `renderRouter('./src/app', {initialUrl:'/'})`.
- openLink ≡ событие `'url'` с `{url:'complior://start'}` в шину `expo-linking.addEventListener`. Это настоящий путь subscribe → useLinking → extractExpoPathFromURL, без прямого `router.push`.
- Дальше шаги сценария идут один к одному: 5 testID shell, `Was möchten Sie klären?`, Vorgänge/Schutz/Post и их заголовки, профиль (`profile-surface`, `Profil bearbeiten`, `shell-back`), Back → `shell-tab-post` + `Ihre Dokumente`.

```
$ npx jest -c rr.jest.config.js src/rrcheck --ci --verbose
    PROFIL_HITS 2
  ✓ без openLink (сценарий 504fcaf): launchApp -> shell-tab-start отсутствует (135 ms)
  ✓ C′: launchApp + openLink complior://start -> весь сценарий (73 ms)
Tests:       2 passed, 2 total
rc=0
```

**Красное предъявлено.** Первый тест фиксирует состояние Н8 до правки: на `/` есть `first-run-continue`, а `shell-tab-start` = null. Мутанты строки openLink (`REV_URL`, тест C′) — каждый RED:

```
== complior://heute    ✕  Tests: 1 failed, 1 skipped  rc=1
== complior://         ✕  Tests: 1 failed, 1 skipped  rc=1
== complior://profile  ✕  Tests: 1 failed, 1 skipped  rc=1
```

Значит, эквивалент различает правильный URL и отклонения от него и не зеленеет на любой строке.

**Flows 995 нетронуты:**
- `git diff --quiet 504fcafb HEAD -- mobile/.maestro/start.yaml mobile/.maestro/rehearsal.yaml` → rc=0.
- Оба flow начинаются с собственного `launchApp: clearState: true` → `first-run-continue`, поэтому состояние shell после сценария 999 до них не доходит.
- Скриншоты `nav-*` с `rehearsal-before/after` не пересекаются, так что `DUPLICATE_EVIDENCE` в `rehearsal-evidence.sh` не возникнет.

**CI сценарий действительно исполняет (H на пине + C′):**
- `pilot_995/maestro_probe.py:43-55` копирует ВСЕ файлы `mobile/.maestro` (rglob) в приватный `.maestro` и запускает `ci-e2e.sh`.
- `ci-e2e.sh:69-70` выполняет `maestro test … .maestro`, то есть все flows папки, включая `cmp-mob-002-tabs.yaml`.
- Если что-то упало (rc≠0 или есть testcase с failure), `maestro_probe.py:97-102` возвращает 1.
- `rehearsal-evidence.sh` краснеет при failure в любом testcase.
- `mobile.yml` (android-e2e) вызывает `maestro_probe.py` из H-checkout `c9f680b4…`, шаг на C′ не менялся.

Падение сценария 999 на устройстве блокирует required-check. Это не декоративный шаг.

## Паразитная сложность (050)

Новых артефактов нет: добавлена одна строка в существующий сценарий.
- (1) Свойство — Android-сценарий навигации и deep link из §Приёмки/§Отложенной.
- (2) Новое состояние явно: URL в тексте сценария.
- (3) Вместе меняется 1 файл, число не выросло.
- (4) Интерфейс не изменился.
- (5) Потребитель — android-e2e через maestro_probe.py; грамматику нигде не дублирует.

Класс — ESSENTIAL. Без строки сценарий не проходит (Н8).

## Пределы проверки

- Физическая доставка intent `complior://start` на эмулятор/APK и исполнение Maestro не проверялись — Scope это запрещает. Это остаётся за android-e2e в PR. [INFERENCE] Поведение Maestro `openLink` (am start VIEW, singleTask → событие `url`) не наблюдал; RNTL-эквивалент моделирует только JS-сторону.
- Прогон 999-проб и frozen-995 на C′ не повторял. Код приложения не менялся (numstat), accept круга 3 остаётся в силе по Scope.

## Советы (не блокируют)

- С1. `Profil bearbeiten` на экране профиля совпадает дважды (PROFIL_HITS 2: заголовок профиля + ещё один узел). Maestro `assertVisible text` берёт любое видимое совпадение, сценарий от этого не падает. Утверждение `id: profile-surface` уже несёт различение. Править не нужно.
- С2. Строка `openLink` упражняет только вход `start` без `returnTo`. Консультант прямо оставил `complior://schutz?returnTo=post` вне Н8, так что это не находка, а возможное расширение будущим срезом.
