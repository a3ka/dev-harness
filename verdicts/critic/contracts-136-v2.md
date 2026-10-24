accept
OBJECT=56e0f1dcd45e04fa89061b3782b526f8c5b2a364

# Узкий гейт 136 v2 до заморозки

**Блокеров: 0.** Судил только закрытый список арбитража `keep136v2/arbitration-136v2.md` п.1 (оси A–D), п.3(а), и проверки, прямо порученные владельцем на OBJECT. Недостающих клеток по таблице осей нет; названных обходов нет. Прежние два FAIL не принимаются как зелёные: все их 19 мутантов предъявлены заново и красны.

Предмет закоммичен: клон `/tmp/dev-harness-verify/Critic136v2c/repo` на `wip/136/architect-v2`, HEAD = OBJECT, родитель `59ba025a9f7c5533aaed535d2daf032659234292`, автор коммита `architect`. Набор полон: предмет и инварианты `contracts/136-dovodka-sessij-proektov.md:44–52`, критерий с командами и rc `:54–66`, названные исполнители и их зоны `:68–78`. Копия получена из `/tmp/dev-harness-verify/Architect136v2/repo` со своим `.git`; исходные репозитории не изменялись. Вердикт записан отдельно, по прямому ограничению задания **не коммичен и не запушен**; для реальной заморозки его надлежит поместить и закоммитить в `verdicts/critic/contracts-136-v2.md` ветки предмета, поскольку `scripts/freeze_contract.sh:292–302` читает именно `HEAD:$verdict`.

Замеры делал последовательно на собственной копии. `scratch/verify.py setup` скопировал оригинальные раннеры: у `scratch/run_136.sh` заменены лишь `B`, корни миров `/tmp/dev-harness-verify/sessii-136-*` и fakehome на собственные `scratch/`, плюс разрешены переменные выбора субъекта `CHECK_DOOR/CHECK_PAR/CHECK_MKT` после штатного `subj`; клетки, оракулы и исходный `source.json` не менялись. У `scratch/run_125.sh` заменены только `BATT` и `WORLDS` на собственную копию/`scratch/s125`. `TMPDIR` — `scratch/tmp`; fakehome расположен вне allowlist `${TMPDIR}/dev-harness-verify`. Каждый из 19 мутантов взят непосредственно из каталогов `Critic136v2/mutants/m01–m12` и `Critic136v2b/mutants/n01–n07`, подставлялся только его собственный скрипт двери/паритета. Три файла отвергнутой реализации из `Architect136v2/impl_3cee078b/` независимо сравнены байт-в-байт с `git show 3cee078b:scripts/<имя>`: все три `identical True`. Полные объединённые stdout/stderr и rc каждого прогона лежат в `scratch/logs/*.txt`.

## Таблица закрытого списка

