ACCEPT

# Ленд 104 через int-ветку: круг 5 (узкий, механический), main `678c64dbd`

Находки с чекбоксами лежат в `.review/2026-10-15-11.md` (prev: `.review/2026-10-15-10.md`). Вердикт круга 4:
`verdicts/review/contracts-104-land-v4.md` (FAIL, единственный блокер — Рв97-21: PR#97 механически CONFLICTING).
Рв97-19/20 этим кругом не пересматриваются: их по построению закрыл круг 4.

Это не повторное ревью предмета 104. Сверка механическая, ровно та, что названа достаточной в арбитраже
`verdicts/arbitration/merge-wip-protiv-main-konflikt-norm.md` §(г).3: «Пятого круга ревьюера по 104 нет: содержание
головы `b2a0573a9` равно принятому… механической сверкой (MERGEABLE + зелёный CI + `check_zones` RC=0)».
Последняя фраза того же пункта говорит, что новый красный CI на `b2a0573a9` арбитраж не покрывает. Н-295 и есть
такой новый красный. Поэтому int-ленд класса Н-256 судится здесь, отдельным узким кругом той же мерой, к которой
добавлена сверка patch-id (Рв104-5-5).

Клон `/tmp/dev-harness-verify/r104v5-2920026/repo` (SSH, `git checkout main && git pull` → `678c64db land: wip/int-104/architect`).

## 1. Родители и identity

```
$ git log --format='%H P:%P A:%an C:%cn %s' -1 678c64dbd
678c64dbdf35660627abd4e30b0ee37de72032a4 P:8210486a5992e58a76799a5d61353170a07d2f86 02c3f382fae4ef7dab76d4ccd1c4a84d099c186c A:orchestrator C:orchestrator land: wip/int-104/architect
$ git log --format='%H P:%P A:%an <%ae> C:%cn <%ce> %s' -1 02c3f382f
02c3f382fae4ef7dab76d4ccd1c4a84d099c186c P:8210486a5992e58a76799a5d61353170a07d2f86 bdffeeaf470583bcea7d6a6b40f73b5c3ac7a9ea A:architect <architect@dev-harness.local> C:architect <architect@dev-harness.local> int: wip/104/implementer2 поверх main (класс Н-256, закрытие Н-295 — CI lane-матрица читает base)
$ git log --format='%H P:%P A:%an C:%cn %s' -1 bdffeeaf4
bdffeeaf470583bcea7d6a6b40f73b5c3ac7a9ea P:b2a0573a99d7836ddeaaf034b07a5ff8237eaeaa A:orchestrator C:orchestrator 104: nudge CI (round2) — … пустой коммит, содержание не меняется
$ git diff --stat b2a0573a9 bdffeeaf4 | wc -l                       → 0
$ git rev-parse origin/wip/104/implementer2 origin/wip/int-104/architect
bdffeeaf470583bcea7d6a6b40f73b5c3ac7a9ea
02c3f382fae4ef7dab76d4ccd1c4a84d099c186c
```
Совпадает. У ленда два родителя: `8210486a5` и `02c3f382f`. Identity ленда — orchestrator (A==C). Второй родитель —
architect (A==C). В int-merge main стоит первым родителем, исходная `wip/104/implementer2` — вторым, и она не
переписана (на origin по-прежнему `bdffeeaf4`).

Merge собран без ручного разрешения конфликтов:
```
tree 678c64dbd                                       : 7dfbe88dbe84322bef6e151799489db51b8fbbf2
tree 02c3f382f                                       : 7dfbe88dbe84322bef6e151799489db51b8fbbf2
git merge-tree --write-tree 8210486a5 bdffeeaf4      : 7dfbe88dbe84322bef6e151799489db51b8fbbf2  rc=0
```

## 2. Дельта к первому родителю: уставные пути не M/D

```
$ git diff-tree --no-commit-id --name-status --diff-filter=MD -r 8210486a5 678c64dbd
M	.omp/agents/orchestrator.md
M	fixtures/dokazatelstva_098/_mir.sh
M	fixtures/dokazatelstva_098/battery_stubs.sh
M	fixtures/dokazatelstva_098/model/judge_gate.sh
M	fixtures/dokazatelstva_098/red_chuzhoe_derevo_opredelenie.sh
M	fixtures/dokazatelstva_098/red_chuzhoj_accept.sh
M	fixtures/dokazatelstva_098/red_chuzhoj_head_sha.sh
M	fixtures/dokazatelstva_098/red_odnoimennoj_chuzhoj_workflow.sh
M	fixtures/dokazatelstva_098/red_otstutvujushaja_objazatelnaja.sh
M	fixtures/dokazatelstva_098/red_postoronnij_zelenyj_ne_zakryvaet.sh
M	fixtures/dokazatelstva_098/red_pozdnij_fail.sh
M	fixtures/dokazatelstva_098/red_semantika_008_bez_flaga.sh
M	fixtures/dokazatelstva_098/red_smeshannaja_istorija.sh
M	fixtures/dokazatelstva_098/red_zhurnal_sozdaetsja_pisatelem.sh
M	roles/orchestrator.md
M	scripts/judge_gate.sh
M	scripts/models_actual.sh
rc=0, строк 17 (D — 0); остальное: A — 14 (дерево 104 + contracts/104-…)
```
Буквального «ПУСТО» из задания здесь нет (Рв104-5-1). Пустой вывод бывает только у ленда, который не меняет ни одного
файла. Критерий из правила решения — «charter-пути не M/D». Он выполнен, проверено предикатом самого барьера:
```
$ bash -c 'CHARTER_LIB=1 source scripts/check_charter.sh; set +e; for p in <17 путей> AGENTS.md ROADMAP.md contracts/104-uzkij-doverennyj-gejt-sudi.md; do is_charter_path "$p" "$PWD"; echo "rc=$? $p"; done'
rc=1 × 17 (все пути выше)
rc=0 AGENTS.md · rc=0 ROADMAP.md · rc=0 contracts/104-uzkij-doverennyj-gejt-sudi.md   (контроль: предикат различает)
```
Набор из 17 путей — это собственные правки 104, а не что-то, внесённое merge. Набор `git diff --name-status 60d82e944 bdffeeaf4`
(merge-base → голова предмета) содержит те же 17 `M`, и patch-id обеих дельт совпадает:
```
git diff 8210486a5 678c64dbd | git patch-id --stable   → c2c3cd6d65540d176da79ea9306c40bfd0f6c624
git diff 60d82e944 bdffeeaf4 | git patch-id --stable   → c2c3cd6d65540d176da79ea9306c40bfd0f6c624
```
`roles/orchestrator.md` правят только содержательные коммиты 104, и круги 1–4 их уже приняли (v4 §2). К уставу в смысле
`is_charter_path` этот файл не относится. Блоб контракта на ленде равен блобу тега: `e4b1e185fec0f6bf2f7d6e9a2fb80f0f9f457a93` ×2.
`git merge-base --is-ancestor frozen/contracts/104/1 678c64dbd` → rc=0.

## 3. patch-id: ничего не переписано

```
$ git rev-list --count 452f682b..b2a0573a9           → 5   (с теговым 452f682b — 6; см. Рв104-5-2)
$ git rev-list --merges 452f682b..bdffeeaf           → 0
коммит     patch-id (--stable)   в 678c64dbd^2^2 (линия второго родителя int-merge)   таблица круга 4 §3
452f682b   0a65ac67131a          452f682b 0a65ac67131a                               452f682b 0a65ac67131a =
af0ded6c   aaffebaefc40          af0ded6c aaffebaefc40                               ed837823 aaffebaefc40 =
ebdd3662   d4ac439e2276          ebdd3662 d4ac439e2276                               59f26b53 d4ac439e2276 =
e33d4bac   0016d3d4aab7          e33d4bac 0016d3d4aab7                               e906e707 0016d3d4aab7 =
4767e51c   5b079d719088          4767e51c 5b079d719088                               355653fe 5b079d719088 =
b2a0573a   046082d376e9          b2a0573a 046082d376e9                               4117f3d4 046082d376e9 =
bdffeeaf   (пусто — пустой коммит)
```
Внутри второго родителя ленда стоят те же объекты (SHA равны), значит, равенство patch-id там тривиально. Содержательная
мера — третья колонка: все 6 содержательных patch-id совпадают с принятой таблицей круга 4. Двух оставшихся строк таблицы
(`8cd920aa` А-917, `9cc284c6` А-918) в линии `b2a0573a9` нет. Это журнальные записи, и обе уже стоят в main
(`git grep '^### А-91[78]' 8210486a5 -- NABLIUDENIA_ARCHITECT.md` → `:8456`, `:8531`; ленд этот файл не меняет,
`git diff --stat 8210486a5 678c64dbd -- NABLIUDENIA_ARCHITECT.md` пуст).

## 4. CI PR#99 (живьём)

```
$ gh pr checks 99 --repo a3ka/dev-harness ; rc=0
antiplacebo (ap1 …) pass 5m29s · (ap2 …) pass 2m38s · (ap3 …) pass 3m5s · (ap4 …) pass 1m32s · (ap5 …) pass 1m35s
ci (l1, check:charter) pass 3m38s · (l2 …) pass 13m16s · (l3, check:zones …) pass 4m6s · (l4 …) pass 7m49s
ci (l5 …) pass 5m3s · (l6, check:orch-restart-family-selftest …) pass 7m24s · (l7 …) pass 8m40s
$ gh run view 38820786546 --json headSha,event,conclusion,…
{"conclusion":"success","event":"pull_request","headBranch":"wip/int-104/architect","headSha":"02c3f382fae4ef7dab76d4ccd1c4a84d099c186c","jobs":12,"pass":12,"status":"completed","workflowName":"ci"}
$ gh pr view 99 --json state,headRefOid,mergeCommit,mergedAt
{"headRefOid":"02c3f382f…","mergeCommit":{"oid":"678c64dbdf35660627abd4e30b0ee37de72032a4"},"mergedAt":"2026-10-15T23:23:17Z","state":"MERGED"}
```
Прогон — событие `pull_request` на голове `02c3f382f`, то есть на дереве, равном дереву ленда. Зелёные все джобы:
их 12, а не 11 (5 ap + 7 ci, Рв104-5-3). Lane l6, на котором краснел Н-295, зелёный.

## 5. check_zones на main

```
$ reslop t -- bash scripts/check_zones.sh .        (клон, main = 678c64dbd)
ok: true · passed: 83 · failed: 0 · exit: 0         → check_zones RC=0
FAIL-строк в сыром логе: 1 —
  FAIL строка ЗОНА вне объявленной грамматики в contracts/055-izoljacija-sostojanija-po-projectid.md: «ЗОНА architect (до-заморозочная батарея …)»
замороженных контрактов: 97 · объявленных авторов: 6 · коммитов в диапазонах: 12800 · проверено по зонам: 2740
```
Единственная FAIL-строка — тот же самотестовый шум грамматики 055, что описан в v4 :39-42 на голом main. К 104 она не относится.

**Своя мера: RC=0 на main для предмета 104 пусто-зелёный (Рв104-5-6).** `check_zones.sh:595-602` исключает из окна N
коммиты merge с заголовком `land: wip/<OTHER>/…`, если OTHER ≠ N. У ленда заголовок `land: wip/int-104/architect`, то есть
OTHER = `int-104` ≠ `104`. Воспроизведение тем же правилом (`../win104.sh`, окно `452f682b..<голова>`):
```
== HEAD 678c64dbd (land: wip/int-104/architect)       == ALT 5ad79763 (land: wip/104/implementer2; те же tree и родители)
af0ded6c architect    EXCLUDED                         af0ded6c architect    judged
ebdd3662 implementer  EXCLUDED                         ebdd3662 implementer  judged
e33d4bac implementer  EXCLUDED                         e33d4bac implementer  judged
4767e51c orchestrator EXCLUDED                         4767e51c orchestrator judged
b2a0573a architect    EXCLUDED                         b2a0573a architect    judged
```
Полный check_zones на ALT (`git commit-tree 678c64dbd^{tree} -p 8210486a5 -p 02c3f382f`, worktree `../alt`):
```
$ reslop t -- bash scripts/check_zones.sh .        (ALT 5ad79763)
ok: true · passed: 83 · failed: 0 · exit: 0        → RC=0
FAIL-строк: 1 (та же строка 055)
замороженных контрактов: 97 · объявленных авторов: 6 · коммитов в диапазонах: 12806 · проверено по зонам: 2744
```
Разница с main: 12800→12806 (+6 коммитов предмета вместе с `bdffeeaf`), 2740→2744 (+4 коммита architect/implementer,
авторов ЗОНА-строк 104). Под судом зон содержание 104 проходит с RC=0. Значит, дефект сидит в грамматике маркера ленда,
а не в предмете. Он общий для класса Н-256: на main с тем же заголовком лежат `c4bd709a` (`land: wip/int-089/architect`)
и `ae280bb8` (`land: wip/int-072-073-075/architect`). Это замечание к механизму (контракт 021, ветвь А), ленд 104 оно не
блокирует: критерий §(г).3 «check_zones RC=0» выполнен, и та же мера, видящая коммиты предмета, тоже зелёная.

## 6. Батарея 104 на main

```
$ reslop t -- bash fixtures/_krasnye_104.sh        (клон, main = 678c64dbd)
ok: true · passed: 39 · failed: 0 · exit: 0
— t104-m1 … t104-m17 пойман (17 мутантов, все пойманы)
```
Счёт совпадает с кругом 4 (39/0).

## 7. Строк `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` нет

```
тело 678c64dbd («land: wip/int-104/architect»)                                  → 0 строк РАЗРЕШИЛ-ВЛАДЕЛЕЦ
тело 02c3f382f («int: wip/104/implementer2 поверх main …»)                     → 0
git diff 8210486a5 678c64dbd | grep -c '^[+-].*РАЗРЕШИЛ-ВЛАДЕЛЕЦ:'               → 0
```
Коммита с заголовком `merge: wip/int-104/architect` нет. Ленд называется `land: …` (Рв104-5-4). Строки не нужны:
уставных M/D нет (п.2).

## Доп. мера: check_charter на main

```
$ reslop t -- bash scripts/check_charter.sh .      (клон, main = 678c64dbd; ~15 мин, полный режим)
ok: true · passed: 307 · failed: 0 · exit: 0        → check_charter RC=0 ; FAIL-строк 0
  ok   contracts/104-uzkij-doverennyj-gejt-sudi.md — уставной с frozen/contracts/104/1, коммитов в диапазоне 125, изменений без разрешения нет
уставных документов: 96 · изменений в них: 211 · с разрешения: 211
```
Merge-коммит судится по дельте к первому родителю (И-7). Ленд уставной дельты не несёт, поэтому строки владельца ему не нужны (п.7).

## Паразитная сложность (050): артефакты этого ленда

Новых файлов, скриптов, флагов и env диффом этого круга нет: дельта к первому родителю по patch-id совпадает с принятым
предметом 104. Новых артефактов два, это коммиты `02c3f382f` и `678c64dbd` и ref `wip/int-104/architect`.

| артефакт | (1) свойство | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| int-ветка `wip/int-104/architect` + merge `02c3f382f` | CI-гейт ленда (зелёный `pull_request`-CI; lane-матрица из base, Н-295) | ref на origin, явный | 0 (файлов не несёт) | интерфейса нет | PR#99 CI → `land_agent` | ESSENTIAL: более простая форма (голова `b2a0573a9`) детерминированно красна на l6 |

## Итог

| находка | класс | блок |
|---|---|---|
| Рв97-21 (CONFLICTING) | закрыто: А-923 main-direct + int-ветка Н-256 | — |
| Рв104-5-1 ожидание «ПУСТО» в п.2 неверно (17 M, все неуставные, равны предмету) | заявленное≠сделанному (задание) | нет |
| Рв104-5-2 «восемь коммитов» → 5 (6 с тегом) | счёт | нет |
| Рв104-5-3 «11 лейнов» → 12 джобов | счёт | нет |
| Рв104-5-4 заголовок `merge:` → `land:` | точность задания | нет |
| Рв104-5-5 §(г).3 не покрывает новый красный буквально → покрыт этим кругом | основание | нет |
| Рв104-5-6 check_zones исключает коммиты `land: wip/int-<N>/…` из окна N (на main RC=0 пусто-зелёный для 104; ALT с собственным маркером RC=0) | механизм вне предмета (021 ветвь А, класс Н-256) | нет |
| Рв104-5-7 identity А-923 `architect104a923`, а не `architect` | точность §(г).2 | нет |

Пункты 1–7 сходятся. Charter-пути не M/D. patch-id тождественны принятому. CI зелёный (12/12). check_zones RC=0
(на main и на ALT, где коммиты предмета судятся), батарея 104 RC=0. **ACCEPT** ленда `678c64dbd`, блоб контракта `e4b1e185`.
