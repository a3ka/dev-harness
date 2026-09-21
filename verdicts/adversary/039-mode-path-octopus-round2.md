# Adversary 039 — круг 2: повторный суд фикса переноса

**Вердикт: ACCEPT.** Судимый HEAD — `65e7edb4712f3db0b49a914c2380214c8692d32a` (`land: wip/039/implementer`); предмет — `contracts/039-check-protected-rename.md`, реализация — `scripts/check_protected.sh`. Найденных обходов: **0**. Все toy-репро и клон лежат только в `/tmp/dev-harness-verify/039-round2-*`.

## Повтор прежних обходов к1

1. **Symlink с тем же blob/OID.** Защищённый regular `plans/001-p.md` с байтами `payload` удалён; в том же коммите добавлен dangling `notes/001-p.md` mode `120000` с целью `payload`. Это тот же blob, но не пригодный file-entry. Настоящий барьер дал **rc 1** и named `защищённый артефакт существовал и на HEAD его нет: plans/001-p.md`; ложного зелёного нет.
2. **PATH-подмена.** Перед настоящим барьером одновременно поставлены `fakebin/comm` и `fakebin/git`, оба `exit 0`; процесс запущен через `/usr/bin/bash` с `PATH=fakebin:$PATH` против genuine delete. Барьер зафиксировал доверенный `/usr/bin:/bin` до внешних команд и дал **rc 1** с тем же named FAIL. Ни подставной `comm`, ни подставной `git` не превратили удаление в пустую выборку.

## Новый слой

* **Gitlink mode `160000` с бывшим blob OID.** Через `git update-index --cacheinfo 160000,<B>,notes/001-p.md` построен tree-entry gitlink, чья ссылка намеренно равна blob B удалённого protected regular file. Проверены две формы: gitlink уже в удаляющем коммите; и честный regular rename в удаляющем коммите с последующей заменой q на gitlink того же B. Обе дали **rc 1** и named FAIL для `plans/001-p.md`. Значит `q` в c и живой носитель на HEAD принимаются только mode `100644`/`100755`; mode `160000` не служит переносом.
* **Октопус с отсутствующим p у части родителей.** Построен трёхродительский merge: у p1 и p2 `plans/001-p.md` несёт один B, p3 уже не содержит p; результирующий merge удаляет p, добавляет regular `notes/001-p.md` с B. Настоящий барьер дал **rc 0** и named transfer — это честный identical-blob перенос, а не обход. Нейтрализация ровно одного условия: p2 изменён на другой blob при тех же p3 и q=B; барьер дал **rc 1** и named FAIL. Следовательно, реализация проверяет все существующие parent-blobs на равенство, а отсутствие p в одном родителе не маскирует расхождение в другом.
* Других Git tree-entry mode для file-entry после `100644`, `100755`, `120000`, `160000`, `040000` не остаётся: regular mode в Git нормализован к двум принятым режимам; directory mode не выдаёт leaf `A q` в `--name-status -r`-сценарии.

## Быстрые сохранённые контроли

* genuine delete — **rc 1** с named FAIL; genuine byte-identical rename — **rc 0** с named transfer;
* построенная цепочка `plans → verdicts/adversary → notes` с промежуточной правкой другого protected файла — **rc 0**, обе transfer-строки названы;
* `bash scripts/check_protected.sh` на судимом HEAD — **rc 0**, `перенесено: 2`;
* `bash scripts/drill_protected_rename.sh` — **rc 0**, оба честных переноса названы;
* `bash scripts/verify_antiplacebo.sh --scope check_protected` — **rc 0**, `20/20` красных повторных предъявлений;
* `bash scripts/verify_antiplacebo.sh --scope drill_protected_rename` — **rc 0**, `1/1` красное повторное предъявление.

Репро: `/tmp/dev-harness-verify/039-round2-runner.sh` (8 сценариев, `SUMMARY repro_failures=0`) и `/tmp/dev-harness-verify/039-round2-chain.sh` (две named transfer-строки). Позитивные контроли — regular rename и identical-blob octopus — зелёные; негативные нейтрализации — symlink, оба gitlink-варианта, подставленные `git`+`comm`, genuine delete и octopus с единственным divergent parent — красные. Поэтому проверка отличает исправную ветку от каждой исполненной обманной заглушки.

Н-111: текст подготовлен вне основного дерева; его blob записан `git hash-object -w`, внесён ровно этим путём через `git update-index --cacheinfo`, commit создан с `user.name=adversary`, `user.email=adversary@dev-harness.local`; затем путь materialized только `checkout HEAD --`. Push не выполнялся.