| Пункт | Итог | Основание на OBJECT и собственный замер |
|---|---|---|
| (i) Строка таблицы ↔ клетка, полный набор осей A–D | **выполнен** | `fixtures/workshop_project/sessii_136/source.json:487–834`: `.osi` 55 (A=37, B=3, C=4, D=11) + `.vne_osi` 14 = 69; `.kletki` 69. Независимый Python-парсинг `ORDER` и `run_cell` дал по 69 **уникальных** имён, множества обоих и `osi+vne_osi` совпадают с `kletki`, missing=[]/extra=[]; jq дал 55/14/69/69/37/54. Таблица A: argv/бриф 5 + 15 форм × 2 источника 30 + `\r`-пара × 2 = 37; код `k_pin_case` содержит ровно одинаковые 15 имён форм для `next` и `taskfile` (30 уникальных case-ветвей, все принадлежат A). B: a27/a31/a50; положительный страж наблюдается a30/a49. C: c3/b3/b4/b5. D: d2/d4/d1+d3/d5/d6/d9/d10/d11/d7/d8. Счёт и симметричная разница проверяются самим раннером до запуска `:684–688`, контракт `:55,:62`. **Недостающих клеток: 0.** |
| (ii) Честная модель и красное дерево | **выполнен** | `red_sessii_136.sh:690–699`, контракт `:58–59`: `--model` 69/69 rc 0; plain 5/69, красных 64, rc 1. Множество **21 новой** против 59ba025a клетки извлечено из diff ключей `source.json:.kletki` и независимо сверено со строкой `красные:` фактического plain: `new 21 red 21 green []`. |
| (iii) Стабы и адресные привязки | **выполнен** | `source.json:459–487`, `red_sessii_136.sh:703–728`, контракт `:60`: `--stabs` **37 стабов / 54 привязки / 0 непойманных**, rc 0. Побайтово равны исходным мутантам: s31=n01, s32=n02, s33=n03, s34=n04, s35=n05, s36=n07 (каждое сравнение `True`). СВОИ строки осей: s31→a47(A бриф), s32→a49(A task-file), s33→a50(B нулевой страж), s34→d9(D иное потеряно при приманке), s35→d10+d11(D вложенное), s36→a48(A пустой NEXT), s37→b5(C нет jq). Привязки читаются из JSON при прогоне, а не из описания. |
| (iv) Все архивные мутанты | **выполнен** | Контракт `:60,:64`; таблица собственных 19 прогонов ниже. m01–m12 и n01–n07 **19/19 красны**, каждый `--model` с подставленным единственным скриптом печатает как минимум одну красную клетку и `RC=2` (штатный код «модель не зелёная», не ошибка окружения). |
| (v) Норма, зоны, 125, старый implementer и границы diff | **выполнен** | Контракт `:44–52,:55–65,:68–79`. Сравнение по полным строкам 59ba025a ↔ OBJECT: И-1…И-5, И-7, И-8 и ВСЕ ЗОНА/ПЕРЕСЕЧЕНИЕ строки байт-в-байт; в И-6 добавлена **только** разрешённая фраза об имеющемся пустом страже. Счётчики критерия 48→69, 30→37, 46→54, таблица осей и ВЕРСИЯ дополнены. Старый нормативный префикс правила 7 байт-в-байт прежний; в конец дописан протокол замера 19 мутантов (совет ниже). `_gruppa_c.sh` и всё семейство 125 без diff: plain 70/70 rc 0, `--model` 70/70 rc 0. Содержимое `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в коммитах 1be3128f, 59ba025a, OBJECT сравнено с дословной строкой задания: три `True`, три одинаковых md5. Архив 3cee078b (три скрипта вместе) красен на **13** клетках, 56/69 rc 2. В `git diff --name-only 59ba025a OBJECT` только контракт 136, раннер/source 136 и семь новых стабов 136; implementer-зона остаётся `scripts/connect_project.sh scripts/make_task.sh scripts/verify_ci_parity.sh` (`:72`), frozen `.omp/extensions/path-guard.ts`, продуктовые скрипты и чужие фикстуры без diff. |
| (vi) Предкритик | **выполнен** | `contracts/136-dovodka-sessij-proektov.md:63`: `bash scripts/pre_critic.sh contracts/136-dovodka-sessij-proektov.md` в копии клона: `КРИТИК: дверь зелёная`, rc 0. |

## Сырые результаты команд

`RC=` ниже — код запущенной батареи, не цвет мутанта. Для мутантов `RC=2` после `модель не зелёная` означает успешное различение.

```text
$ bash /tmp/dev-harness-verify/Critic136v2c/scratch/run_136.sh --model
sessii_136: клеток 69, зелёных 69, красных 0
RC=0
$ bash /tmp/dev-harness-verify/Critic136v2c/scratch/run_136.sh
sessii_136: клеток 69, зелёных 5, красных 64
RC=1
$ bash /tmp/dev-harness-verify/Critic136v2c/scratch/run_136.sh --stabs
sessii_136 --stabs: стабов 37, привязок 54, непойманных 0
RC=0
$ bash /tmp/dev-harness-verify/Critic136v2c/scratch/run_125.sh
s125 red: зелёных 70, красных 0
RC=0
$ bash /tmp/dev-harness-verify/Critic136v2c/scratch/run_125.sh --model
s125 model: зелёных 70, красных 0
RC=0
$ bash /tmp/dev-harness-verify/Critic136v2c/scratch/run_136.sh --model  [CHECK_DOOR/CHECK_MKT/CHECK_PAR=git show 3cee078b:scripts/*, проверенные байтовые копии]
sessii_136: клеток 69, зелёных 56, красных 13
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a27-strazh-net a28-taskfile-argv a31-net-node a47-brief-struktura a48-pustoj-next-brief b3-trassa-net-konfiga d5-sloi-poterjan d7-bez-jq d8-profil-bit d9-sloi-drugoe-imja-poterjan d11-sloi-vlozhennoe-poterjan
модель не зелёная
RC=2
$ bash scripts/pre_critic.sh contracts/136-dovodka-sessij-proektov.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
RC=0
```

У plain после итоговой строки фактически выведена также строка `красные:` с 64 именами; полный неизменённый вывод в `scratch/logs/136-plain.txt`. Независимый вывод `scratch/check_red.py`: `new 21 red 21 green []`. Независимый `scratch/check_shape.py`: `CODE_ROWS 30 UNIQUENESS 30 … EXACT_15x2 True`, `EVERY_SHAPE_ROW_IN_AXIS True`. Независимый `scratch/meta.py`: `NORM I6 only permitted phrase: True extra present: True`, `RULE7 old normative prefix exact: True`, `OWNER` трижды `1 True`, `FROZEN_OUTSIDE []`, `BIJECTION ORDER/AST_CASE/AXES+OUTSIDE length 69 unique True missing [] extra []`.

## Мутанты: собственный красный прогон каждого

Таблица снята с полных сырых файлов `scratch/logs/<имя>.txt`: каждое значение клеток — список из фактической строки `красные:`, каждый код — фактический `RC`. Вызовы последовательны, каждый мутант подставлен из каталога соответствующего критика без правки его файла.

| Файл мутанта | Цвет, rc; зелёных/красных из 69 | Красные клетки |
|---|---|---|
| m01-noroot | **красный**, 2; 63/6 | a25 a26 a28 a29 a47 a48 |
| m02-root-in-msg | **красный**, 2; 63/6 | a25 a26 a28 a29 a47 a48 |
| m03-root-after-separator | **красный**, 2; 63/6 | a25 a26 a28 a29 a47 a48 |
| m04-foreign-root | **красный**, 2; 63/6 | a25 a26 a28 a29 a47 a48 |
| m05-duplicate-root | **красный**, 2; 63/6 | a25 a26 a28 a29 a47 a48 |
| m06-taskfile-noroot | **красный**, 2; 68/1 | a28 |
| m07-no-final-oracle | **красный**, 2; 66/3 | a30 a49 a50 |
| m08-node-fallback | **красный**, 2; 68/1 | a31 |
| m09-exact-layer-only | **красный**, 2; 65/4 | d6 d9 d10 d11 |
| m10-parity-jq-fallback | **красный**, 2; 68/1 | d7 |
| m11-allow-duplicate | **красный**, 2; 65/4 | a10 a19 a21 a43 |
| m12-append-root-to-msg | **красный**, 2; 64/5 | a25 a26 a28 a47 a48 |
| n01-brief-extra-root | **красный**, 2; 67/2 | a47 a48 |
| n02-taskfile-skip-oracle | **красный**, 2; 68/1 | a49 |
| n03-empty-guard-fallback | **красный**, 2; 68/1 | a50 |
| n04-check-wrong-layer | **красный**, 2; 67/2 | d9 d11 |
| n05-nested-layer-harness | **красный**, 2; 67/2 | d10 d11 |
| n06-broken-profile-accepted | **красный**, 2; 68/1 | d8 |
| n07-empty-next-selected | **красный**, 2; 68/1 | a48 |

Сырой формат любого mutant-файла, пример `scratch/logs/n05-nested-layer-harness.txt`:
```text
$ bash /tmp/dev-harness-verify/Critic136v2c/scratch/run_136.sh --model
sessii_136: клеток 69, зелёных 67, красных 2
красные: d10-sloi-vlozhennoe-imja d11-sloi-vlozhennoe-poterjan
модель не зелёная
RC=2
```

## Находки и обходы

**Блокирующих находок и ОБХОДОВ: нет.** Все пункты закрытого перечня исполнены; никакая проверенная здесь реализация, нарушающая названное свойство, не проходит батарею зелёной.

СОВЕТ contracts/136-dovodka-sessij-proektov.md:64 — старый нормативный текст правила 7 сохранён, но после него дописан протокол замера мутантов. Это литеральное отклонение от «правило 7 без изменений» п.3(а), а не ослабление правила: перечисленные цвета перепроверены выше, обхода нет. При желании протокол можно вынести из пункта в отчёт, нового круга для этого не требуется.

СОВЕТ contracts/136-dovodka-sessij-proektov.md:50 — И-6 требует *именованный отказ* rc 1 без exec при нулевом страже и приводит `PIN_CHUZHOJ` как имя честной модели; `fixtures/workshop_project/sessii_136/red_sessii_136.sh:409–414` требует строго `PIN_CHUZHOJ`. Клетка строже буквальной нормы: реализация с иным именованным отказом покраснеет, не получит ложного зелёного. Обхода нет; согласовать имя в норме либо оракул в батарее по усмотрению автора.

СОВЕТ contracts/136-dovodka-sessij-proektov.md:58 — SIGPIPE-флейк `c2-p17-rules` устранён по построению: `red_sessii_136.sh:454–491` показывает ВСЕ четыре использования `mkt_brief` (`k_c1`, `k_c2`, `k_c3`, `k_c5`): полный stdout сначала захватывается в `out="$(mkt_brief …)"`, затем `grep` читает here-string `<<<"$out"`. Раннего `mkt_brief | grep -q` нет (отдельный regex-поиск — ноль совпадений). Это подтверждение механизма, не новый блокер.
