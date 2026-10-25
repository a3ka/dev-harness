accept
OBJECT=18c0f937db8ac02014d1a933c63dcf26c8666028
СУД: repo=dev-harness; предмет=138; фаза=контракт; роль=critic; вызов=по-перечню-арбитра (после 3 вызовов критика кр.1–3 и арбитража №1/№2/сверки); модель-план=anthropic/opus (роль critic, верхний уровень чужого семейства); сессия=Critic138fin; модель-факт=openai-codex/gpt-6-sol; SHA=18c0f937db8ac02014d1a933c63dcf26c8666028; предыдущий=verdicts/arbitration/contracts-138-sverka.md (accept); исключение=слово владельца 2026-10-25 (ОДИН вызов по перечню арбитра заранее)

# Узкий суд по решению арбитра 138-2

Судится закоммиченный OBJECT, закрытый перечень `/tmp/dev-harness-verify/orch/keep138/contracts-138-arbitraz-2.md` (таблица, A–H) и блокеры B1/B2 круга 3; реализация Android не судится. Прочитана сверка арбитра `contracts-138-sverka.md` (accept). **ВНИМАНИЕ учёту:** моя фактическая модель по данным окружения openai-codex/gpt-6-sol отличается от плана anthropic/opus в HANDOFF. Архитектор — GLM, согласно сверке арбитра, поэтому семейства различны; оркестратор до материализации обязан подтвердить `сессия` и `модель-факт` по трейсу, дописать HANDOFF и сверить независимость. Доступ к трейсу у критика не заявлен. Этот файл только передаётся оркестратору, без commit/push.

## Живые команды, замеры

Рабочий клон создан `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Critic138fin/repo` → rc 0. `git checkout -q -b wip/138/critic-fin e56edc322f140ac9217ef778d1499134ef2fc1ae` → rc 0; `GIT_COMMITTER_NAME=architect GIT_COMMITTER_EMAIL=architect@dev-harness.local git -c core.hooksPath=/tmp/dev-harness-verify/nohooks am /tmp/dev-harness-verify/Architect138/patches4/000{1,2,3,4}-*.patch /tmp/dev-harness-verify/Architect138/patches5/0001-*.patch` → rc 0, пять `Applying: 138…`. `git rev-parse HEAD^{tree}` и `git -C /tmp/dev-harness-verify/Architect138/repo rev-parse 18c0f937^{tree}` → оба `b43fd10aba533fcce8d0d0069f0f5c58a8680bca`: все tracked-файлы идентичны OBJECT. `diff -r` контракта → rc 0; `diff -r` семьи → rc 1 только из-за трёх неотслеживаемых `__pycache__` у автора (tree equality разрешает эту несущественную разницу).

Из корня клона:

| команда | rc | наблюдение |
|---|---:|---|
| `python3 fixtures/workshop_project/start_ekran_138/probe.py --model` | 0 | 68 `CASE … ok`, 11 зелёных/57 красных ожиданий |
| `python3 fixtures/workshop_project/start_ekran_138/probe.py --stabs` | 0 | контроль 68/68, 51 `STAB … KRASEN`, `SVJAZI 51`, живых 0 (30 стабов) |
| `env TMPDIR=/tmp/dev-harness-verify/Critic138fin bash fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh` | 1 | 11 `CASE … ok` + 57 `CASE … KRASNO` (штатный безфлаговый режим с субъектом) |
| `python3 /tmp/dev-harness-verify/Critic138fin/no_subject.py` | 0 | копия без субъекта: `COMMAND bash …/red_start_ekran_138.sh rc 1`; `SHABLON_ABSENT`; `KRASNO 68`; stderr `''` |
| `bash scripts/pre_critic.sh contracts/138-start-ekran.md` | 0 | `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3`; `КРИТИК: дверь зелёная` |
| `env TMPDIR=/tmp/dev-harness-verify/Critic138fin bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic138fin/repo contracts/138-start-ekran.md` | 0 | `OK` |
| `node /tmp/dev-harness-verify/Critic138fin/syntax.cjs` | 0 | Babel `typescript,jsx`: 4 стенд-ина + 8 новых форм H2/H3/C — каждое `BABEL … OK` |
| `bash fixtures/workshop_project/first_run_ekran_135/red_first_run_ekran_135.sh --stabs` | 0 | `SVJAZI 13` |
| `bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh --stabs` | 0 | `SVJAZI 37` |
| `bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh --stabs` | 0 | `SVJAZI 38` |
| `bash scripts/check_provodka.sh . contracts/138-start-ekran.md` | 1 | `проводка: guard не подключён: fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh не вызывается в .githooks/ или .github/workflows/` — оркестратор подключит в интеграции |

