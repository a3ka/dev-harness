accept
OBJECT=36797c6ce445179a190fbcd9f14c0cc0ce94daa5

# Контракт 111 — критик, круг 3, до заморозки

**Решение:** закрытый перечень П-1…П-5 выполнен; регресс закрытого кругами 1–2 не обнаружен. Блокирующих находок нет. Основания для передачи владельцу по капу нет.

Суд выполнен только в границах `verdicts/arbitration/contracts-111-dark-light-perechen-v1.md`, Решение 1. Его блоб на `main` побайтово равен `/tmp/dev-harness-verify/Arbiter111/verdict.md` (SHA-256 `56e64c337851943bae06448d4d0fb0063a12f4d759e1fa391caabb19091d94f3`). Остальная продуктовая приёмка не подменяется этим accept.

## Предмет и изоляция

Предмет закоммичен: OBJECT существует, автор `architect`; `H/HEAD` закреплён на OBJECT. Контракт и все десять файлов семьи, включая модель, побайтово сверены с блобами OBJECT. Предмет, команды готовности, исполнители и зоны присутствуют: `contracts/111-cmp-mob-first-run.md:72–82,182–205,215–236`. Набор артефактов полон.

Все записи — внутри `/tmp/dev-harness-verify/Critic111r3/`. H материализован через `git archive OBJECT`; для исполнения git-зависимых дверей использована отдельная копия git-метаданных с локальным fetch OBJECT. R — `cp -a /tmp/dev-harness-verify/Architect111/R`, HEAD базы `76ac10fac668a1036371c4b392061ce9b3277ebc`, зависимости уже установлены. Основной чекаут, чужие worktree и исходный R не изменялись. Коммитов и push нет — прямое ограничение непиннованной сессии.

## Диагноз по закрытому перечню

Все пути в таблице — относительно H; доказательства — относительно каталога этого вердикта. Знак «выполнено» означает результат приведённого наблюдения, не отдельный маркер инструмента.

