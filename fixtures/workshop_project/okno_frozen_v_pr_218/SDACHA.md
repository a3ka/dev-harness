# СДАЧА 218 — собственное окно PR, исправление батареи по Adv218

OBJECT=682fb9881c94cf674b107d99238102b0313eb18d
Reference baseline: source.json/baseline = a32c577f292a2e925417d78a85cdb00abf25fae3.
Вход: 7c980484af:verdicts/adversary/contracts-218-impl-v1.md, FAIL, Б-1…Б-4.
Изменяется только эта семья фикстур. Контракт 218/1, production, CI и реестры не меняются.
Батарея намеренно красна на OBJECT: исправление production — работа Impl218b.

## Двери

- production-красный · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --repo . · 1 · 1
- честная-модель · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --stabs · 0 · 0
- синтаксис · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --sintaksis · 0 · 0
- каталог · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --catalog · 0 · 0
- живые-мутанты · python3 fixtures/workshop_project/okno_frozen_v_pr_218/production_mutants.py · 0 · 0
- CI-паритет · bash scripts/gen_ci_steps.sh --check · 0 · 0
- контекст · python3 fixtures/workshop_project/okno_frozen_v_pr_218/context.py · 0 · 0

Синтаксис выполнен с VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck.
Полные pre_critic/check_sdacha/done в этом исправительном задании не запускались и не объявляются зелёными.

## Карта классов