Первый параллельный precision-gate тоже rc 0 `OK`, но вывел шум отсутствующих файлов в общем `/tmp/lib_zones.*`; отдельный запуск с изолированным TMPDIR выше чист. `git diff --exit-code frozen/contracts/108/1 HEAD -- contracts/108-cmp-mob-004-start.md` и аналогично 995/1, 117/3, 118/1, 135/1 → rc 0 ×5, без вывода. `git diff --exit-code e56edc322 HEAD -- fixtures/workshop_project/first_run_ekran_135 fixtures/workshop_project/erstinformation_118 fixtures/workshop_project/ekran_shablon_132` → rc 0. Frozen-владельцы названы в ЗОНА/ПЕРЕСЕЧЕНИЕ 138: implementer только `mobile/src/features/start/`, `mobile/.maestro/`, `mobile/e2e-start/`, `.github/workflows/mobile.yml`; auth/app/mocks/api-client/tab-shell вне зоны. Исполнители architect/critic/implementer/reviewer/adversary названы. Тег в `contracts/138-start-ekran.md:3` — `id/CONTRACT/138`, прежней опечатки `ConTRACT` нет.

`python3 /tmp/dev-harness-verify/Critic138fin/audit.py` → rc 0. Источник `source.json`: **68 входов (11/57), 30 стабов, 51 связь, 16 PNG, 8 кадров**; контракт пачки — **60 строк / ширина 108 / 3998 байт**, `SYNC True` для `proverka_tekst`, `flow`, `kontrakt_tekst`. Замер на продукте `/tmp/dev-harness-verify/Impl118g/mob`, старая маска из 7c22be4d против кандидата: **80 уникальных литералов, 82 вхождения, 10 файлов, 0 расхождений и 0 несовпадающих масок** (`PRODUCT 80 82 10 diffs 0 mask_diffs 0`). Проверены `probe.py:650-885`, `source.json.stab_vhod`, `stubs/s51…s64.py`, `teksty/proverka_text.py:266-317`: на 7 защит лексера и 7 элементов места — отдельный стаб, импортирующий настоящую проверку и выключающий одну защиту, и различающая красная клетка. Формы `__tests__/helper.tsx`, `__snapshots__/f.tsx`, экранированные разделители и line continuation; три прежние зелёные и четыре продуктовые зелёные C не краснеют. `NE_EKRAN_IMENA` только `.test.`, `.spec.`, `.stories.`; мёртвые `.d.ts`/`.snap` удалены, расширения отдельно отсечены белым списком. s49/s50 удалены. Проза контракта не назначает связи — их назначает `stab_vhod`.

### Собственные независимые мутации, по всем 57 proverka-входам каждая

Одна команда `python3 /tmp/dev-harness-verify/Critic138fin/audit.py` создаёт мутантов только в одноразовой собственной области и вызывает настоящие `probe.run_subject`/`judge`. Сырой вывод (защита → количество и имена клеток, отвергнувших мутант):

