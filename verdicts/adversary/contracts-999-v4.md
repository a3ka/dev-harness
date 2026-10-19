accept
OBJECT=db46d607001e212b2584e78b6907af1bd7c787b4

## Предмет и дельта

Проверен C′ в отдельном клоне. Команда

```text
git -C /tmp/dev-harness-verify/Adv999d/mob diff --numstat 504fcafb7f3871155cf2d7e297d3d766d0f098a5 db46d607001e212b2584e78b6907af1bd7c787b4 &&
git -C /tmp/dev-harness-verify/Adv999d/mob diff --check 504fcafb7f3871155cf2d7e297d3d766d0f098a5 db46d607001e212b2584e78b6907af1bd7c787b4
```

дала rc=0 и сырой numstat `1 0 mobile/.maestro/cmp-mob-002-tabs.yaml`. Полный diff содержит ровно одну вставку между `launchApp: clearState: true` и первым `assertVisible`:

```yaml
- openLink: complior://start
```

`git diff --name-status` дал rc=0 и единственную строку `M mobile/.maestro/cmp-mob-002-tabs.yaml`; `git status --short --untracked-files=no` после проб пуст. Поэтому остальные assertions, переходы и скриншоты cmp-flow, а также `start.yaml`, `rehearsal.yaml`, исходники, `app.json` и workflow не менялись этой дельтой.

## Применимость прежнего accept и контрпробы

Позитивный контроль C′:

```text
python3 h/fixtures/workshop_project/nav_999/shell_static_probe.py --repo mob
```

дал rc=0: `TOKENS_MATCH`, `LITERAL_PALETTE`, `FONTS_PRESENT`, `FONTS_OFL`, `NO_WEB_BUNDLE`, `DEEP_LINK_SCHEME` — все rc=0; последняя строка: `scheme=complior`.

Полная offline-матрица той же пробы также дала rc=0. Честный прогон зелёный; все семь встроенных контрзаглушек дали named RED без unexpected_red: `invented-palette`, `theme-light-dropped`, `literal-hex-screen`, `font-ttf-missing`, `ofl-missing`, `web-bundle-import`, `scheme-changed`. В частности, подмена схемы на `other-app` наблюдалась как `DEEP_LINK_SCHEME_CHANGED ...`, named `DEEP_LINK_SCHEME RED`.

После быстрого `npm ci --no-audit --no-fund` (rc=0) дополнительно исполнены реальные RNTL-пробы C′: `nav_probe.py`, `ui_probe.py`, `copy_probe.py` с `--repo mob` дали соответственно rc=0; все выведенные клетки каждой из трёх семей имеют rc=0. Это подтверждает, что одно YAML-изменение не нарушило принятую поверхность 999.

Проверен контрпример «правильная схема, но не тот маршрут». Исполненный настоящий `extractExpoPathFromURL` из установленного `expo-router` дал rc=0 и:

```text
complior://start -> "start"
complior:// -> ""
complior://vorgaenge?returnTo=start -> "vorgaenge?returnTo=start"
```

Следовательно, добавленная строка не является зашитым успехом по одной лишь схеме: она несёт сегмент `start`. Этот сегмент принимается `mobile/src/app/(tabs)/[section].tsx`, проверяется против `TAB_ORDER` и монтирует `TabShell`; `/` отдельно остаётся экспортом `PilotApp`. Прежние 995 flows холодно запускают `/` и по diff не затронуты.

## Исполнение CI и граница доказательства

Обхода через исключение cmp-flow из native gate не найдено. В `.github/workflows/mobile.yml` Android job вызывает frozen `pilot_995/maestro_probe.py` с `--repo`; он снимает байты **всех** файлов из `mobile/.maestro` через `rglob('*')`, переносит их в приватный `.maestro`, а скопированный `mobile/scripts/ci-e2e.sh` запускает:

```text
maestro --device "$SERIAL" test --format junit --output maestro-out/report.xml --test-output-dir maestro-out .maestro
```

То есть `cmp-mob-002-tabs.yaml` остаётся среди реально переданных Maestro flow; `start.yaml` и `rehearsal.yaml` с собственным `launchApp: clearState: true` не получают состояние от deep link cmp-flow. Ошибочный bare-link `complior://` прошёл бы только static-схемный чек, но не даёт сегмента маршрута по исполненной Expo-парсер-пробе; это не найденный обход native gate, а отрицательный контроль значения URL.

Android/Gradle/Maestro намеренно не запускались по прямому ограничению задания. Поэтому доставка Android intent и фактический rc native Maestro здесь не заявляются как измеренные; статический разбор CI доказывает включение файла в команду, но не заменяет нативную приёмку. Наблюдаемого обхода единственной строкой, нарушающего frozen-пробы 995/999 либо rehearsal-evidence gate, не найдено.

## Советы

Нет.