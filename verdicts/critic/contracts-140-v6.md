FAIL

OBJECT=880ed662d7e531d9ab9ae66c7938dbab2403c1d4

СУД: repo=dev-harness; предмет=140; фаза=контракт v6/R0191, scoped; роль=critic; вызов=9/2; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit140R0191Scoped9; модель-факт=не установлена собственной bind-трассой; SHA=880ed662d7e531d9ab9ae66c7938dbab2403c1d4; предыдущий=verdicts/critic/contracts-140-v5.md; исключение=SANKCIJA консультанта 2026-11-28T03:13:44Z по ADR2026-11-24/m2729, по заданию. Фактическую модель и привязку этой сессии обязан материализовать оркестратор по собственной трассе; назначение не является фактом трассы. Предыдущий accept относится к 3d82fe0f8ecc9f3a8dcbb9b3785192dac939d880, не к настоящему OBJECT.

Scope: R0191 Ф0, непосредственно затронутые привязки 208 и фазовая проводка, без пересуда неизменённой старой 140. Источник — собственный независимый SSH-клон вне /zones/, detached OBJECT; автор OBJECT architect. Доступ к собственному OBJECT подтверждён git rev-parse rc 0. Предыдущий полный pre_critic rc 0 сообщён заданием, не собственный прогон.

БЛОКИРУЕТ contracts/140-odin-agent-na-predmet.md:97 — несовместимые фазы и отсутствующий путь подключения нового guard.
ОБЯЗАТЕЛЬСТВО: пункт 9 требует обычный check_provodka rc 0 до суда; строки 175, 181, 184 помещают подключение в окно freeze..done, а строка 190 добавляет новый guard process_ekrany_140.py. Обычный check_provodka остаётся обязательной дверью done (scripts/done_contract.sh:639–654).
СОСТОЯНИЕ: OBJECT до реализации и freeze; в registry/ci-steps.tsv:283 подключён только W с --model, в .githooks, .github/workflows, registry/ci-steps.tsv и harness.project.json имя process_ekrany_140 отсутствует. scripts/check_provodka.sh:379–480 проверяет физическое подключение каждого guard, а не только грамматику. Контракт:175 поручает оркестратору одну строку W без флага, но не подключение нового F-guard; СДАЧА откладывает обычный gate и предъявляет только --grammar.
НАБЛЮДЕНИЕ: заявленное до суда rc 0 не следует из grammar и прежнего pre_critic; после только указанного переключения W новый F-guard тоже остаётся неподключённым, поэтому обязательный done-gate не достижим предусмотренной раздачей. Обычный gate досрочно не запускался и его rc не приписывается. Должны быть согласованы фаза реально обязательной проверки и исполнимый путь подключения каждого объявленного guard до done без ослабления позднего rc 0.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-07

## Карта классов

К-01: чисто — собственный check_sdacha --run rc 0, двери=20 карта=17/17 дельта=0.
К-02: чисто — вход R0191/m2701 и закреплённый материал R-0136/R-0139; sourceCanon=null.
К-03: чисто — вход И-1а и 208-привязки в СДАЧА; общий D9/D11 не отменён.
К-04: блок — F объявлен guard, но указанная оркестратору проводка включает только W.
К-05: блок — п.9 требует обычный gate до суда, тогда как сдаточный лист относит его к поздней фазе.
К-06: чисто — вход private_session_paths и исключение раннера rc 2 при недоступной среде.
К-07: блок — несовместимые фазы и отсутствующий путь подключения нового guard.
К-08: чисто — вход собственная мутация обнаружения PROCESS и F --stabs в листе; прочие старые поверхности вне scoped-поиска.
К-09: чисто — вход CASES, flat/batch, session и отрицательные запросы в process_ekrany_140.py.
К-10: чисто — вход cell(): результаты hook и вызовы двери плюс побайтовые снимки state.
К-11: чисто — вход загрузка hook/reference/policy и ожиданий до вызова субъекта.
К-12: чисто — вход реальные Git, hook и проверка policy blob, источник process_ekrany_140.py.
К-13: н/п — новые секреты не заявлены.
К-14: чисто — вход honest контроль собственной мутации; честные flat/ssh/title описаны CASES.
К-15: чисто — вход CASES и MUTATIONS в process_ekrany_140.py; старые числа листа явно исторические.
К-16: чисто — вход риск и модель угроз в контракте; actual модель не заменена полем item.model.
К-17: н/п — sourceCanon=null, новая архитектурная схема не заявлена.

## Сдаточный лист

`env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL -u SDACHA_OKRUG TMPDIR=/tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/tmp PYTHONDONTWRITEBYTECODE=1 SDACHA_TIMEOUT_SEK=180 SDACHA_BUDZHET_SEK=900 VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck VALIDATE_STD_PYTHON=/usr/bin/python3 bash /tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/scripts/check_sdacha.sh /tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo contracts/140-odin-agent-na-predmet.md --run` → rc 0, сырой stdout:

```text
СДАЧА: лист зелёный (двери=20 карта=17/17 дельта=0)
```

Лист содержит F-preflight, F-production-current с ожидаемым rc 1, F-model, F-stabs, W и precision; это не отдельные повторные прогоны и не production F после реализации.

## Собственная мутация

Изменена в памяти проверка `line.startsWith('PROCESS=')` на `line === 'PROCESS=PROCESS-EKRANY'`, т.е. отказ от проверки ошибочного PROCESS=, при сохранении честного значения. Одноразовый собственный private-мир; скрипт `tmp/critic140_mutation.py`. Команда `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL -u SDACHA_OKRUG TMPDIR=/tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/tmp PYTHONDONTWRITEBYTECODE=1 timeout 180 python3 /tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/tmp/critic140_mutation.py` → rc 1, ожидаемая краснота; честный контроль зелёный. Сырой результат:

```text
F0 recognition honest OK {"result": null, "calls": []}
F0 recognition fake-process KRASNO {"result": {"block": true, "reason": "ОТКАЗ: SUBJECT_NET_V_ZADANII: item 0: строка ^SUBJECT=[0-9]{3}$ отсутствует"}, "calls": [{"argv": ["/tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/tmp/critic140-recognition/worlds-lsrbjb_s/attack/recognition/fake-process/install/scripts/zamok_predmeta.sh", "--sudit", "--sostojanie", "/tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/tmp/critic140-recognition/worlds-lsrbjb_s/attack/recognition/fake-process/state/zamok", "--zhurnaly", "/tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/tmp/critic140-recognition/worlds-lsrbjb_s/attack/recognition/fake-process/state/zones/dev/.omp/profiles/dev/agent/sessions", "--repo", "/tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/tmp/critic140-recognition/worlds-lsrbjb_s/attack/recognition/fake-process/product", "/tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/tmp/critic140-recognition/worlds-lsrbjb_s/attack/recognition/fake-process/state/.zamok140-event-1513316-b5c8c5f2a5k.json"], "rc": 1, "stdout": "", "stderr": "ОТКАЗ: SUBJECT_NET_V_ZADANII: item 0: строка ^SUBJECT=[0-9]{3}$ отсутствует\n"}]}
F0_RESULTS CHECKS=2 BAD=1 REPORT=/tmp/dev-harness-verify/crit140-r0191-Crit140R0191Scoped9/repo/tmp/critic140-recognition/model.json
```

Это красный мутант, не дефект честной модели и не готовность production. После FAIL автоматический десятый суд не разрешён. Станционные S, production F после реализации, живой reviewer325, поздний обычный check_provodka и доставка/merge/push — NOT_RUN.
