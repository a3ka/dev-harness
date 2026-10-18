accept
OBJECT=5bdd707e443feb8c3fca8f9e5f24838f87742091

---
status: ready
contract: 993 (CMP-BCK-121, Complior-back, ветка cmp-bck-121/validator-5-8-3)
object: 5bdd707e443feb8c3fca8f9e5f24838f87742091
parent: 0230ee068d10047b1be99c26747aef1bd1579bcf
round: 6 (микро-круг; слово владельца 2026-10-18 ~11:35 UTC — только Рв993-14 и замороженные меры, без новых классов находок)
reviewer: Reviewer993Micro
prior_verdict: verdicts/review/contracts-993-v5.md (HEAD основного чекаута b5eaa8ef4f504c5a87ea20cfdd0766ab6ae0230a)
---

# Вердикт reviewer, контракт 993, микро-круг 6

Рабочая копия: `cp -a /tmp/dev-harness-verify/c993r6/repo /tmp/dev-harness-verify/reviewer993r6/repo`
(целевого каталога до копирования не было). Снимок c993r6 не тронут: `git status --porcelain | wc -l` = 0.
PY = `/tmp/dev-harness-verify/architect993-venv/bin/python` (3.12.3, jsonschema 4.26.0, py_rc=0).
H = `/home/harness/dev-harness`, только чтение. `git status --porcelain fixtures/workshop_project/validator_993/` → 0 строк.
Последний коммит handoff_probe.py: `950dd973efb443ba56a329909cecc0671abff3ac`,
sha256 `f8ee59166c56555d270f05bcc392980bc6d0efdc4e0dd3f5cb676d2655f8a01c`.

## Находки

- [x] **Рв993-14 (блокер круга 5): ЗАКРЫТ.** FILES.sha256 больше не ссылается на незакоммиченный
  `evidence/ux175/20261018T100915.689049Z/results.json`; sha_rc=0, handoff_rc=0, handoff_probe rc0 46/46 (ниже).
- Новых находок нет: класс новых находок закрыт словом владельца. Совет — отдельно в конце.
- В-1 (57 именованных отказов, блокер владельца) не меняется: честный остаток, подтверждён ещё раз (§3).
  Слияние держит именно он, вины implementer тут нет. Решение о слиянии остаётся за владельцем.

## 1. Дифф 5bdd707 против 0230ee068

```
$ git rev-parse HEAD
5bdd707e443feb8c3fca8f9e5f24838f87742091
$ git status --porcelain | wc -l
0
$ git diff --stat 0230ee0 5bdd707
 FILES.sha256 | 1 -
 1 file changed, 1 deletion(-)
$ git diff --numstat 0230ee0 5bdd707
0	1	FILES.sha256
$ git diff 0230ee0 5bdd707
@@ -484,7 +484,6 @@
-28ac87f6f49608868fad04ec09919b9007fed8bf4add49408ab02eed936e12b2  evidence/ux175/20261018T100915.689049Z/results.json
$ git log -1 --format='%H %P %an <%ae>%n%s'
5bdd707e… 0230ee068d10047b1be99c26747aef1bd1579bcf implementer <implementer@dev-harness.local>
993 implementer micro-round: FILES.sha256 regenerated on clean tree (Рв993-14)
$ git merge-base --is-ancestor 0230ee0 5bdd707 ; echo ff_rc=$?
ff_rc=0
```

Ровно один файл FILES.sha256: 1 строка удалена, 0 добавлено, удалена ровно та строка, на которую указывал
Рв993-14. Коммит атомарный, ссылается на предмет, автор implementer. Это fast-forward над C круга 5.

## 2. Рв993-14: handoff

```
$ sha256sum -c --quiet FILES.sha256 ; echo sha_rc=$?
sha_rc=0
$ PY tools/verify_handoff.py ; echo handoff_rc=$?
{"status": "PASS_STATIC", "schema_documents": 13, "all_manifest_files_and_hashes": "PASS", "runtime_acceptance": "NOT_ASSERTED"}
handoff_rc=0
$ wc -l < FILES.sha256 ; git ls-tree -r --name-only HEAD | wc -l
613
614
$ diff <(git ls-tree -r --name-only HEAD | sort) <(cut -c67- FILES.sha256 | sort)
8d7
< FILES.sha256
```

Своя мера, а не вывод автора: 614 путей дерева. Из них 613 в манифесте, а единственный путь вне его — сам
FILES.sha256 (он себя не перечисляет, как на 5fdac96). Лишних записей в манифесте нет. Условие владельца
«финальный FILES.sha256 должен ссылаться только на поставленные файлы» выполнено.

Замороженная батарея (§Приёмка, подраздел Handoff CLI):

```
$ PY -W ignore H/fixtures/workshop_project/validator_993/handoff_probe.py \
     --repo /tmp/dev-harness-verify/reviewer993r6/repo --out /tmp/dev-harness-verify/reviewer993r6/handoff-out
…
993 handoff case=corrupt-014 rc=1 expected=1 matched=True
993 handoff case=missing-file-outside-db rc=1 expected=1 matched=True
993 handoff case=missing-file-014 rc=1 expected=1 matched=True
993 handoff cases=46 mismatches=0 baseline_green=True
handoff_probe_rc=0
$ grep -c 'matched=True' handoff_probe.log ; grep -c 'matched=False' handoff_probe.log
46
0
$ git -C repo status --porcelain | wc -l      # после батареи
0
```

