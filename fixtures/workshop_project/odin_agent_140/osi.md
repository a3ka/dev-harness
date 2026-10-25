# Таблица осей батареи 140 «odin-agent-na-predmet» (полная)

Форма → клетка → защита → стаб-на-защиту (метод арбитражей 136 v2/117/116 v3/138/139).
Субъекты (исправительный проход, вердикт критика 1/2 — батарея обязана судить
ПОСТАВЛЯЕМЫЙ механизм, не только модель): безфлаговый режим судит реальную
дверь `scripts/zamok_predmeta.sh` дерева (нет → SUBJECT_ABSENT rc 1 по её
пути; обманная дверь → rc 1 с названными клетками); `--model` — эталон
`model/zamok_predmeta.sh`; `--stabs` — обманные двери над моделью (опора до
ленда) +, когда поставленная дверь существует, СЛОЙ СУБЪЕКТА: контроль всех
клеток на ней и та же матрица обманных дверей над её текстом. Интеграция
`.omp/extensions/spawn-guard.ts` без станции неисполнима (корни состояний — из
живого ctx сессии omp, инвариант 1 контракта): её клетки — «станция», закрыты
КОМАНДОЙ приёмки `stancija_odin_agent_140.sh` (rc 0/1, PROBA-строки).
Привязки «стаб ↔ вход» — ТОЛЬКО `source.json:.stab_vhod` (Н-39);
здесь и в контракте пары не утверждаются, только перечисляются клетки и защиты.

## Оси

1. **Источник события**: журнал сессии (`w02`,`w03`,`w04`,`s01`,`s22`,`u01` —
   yield-предикат `"toolName":"yield"`, mtime-брошенность) × реестр
   (`w10` pauzy.tsv, `w17` done-тег, `s13` КЛАСС РИСКА) × замок/учёт (`w01`,
   `w02`, `w13`–`w16`, `b02`, `b04`) × git-remote пина (`w19`).
2. **Роль**: рабочие architect/implementer(-glm/-vision) (`w01`–`w04`,
   `w13`–`w19`) × судьи critic/critic-sol/adversary/reviewer (`s01`–`s13`)
   × арбитр и прочие роли — пропуск (`w11`,`w12`).
3. **Состояние автора/держателя**: свободно (`w01`) × бежит (`w02`, `s02`,
   `s22`) × сдал/yield (`w03`, `s01`) × оборван-рестарт (`w04`, `w05`) ×
   автора нет (`s08`).
4. **OBJECT**: совпадает с tip ветки (`s01`, `s07`, `s10`, `b05`) × чужой
   (`s03`) × отсутствует (`s04`) × повтор того же sha той же ролью (`s06`) ×
   новый sha после правки (`s07`) × ветка утеряна (`s12`).
5. **Batch**: разные предметы (`b01`) × один предмет дважды (`b02`) ×
   смешанный с отказом — откат всего пакета (`b03`) × гонка двух процессов
   (`b04`) × рабочий + не-гейт роль (`b06`).
6. **Режим**: изолированный/нет — инвариант вердикта (`b05`).
7. **Дубль после рестарта**: отказ (`w04`), явное освобождение (`w05`),
   живой не освобождается (`w06`).
8. **Сторож/учёт**: свод состояний bezhit/yield/pauza/done + GRP-лимиты
   (`u01`), пустой учёт (`u02`), ПАУЗА освобождает слот (`w18`), done
   освобождает (`w17`), СЛОВО сверх лимита (`w16`), группа из remote
   (`w19`), смена держателя не занимает второй слот (`w03`, `w14`).
9. **Риск/порядок судей**: рисковый без адверсария (`s09`) × с завершённым
   адверсарием (`s10`) × обычный без адверсария (`s11`) × строка риска
   отсутствует — fail-closed (`s13`).
10. **Гигиена 041** (на модели; профиль parsing_hygiene — реализационной
    пачкой): delimiter-collision (`g01` префикс, `g03` TAB в имени, `g06`
    подстрока пина) × regex-injection (`g02` две строки SUBJECT) ×
    silent-drop (`g04` битый вход трёх форм) × self-application-green
    (`g05` спавн исполнителя самого предмета 140).

