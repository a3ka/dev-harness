FAIL

Диапазон: `ef32e2b..9100ecc`.

## Находка

- `workshop:96` — **область правки**. Замороженный план 007 разрешает исполнению только
  `scripts/`, `fixtures/`, `config/`, `package.json`, `.github/workflows/ci.yml`,
  `plans/007-reglament-vorkflou.md`, `contracts/`, `roles/`, `AGENTS.md`, `ROADMAP.md`,
  `HANDOFF.md`, `.omp/` и `plans/005-four-mechanisms.md`; судейские `verdicts/**` и
  `NABLIUDENIA.md` имеют отдельно названные основания. `workshop` в границу не входит.
  Коммит `ae89fd0377c3059964376233d20e111aef764a2e` автора `architect` меняет в нём
  33 строки и удаляет 9, начиная с добавления `RESUME` на строке 96. Это расширение
  диффа планом не объявлено, поэтому пачку нельзя принять независимо от того, полезен
  ли лаунчер.

  Доказательство, код 0:
  ```text
  $ git diff --name-only ef32e2b..HEAD -- . \
      ':(exclude)scripts/**' ':(exclude)fixtures/**' ':(exclude)config/**' \
      ':(exclude)package.json' ':(exclude).github/workflows/ci.yml' \
      ':(exclude)plans/007-reglament-vorkflou.md' \
      ':(exclude)plans/005-four-mechanisms.md' ':(exclude)contracts/**' \
      ':(exclude)roles/**' ':(exclude)AGENTS.md' ':(exclude)ROADMAP.md' \
      ':(exclude)HANDOFF.md' ':(exclude).omp/**' ':(exclude)verdicts/**' \
      ':(exclude)NABLIUDENIA.md'
  workshop
  $ git log --format='%H%x09%an%x09%s' ef32e2b..HEAD -- workshop
  ae89fd0377c3059964376233d20e111aef764a2e	architect	Архитектор переведён на glm-5.3; лаунчер умеет продолжать сессию
  $ git diff --numstat ef32e2b..HEAD -- workshop
  33	9	workshop
  ```

## Прогоны в чистом клоне

Все команды выполнены как `env -i PATH=/usr/bin:/bin HOME="$HOME" npm run --silent <имя>`
в `/home/aka/Documents/dev-harness/tmp/reviewer/clean`, созданном `git clone -q .` до
написания этого вердикта. Сырым выводом каждой команды были следующие строки; все коды — 0.

```text
check:ci-parity
workflow-команд: 12 · скриптов в приёмке: 19 · объявленных исключений: 7 · расхождений: 0

check:antiplacebo
барьеров: 16 · фикстур: 102 · предъявлено красным повторным прогоном: 102

check:gen
харнес соответствует roles/ (6 ролей)

check:ids
  ok   номера уникальны и согласованы с регистром выдачи

drill:next-id-race
  ok   атомарность выдачи: 001 и 002 — max+1 и max+2 от пустого репозитория, оба с тегами

check:protected
область: :(literal)plans/ :(literal)verdicts/adversary/ :(literal)verdicts/arbitration/ :(literal)verdicts/critic/ :(literal)verdicts/review/ · коммитов пройдено: 91 · существовало: 17 · на HEAD: 17 · исчезло: 0 · с разрешения: 0

drill:protected-exception
  ok   явное именное разрешение принято и названо в отчёте

check:contract-frozen
  ok   contracts/001-fikstura-antiplacebo.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
  ok   plans/005-four-mechanisms.md — черновик, не заморожен
  ok   plans/007-reglament-vorkflou.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
планов и контрактов на HEAD: 3 · черновиков: 1 · заморожено: 2 · реестр: full

check:zones
  ok   contracts/001-fikstura-antiplacebo.md — работа не раздаётся: кодифицирует уже действующее соглашение, заданий по нему не раздаётся
замороженных контрактов: 1 · зон не объявлено — проверять нечего

check:charter
  ok   AGENTS.md — уставной с ustav/1, коммитов в диапазоне 1, изменений без разрешения нет
  ok   ROADMAP.md — уставной с ustav/1, коммитов в диапазоне 1, изменений без разрешения нет
  ok   contracts/001-fikstura-antiplacebo.md — уставной с frozen/contracts/001/1, коммитов в диапазоне 5, изменений без разрешения нет
  ok   plans/007-reglament-vorkflou.md — уставной с frozen/plans/007/1, коммитов в диапазоне 5, изменений без разрешения нет
уставных документов: 4 · изменений в них: 0 · с разрешения: 0

drill:contract-change
  ok   шаг 1: контракт и вердикт критика v1 закоммичены
  ok   шаг 2: freeze_contract.sh выдал v1
  ok   шаг 3: устав введён тегом ustav/1
  ok   шаг 4: правка, вердикт v2 и строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в ОДНОМ коммите
  ok   шаг 5: freeze_contract.sh выдал v2
  ok   шаг 6а: check_contract_frozen.sh принял v2 и назвал её
  ok   шаг 6б: check_charter.sh принял правку и назвал разрешение
процедура принята целиком: шесть шагов, оба барьера зелёные и оба назвали предмет
```

## Отдельные проверки ревьюера

- Шапки новых `freeze_contract.sh`, `check_contract_frozen.sh`, `check_charter.sh`,
  `check_zones.sh`, `drill_contract_change.sh` объявляют `0/1/2`; анти-плацебо предъявил
  их красные ветви кодом 1 и зелёные ветви выше назвали предмет. У `check_contract_frozen`,
  `check_charter`, `check_zones` и дрилла зелёный вывод назван по каждому применимому предмету.
- Числа проверены иной мерой: `git ls-files 'fixtures/**/case_*.sh' | wc -l` → `102`;
  поиск `Коды возврата:` в `scripts/` дал 16 барьеров, включая `gen-harness.ts`; в CI 12
  запусков `npm run`, в `package.json` 19 скриптов, а в `config/ci_parity_exceptions.txt`
  семь записей формата `<имя> = <причина>`. Эти значения совпадают с выводом паритета и
  анти-плацебо.
- После `ustav/1^{commit}=e410e36e69f6c7e175d6ed2fb384eef43487b1d8` команда
  `git log ustav/1..HEAD -- AGENTS.md ROADMAP.md plans contracts` не напечатала ни одного
  коммита. Замороженные нормы не менялись.
- История показывает, что механизмы и их фикстуры писал `architect`; для этой пачки это
  прямо разрешённое владельцем однократное исключение в замороженном плане 007,
  «Кто исполняет и в каких границах», строки 398–435. Подгонка проверок под код отдельно
  не обнаружена: 102 фикстуры повторно выполнили красный вызов через `$BARRIER`.

Единственная блокирующая причина отказа — неразрешённая правка `workshop`.