```text
PROVERKA_CASES 57
MUTANT H1-minus-line KILLED 3 ['proiskhozdenie-selektor-nositel-v-kommentarii', 'proiskhozdenie-nositel-kommentarij-hvost', 'proiskhozdenie-nositel-kommentarij-stroka']
MUTANT H1-minus-block KILLED 5 ['proiskhozdenie-nositel-kommentarij-blok', 'proiskhozdenie-nositel-kommentarij-blok-mnogostrochnyj', 'proiskhozdenie-nositel-kommentarij-jsdoc', 'proiskhozdenie-nositel-kommentarij-jsx', 'proiskhozdenie-nositel-kommentarij-jsx-mnogostrochnyj']
MUTANT H2-minus-quotes KILLED 4 ['proiskhozdenie-selektor-nositel-v-stroke', 'proiskhozdenie-nositel-stroka-odinarnaja', 'proiskhozdenie-nositel-stroka-dvojnaja-ekranirovannaja', 'proiskhozdenie-nositel-stroka-prodolzhenie']
MUTANT H2-minus-quote-escape KILLED 2 ['proiskhozdenie-nositel-stroka-dvojnaja-ekranirovannaja', 'proiskhozdenie-nositel-stroka-prodolzhenie']
MUTANT H2-minus-continuation KILLED 1 ['proiskhozdenie-nositel-stroka-prodolzhenie']
MUTANT H2-minus-template KILLED 3 ['proiskhozdenie-nositel-stroka-shablon', 'proiskhozdenie-nositel-stroka-shablon-ekran-backtick', 'proiskhozdenie-nositel-stroka-shablon-ekran-bekslesh']
MUTANT H2-minus-template-escape KILLED 2 ['proiskhozdenie-nositel-stroka-shablon-ekran-backtick', 'proiskhozdenie-nositel-stroka-shablon-ekran-bekslesh']
MUTANT H3-minus-tests KILLED 1 ['proiskhozdenie-nositel-mesto-tests']
MUTANT H3-minus-mocks KILLED 1 ['proiskhozdenie-nositel-mesto-mocks']
MUTANT H3-minus-snapshots KILLED 1 ['proiskhozdenie-nositel-mesto-snapshots']
MUTANT H3-minus-test KILLED 1 ['proiskhozdenie-nositel-mesto-test-fajl']
MUTANT H3-minus-spec KILLED 1 ['proiskhozdenie-nositel-mesto-spec-fajl']
MUTANT H3-minus-stories KILLED 1 ['proiskhozdenie-nositel-mesto-stories']
MUTANT H3-minus-suffix KILLED 3 ['proiskhozdenie-nositel-mesto-d-ts', 'proiskhozdenie-nositel-mesto-snap', 'proiskhozdenie-nositel-mesto-ne-kod']
MUTANTS 14 ALIVE 0
```

В той же команде четыре независимых дерева-свидетеля круга 3: валидатор V для каждого rc 0 (сырые `KADR` ×8 `1.000 0.600 G OK`, `SHABLON start-ekran OK`); проверяющий Pr даёт:

```text
WITNESS escaped-backtick Pr rc 1 stdout '' stderr 'PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer\n'
WITNESS line-continuation Pr rc 1 stdout '' stderr 'PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer\n'
WITNESS tests-helper Pr rc 1 stdout '' stderr 'PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer\n'
WITNESS tests-helper Pr-minus-tests rc 0 stdout '' stderr ''
WITNESS snapshots Pr rc 1 stdout '' stderr 'PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer\n'
```

Таким образом B1 (экранированный бэктик, также продолжение строки) теперь красный; B2 (`__tests__/helper.tsx` без `.test.`) красный И единственный мутант «минус `__tests__`» отвергнут соответствующей отдельной клеткой. Поведение/граница A–H выполнены: `${…}` не разбирается; `&&`/`?:`/`if` и достижимость лексер не вычисляет; `.d.tsx` рассматривается как обычный код `.tsx` по алфавиту и решению сверки арбитра; H4/H5 переданы реальному Maestro `assertVisible` → FLOW_BEZ_DOSTIZHENIJA/E2E_NE_PROSHLA и ревью. Дословные строки лексического и H4/H5 остатка прочитаны в §НЕ ЗАЩИЩАЕТ, совпадают со сверкой арбитра.

## Находки и решение

**БЛОКИРУЕТ:** нет в разрешённом перечне. Предмет, критерии с исполнимыми командами и rc, зоны/исполнители, класс риска и модель угроз присутствуют. Нового обязательства вне решения не вводилось; прежние проверки G/H не ослаблены.

**СОВЕТ contracts/138-start-ekran.md:85-86** — проводка `check:start-ekran-138-family-selftest` пока отсутствует в CI харнесса (`check_provodka.sh` rc 1 выше). Оркестратор объявлен ответственным за строку `step\tcheck:start-ekran-138-family-selftest\t22\tbash fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh --stabs` в `registry/ci-steps.tsv` (вне зоны architect). Перед freeze проверить rc 0 после интеграции; не выдаю сегодняшний rc 1 за зелень.

**СОВЕТ contracts/138-start-ekran.md:102** — дословно исполненная строка решения называет любой `${…}` остаток ложным красным, хотя вложенный бэктик может дать ложное зелёное. Менять принятое владельцем решение/границу в этом суде нельзя; это редакционное уточнение для v+1, не условие accept.