## Клетки (48) — имя → ось → исход

| клетка | ось (кратко) | исход честной двери |
|---|---|---|
| w01-pervyj-rabochij | рабочий; свободно; замок | rc 0 PUSCHEM + START + занятие |
| w02-vtoroj-rabochij-zhiv | рабочий; бежит; дубль | rc 1 RABOCHIJ_ZHIV |
| w03-posle-yield-novyj-rabochij | рабочий; автор сдал | rc 0 (ротация; слот не дважды) |
| w04-dubl-posle-restarta | оборван; рестарт | rc 1 ZAMOK_BROSHEN |
| w05-osvobodit-broshennyj | оборван; --osvobodit | rc 0 + RELEASE; повтор rc 0 |
| w06-osvobodit-zhivoj | бежит; --osvobodit | rc 1 ZAMOK_ZHIV |
| w07-subject-net | форма | rc 1 SUBJECT_NET_V_ZADANII |
| w08-subject-vne-grammatiki | форма 1404 | rc 1 SUBJECT_NET_V_ZADANII |
| w09-imja-net | форма | rc 1 IMJA_NET |
| w10-pauza | реестр ПАУЗА | rc 1 PAUZA_VLADELTSA |
| w11-scout-propusk | роль вне классов | rc 0 PROPUST, записей нет |
| w12-arbiter-propusk | арбитр процесса | rc 0 PROPUST |
| w13-limit-harness | лимит 1 | rc 1 LIMIT_GRUPPY |
| w14-limit-mob-tri-ok | mob 2/3 | rc 0 |
| w15-limit-mob-chetyre | mob 3/3 + новый | rc 1 LIMIT_GRUPPY |
| w16-limit-slovo | mob 3/3 + SLOVO | rc 0 |
| w17-limit-done-osvobozhdaet | done-тег | rc 0 |
| w18-limit-pauza-osvobozhdaet | ПАУЗА держит/освобождает | rc 0 |
| w19-gruppa-iz-pina | remote Complior-mob | rc 0, START group=mob |
| s01-sudja-posle-yield | судья; автор сдал; OBJECT== | rc 0 + судейское занятие |
| s02-kritik-pri-zhivom-rabochem | судья; рабочий бежит | rc 1 RABOCHIJ_ZHIV |
| s03-object-rashoditsja | OBJECT чужой | rc 1 OBJECT_RASHODITSJA |
| s04-object-net | OBJECT нет | rc 1 OBJECT_OTSTUTSVUET |
| s05-vtoroj-sudja-zhiv | живой судья | rc 1 SUDJA_ZHIV |
| s06-object-uzhe-suzhen | та же роль + тот же sha | rc 1 OBJECT_UZHE_SUZHEN |
| s07-ispravitelnyj-novyj-object | новая роль/новый sha | rc 0 |
| s08-rabochego-net | автора нет | rc 1 RABOCHEGO_NET |
| s09-adv-do-rev | рисковый; ревьюер раньше | rc 1 ADVERSARIJ_DO_REVJUERA |
| s10-adv-do-rev-zakryt | рисковый; адверсарий сдал | rc 0 (конвейер на одном OBJECT) |
| s11-obychnyj-bez-adv | обычный | rc 0 |
| s12-vetka-nedostupna | ветка утеряна | rc 1 VETKA_NEDOSTUPNA |
| s13-klass-riska-net | строки риска нет | rc 1 KLASS_RISKA_NET |
| s14-pin-rashozhdenie | пин ≠ предмет | rc 1 RASHOZHDENIE_PINA |
| s22-avtor-zhiv-bez-zamka | автор бежит; замок снят вручную | rc 1 AVTOR_ESHCHO_RABOTAET (журнал) |
| b01-paket-dva-predmeta | batch 141+142 | rc 0, 2 START, 2 занятия |
| b02-dubl-v-pakете | batch 140+140 | rc 1 DUBL_V_PAKETE, состояние нетронуто |
| b03-smeshannyj-otkat | batch рабочий+судья-отказ | rc 1, откат: записей нет |
| b04-gonka-dva-protsessa | параллельные двери | ровно один rc 0; START 1 |
| b05-izolirovannyj-invariant | isolated true/false | вердикт инвариантен |
| b06-paket-rabochij-plus-scout | смешанный batch | rc 0, 1 START |
| u01-uchet-svod | учёт состояний | UCHET-строки + GRP harness 2/1 |
| u02-uchet-pust | пустой учёт | только GRP 0/1 0/3 0/2 |
| g01-prefiks-kollizija | XSUBJECT | rc 1 SUBJECT_NET (якорь) |
| g02-dve-stroki-subject | инъекция второй строкой | rc 1 SUBEKT_DVA_V_ZADANII |
| g03-tab-v-imeni | разделитель в имени | rc 1 IMJA_NET |
| g04-bityj-vhod | три формы битого | rc 1 BITYJ_VHOD (не молча) |
| g05-samo-prolozhenie | собственный предмет 140 | rc 0 (механизм себе не мешает) |
| g06-podstroka-pina | пин подстрокой | rc 1 PIN_NET (якорь) |

