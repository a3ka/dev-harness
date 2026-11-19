# СДАЧА 143 — согласование шва v5 с 197/3 (форма контракта 193)

Предмет этой исправительной пачки — только контракт и этот лист; батарея,
модели, пины и код шва не менялись. Основание — слово владельца №44
(m1474) и закреплённая в контракте 197 §1 замена baseline словом
2026-11-18 ~21:09 UTC. Н-39: стабы к ветвям привязаны кодом, не прозой.

Предыдущий вердикт — `verdicts/critic/contracts-143-v7.md`: FAIL,
Crit143V5, OBJECT `0d391630a037d3c3e71d0795866dddba55f1fc57`,
блок К-03/К-05 о несогласованной приёмке шва (контракт :370,387,
прежний лист :89–92). Прочитана копия
`/tmp/dev-harness-verify/p143/crit143v5-verdict.md`.
Вердикт не содержит раздела «## Карта классов»: машинное поле предыдущего
вердикта не заявляется, поскольку check_sdacha.sh требует карту;
чужой вердикт не правится. Оба блока явно закрываются в «Дельта» ниже.
Ранее принятый v6 (OBJECT 49b27bdf79d9b671785c116d7d47a6d7bcff5973)
не подменяет последний FAIL v5.

## Двери

- pre_critic · bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md · 0 · 0
- battery-model · bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model · 0 · 0
- battery-stabs · bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs · 0 · 0
- seam-before · bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh до · 0 · 0
- seam-after-directory · bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh после --dir /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tcbd2c5156/m/fixtures/workshop_project/mob_ci_143 · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md · 0 · 0
- К-02 · чисто · вход: слово №44 (m1474), контракт 197 §1 и FAIL Crit143V5; дельта только согласует текст шва, батареи/модели/пины неизменны · - · -
- К-03 · чисто · bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh до · 0 · 0
- К-04 · чисто · вход: ровно contracts/143-mob-ci-razdelenie.md и fixtures/workshop_project/mob_ci_143/sdacha_143.md внутри frozen ЗОНА architect; новые файлы не вводятся · - · -
- К-05 · чисто · bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh после --dir /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tcbd2c5156/m/fixtures/workshop_project/mob_ci_143 · 0 · 0
- К-06 · чисто · вход: шапки red_mob_ci_143.sh и check_sdacha.sh — отсутствие python3/node/git/timeout даёт rc 2 NOT_IMPLEMENTED, не красную клетку · - · -
- К-07 · чисто · вход: replay подложных git/gh/adb/emulator/maestro по живым форматам носителей; клетки i08/i09 — настоящий git-diff; модели .cjs исполняет node станции · - · -
- К-08 · чисто · bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs · 0 · 0
- К-09 · чисто · вход: демаркация v5 — обе целые формы транспорта конформны (эталон GitHub-эпохи frozen 143/4 и lane-модель 197), смешение форм красно именованными причинами И-16…И-18 · - · -
- К-10 · чисто · вход: клетки судят rc и именованную причину полного вывода субъекта (SVJAZI, WORKFLOW_CONTROL, ПАРА_NE_IZ_SBORKI), не строку-маркер · - · -
- К-11 · чисто · bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model · 0 · 0
- К-12 · чисто · вход: разбор workflow — yaml safe_load плюс структурный канон модели 197 по ссылке (source.json:.ssylki, нормализация run-шагов правилом sweep); самописного парсера формата и второй копии модели нет · - · -
- К-13 · н/п · секреты не предмет: PILOT_DEMO_CODE — продуктовая предпосылка v3, батареи без секретов · - · -
- К-14 · чисто · вход: old-форма не ослаблена — исторический прогон чистого fda1fc8 rc 0 (396/396 и 79/79); свежие model/stabs зелены, И-18 не требует пару run_attempt в old-форме (Н-39) · - · -
- К-15 · чисто · вход: пины/клетки/стабы не менялись; свежие --model и --stabs печатают счёт ниже, шесть ДО сверяет существующий оракул 197; четыре frozen/4 не выдаются за шесть · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/143-mob-ci-razdelenie.md · 0 · 0
- К-17 · н/п · архитектура 188 не предмет: markdown-дельта без продуктового кода · - · -

## Дельта

- К-03 · канон/инструмент · bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh до · 0 · 0
- К-05 · канон/инструмент · bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh после --dir /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tcbd2c5156/m/fixtures/workshop_project/mob_ci_143 · 0 · 0

