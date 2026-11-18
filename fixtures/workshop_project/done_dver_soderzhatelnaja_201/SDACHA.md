# СДАЧА 201 — v2: ПОТРЕБИТЕЛЬ-проба, census-замер, место реализации

Круг v2 по слову владельца (батч №3 №17, 2026-11-18 ~18:10 UTC, «согласно
рекомендаций»; разбор `Cons201Consumers` §3 —
`/tmp/dev-harness-verify/Cons201Consumers/otvet.md`, раздел «Готовые задания
после согласия → Architect»). Основание: первый done 201 законно остановлен
дверью потребителей 116 — frozen/contracts/201/1 не нёс строки ПОТРЕБИТЕЛЬ и
census-замера (писатель `scripts/done_contract.sh` изменён лендами 201,
потребитель `scripts/check_spec_ready.sh` не верифицирован).

Дельта контракта — только добавления, 6 строк (сверка: `git diff
frozen/contracts/201/1^{commit} -- contracts/201-done-dver-soderzhatelnaja-sverka.md`,
удалений нет, остальные обязательства и production-blobs нетронуты):

```text
ПОТРЕБИТЕЛЬ scripts/check_spec_ready.sh: bash scripts/verify_antiplacebo.sh --scope check_spec_ready
замер: `cat scripts/consumers.d/*.tsv | wc -l` = 6 census scripts/consumers.d/*.tsv
## Место реализации
(пустая строка)
ПРОДУКТ: станция
(пустая строка)
```

Грамматика строк снята дословно с кода потребителей: проба —
`scripts/check_consumers.sh:362` (executes `sh -c` в корне, таймаут 60 с,
rc 0), census — `:399` (anchored ERE, наличие на окне с непустым
consumers.d у тега заморозки), место — `scripts/done_contract.sh:529–545`
(`grep '^ПРОДУКТ:'`, литерал `ПРОДУКТ: станция`, ровно одна строка). Живые
образцы форм: `contracts/038-provodka-done-gejt.md:567–570`,
`contracts/187-arhitektura-v-processe.md:45–49`. Census измерен командой
`cat scripts/consumers.d/*.tsv | wc -l` → 6 (не подготовленное значение).

## Двери

- pre_critic · bash scripts/pre_critic.sh --repo . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- потребители-116 · bash scripts/check_consumers.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- ПОТРЕБИТЕЛЬ-проба · bash scripts/verify_antiplacebo.sh --scope check_spec_ready · 0 · 0
- spec_ready · bash scripts/check_spec_ready.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- threat_model · bash scripts/check_threat_model.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- provodka · bash scripts/check_provodka.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- батарея-201-живая-дверь · bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo . · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/pre_critic.sh --repo . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- К-02 · чисто · вход: дельта — ровно строки, предписанные словом владельца (батч №3 №17) и разбором Cons201Consumers §3 «Architect»; предмет не расширен, вопросы не заданы сверх задания · - · -
- К-03 · чисто · вход: git diff frozen/contracts/201/1 — только 6 добавленных строк контракта 201; scripts/, registry/ и чужие заморозки не тронуты; census-строка читает scripts/consumers.d/*.tsv без правки · - · -
- К-04 · чисто · вход: правки только contracts/201-done-dver-soderzhatelnaja-sverka.md и fixtures/workshop_project/done_dver_soderzhatelnaja_201/SDACHA.md — оба пути в ЗОНА architect frozen/201/1:145 · - · -
- К-05 · чисто · вход: каждая новая строка контракта — исполняемая команда гейта (проба, rc 0 ≤ 60 с), замер с числом из вывода команды либо литерал грамматики места; двери листа несут заявленные rc · - · -
- К-06 · чисто · вход: дверь листа без git/timeout/awk/sed даёт rc 2 NOT_IMPLEMENTED (шапка check_sdacha.sh); именованный отказ формата наблюдался живьём до правки листа — «ОТКАЗ: строка 88: ряд таблицы ("- ") вне машинной секции» · - · -
- К-07 · чисто · bash scripts/verify_antiplacebo.sh --scope check_spec_ready · 0 · 0
- К-08 · чисто · вход: живой отказ done на frozen/201/1 без пробы — «потребители 116: писатель scripts/done_contract.sh изменён, потребитель scripts/check_spec_ready.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы» (замер консультанта, Cons201Consumers §1.1); то же окно с добавленной строкой — rc 0 за 18 с (проба исполнялась, не vacuous) · - · -
- К-09 · чисто · вход: конформные формы трёх строк сверены побайтово с живыми образцами 038:567–570 и 187:45–49; грамматики потребители — код гейта 116 и done_contract.sh, не проза · - · -
- К-10 · чисто · вход: census 6 — вывод команды cat scripts/consumers.d/*.tsv | wc -l; тайминги — из вывода time; rc — из прогонов этого круга · - · -
- К-11 · чисто · вход: census и проба исполняются дверью листа независимо от автора (перезапуск check_sdacha --run судьёй/критиком воспроизводит rc) · - · -
- К-12 · чисто · вход: формы строк не переизобретены — единый источник грамматики код гейта 116 (check_consumers.sh:362,399) и done_contract.sh:529–545; самописного парсера нет · - · -
- К-13 · н/п · секреты не предмет круга · - · -
- К-14 · чисто · вход: честная запись (текущий текст) зелёна во всех дверях выше; удаление строки пробы возвращает отказ check_consumers.sh:364, замера — :403, строки места — done_contract.sh:560 (запись mesto-legacy привязана к blob frozen/201/1, новый blob F2 записи не имеет — вывод из кода, не прогон) · - · -
- К-15 · чисто · вход: числа 6, 10.36 с, 18.0 с, 62.6 с — из выводов команд этого круга · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- К-17 · н/п · раздел «## Архитектура 188» у предмета отсутствует (гейт приёмки без брифа модели) · - · -

## Прогоны круга v2 (сырые свидетельства)

Все команды — cwd корень кандидата, env без ambient GIT_AUTHOR_*/GIT_COMMITTER_*.

