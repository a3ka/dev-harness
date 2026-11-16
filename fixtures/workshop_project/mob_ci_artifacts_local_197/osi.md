# Оси и клетки батареи 197 (mob_ci_artifacts_local_197)

Субъект — артефактный транспорт CI моба: `.github/workflows/mobile.yml`,
`package.json` (lanes `ci:artefakt-*`), `mobile/scripts/ci-artefakty.cjs`
(скрипт-канон, байтовый пин). Ожидания — в памяти проверяющего до чтения
субъекта; пины модели — `source.json:.piny`; привязки стабов —
`source.json:.stab_vhod` (Н-39: по коду мутатора, не по прозе контракта).

## A. Канал GitHub закрыт (статика workflow)

| Клетка | Инвариант | Именованная причина |
|---|---|---|
| a01-upload-artefakt-ostalsja | ни одного шага `uses: actions/upload-artifact@*` | `UPLOAD_ARTIFAKT_OSTALSJA: <job>.<шаг>` |
| a02-download-artefakt-ostalsja | ни одного шага `uses: actions/download-artifact@*` | `DOWNLOAD_ARTIFAKT_OSTALSJA: <job>.<шаг>` |
| a03-gh-kanal-v-run | в run-текстах нет `gh run download` / `gh api … /artifacts` | `GH_KANAL_V_RUN: <job>.<шаг>` |

## B. Писатели: закрытая форма, свой run-контекст

| Клетка | Инвариант | Причина |
|---|---|---|
| b01-forma-pisatelja | шаг с вызовом `ci:artefakt-zapis` несёт РОВНО один lane-вызов c аргументами ровно `--imja/--chto`; прочие команды шага — только охранные (`set`/`test`/`[`) | `FORMA_PISATELJA` |
| b02-imja-pisatelja-razreshimo | имя писателя — литерал алфавита либо выражение из замкнутого набора (`steps.<id>.outputs.<key>`, `matrix.*`) | `IMJA_PISATELJA_NE_RAZRESIMO` |
| b03-pisatel-s-run-argumentom | писатель НЕ передаёт `--run-id/--run-attempt` (путь строится из собственных `GITHUB_RUN_ID`/`GITHUB_RUN_ATTEMPT` скриптом) | `PISATEL_S_RUN_ARGUMENTOM` |

## C. Читатели: замыкание чтение/запись

| Клетка | Инвариант | Причина |
|---|---|---|
| c01-forma-chitatelja | ровно один вызов `ci:artefakt-chtenie`; ключи из замкнутого набора; `--run-id`/`--run-attempt` оба или ни один | `NEPOLNAJA_IDENTIFIKACIJA_RUNA` / `FORMA_CHITATELJA` |
| c02-imja-bez-pisatelja | каждый читаемый `--imja`/`--shablon` структурно совпадает с каким-то писателем того же workflow (литерал, цепочка env→needs→steps, glob-класс matrix) | `IMJA_BEZ_PISATELJA` / `SHABLON_BEZ_PISATELEJ` |
| c03-run-para-iz-sborki | значения `--run-id`/`--run-attempt` ПОСЛЕ env-разрешения — только выражения `needs.build-apk.outputs.run_id`/`needs.build-apk.outputs.run_attempt`; литеральная пара чужого прогона красна | `RUN_PARA_NE_IZ_SBORKI` |

## D. Корень и гигиена пути

| Клетка | Инвариант | Причина |
|---|---|---|
| d01-koren-vne-skripta | литерал `/var/lib/ci-artifacts` не встречается в workflow: грамматика пути живёт ТОЛЬКО в скрипте-каноне | `KOREN_VNE_SKRIPTA` |
| d02-vyhod-za-koren | литералы `--imja`/`--shablon` — алфавит без `/` и `..`; `--chto`/`--kuda` — относительные пути без сегмента `..` | `IMJA_VNE_ALFAVITA` / `VYHOD_ZA_KOREN` |

## E. Скрипт-канон и lanes

| Клетка | Инвариант | Причина |
|---|---|---|
| e01-skript-pin | `mobile/scripts/ci-artefakty.cjs` существует и байты равны пину | `SKRIPT_NET` / `SKRIPT_PIN_RASHOZHDENIE` |
| e02-linei-npm | `package.json` несёт ровно lanes `ci:artefakt-zapis`/`ci:artefakt-chtenie` со значениями канона | `LINEJ_NET` / `LINEJA_FORMA` |


## И. Исполнимость носителей и замкнутый инвентарь (писатели и читатели)