- К-01 · чисто · вход: исправительный task-architect218c.md, все его двери перечислены выше; новый суд/freeze/done не объявляется · - · -
- К-02 · чисто · вход: замороженный контракт 218/1 и вердикт Adv218 прочитаны; SourceCanon не объявлен · - · -
- К-03 · чисто · python3 fixtures/workshop_project/okno_frozen_v_pr_218/context.py · 0 · 0
- К-04 · чисто · вход: только fixtures/workshop_project/okno_frozen_v_pr_218/; production меняется только внутри одноразовых мутантных клонов · - · -
- К-05 · чисто · вход: команды и ожидаемые/наблюдённые rc в разделе Двери · - · -
- К-06 · чисто · вход: настоящий Git, bare origin, plumbing, PATH-инъектор только rc 127; ошибка инструмента/якоря не считается поимкой · - · -
- К-07 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model · 0 · 0
- К-08 · чисто · python3 fixtures/workshop_project/okno_frozen_v_pr_218/production_mutants.py · 0 · 0
- К-09 · чисто · вход: до/после импорта удаления контракта, вердикта и обоих; версии v1/v2/v3 contracts/plans; несколько документов; ошибки чтения PR-области · - · -
- К-10 · чисто · вход: rc, независимый литерал предметной причины, неизменность HEAD/index/cache; прежний Trace2-критерий не менялся · - · -
- К-11 · чисто · вход: Cell/диагноз и Git-факты мира сняты до субъекта; диск субъекта не источник ожиданий · - · -
- К-12 · чисто · вход: Git для DAG/блобов, stdlib JSON для Trace2/стабов, канонический TSV из stabs/*.json; bash -n и validate_std · - · -
- К-13 · н/п · секретов и owner-identity нет, разрешения синтетические в мирах · - · -
- К-14 · чисто · вход: каждый FAIL по версии имеет accept-контроль; обе частичные per-document авторизации имеют общий разрешённый контроль; прежние clean/legacy миры сохранены · - · -
- К-15 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --catalog · 0 · 0
- К-16 · чисто · вход: доверенный PATH не объявляется атакой; инъектор воспроизводит ошибку Git, прочие исключения frozen-контракта не расширены · - · -
- К-17 · н/п · станционный guard, продуктовой модели 188 нет · - · -

## Дельта

- Б-1 / К-09 · клетка · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model · 0 · 0
- Б-2 / К-08 · клетка · python3 fixtures/workshop_project/okno_frozen_v_pr_218/production_mutants.py · 0 · 0
- Б-3 / К-08 · клетка · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --stabs · 0 · 0
- Б-4 / К-08 · клетка · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --stabs · 0 · 0

Снятие/граница невозможны без ослабления И2/И4/И5. Канон Git устанавливает DAG и блобы,
но сам не доказывает решение CLI, поэтому использованы поведенческие клетки в прежнем observe.
Новых дверей сверх задания и новых production-предикатов нет.

Б-1: настоящий собственный коммит несёт FAIL v2 и аннотированный frozen/contracts/NNN/2.
В main удаляется контракт, вердикт либо оба, merge импортирует удаление. Каждый вариант
предъявлен до и после merge, независимо для обоих CLI. Для frozen ожидаются rc 1 и литерал
«заморозка v2 лежит поверх вердикта, который её не разрешил»; при удалённом вердикте
источник свидетельства — собственная заморозка, не исчезнувший HEAD-путь.
Charter не судит accept-вердикты: его парные миры содержат собственную неразрешённую
правку контракта и сохраняют причину «без разрешения владельца» после импорта удаления.
Reference ищет артефакт также в исторических деревьях и, только при отсутствующем
HEAD-вердикте собственной заморозки, читает вердикт её основания. Существующий HEAD FAIL
не заменяется историческим accept. s27/s28 отдельно возвращают оба дефекта.

Б-2: только вердикт существующей main-заморозки изменяется в PR; собственный frozen-тег
не маскирует пропуск scope. Проверены contracts/plans, v1/v2/v3 при максимальной v3,
FAIL и разрешённая правка пояснения accept. s16/s17/s18 ограничивают область v1,
последней версией и только accept соответственно.

Б-3: один собственный коммит меняет AGENTS.md и ROADMAP.md; разрешение дано одному,
другому, обоим либо ни одному. s19/s20 исключают раздельно каждый документ и привязаны
только к ветви, где именно исключённый документ не разрешён.

Б-4: настоящий Git строит мир; только вызов субъекта получает PATH-инъектор rc 127.
Отдельно падают общая diff-tree, MD diff-tree, rev-list, ls-tree области, каталог тегов
и чтение peeled-тега. Для каталога первый успешный вызов оставляет registry_state
работоспособным, последующие чтения падают в PR-коде. Файл injected подтверждает
достижение инъекции, но не задаёт ожидаемую причину. s21…s26 подавляют эти отказы
раздельно; обычные Git-миры служат честными эквивалентами без отказа инструмента.

## Наблюдавшиеся измерения

До: 71 клетка, 15 стабов, 32 связи (база и вердикт Adv218).
После: CELLS=108 MUTATIONS=28 BINDINGS=53; добавлено 37 клеток, 13 стабов, 21 связь.
Старые клетки/ожидания и их наблюдатель не удалены и не ослаблены.

--repo на OBJECT: rc 1, KLETKI=108 ZELENYE=105 KRASNYE=3 (34.69 с).
Только Б-1:

```
frozen-own-v2-delete-contract-after RED rc=0 DIAGNOSIS,RC
frozen-own-v2-delete-verdict-after RED rc=1 DIAGNOSIS
frozen-own-v2-delete-both-after RED rc=0 DIAGNOSIS,RC
```

--model: rc 0, KLETKI=108 ZELENYE=108 KRASNYE=0 (32.96 с).
--stabs: rc 0, STABY=28 SVJAZI=53 POIMANY=53 ZHIVYH=0 (28.44 с).
--sintaksis: rc 0, SYNTAX rc=0. --catalog: rc 0, 108/28/53.
gen_ci_steps --check: rc 0. context.py: rc 0, INTERSECTIONS=88.

production_mutants.py: rc 0 (97.29 с), PRODUCTION_MUTANTS=3.
Каждый мутант воспроизведён в отдельном локальном клоне OBJECT; контроль на выбранном
новом входе зелёный, затем тот же вход красен после мутации, затем выполнен полный --repo:

| Мутант | Честный subject rc | Мутант subject rc | Новая различающая клетка | Полный --repo |
|---|---|---|---|---|
| verdict-v1-only | 1 | 0 | frozen-verdict-contracts-v2-fail | rc 1, 101 зелёная / 7 красных |
| hide-roadmap | 1 | 0 | charter-two-documents-agents | rc 1, 103 зелёных / 5 красных |
| delta-errors-clean | 1 | 0 | charter-git-fault-diff-all | rc 1, 101 зелёная / 7 красных |

Во всех трёх полных мутантных прогонах прежние 71 клетка зелены; красны Б-1 и новые
адресные предъявления. Это не поимка лишь по уже известному дефекту OBJECT.

Первый технический прогон нашёл неверную точку fault tags (раньше PR-кода), она исправлена
на последовательный отказ после registry_state; окончательный --repo имеет только Б-1.
Первый синтаксический прогон нашёл non-ASCII в bytes-литерале драйвера; исправлено .encode(),
окончательный синтаксический прогон зелёный. Порог и прежние ожидания не менялись.

## Граница и рефлексия

Adv218 прямо признал отклонение lib_pr_window НЕ самостоятельным нарушением:
общий код импортируется единожды из check_charter, контракт не требует создания нового файла.
CHARTER_LIB — прежняя библиотечная семантика в доверенной среде; её контракт не меняется.

Процессное наблюдение для оркестратора: общий Git fault на for-each-ref раньше ломает
registry_state, чем достигает PR-области; нужно адресно задавать последовательность успешного
и отказного чтений. Иначе проверяется другой отказ, и мутация pr_files остаётся недоказанной.
Журнал А-NN разрешён только отдельным коммитом в main; в этой wip-ветке не изменяется.
Scratch и мутантные клоны находятся внутри копии, вне судимых репозиториев;
TemporaryDirectory удаляет их по завершении. Внешний push не выполняется.