Полный лог: `/tmp/dev-harness-verify/reviewer993r6/handoff_probe.log`. В круге 5 на C было rc2
`HANDOFF_UNMEASURABLE: BASELINE_NOT_GREEN`, теперь rc0. 46/46 посчитано по логу отдельным grep, а не по
итоговой строке раннера.

## 3. Замороженные меры: регрессии нет

### Валидатор

```
$ PY -W ignore tests/validate_contract_v3_9.py --out /tmp/dev-harness-verify/reviewer993r6/val-out ; echo validator_rc=$?
{"status": "FAIL_STATIC", "checks": 1491, "negative_cases": 28, "examples": 250, "failures": [ … ]}
validator_rc=1
```

Своя мера (разбор `val-out/contract-validation.json`, не stdout):

```
status FAIL_STATIC runtime NOT_RUN_BY_THIS_VALIDATOR checks 1491 failures 57 unique 57
{'source_consumers': 51, 'cas': 5, 'conditional_policy': 1}
non-consumer ['acknowledgeDisclosure_cas', 'requestAction_cas', 'revokeApproval_cas', 'revokePartnerGrant_cas',
              'revokePartnerGrant_conditional_policy', 'revokePermission_cas']
validator consumers 51 all named in blocker True []      # remaining-source-consumers-blocker.txt
parse_rc=0 / rc=0
```

57 = 51 + 5 + 1, checks 1491. Всё совпадает с кругом 5 (v5 §2). Множество non-consumer то же.

### Зона от реального merge-base

```
$ git rev-parse origin/main ; git merge-base origin/main HEAD
f7b972913ec2af0df83ce58ea34dd688870fb0e9
f7b972913ec2af0df83ce58ea34dd688870fb0e9
$ git diff --name-only f7b9729 HEAD | wc -l
25
$ git diff --name-status --diff-filter=D f7b9729 HEAD      → пусто
$ git diff --name-only f7b9729 HEAD -- backend/ | wc -l     → 0
$ diff <(git diff --name-only f7b9729 0230ee0) <(git diff --name-only f7b9729 HEAD) ; echo setdiff_rc=$?
setdiff_rc=0
```

25 путей:
Complior_Backend_Architecture_v3_14_RU.md, FILES.sha256, README_RU.md, VALIDATION.json, VERSION_MANIFEST.json,
contracts/{BrokerOS_Unified_OpenAPI_v3.yaml, api-examples.json, backend-5_8_3-alignment.json, dto-ui-mapping.json,
operation-index.json}, evidence/contracts/993/{fix2-mutant-controls.json, handoff-battery-raw.json,
probe-battery-raw.json, remaining-source-consumers-blocker.txt, validator-baseline-52-consumers.json,
validator-baseline-honest-remainder.json, validator-baseline-honest-remainder.manifest.json},
server/{mock-5_8.json, src/mock-5_8.ts, test/mock-5_8.test.ts}, tests/validate_contract_v3_9.py,
tools/{generate_derived.py, validate_alignment_11782_31422.py, validate_invitation_target_31421.py, verify_handoff.py}.

Каждый путь проверен по второй строке «ЗОНА implementer» контракта (строка 134): `contracts/`, `evidence/contracts/`
и перечисленные файлы. Удалений нет, `backend/` не тронут. Набор путей тот же, что на C круга 5.

## 4. Идемпотентность генерации (отдельная чистая копия)

```
$ cp -a /tmp/dev-harness-verify/c993r6/repo /tmp/dev-harness-verify/reviewer993r6/gen ; git status --porcelain | wc -l
0
$ PY -W ignore tools/generate_derived.py ; echo gen_rc=$?
Derived consumers, wire and 10-route mock rebuilt
Handoff hashes rebuilt: 613 files
gen_rc=0
$ git status --porcelain            → пусто
$ git diff --stat                   → пусто
diff_lines=0
$ PY -W ignore tools/verify_handoff.py ; echo handoff_after_regen_rc=$?
{"status": "PASS_STATIC", …}
handoff_after_regen_rc=0
```

На чистом дереве регенерация воспроизводит закоммиченный манифест байт в байт. В круге 5 на C она давала
`FILES.sha256 | 1 -`. Механизм Рв993-14 устранён: манифест собран на чистом дереве.

## Факт (не блокер)

- Push круга 5 шёл через HTTPS-insteadOf/gh token. Этот микро-круг, по словам оркестратора, запушен через
  `gh auth git-credential` (HTTPS) в ту же ветку fast-forward. Сам я ветку origin не проверял: мой ssh-ключ
  видит только a3ka/dev-harness, `git ls-remote` Complior-back недоступен. В снимке c993r6
  `refs/remotes/origin/cmp-bck-121/validator-5-8-3` = 0230ee068… (ref снят до push или без fetch). Вывожу
  только из графа: 5bdd707 — потомок 0230ee0 (ff_rc=0). Совпадение origin = 5bdd707 — [INFERENCE] со слов оркестратора.

## Совет (не блокирует, новых классов нет)

1. Перед слиянием владельцу стоит один раз посмотреть `git ls-remote origin cmp-bck-121/validator-5-8-3` и
   job `package` в PR 146. В круге 5 он был красным, и связь с Рв993-14 была [INFERENCE]. Этот прогон CI не смотрел.
2. Ловушку круга 5 (манифест, собранный на грязном дереве, включил незакоммиченный evidence) закрывает уже
   существующая мера: `generate_derived.py` на чистой копии плюс пустой `git diff`. Новых артефактов для этого не нужно.