| Клетка | Инвариант | Причина |
|---|---|---|
| i01-nositel-ispolnim | клетка краснеет, когда операция ОТСУТСТВУЕТ или НЕИСПОЛНИМА, а не когда в файле есть текст: `if:` шага-носителя — замкнутый набор {отсутствует, `always()`, `success()`}; константная ложь шага/job'а и `continue-on-error` носителя красны | `NOSITEL_NEISPOLNIM` / `USLOVIE_VNE_KANONA` / `JOB_NOSITELJA_OTKLJUCHEN` / `PROVALY_PODAVLENY` |
| i02-zamknutyj-inventar | пять категорий предмета (APK `apk-*`, `selection`, доказательства `maestro*`, child-evidence `screen-evidence-*`, маркер `regression-marker`) обязаны иметь писателя; посторонний писатель красен; потребляемые категории (APK, child-evidence) обязаны иметь читателя в workflow — молчаливая потеря видима; тело heredoc — данные, вызов-как-текст операцией не считается | `KATEGORIJA_BEZ_PISATELJA` / `POSTORONNIJ_PISATEL` / `KATEGORIJA_BEZ_CHITATELJA` |

Класс имени-выражения (`steps.*`/`matrix.*` → `*`) удовлетворяет только
glob-категориям (`apk-sborki`, `child-evidence`) — известная грубость;
терминальные категории (`selection`, `maestro*`, `regression-marker`)
читает ops/server (предмет 196), читателя в workflow не требуют.

## R. Replay скрипта-канона (замкнутая песочница, root через env)

| Клетка | Инвариант | Причина |
|---|---|---|
| r01-krug-zapisi-chtenija | запись→чтение возвращает байты | `KRUG_NARUSHEN` |
| r02-popytka-prodjusera | APK читается из продюсерской попытки при собственной 2 (сборка переживает повтор); чтение без аргументов в пустой попытке — именованный отказ, не молчаливое чтение чужой | `SBORKA_NE_PEREZHILA_POVTOR` / `SOBSTVENNAJA_POPYTKA_NE_IZOLIROVANA` |
| r03-imja-pobeg | `--imja ../pobeg` — отказ, ничего вне корня не создано | `POBEG_PROPUSHCHEN` / `POBEG_ISPOLNEN` |
| r04-imja-razdelitel | `--imja a/b` — отказ | `RAZDELITEL_PROPUSHCHEN` |
| r05-run-nechislovoj | нечисловой `GITHUB_RUN_ID` — отказ | `NECHISLOvoj_PROPUSHCHEN` |
| r06-nepolnaja-identifikacija | `--run-id` без `--run-attempt` — отказ | `NEPOLNAJA_PROPUSHCHENA` |
| r07-shablon-sbor | glob собирает каждого ребёнка отдельным каталогом; пустой glob — отказ | `SHABLON_NE_SOBRAL` / `PUSTOJ_SHABLON_NE_KRASN` |
| r08-istochnik-otsutstvuet | запись отсутствующего источника — отказ (аналог `if-no-files-found: error`) | `PUSTOJ_ZAPIS_NE_KRASN` |
| r09-izoljacija-popytok | записи попыток 1 и 2 лежат в разных каталогах | `POPYTKI_SLILIS` |

Итого 24 клетки (A3 + B3 + C3 + D2 + E2 + И2 + R9), 12 стабов (ветви
A1/A3/B1/C1/C2/C3/D1/D2/И3/R9, где И3 = две ветви i01 `if: false` и
`continue-on-error` плюс i02 heredoc-носитель; привязки и ожидаемые
причины — `source.json:.stab_vhod`).

## Модель

`model/.github/workflows/mobile.yml` выведена из живого дерева продукта
(`origin/main` fda1fc871960b8061d8e6f6d12f2cc38f5834cee, 2026-11-12 — последний
fetch клона на станции; sha базового mobile.yml в `source.json:.bazovoje_derevo`)
заменой артефактного транспорта: 9 шагов upload-artifact, 3 шага
download-artifact и 5 команд `gh run download` → 9 lane-вызовов `zapis` и 8
`chtenie` — и ОДНОЙ структурной перестановкой: в e2e-pilot проба изоляции
раннера перенесена ДО читателя APK (npm-lane — код PR, замороженный
инвариант 143 С-3; в живом дереве на этом месте стоял не-PR-код gh). Прочие
слои workflow не тронуты; после ленда продукт законно
расходится с моделью вне артефактного слоя (прецедент Arb143r) — клетки
A–И судят только артефактный слой, исполнимость носителей и lane-форму,
побайтового пина всего workflow нет. Состав красных батареи 143 на
псевдо-продукте fda1fc8+модель пинирован (`source.json:.krasnye_143_posle_197`)
и сверяется живым прогоном `sverka_inventarja_143.sh`.
