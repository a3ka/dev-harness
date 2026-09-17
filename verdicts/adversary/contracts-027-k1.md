FAIL

Контрпримеры воспроизведены на настоящем `scripts/check_document.ts`; каждый ниже имеет отдельный честный минимальный положительный контроль с rc=0.

1. **Нарушена связка `commit:path -> blob`.** Контроль: frozen `v1` объявляет `data/source.json` из коммита `source_commit`, его действительный blob и `expected=7`; `--check` возвращает rc=0. Контрпример: frozen `v2` сохраняет тот же `commit` и `path`, но подставляет blob `unrelated/other.json` из другого коммита (`{"n":8}`), меняет рабочий `data/source.json` и пакет на 8. `--check` возвращает rc=0. `resolveGitSource` вызывает только `git cat-file blob <blob>` и для `current` сравнивает рабочий файл с этим blob; `git show <commit>:<path>` отсутствует. Поэтому источник, которого объявленный commit по объявленному path никогда не содержал, принят как основание.

   Воспроизведение: `python3 /tmp/dev-harness-verify/adv-027-toys/source_binding_probe.py`.
   Наблюдённый вывод: `POSITIVE rc= 0`, `COUNTEREXAMPLE rc= 0`.

2. **Неверно реализован RFC 6901 pointer `/`.** Контроль frozen `v1` с `/n` и значением `7` зелёный. Контрпример frozen `v2` применяет pointer `/` к JSON `{"n":7}` и объявляет ожидаемым/пакетным значением весь объект. В RFC 6901 `/` — токен пустого имени, а не указатель на root; при отсутствии ключа `""` мера обязана отказать. Реализация `applyJsonPointer` приравнивает `/` к `''` и возвращает root, поэтому контрпример принят.

   Воспроизведение: `python3 /tmp/dev-harness-verify/adv-027-toys/pointer_root_probe.py`.
   Наблюдённый вывод: `POSITIVE rc= 0`, `COUNTEREXAMPLE rc= 0`.

3. **Probe допускает shell вопреки обязательству «без shell».** Контроль frozen `v3` использует `argv=["python3","probe.py"]` и зелёный. Контрпример frozen `v4` использует `argv=["sh","-c","printf '{\"n\":7}'"]`; `--check` возвращает rc=0. `spawnSync(..., {shell:false})` не запрещает явно запустить `sh`; значит, это не защита механизма от shell, а только запрет неявной оболочки.

   Воспроизведение: `python3 /tmp/dev-harness-verify/adv-027-toys/pointer_root_probe.py && python3 /tmp/dev-harness-verify/adv-027-toys/probe_shell_probe.py`.
   Наблюдённый вывод второй пробы: `POSITIVE rc= 0`, `COUNTEREXAMPLE rc= 0`.

4. **Локальный путь выходит через симлинк.** Контроль frozen `v5` читает `docs/a.md` и `docs/a.json` внутри проекта, rc=0. Контрпример frozen `v6` задаёт лексически допустимые outputs `docs/link/a.md` и `docs/link/a.json`, где `docs/link` — симлинк на `/tmp/dev-harness-verify/adv-027-toys/escaped-docs` вне проекта; `--check` возвращает rc=0. `validatePath` проверяет только компоненты строки и не разрешает реальный путь до чтения.

   Воспроизведение: `python3 /tmp/dev-harness-verify/adv-027-toys/pointer_root_probe.py && python3 /tmp/dev-harness-verify/adv-027-toys/probe_shell_probe.py && python3 /tmp/dev-harness-verify/adv-027-toys/symlink_escape_probe.py`.
   Наблюдённый вывод третьей пробы: `POSITIVE rc= 0`, `COUNTEREXAMPLE rc= 0`.

Дополнительно: exit-code probe также расходится с контрактом. После положительного контроля, probe с `raise SystemExit(1)` дал checker rc=2 и `NOT_IMPLEMENTED`, хотя контракт задаёт rc=1 как содержательное нарушение; команда проверки подтвердила именно rc=2. `copyProjectShallow` также обходит все regular files вне `.git` и копирует их на каждый probe: добавление `docs/bomb.bin` размером 134217728 байт сохраняет rc=0, а измеренный запуск вырос с 0.379 s до 0.496 s; у песочницы нет ограниченного предметного среза и она пропускает симлинки (`Dirent.isFile()`/`isDirectory()` оба false).

Scoped controls на реализации: `bash fixtures/check_check_contract_ready/red_doc_evidence.sh && bash fixtures/check_check_contract_ready/red_doc_assertions.sh && bash fixtures/check_check_contract_ready/red_doc_oracle.sh && bash fixtures/freeze_contract/red_doc_lifecycle.sh` — rc=0.

Незыблемость: замороженные тексты и runner/CLI не изменялись. Раскрытия: Н-98 composer-самотрип детектора на живом дереве благословлён владельцем 2026-09-17, миграция после done×4; CI f4a62c4 зелёный (6/6 success, шардированный).