| Дверь | Команда | rc | Время (time) |
|---|---|---:|---|
| ПОТРЕБИТЕЛЬ-проба | bash scripts/verify_antiplacebo.sh --scope check_spec_ready | 0 | 10.36 с (барьеров 1, фикстур 8, предъявлено 8) |
| потребители-116 | bash scripts/check_consumers.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md | 0 | 17.99 с |
| spec_ready | bash scripts/check_spec_ready.sh . contracts/201-…md | 0 | — |
| precision | bash scripts/check_precision_gate.sh . contracts/201-…md | 0 | — |
| threat_model | bash scripts/check_threat_model.sh . contracts/201-…md | 0 | — (ЗАЩИЩАЕТ 9, НЕ ЗАЩИЩАЕТ 9) |
| ceilings | bash scripts/check_ceilings.sh . | 0 | — |
| provodka | bash scripts/check_provodka.sh . contracts/201-…md | 0 | 10.5 с (пак) |
| батарея-201 | bash fixtures/…/red_done_dver_201.sh --repo . | 0 | 62.6 с |
| pre_critic | bash scripts/pre_critic.sh --repo . contracts/201-…md | 1 → 0 | 12.9 с; rc 1 ДО правки листа — единственная красная нога «сдаточный лист красен (rc=1)» на старом формате; после правки rc 0 |

Census: `cat scripts/consumers.d/*.tsv | wc -l` → `6` (шесть TSV в
scripts/consumers.d/, включая пару done_contract.sh → check_spec_ready.sh).

## Контроли и граница

Положительный контроль — сам прогон гейта 116 на кандидате (rc 0, 18 с:
проба исполнялась, окно писателя непусто — ленды 201 в окне
frozen/201/1..HEAD). Негативный контроль пробы — живой отказ первого done
(замер консультанта §1.1, cited в К-08). Отрицательные контроли удалением
строк замера/места в этом кругу НЕ прогонялись (вывод из кода ветвей
:403/:560, помечено в К-14) — ловец: критик v2 и adversary №5 на
post-freeze OBJECT по санкции слова владельца. Стабы/привязки не требуются:
предмет круга — текст контракта, не новый проверяющий код (Н-39: пар в
контракте нет, инварианты + rc-команды).

## Остатки

Батарея и dver_probe.py этого круга НЕ менялись (текущие числа круга
Adv201c: 62 клетки / 27 стабов; живой прогон --repo . rc 0 — строка таблицы
выше). История листа (круги Adv201/Adv201c/Arb201V2 с таблицами мутаций
M1–M4) — в git-истории файла SDACHA.md (блоб до правки этого круга:
5d2b3c6b10cf0154c5e345dfc49e2c7413014241, `git show
5d2b3c6b10cf0154c5e345dfc49e2c7413014241` восстанавливает текст; журнал —
`git log --follow -p fixtures/workshop_project/done_dver_soderzhatelnaja_201/SDACHA.md`);
содержательные таблицы тех кругов не переизданы. Строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ —
вносится оркестратором при переиздании (задание архитектору её не пишет).
Развилок круга: нет (пути правки в зоне architect; scripts/consumers.d/ не
требует правки — пара зарегистрирована).
