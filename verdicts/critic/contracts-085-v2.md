accept

# Контракт 085 v2 — адресный суд дельты

СУД: repo=dev-harness; предмет=085; фаза=контракт, адресный v+1 от frozen/contracts/085/1; роль=critic; вызов=3 по старому порядку; модель-план=config/agent_models.json (critic → apex-sol → @gpt-terra); сессия=Crit085V2; модель-факт=openai-codex/gpt-6.1-terra; SHA=9b504ade1865cf0390155fd3c3756baa8b91554b; предыдущие=verdicts/critic/contracts-085.md FAIL и contracts-085-v1.md accept; исключение=слово владельца «085 v+1 — да».

`bash scripts/models_actual.sh --tsv --bind --session Crit085V2` → rc 0, `critic openai-codex/gpt-6.1-terra allowed Crit085V2 9b504ade1865cf0390155fd3c3756baa8b91554b`. Запись до вызова найдена в HANDOFF state-WT. Автор коммита — architect, не critic. Предмет и критерий закоммичены; исполнители и зоны названы. Основание дополнительного поиска: новая семантика MSG и смена снимка и пина в v2; полный повтор суда v1 не проводился.

## Оценка

Блокирующих находок в адресной области не установлено. `contracts/085-cikl-perezapuska-repo.md:210–226,318–331`: И-10 и т1 предъявляют точную строку, пять ссылок, запрет устаревшего блока и подстановок, ограничение длины и равенство снимку. `fixtures/ops_server/red_cikl_perezapuska_085.sh:512–523,907–925,1263–1265`: s41–s46 привязаны к т1 именно в исполняемом коде; не требуется переносить привязку в прозу (Н-39). `contracts/085-cikl-perezapuska-repo.md:390–406`: зоны architect/implementer и отдельная установка консультантом названы; перенос роли и root-части исключён. `git diff frozen/contracts/085/1 9b504ade -- fixtures/ops_server/cikl_085/stancija.orch-loop` показывает замену ровно одной строки MSG. SHA-256 снимка `5fabbf959d3da14ac52b0d66c2eca5ec3d1f0e66e477008ad7273630cbce6a7c`, субъекта до реализации `30d837128ab285b4f8430acce14a952b5e6b5f7cb7c22f54639fb25c0393dda7`.

СОВЕТ contracts/085-cikl-perezapuska-repo.md:314–317 — общий сценарий А1 описывает историческое состояние v1, тогда как А1v описывает современный субъект; при дальнейшей редакции полезно сохранять явное различие этих миров. Это не блокирует адресный v2.

## Проверки и атаки

Прогоны проводились в `/tmp/dev-harness-verify/Crit085V2/repo` на OBJECT, с `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_AUTHOR_DATE -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL -u GIT_COMMITTER_DATE`. Числа — фактический вывод.

- `bash fixtures/ops_server/red_cikl_perezapuska_085.sh`: rc 1, `красных=5, стабы=46/46, диффпроба=33/33`; красны р2, м1, м2, м6, т1 — ожидаемый старый MSG до реализации.
- `FIXSIM=1 bash fixtures/ops_server/red_cikl_perezapuska_085.sh`: rc 0, `красных=0, стабы=46/46, диффпроба=33/33`.
- Запрошенные `--model` и `--stabs` не являются режимами этой батареи: оба дали rc 2 и `использование: bash fixtures/ops_server/red_cikl_perezapuska_085.sh [fast|stancija]`. Модель и стабы реально проверены выше посредством FIXSIM и встроенного в полный прогон стаб-пака.
- Независимый честный контроль: в живом `ops/server/user/orch-loop` заменена только строка MSG на точную строку И-10 (`git apply /tmp/dev-harness-verify/Crit085V2/honest.patch`); полный прогон rc 0, `красных=0, стабы=46/46, диффпроба=33/33`. Это не проверка установки на станцию и не переснятие пина 074.
- Мутация источника: от этого честного состояния `git apply /tmp/dev-harness-verify/Crit085V2/source.patch` заменил в MSG `registry/pauzy.tsv` на `registry/plan.tsv`. Полный прогон rc 1; сырой существенный вывод:

  ```text
  КРАСНО: т1 — MSG без обязательной ссылки «registry/pauzy.tsv» (И-10)
  стаб-пак: 46/46 поймано, диффпроба: 33/33
  итог 085: красных=5, стабы=46/46, диффпроба=33/33
  ```

  Дополнительно зелёный контроль и адресный стаб s41 воспроизводят прежний MSG с «Следующая сессия»: `стаб s41 пойман (вход т1): старый MSG: генерируемый блок «Следующая сессия» как истина — MSG без обязательной ссылки «HANDOFF «ГДЕ МЫ»» (И-10)`.
- Мутация снимка: `git apply /tmp/dev-harness-verify/Crit085V2/snapshot.patch`, затем `bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast` → rc 2, сырой вывод:

  ```text
  ОТКАЗ: подмена входа: cikl_085/stancija.orch-loop sha256 6d61d6ab7215a3a79e440f10de09f28fbc74000bd29bd318bb151b91e10fc50b ≠ пину 5fabbf959d3da14ac52b0d66c2eca5ec3d1f0e66e477008ad7273630cbce6a7c
  ```

  Мутации отменены до коммита вердикта.
- `pre_critic.sh contracts/085-cikl-perezapuska-repo.md` → rc 0, «КРИТИК: дверь зелёная»; `check_spec_ready.sh . ...` → rc 0 `OK`; `check_threat_model.sh . ...` → rc 0; `check_ceilings.sh . ...` → rc 0; `check_charter.sh . ...` → rc 0, строка `ok уставной документ изменён с разрешения владельца: contracts/085-cikl-perezapuska-repo.md в 9b504ade`.
- `check_precision_gate.sh . contracts/085-cikl-perezapuska-repo.md`: после `git fetch --tags origin` rc 0 `OK`. До fetch был rc 1 `реестр заморозок не читается: missing-remote`; параллельный первоначальный вызов также имел ошибки временного каталога, поэтому не использован как свидетельство.
- Сосед 074: `bash fixtures/_krasnye_074.sh` → rc 1, `красных клеток=1 стабы=8/8`; k5b наблюдала расхождение живого `/usr/local/sbin/orch-peak` со снимком. Это не доказательство регресса дельты MSG и не зелёная проверка станции.
- Сосед 090: `bash fixtures/_krasnye_090.sh` → rc 1: четыре обычных пробы и 4/4 стаба зелёны, герметичность отказала из-за изменявшихся живых session JSONL. Зелёный итог 090 не установлен.
- `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` → rc 0, `SVJAZI 60`; `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs` → rc 0, `SVJAZI 69`, `zhivykh 0`. Без продукта и `--repo` оба безфлаговых запуска дали ожидаемый `SUBJECT_ABSENT`, rc 1: состояние продукта ими не проверено.

Не проверялись установка на живую станцию, режим `stancija`, последующее переснятие пина 074, фактическое поведение модели-читателя сообщения и живые продукты 139/995. Эти ограничения не подменяются зелёной симуляцией. Проверка 074/090 на текущем занятом хосте не показала общего зелёного итога.
