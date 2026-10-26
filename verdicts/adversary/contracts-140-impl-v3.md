accept
OBJECT=e26f0c06312b3ecceb1e5c73f1893cd778ba20f1
СУД: repo=dev-harness; предмет=140; фаза=реализация; роль=adversary; вызов=3 (решение арбитра); сессия=Adv140c; модель-факт=openai-codex/gpt-5.6-terra

Изолированный SSH-клон: /tmp/dev-harness-verify/Adv140c/repo; `git rev-parse HEAD` → `e26f0c06312b3ecceb1e5c73f1893cd778ba20f1`.

## БЛОКИРУЕТ

Нет. Ни одна построенная обманная реализация источника класса риска не прошла дверь: рискованный предмет не был пропущен как обычный, а все неоднозначные/неразбираемые источники остановлены до START reviewer.

## СОВЕТ

Нет.

## Сырые прогоны и наблюдения

```text
$ bash /tmp/dev-harness-verify/Arbiter140/probe_real.sh /tmp/dev-harness-verify/Adv140c/repo /tmp/dev-harness-verify/Adv140c/repo/scripts/zamok_predmeta.sh
116 obychnyj
118 risikovyj
136 risikovyj
138 obychnyj
139 obychnyj
140 risikovyj
141 obychnyj
[rc=0]

$ python3 /tmp/dev-harness-verify/Adv140c/q2_adversary_probe.py
real-116, real-138, real-139, real-141: rc=0, judge_starts=1, PUSCHEM
real-118, real-136, real-140: до adversary rc=1, judge_starts=0, ADVERSARIJ_DO_REVJUERA; после yielded adversary rc=0, judge_starts=1, PUSCHEM
real-140-full: до adversary rc=1, judge_starts=0, ADVERSARIJ_DO_REVJUERA; после yielded adversary rc=0, judge_starts=1, PUSCHEM
two-identical, mention-only, typo-value, glued, empty: rc=1, judge_starts=0, KLASS_RISKA_NET
tab-risk, many-blanks-risk: rc=1, judge_starts=0, ADVERSARIJ_DO_REVJUERA
term-dot, term-comma, term-semicolon, bom-ordinary, quote-template: rc=0, PUSCHEM
crlf-bare-risk: rc=1, judge_starts=0, KLASS_RISKA_NET
symlink-live, symlink-dangling, directory-md, conflict-ab, conflict-ba, zero-files: rc=1, judge_starts=0, KLASS_RISKA_NET
Q2_CASES 31 FAILED 0
[rc=0]

$ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh
KLETKI 63 KRASNYH 0
[rc=0]
$ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model
63 CASE ... ok
[rc=0]
$ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs
SVJAZI 60
SUBJEKT_SVJAZI 60
STAB_ZHIV отсутствует
[rc=0]

$ env -i PATH=/usr/bin:/bin HOME=... TMPDIR=... /usr/bin/bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh
KLETKI 63 KRASNYH 0
[rc=0]
$ env -i PATH=/usr/bin:/bin HOME=... TMPDIR=... /usr/bin/bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model
63 CASE ... ok
[rc=0]
$ env -i PATH=/usr/bin:/bin HOME=... TMPDIR=... /usr/bin/bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs
SVJAZI 60
SUBJEKT_SVJAZI 60
[rc=0]
$ env -i PATH=/tmp/dev-harness-verify/Adv140c/empty-path ... /usr/bin/bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs
NOT_IMPLEMENTED: нет python3
[rc=2]

$ bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh  # три последовательных прогона
PROB VSEGO 15 KRASNYH 0
PROB VSEGO 15 KRASNYH 0
PROB VSEGO 15 KRASNYH 0
[rc=0]
$ bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta
БАТАРЕЯ zamok_predmeta: итог 4/4 классов закрыто
[rc=0]

$ python3 /tmp/dev-harness-verify/Adv140c/tamper_probe.py
model rc=2 OK ORACLE_TAMPERED: sha256 носителя model/zamok_predmeta.sh
carrier rc=2 OK ORACLE_TAMPERED: sha256 носителя s01-bez-dublja-rabochego
[rc=0]

$ python3 /tmp/dev-harness-verify/Adv140c/old_door_probe.py
73aa92b7 rc=1 red=s23 s24 s25 s28 s29 s30 s31 s33 s35 s36 s37 OK
9ec350f7 rc=1 red=s29-klass-riska-realnaja-116 s30-klass-riska-realnaja-139 s31-klass-riska-realnaja-140 s36-klass-riska-simlink s37-klass-riska-citata-shablona OK
[rc=0]

$ git diff --exit-code 73aa92b7a0b0d756f26c35a06f5f529154cf37da..e26f0c06312b3ecceb1e5c73f1893cd778ba20f1 -- .omp/extensions/spawn-guard.ts
[rc=0]
```

Позитивный контроль: честная обычная декларация и все четыре реальные обычные формы проходят; рисковые реальные формы до yield adversary отказывают именно `ADVERSARIJ_DO_REVJUERA`, а после yield — пропускают reviewer. Негативные контроля: старые двери красны; v3 дверь 9ec350f7 красна ровно на s29/s30/s31/s36/s37; стаб `x01-vsegda-puschem` красен в `--stabs` (12 связей).

Проверенные классы: реальная форма в середине строки, хвост ` (` / ` —` / `.`; полный 140 с не-декларационным упоминанием; две одинаковые декларации; упоминание без декларации; вне алфавита; слипшееся значение; пустое значение; TAB/несколько пробелов; `.`, `,`, `;`; CRLF; BOM; живой/битый симлинк и каталог `NNN-*.md`; цитата шаблона; ноль файлов; конфликт двух файлов в обоих порядках; отсутствие инструмента в PATH; подмена модели/носителя; станционная интеграция и неизменность spawn-guard.

## Не проверено

Живой `omp`-стенд не запускался: это scoped-повтор по точному перечню решения арбитра, а станционная интеграция прошла 15/15 три раза. Вне перечня не проверялись fenced-блок и подкаталог `contracts/sub/`.