FAIL

Суд предмета 993: `a3ka/Complior-back` PR #146, commit
`19d40691da9a43f83bb5ebe938e0b05c30fcdefc`.

## PR_ZONE_VIOLATION

Команда из задания

```sh
git diff --name-only 842f4e99d6024ab62336a6a0be787ae667fb555b..19d40691 -- tests/ contracts/ tools/ evidence/ README_RU.md VALIDATION.json FILES.sha256 VERSION_MANIFEST.json data/ server/ Complior_Backend_Architecture_v3_14_RU.md
```

вернула 44 пути. Следующие изменённые пути не принадлежат зоне implementer
993 (разрешены только `evidence/contracts/` и `evidence/contracts/993/`;
из `tools/` — только четыре перечисленных CLI):

- `evidence/ci/2026-10-17-local-and-negatives.md`;
- `evidence/ddl/2026-10-17T18-52-23-411Z/results.json`;
- `evidence/ddl013/2026-10-17T18-52-22-799Z/results.json`;
- `evidence/mock/2026-10-17T18-52-05-673Z/results.json`;
- `evidence/mock/2026-10-17T18-52-30-153Z/results.json`;
- `evidence/policy/2026-10-17T18-52-00-252Z/results.json`;
- все шесть `evidence/runs/vs01-*` файлов и оба
  `evidence/runs/vs02-policy-*` файла;
- оба `evidence/ux175/*/results.json`;
- `tools/check_backend_provenance.py`, `tools/check_backend_standards.py`,
  `tools/check_backend_structure.py`, `tools/requirements-backend-checks.txt`,
  `tools/run_backend_ci.py`.

Это само по себе PR_ZONE_VIOLATION. `backend/` не оценивался.

## Живой CLI и точечные мутации

С зависимостями из
`/tmp/dev-harness-verify/architect993-venv/bin/python3` живой запуск
`tests/validate_contract_v3_9.py` завершился rc=1, записал структурный report
без crash: 1491 checks, 28 negative cases, 250 examples. Отдельное сравнение
его `failure_ids` с
`evidence/contracts/993/remaining-source-consumers-blocker.txt` дало:

```text
expected=52, actual=52, unexpected=[], missing=[],
all_source_consumers=True
```

То есть известный ожидаемый красный baseline подтверждён: иных категорий
отказов в неизменённом C нет.

В изолированных полных копиях C живой валидатор дал rc=1 и точный именованный
failure для каждой следующей порчи:

| Порча | Ожидаемый и наблюдённый ID |
|---|---|
| удалить `createIntent` из operation index | `createIntent_source_consumers` |
| подменить method index-строки | `createIntent_source_consumers` |
| подменить deprecated index-строки | `createIntent_source_consumers` |
| подменить `source_sha256` index | `index_source_sha256` |
| добавить non-mobile workflow consumer без `source_ref` в canonical bindings и согласованную index-строку | `getSession_consumer_resolution` |

Проверка не имеет `except Exception`/`except BaseException`; её узкие
`KeyError`/`TypeError` ветви для неразрешимого local example заканчиваются
пустым набором examples и последующим именованным отказом. Однако две
обманные заглушки прошли, поэтому это не ACCEPT.

## Найденные обходы

1. **Плацебо `policy_consistency`.** В обычной command-ветви
   `tests/validate_contract_v3_9.py:230` вызывается
   `check(oid+'_policy_consistency', True)`. Я подменил у `createIntent`
   `x-operation-class` на `SAFE_READ_OVER_POST`, сохранив `mutation=true` и
   согласованный source hash. Валидатор вернул rc=1 только из известного
   baseline: его 52 failure IDs в точности равны blocker-списку;
   `createIntent_policy_consistency` отсутствует. Следовательно правило
   присутствует в report/coverage, но не проверяет классификацию normal
   command и пропускает неверный ответ на предметный вопрос.

2. **Удаление VS01 freeze принимается как успех.** В отдельной полной копии
   C я удалил `VERSION_MANIFEST.json:vs01_spec_freeze` и выполнил
   `tools/generate_derived.py`. Получен rc=0 и stdout:

   ```text
   Derived consumers, wire and 10-route mock rebuilt
   Handoff hashes rebuilt: 481 files
   ```

   Это прямо запрещённый обход freeze. Условие в генераторе проверяет digest
   только если ключ ещё существует; при отсутствии ключа без
   `--freeze-vs01` named refusal отсутствует. Позитивный контроль на честной
   неизменённой копии C также дал rc=0 с теми же двумя штатными строками, так
   что находка не является «вечно красной» проверкой.

Статические проверки выполнены по исходнику: broad-except не найден. Но
константная ветвь выше подтверждена исполнением, а не только чтением.

Требуемая правка автора: вернуть PR в implementer-зону и сделать absence
`vs01_spec_freeze` именованным отказом при штатной регенерации; заменить
константный normal-command `policy_consistency` предметной проверкой с
зелёным control и отдельным red mutant.