## Каналы клеток

Все 48 клеток таблицы выше — канал «дверь-CI»: гоняются против субъекта
безфлагового режима (`scripts/zamok_predmeta.sh`; до ленда — SUBJECT_ABSENT rc 1
по пути реального субъекта) и против эталона/стабов (`--model`/`--stabs`).
Клетки интеграции расширения — канал «станция»: таблица ниже, команда приёмки
`stancija_odin_agent_140.sh` (подложный tool_call через РЕАЛЬНЫЙ хук — приём
zashchita_main_104; omp не нужен, корни — из подложного ctx по грамматике
инварианта 1). Слои не подменяют друг друга: алфавит 104 в CI остаётся на
замороженной семье zashchita_main_104.

## Станционные клетки интеграции (15) — имя → ось → исход честной интеграции

| клетка | ось (кратко) | исход |
|---|---|---|
| p01-int-dubl-rabochego | дубль живого рабочего через tool_call (приёмка 5а) | block RABOCHIJ_ZHIV |
| p02-int-sudja-do-yield | судья до yield автора (класс свидетеля критика) | block RABOCHIJ_ZHIV |
| p03-int-sudja-bez-object | судья без OBJECT= (приёмка 5б) | block OBJECT_OTSTUTSVUET |
| p04-int-object-rashoditsja | OBJECT ≠ tip ветки автора | block OBJECT_RASHODITSJA |
| p05-int-porjadok-adv-rev | рисковый: ревьюер раньше адверсария | block ADVERSARIJ_DO_REVJUERA |
| p06-int-limit-harness | лимит harness 1 занят | block LIMIT_GRUPPY |
| p07-int-paket-atomarnyj | batch с дублем предмета | block DUBL_V_PAKETE, занятий ноль |
| p08-int-gonka | два параллельных tool_call (симметричные) | ровно один pass и ровно один block |
| p09-int-dubl-posle-restarta | брошенный замок (журнал молчит 120 мин) | block ZAMOK_BROSHEN |
| p10-int-propusk-posle-yield | судья после yield на tip | pass + START/занятие пишет расширение |
| p11-int-alfavit-104 | агент вне алфавита (104 не ослаблен) | block «вне алфавита» |
| p12-int-ne-task | toolName≠task | pass (хук не трогает чужие инструменты) |
| p13-int-fail-closed | состояние нечитаемо (дверь rc 2) | block «страж замка сломан» |
| p14-int-uchet | --uchet живого мира (приёмка 5в) | UCHET/GRP-строки состояний |
| m01-huk-bez-dveri | обманная интеграция: блок [ZAMOK140] снят | симптом обязан быть виден (проход где block) — проверка проверяющего |

