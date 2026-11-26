FAIL
OBJECT=414a5cb183295ead0f868c69e785b02d5bb7e086

СУД: repo=dev-harness; предмет=230; фаза=контракт; роль=critic; вызов=1/2 (полный; новый предмет); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit230; модель-факт=openai-codex/gpt-6.1-terra; автор Architect230 — openai-codex/gpt-6.1-sol; SHA=414a5cb183295ead0f868c69e785b02d5bb7e086; предыдущий=нет; исключение=нет.

## Блоки

БЛОКИРУЕТ contracts/230-sud-model-drift.md:25,38,48,90 — объявленная замена frozen 174 неполна и не имеет оформленного пути согласования с действующим обязательством.
ОБЯЗАТЕЛЬСТВО: frozen/contracts/174/1 `contracts/174-models-actual-session.md:17` требует при нескольких одноимённых JSONL сохранять прежний порядок всех совпадений, а без `--session` сохранять CLI и коды. AGENTS.md:149–152 запрещает ослаблять замороженное и устанавливает для правки его текста v+1 с новым critic и `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в изменяющем коммите. Само ПЕРЕСЕЧЕНИЕ не изменяет frozen-текст и не делает взаимоисключающие требования совместимыми.
СОСТОЯНИЕ: два валидных JSONL с одним basename в разных датированных каталогах; запускается `--session ID --tsv --bind` либо `--bind` без `--session`. Это не гипотеза вне области: случай прямо задан затравкой и клетками duplicate-bind/duplicate-global-bind.
НАБЛЮДЕНИЕ: 174 требует прежней выдачи совпавших файлов, а И1 230 требует до выдачи rc 2 `SESSION_AMBIGUOUS`; вторая форма противоречит ещё и требованию 174 о сохранении поведения без `--session`, хотя строка 25 заявляет замену одной только фразы про выбранную сессию. Задание 230 передаёт волю исправить неоднозначность, но не предъявляет разрешение на изменение уставного текста 174 и кандидат не содержит его новой версии. Зелёный регресс 174 не доказывает совместимость обязательств: его мир содержит разные basename.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: предъявить законный маршрут согласования всех затронутых frozen-обязательств с требуемым fail-closed, включая отсутствие `--session`, и обеспечить, чтобы оба обязательства не оставались одновременно действующими и противоположными; если маршрут требует изменения текста 174 — соблюсти указанные AGENTS.md v+1, critic и разрешение владельца. Не предписывается менять меру защиты 230.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-03

## Карта классов

К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0
К-02: чисто — вход затравка fcaff8bf:contracts/230-sud-model-drift.md и task-architect230.md
К-03: блок — несовместимость с frozen 174
К-04: чисто — check_precision_gate.sh rc 0 и contracts/230-sud-model-drift.md:79-156
К-05: чисто — вход contracts/230-sud-model-drift.md:59-65
К-06: чисто — вход probe.py:253-315 и отрицательные случаи ошибок JSON
К-07: чисто — --model rc 0 KLETKI=57 KRASNYH=0
К-08: чисто — --stabs rc 0 STABS=23 ZHIVYH=0 и пять независимых мутаций ниже
К-09: чисто — вход catalog в probe.py:42-91 и мутации разных режимов ниже
К-10: чисто — вход probe.py:207-244 сравнение полного TSV и журнала
К-11: чисто — вход probe.py:206-217 ожидания до вызова субъекта
К-12: чисто — вход model/models_actual.py стандартный json и настоящий roles.ts
К-13: н/п — секреты и их вывод не предмет 230
К-14: чисто — --model rc 0 честные сериализации и допустимый fallback
К-15: чисто — --repo 57/27 --model 57/0 --stabs 23/0 совпадают со сдаточным листом
К-16: чисто — вход contracts/230-sud-model-drift.md:4,67-76 риск безопасности суда и граница доверия
К-17: н/п — станционный producer без объявленной продуктовой архитектуры 188

## Доказательства

До реализации `bash fixtures/workshop_project/sud_model_drift_230/red_sud_model_drift_230.sh --repo .` rc 1; сырой итог `KLETKI=57 KRASNYH=27`. `--model` rc 0: `KLETKI=57 KRASNYH=0`. `--stabs` rc 0: `STABS=23 ZHIVYH=0`. В частности на базовом дереве `ZELENO denied-not-fallback`, а duplicate-bind: `rc=1/2 journal=True projection=False stderr=ОТКАЗ: фолбэк вне списка тира: adversary на zai/glm-5.3, тир advisor (Н-270)`; duplicate-allowed-bind `rc=0/2 journal=False projection=False`. То есть producer объединяет файлы и при компактном denied настоящая дверь отвергает; отказ об источнике ещё отсутствует. Ремонт в зоне producer должен проверять единственность до вывода и разбирать все события JSON стандартным парсером, сохраняя старые сверки двери и вызовы регресса; reference не является полной заменой human-CLI.

`SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/230-sud-model-drift.md --run`: rc 0, сырой вывод `СДАЧА: лист зелёный (двери=13 карта=17/17 дельта=0)`. `bash scripts/pre_critic.sh contracts/230-sud-model-drift.md`: rc 0, последний вывод `КРИТИК: дверь зелёная`. `bash scripts/check_precision_gate.sh "$PWD" contracts/230-sud-model-drift.md`: изолированный повтор rc 0, `OK`. Первый параллельный запуск precision дал rc 0 с ошибками пропавших промежуточных файлов общей scratch-директории; не используется как доказательство. Перед запуском uptime: `load average: 17.83, 16.63, 14.46`.

Трассы `models_actual.sh --tsv --bind --session Crit230` и аналогично Architect230 rc 0: соответственно `critic openai-codex/gpt-6.1-terra allowed Crit230 414a5cb183295ead0f868c69e785b02d5bb7e086` и `architect openai-codex/gpt-6.1-sol allowed Architect230 -` (каждая строка в выводе повторена дважды); это разные сессии. `node scripts/roles.ts --resolve-model critic`: `apex-sol openai-codex/gpt-6.1-terra zai/glm-5.3 false`.

## Независимые мутации

В одноразовом собственном клоне OBJECT вызван `python3 ../attack230.py`, который предъявляет к контрольной модели отдельные мутации через `probe.check` в отдельных временных Git-мирах. Это не каталог source.json; ниже сырой вывод без временного абсолютного пути последней диагностики. `mutant_rc=1` означает, что соответствующая клетка различила мутанта, а не код продакшена.

```text
first-by-mtime duplicate-bind mutant_rc=1 rc=0/2 journal=False projection=True stderr=
first-by-mtime duplicate-reverse-bind mutant_rc=1 rc=1/2 journal=True projection=False stderr=ОТКАЗ: фолбэк вне списка тира: adversary на zai/glm-5.3, тир advisor (Н-270)
substring-prefix exact-name-not-substring mutant_rc=1 rc=1/0 journal=False projection=False stderr=ОТКАЗ: чужая трасса: сессия Judge230_A-suffix, суд Judge230_A
same-parent-only duplicate-bind mutant_rc=1 rc=1/2 journal=True projection=False stderr=ОТКАЗ: фолбэк вне списка тира: adversary на zai/glm-5.3, тир advisor (Н-270)
bind-only-alt duplicate-tsv mutant_rc=1 rc=0/2 journal=True projection=False stderr=
bind-only-alt duplicate-human mutant_rc=1 rc=0/2 journal=True projection=True stderr=
bind-only-alt duplicate-global-bind mutant_rc=1 rc=1/2 journal=True projection=False stderr=ОТКАЗ: фолбэк вне списка тира: adversary на zai/glm-5.3, тир advisor (Н-270)
ignore-no-role denied-not-fallback mutant_rc=1 rc=2/1 journal=True projection=True stderr=NOT_IMPLEMENTED: TRACE_EMPTY: <временный путь>/zone/2026-11-25/Judge230_A.jsonl
```

Мутации соответственно заменяют проверку дубля выбором первого по mtime, буквальное равенство префиксом, проверку дубля проверкой только одного каталога, общую проверку ограничением на выбранный bind, и распознавание model_change требованием `role=fallback`. Все предъявленные клетки покраснели. Это не доказательство произвольных программ.

## НЕ ЗАЩИЩАЕТ

Как в contracts/230-sud-model-drift.md:71-76: подделка доверенного JSONL/TSV или задания, сам переключатель omp и произвольная программа, распознающая конечную батарею; ловцы — изоляция, 104/222, 129/215, CI и независимый суд.

## Советы

СОВЕТ contracts/230-sud-model-drift.md:25 — при уточнении маршрута отдельно назвать обе затронутые формы CLI: с явным `--session` и глобальный `--bind`, чтобы не свести конфликт к одной фразе frozen 174.