| Пункт | Место предмета и проверенное свойство | Замер | Итог / ОБХОД |
|---|---|---|---|
| П-1 | `contracts/111-cmp-mob-first-run.md:145–148`; `fixtures/workshop_project/first_run_111/first_run.test.tsx:160–168`: К3 — цикл по `['dark','light']`, реальный `renderFirstRun(scheme)`, прежний литерал `EDGES_ALL_ACTIVE` со всеми четырьмя краями. | Модель: обе `SAFEAREA_EDGES_ACTIVE_*` зелёные. Дословная мутация критика `new-light-edges-top-bottom`: rc1, **только** `SAFEAREA_EDGES_ACTIVE_LIGHT` красная; DARK зелёная. `evidence/model-jest-independent.txt`, `evidence/replay-r2-light-edges-top-bottom-probe.txt`. | Выполнено; блокирующего обхода нет. |
| П-2 | `contracts/111-cmp-mob-first-run.md:149–151`; `first_run.test.tsx:174–185`: К4 — такой же цикл, наблюдается source отрендеренного wordmark; ожидание — прежний литерал `wordmark-dark.png`. | Модель: обе `WORDMARK_SOURCE_BOUND_*` зелёные. `new-light-wrong-source`: rc1, **только** `WORDMARK_SOURCE_BOUND_LIGHT` красная. `evidence/replay-r2-light-wrong-source-probe.txt`. | Выполнено; блокирующего обхода нет. |
| П-3 | `contracts/111-cmp-mob-first-run.md:152–155`; `first_run.test.tsx:192–205`: К5 — цикл по обеим схемам, текстовые листья фактического host-дерева сверяются с прежними литералами Demo/promise/CTA. | Модель: обе `FIRST_RUN_COPY_CLOSED_*` зелёные. `new-light-extra-copy`: rc1, **только** `FIRST_RUN_COPY_CLOSED_LIGHT` красная. `evidence/replay-r2-light-extra-copy-probe.txt`. | Выполнено; блокирующего обхода нет. |
| П-4 | `contracts/111-cmp-mob-first-run.md:167–180`; `fixtures/workshop_project/first_run_111/first_run_probe.py:25–143`: три light-мутации включены в MUTANTS; named/depends назначены в коде. | Все три последовательности замен равны JSON критика круга 2, включая строки и порядок (`evidence/mutation-identity.json`). Матрица исполнила 14 стабов; наблюдённое множество красных клеток **точно равно** `named ∪ depends` у каждого, включая переякоренные схемонезависимые стабы и зависимости `wordmark-absent`, `cta-label-weiter`, `promise-invented` (`evidence/integrity.json`). Независимый replay исходных JSON подтверждает каждую LIGHT-клетку. | Выполнено; не декларация списка вместо исполнения. Блокирующего обхода нет. |
| П-5 | `contracts/111-cmp-mob-first-run.md:134–180,190–194,249–277,310–332`: 11 клеток, К3/К4/К5 ×2, 14+9 стабов, три стаба круга 2, обе схемы в модели угроз, обновлённый фактический замер. | `--model`: rc0, 11/11 и 14/14; `--matrix`: rc0, 14 и 9 исполненных стабов. Число поведенческих клеток дополнительно подтверждено прямым Jest-отчётом — 11 конкретных результатов; форма кода — пять циклов ×2 и одна одиночная клетка. Статическая семья, оракул, библиотека и все файлы модели не изменились относительно круга 2. | Выполнено; недостоверного предъявления не обнаружено. Блокирующего обхода нет. |
| Регресс: модель / матрицы | `contracts/111-cmp-mob-first-run.md:190–194,321–323`. | Обе модели rc0; обе матрицы rc0. В выводе нет `MUTANT_GREEN`, `MUTANT_NAMED_MISS`, `MUTANT_UNEXPECTED_RED`, `MUTANT_ANCHOR_BROKEN`; все 14+9 мутантов перечислены. | Сохранён. |
| Регресс: стабы кругов 1–2 | `contracts/111-cmp-mob-first-run.md:175–180,325–330`. | Пять исходных JSON круга 1 и три исходных JSON круга 2 повторно применены к неизменённой модели OBJECT и исполнены обеими пробами. Именованная краснота приведена ниже; у трёх light-мутаций статическая проба rc0 14/14. | Сохранён. |
| Регресс: база B | `contracts/111-cmp-mob-first-run.md:187–189,319–320`. | Обе пробы без модели: rc1, дословно `FIRST_RUN_SEAM_ABSENT`. `evidence/base-probe.txt`, `evidence/base-static_probe.txt`. | Сохранён. |
| Регресс: scoped 995 | `contracts/111-cmp-mob-first-run.md:197–199`. | На установленной модели OBJECT настоящий Jest `pilot.test.tsx --testNamePattern 'DIRECT_unknown\|DEFAULT_OFFLINE'`: rc0, обе клетки passed, остальные 12 не запускались. `evidence/scoped-995-entry.txt`. | Сохранён в назначенном scope. |
| Регресс: precision / precritic | `contracts/111-cmp-mob-first-run.md:204–205,217–224`. | Живые bash-команды из H: `check_precision_gate.sh H contracts/111-cmp-mob-first-run.md` → rc0 `OK`; `pre_critic.sh --repo H contracts/111-cmp-mob-first-run.md` → rc0 `КРИТИК: дверь зелёная`. `evidence/gates.txt`. | Сохранён. |
| Регресс: восстановление R | `contracts/111-cmp-mob-first-run.md:195–196,331–332`. | `git status --short --untracked-files=all` до и после всех проб: rc0, **0 строк**. Все пять путей модели побайтово восстановлены; временные test/splash-файлы отсутствуют. | Сохранён. |
| Регресс: frozen 995 = фактический CI-пин | `contracts/111-cmp-mob-first-run.md:43–46,197–199,226–228`; продуктовая `.github/workflows/mobile.yml:27–48`. | `pilot.test.tsx` и `source.json` в R побайтово равны **фактическому** H-пину CI базы B: `c9f680b4d9fd2e7eec24524c172343a70d2d8aae`. Diff frozen-семейств `pilot_995`/`nav_999` от OBJECT круга 2, а также от OBJECT круга 1 до нового OBJECT пуст; `git diff --exit-code` rc0. `evidence/integrity.json`, `evidence/*frozen-diff.txt`. | Сохранён; сравнение не подменено текущей версией H. |

### Именованная краснота исходных мутаций

Это результаты отдельных replay, а не вывод из имён стабов в прозе. Дословные исходные JSON скопированы в `evidence/`; соответствующие stdout/stderr лежат в `evidence/replay-r*-*.txt`.