Классы «хук глотает rc 1» и «хук fail-open на rc 2» дают СИМПТОМЫ p02/p13
(проход/молчание там, где обязан блок) — ловятся поведенчески на живом дереве;
m01 демонстрирует ловимость класса «дверь не вызывается» живой мутацией по
якорям [ZAMOK140] (до ленда само дерево есть эта обманка: p02 KRASNO).

## Защиты двери ([Dn] — маркеры в тексте модели; стабы — мутации по ним)

D1 дубль живого рабочего; D2 yield-предикат журнала; D3 брошенный замок ≠
разрешение (+D3b подбор упавшего мьютекса); D4 обязательность имени; D5 якорь
SUBJECT; D6 пин == предмет; D7 пара пина; D8 обязательность OBJECT; D9 OBJECT ==
tip ветки; D10 автор сдал до судьи; D11 повтор роли на OBJECT; D12 автора нет;
D13 строка КЛАСС РИСКА; D14 адверсарий до ревьюера; D15 ПАУЗА; D16 СЛОВО; D17
repoId реестра; D18 done-тег; D19 группа из remote; D20 дубль в пакете; D21
второй живой судья; D22 атомарность (мьютекс mkdir); D23 START до возврата
разрешения; D24 живой замок не освобождается; D25 лимит 1/3/2 (сам предмет
исключается из счёта — ротация держателя не занимает второй слот); D26 откат
пакета; D27 битый вход; D28 роли вне классов — пропуск; X1 свидетель критика
(вердикт 1/2, attack-repo): обманная дверь «всегда PUSCHEM» — все защиты сняты
сразу, стаб x01-vsegda-puschem (мутация КОДОМ, маркер [X1]; замер красноты по
всем 48 клеткам: красны 44, зелены б05/s11/w17/w18 — клетки с единственным
предъявлением «голый rc 0»; привязка — минимальный набор классов, 12 клеток).

## Замеры (прогоны этой пачки, 2026-10-25, исправительный проход v2)

- безфлаговый на дереве БЕЗ реализации: rc 1, `SUBJECT_ABSENT: субъекта-двери
  нет: <абс-путь>/scripts/zamok_predmeta.sh`, 48 строк `CASE … KRASNO
  (SUBJECT_ABSENT: <путь>)` + строка STANCIONNYE (15 клеток);
- `--model`: rc 0, 48/48 ok;
- `--stabs`: rc 0, контроль 48/48, SVJAZI 39 (27 модельных + 12 x01), живых 0,
  строка SUBJEKT_NET (слоя субъекта нет — опора над моделью);
- зелёный контроль реального субъекта: одноразовая копия дерева с
  model/zamok_predmeta.sh в позиции scripts/ ⇒ безфлаговый rc 0, KLETKI 48
  KRASNYH 0; `--stabs` там же: контроль субъекта 48/48 + SUBJEKT_SVJAZI 39,
  живых 0 (слой субъекта жив);
- свидетель критика (обманная дверь «PUSCHEM», копия attack-repo): безфлаговый
  rc 1, KLETKI 48 KRASNYH 44 (именованные клетки и причины); `--stabs` rc 1,
  SUBJEKT_KRASNO 44 — поставленная дверь поймана;
- станционная команда (15 клеток): на нашем дереве rc 1 (13 KRASNO — интеграции
  нет, боли живы; p11/p12 OK — слой 104 жив); на одноразовой честной интеграции
  (замороженный хук + блок [ZAMOK140] инварианта 1, дверь-модель) rc 0, 15/15
  OK (три прогона подряд — гонка стабильна); та же интеграция с дверью-свидетелем
  в scripts/ ⇒ rc 1, 12 KRASNO (обманная дверь видна и через интеграцию);
- порча модели (дописанная строка) → rc 2 ORACLE_TAMPERED; порча стаба → rc 2
  ORACLE_TAMPERED (дрейф от мутации);
- `env -i PATH=/usr/bin:/bin` — те же числа (48/48/39); omp в PATH не нужен;
  сети нет; git/jq/bash обязательны (станционной команде ещё и node).