К-03: совместимость предъявляется существующим механизмом 197/3 на одном
псевдо-продукте fda1fc8+197, а не соседней текущей батареей вместо baseline.
Закреплены commit/tree ДО, 197 остаётся зелёной 29/29; код и пины 197 не меняются.
К-05: пункт 1 приёмки называет исполнимые команды ДО и ПОСЛЕ с разными
ожидаемыми rc дочерней 143 (1 и 0); после freeze — повтор на frozen/143/5.
Отложенная развилка «после ленда либо перепинировать» снята: механизм уже
поставлен 197/3. Новые предикаты/клетки/стабы не добавлены; адресные
негативные и эквивалентные входы интерфейса уже живут в proverka_sverki_143.sh
(прогон по итоговому ref подтверждает оркестратор).

## Свежие замеры исправительной пачки (2026-11-19)

Корень копии (pwd):
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tcbd2c5156/m`.
Для всех прогонов `TMPDIR=<этот pwd>/tmp`. База после обязательного git am:
ref/commit `1183064f05c51a2a105ee7d080b62087eb277c42`,
исходный tree каталога 143 `a99b4b17d2e93fab6ee70a76f04fd353aee09be6`
(до правки этого листа; исполняемые файлы неизменны).

1. `sverka_inventarja_143.sh до` → фактический rc 0;
   ref/commit `9d3ad2bea4f1f15be15a9d975966bb20451a9a54`,
   tree `89ccddf8281b15842eda6aa1a316bdde579845ee`.
   Дочерняя 143 rc 1 (обязательный контроль скрипта); 197 зелёна 29/29;
   `ИНВЕНТАРЬ_143_СОВПАЛ: красных 6 из 6 пина, поимённо`.
   Состав из полного вывода:

```
a17-digest-do-ustanovki: e2e-splash: РЕНДЕР_ВНЕ_АЛФАВИТА: needs.build-apk.outputs.run_attempt
evidence: CHILD_DOWNLOAD_ABSENT_android-e2e
legacy: LEGACY_JOB_CHANGED
workflow-build-apk-outputs: WORKFLOW_CONTROL_workflow-build-apk-outputs
workflow-build-apk-run-step-7: WORKFLOW_CONTROL_workflow-build-apk-run-step-7
y19-outputs-provodka: outputs build-apk: ['apk_sha256', 'artifact_name', 'run_attempt', 'run_id']
```

2. `sverka_inventarja_143.sh после --dir <абсолютный каталог из двери
   seam-after-directory>` → фактический rc 0; 197 зелёна 29/29,
   `ИНВЕНТАРЬ_143_НОЛЬ_КРАСНЫХ: ноль красных; батарея 143 приняла lane-форму`.
   Оба состояния сверили исходный агрегат по sha256
   `e486e353f319ed2c0a65fc1092a0f16f8c9d8314bab4aed6e1d3619630d8fec6`.
3. `red_mob_ci_143.sh --model` → фактический rc 0:
   397/397 + lane 5/5; legacy 80/80 + lane 79/79.
   `--stabs` → фактический rc 0: matrix 413 стабов/422 привязки/0 живых;
   legacy 66 стабов/82 привязки/0 непойманных.
4. Итоговый commit ещё не существует при составлении листа.
   `bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh после --ref <полный-SHA-итогового-коммита>`
   и `bash fixtures/workshop_project/mob_ci_artifacts_local_197/proverka_sverki_143.sh --ref <полный-SHA-итогового-коммита>`
   — подтверждает оркестратор после коммита на чистом клоне; ожидаются rc 0,
   это НЕ фактические замеры этой копии. Ref/commit/tree/rc — в карточку ленда.
   После freeze — `sverka_inventarja_143.sh после --ref frozen/contracts/143/5`
   с теми же полями; ожидается rc 0.
5. `bash scripts/check_sdacha.sh . contracts/143-mob-ci-razdelenie.md --run`
   → rc 0, «СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=2)».
   `bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md`
   → rc 0, «КРИТИК: дверь зелёная». Результаты записаны после прогонов;
   машинные ряды листа не менялись.

## Исторические замеры исходной v5 (не текущая приёмка шва)

Прежний лист :89–92 зафиксировал: 197 `--model` rc 0 (28/28);
старый `sverka_inventarja_143.sh` без выбора версии запустил соседнюю
текущую 143, получил 0 красных вместо шести и вернул rc 1 — прежняя
«развилка 2 (зона 197)». Этот FAIL сохранён как история, не перекрашен.
Числа 28/28 и 29 стабов относятся к 197/2; действующий контракт 197/3
требует модель 29/29 и 38 стабов, код соседа этой пачкой не менялся.

Исторические прогоны исходной v5: чистый fda1fc8 → rc 0 (396/396 и
79/79); псевдо-продукт fda1fc8+модель 197 → rc 0 (403/403 и 79/79).
Прежнее красное-до двери без поля СДАЧА: pre_critic rc 1,
«строка СДАЧА: обязательна». Они не выдаются за новые замеры.
