accept
OBJECT=872a0641cc8a3268c5d2d6bf62108b584ddc75f6
СУД: репо=dev-harness; предмет=208; роль=adversary; вызов=3 (узкий по дельте, слово владельца для done); фаза=реализация; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=3a02f2250014ae375852683e70d55a546e5adcf9:verdicts/adversary/contracts-208-v1.md (accept, OBJECT 94251e24c); класс риска=рисковый

Фактическая модель — из runtime project-context; независимая допись модели из трассы в HANDOFF за оркестратором согласно заданию. Судья не автор дельты. Задание назвало предыдущий путь `contracts-208-v2.md`, но `git show 3a02f2250014ae375852683e70d55a546e5adcf9:verdicts/adversary/contracts-208-v2.md` вернул rc 128: пути нет. В указанном коммите существует `contracts-208-v1.md`; прочитан целиком, это accept вызова 2 на указанный OBJECT. `git log --all -- verdicts/adversary/contracts-208-v2.md` не нашёл другого коммита.

## Дельта

Суд только дельты от `94251e24cf96b2b8bf292fbbb9c70d171c8dd69b`. Авторы и коммиттеры: `a79fa9f54 architect|architect`, `4b5c1f031 implementer|implementer`, `872a0641c architect|architect`. `git diff --name-only` с исключением зон задания пуст; `git show --name-only 4b5c1f031` показывает у implementer только `scripts/zamok_predmeta.sh`. Diff двери прочитан: два вызова предиката в резолвере заменяют идентичные прежние выражения, третий в D9b заменяет широкий `.review/*` на то же выражение резолвера. Равенство байтов двери и модели: обе SHA-256 `47de5c0244b548d275b268a0530f634e90a09e7224b8542bb2cbe1601826bdfe` (`sha256sum`, rc 0).

Оракул `--repo` не вычисляет ожидания из проверяемой двери: `probe208.py:1317-1322,1384-1402` берёт клетки `kejsy()` и запускает субъект; ожидаемые результаты заданы в клетках, включая `:779-859`. Байт-в-байт совпадающая модель — не независимое доказательство сама по себе. По проведённым пробам не обнаружено ослабления прежних отказов; конечная батарея не доказывает эквивалентность произвольной программы.

## Мутации

Каждая дверь копировалась отдельно в `/tmp/dev-harness-verify/scratch-adv208c/mutant/scripts/zamok_predmeta.sh`, запускалась `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo /tmp/dev-harness-verify/scratch-adv208c/mutant`, затем удалялась. Сырые итоги:

| дверь | rc | вывод | примеры красных клеток |
|---|---:|---|---|
| st40, константа публикации | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 2` | r24, r25 |
| st41, константа в общем предикате | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 3` | r26, r27, r30 |
| st42, константа санкции | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 2` | r28, r29 |
| st43, константа аргумента резолвера | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 1` | r30 |
| st44, прежний glob `.review/*` в D9b | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 2` | r31, r32 |
| первый вызов `verdikt_put` резолвера заменён на `true` | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 22` | r01, r04, r06, r31–r35 |
| инверсия `[[ ... ]]` в `verdikt_put` | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 23` | r01, r04, r06, r31–r35 |
| `return 0` в начале `verdikt_put` | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 22` | r01, r04, r06, r31–r35 |
| `return 1` в начале `verdikt_put` | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 8` | r06, r18, r26, r27, r30, r33–r35 |
| в D9b `verdikt_put "$n" "$p"` заменён на `false` | 1 | `SUBJEKT 208: KLETKI 35 KRASNYH 6` | r06, r26, r27, r33–r35 |

Собственные мутации создавались из двери OBJECT заменой с проверкой единственности якоря; для первых трёх якорь — `  local n="$1" p="$2"\n`, после которого вставлялись соответственно `  ! ` перед исходным `[[`, `  return 0\n`, `  return 1\n`; для резолвера — `    verdikt_put "$n" "$p" \\\n` → `    true \\\n`; для D9b — `    verdikt_put "$n" "$p" || return 0` → `    false || return 0`. Результаты rc извлекались непосредственно из `subprocess.run` батареи; имена клеток и итог — её stdout. В st44 отдельно наблюдались обе r31/r32, не только одна связь. Контроли r33–r35 зелёные на честной двери и модели, красные на D9b-off. Привязки стабов — код `probe208.py` и `source.json`, не проза контракта (Н-39). `--stabs` проверяет наличие хотя бы одной красной связанной клетки на стаб, поэтому индивидуальное наблюдение обеих r31/r32 приведено отдельно.

## Регресс

Везде `TMPDIR=/tmp/dev-harness-verify/scratch-adv208c`, `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`:

- `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo .` → rc 0, `SUBJEKT 208: KLETKI 35 KRASNYH 0`.
- Та же батарея `--model` → rc 0, `MODEL 208: KLETKI 35 KRASNYH 0`.
- Та же батарея `--stabs` → rc 0, `MODEL 208: KLETKI 35 KRASNYH 0`, `STABY 208: SVJAZI 73 ZHIVYH 0`.
- `bash -n scripts/zamok_predmeta.sh` → rc 0.
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc 0, `MODEL_KLETKI 244 KRASNYH 0`. В задании ожидаемые «244/12» для `--model` не совпали с наблюдением: 12 — прежний результат Adv208b для режима субъекта, не этой команды модели.
- `bash scripts/pre_critic.sh contracts/208-zamok-object-predok.md` → rc 0, `КРИТИК: дверь зелёная`.
- `bash scripts/check_sdacha.sh "$PWD" contracts/208-zamok-object-predok.md --run` → rc 0, `СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=4)`.
- `bash scripts/gen_ci_steps.sh --check` → rc 0.

## Блоки

В пределах разрешённого узкого повтора доказанных блокирующих нарушений нет. Неверное имя предыдущего файла в задании разрешено по указанному SHA и содержимому самого вердикта; это не доказанное нарушение инварианта двери.

## НЕ ЗАЩИЩАЕТ

Не пересуждал принятые части 208, live-приёмку, конфликт CI-реестров с main, доверие к писателю учёта, свежесть origin-view, преддверие 172 и выбор done-вердикта. Остаток контракта о ширине D9/D11: в пределах дельты пробы st40–st44 и собственные мутации выше укусили; вне этих конечных входов эквивалентность не доказана. SourceCanon не объявлен.

## Советы

Для передачи учесть расхождение имени предыдущего вердикта и фактический результат `140 --model`; не подменять ими результаты прогона. Дописать модель-факт в HANDOFF по трассе после вызова.