| Круг / исходная мутация | Поведенческая rc | Статическая rc | Наблюдённые красные клетки |
|---|---:|---:|---|
| 1 / light-cta-noop | 1 | 0 | `CTA_OPENS_F03_01_LIGHT` |
| 1 / safearea-disabled | 1 | 0 | `SAFEAREA_EDGES_ACTIVE_DARK`, `SAFEAREA_EDGES_ACTIVE_LIGHT` |
| 1 / wordmark-wrong-source | 1 | 0 | `WORDMARK_SOURCE_BOUND_DARK`, `WORDMARK_SOURCE_BOUND_LIGHT` |
| 1 / android-splash-blue | 0 | 1 | `SPLASH_EFFECTIVE_GROUND_BOTH` |
| 1 / extra-unreviewed-copy | 1 | 0 | `FIRST_RUN_COPY_CLOSED_DARK`, `FIRST_RUN_COPY_CLOSED_LIGHT` |
| 2 / new-light-edges-top-bottom | 1 | 0 | `SAFEAREA_EDGES_ACTIVE_LIGHT` |
| 2 / new-light-wrong-source | 1 | 0 | `WORDMARK_SOURCE_BOUND_LIGHT` |
| 2 / new-light-extra-copy | 1 | 0 | `FIRST_RUN_COPY_CLOSED_LIGHT` |

## Пять вопросов критика — в границах арбитража

1. **Слабее ли критерий предмета в П-1…П-5?** Нет: инварианты К3/К4/К5 наблюдаются в обеих заявленных схемах, а не только названы суффиксами. Три прежних обхода теперь красны ровно по своему light-дефекту.
2. **Доказывается ли готовность командами?** В назначенном перечне — да, rc и наблюдения приведены выше; числа не приняты только из итоговой строки пробы.
3. **Оставлено ли решение исполнителю?** Нового незаданного решения в дельте нет: литералы, произведение scheme(2), мутации и привязки определены; модель и статическая семья сохранены. Отложенная продуктовая приёмка не расширялась.
4. **Названы ли границы?** Зоны architect/implementer и судей сохранены; дельта круга 3 — контракт, поведенческая батарея и её MUTANTS. Изменений модели, оракула, статической семьи и frozen-семейств нет.
5. **Есть ли противоречие нормам в рассматриваемой дельте?** Не обнаружено: ожидания К3/К4/К5 — прежние литералы, назначение named/depends проверено по коду полным прогоном, обе двери rc0. Из принятой арбитром прозы и остаточных рисков новый блокер не выводился.

## Советы

Новых советов нет. Принятый арбитром остаток кругов 1–2 (К2′ ×1, Android dark override, визуальное обрамление, PNG-пиксели, форма ПЕРЕСЕЧЕНИЕ и отложенная визуальная приёмка) не переоткрывался и не служил основанием решения.

## Сырой вывод отдельно от диагноза

- `evidence/results.json` — argv-прогоны через `review.py`: rc/stdout/stderr для базового дерева, обеих моделей, обеих матриц и восьми replay; отдельные `.txt` содержат также COMMAND и CWD.
- `evidence/model-probe.txt`, `evidence/model-static_probe.txt`, `evidence/matrix-probe.txt`, `evidence/matrix-static_probe.txt` — полный вывод основных CLI.
- `evidence/replay-r2-light-*-probe.txt` и `*-static_probe.txt` — независимое применение трёх исходных мутаций; `evidence/mutation-identity.json` — точное равенство замен данным критика круга 2.
- `evidence/replay-r1-*.txt` — пять исходных мутаций круга 1.
- `evidence/model-jest-independent.txt`, `evidence/scoped-995-entry.txt` — прямые Jest-наблюдения.
- `evidence/gates.txt` — дословный вывод двух живых bash-дверей с rc.
- `evidence/status-before.txt`, `evidence/status-after.txt`, `evidence/base-head.txt` — база и восстановление.
- `evidence/integrity.json`, `evidence/r3-frozen-diff.txt`, `evidence/all-rounds-frozen-diff.txt` — committed-байты, неизменность, оракул, CI-пин и точные множества красных клеток.
- `evidence/arbitration-committed.md` — проверенный блоб арбитража с main.

**NOT_RUN:** полный npm test/lint/typecheck, полный регресс 995/999, CI, Android APK/Maestro, визуальная проверка устройства. Они не входят в закрытый перечень этого круга. Accept разрешает заморозку текста OBJECT; это не accept будущей реализации C.

Вердикт сохранён в назначенном каталоге; перенос и коммит на ветку предмета — оркестратору в пиннованной сессии. В этой сессии коммиты прямо запрещены.
