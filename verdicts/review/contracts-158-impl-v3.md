FAIL

OBJECT=1d5c2ee06afa39cfb576b6d2deef1f392fdf1861
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; ТРЕК набора: ПОЛНЫЙ)
СУД: repo=dev-harness (контракт frozen/contracts/158/2 → 60ed70d4); предмет=158; фаза=реализация (scoped-исправительный); роль=reviewer; сессия=Rev158r6; модель-план=@opus (config/agent_models.json roles.reviewer → tiers.audit) = anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; вызов=5 из 5, последний (прежние: Reviewer158Scoped, Reviewer158Fresh, Reviewer158Opus3 FAIL @a77f3d11; Rev158r5 FAIL @f8134ed4)
НЕЗАВИСИМОСТЬ: автор — implementer (identity implementer, все 22 коммита кандидата); адверсарий r2 accept @a77f3d11 повторно не звался (бюджет 2/2, класс обычный); судья — reviewer, кода не правил; референс mob-ref — продукт Impl148h/mob (коммиты 148, 2026-11-04, до работы 158) без правок, плюс модуль токенов носителя 148.
НАХОДКИ: .review/2026-11-09-92.md — блок Б-7 (адресат architect, v+1 контракта/SPEC; иначе слово владельца); советы С-12, С-13, С-14; повторы С-7, С-8, С-1. Закрыты: Б-5, Б-6, С-9, С-11; У-3 (а)(б) закрыты, (в)(г) — Б-7.

## Вердикт

FAIL. Блок один — Б-7, и его адресат не implementer. Исполнение объекта по своим строкам
зелёное моей мерой: все семь команд задания дали rc 0, а счёты совпали с заявленными.
Но зелёный `W --repo mob-ref` держится на правиле приёмки, которого нет в frozen 158/2.

**Б-7** (И-2, И-1(г); SPEC §4, §5, §6F, §7; Демаркация). И-2 требует «надпись видима по
И-1(г)» у КАЖДОЙ обязательной цели, а И-1(г) понимает под надписью видимый Text с
ожидаемым содержимым. В карте `model/karta-mob-ref.json` у цели `shell-profile-entry` стоит
`"objazatelna": true` и `"nadpis": null`. Зонд (`nabor-zond-158.test.tsx:131`
`tsel.nadpis !== null && …`) при null проверку И-1(г) пропускает и вместо неё сверяет
`accessibilityLabel` новой веткой `a11yNadpis`. Ни ветки, ни клетки f34, ни стаба st14 в SPEC
нет: §6F кончается на f33, §7 — на st13. Честный эталон B — продукт 148 без правок, где вход
профиля — значок без Text. По тексту frozen 158/2 такой эталон обязан краснеть
NADPIS_NEVIDIMA, а п.2 требует от него rc 0. Замороженные обязательства противоречат друг
другу на единственном честном входе, и средствами зоны implementer это не решается (см.
.review). Прямой замер того же противоречия: на дереве `cf18361c` (r5, карта со старой видимой надписью «Profil bearbeiten», т.е. карта по тексту frozen 158/2) честный эталон B даёт `f00-chestnyj-kontrol` rc 1 NADPIS_NEVIDIMA (лог красного-до ниже). **Ответ на вопрос (г) задания: НЕТ.** Иконка с доступным именем без видимой надписи
по тексту frozen 158/2 недопустима. Адресат — architect (v+1 контракта и SPEC), выбор
другого эталона — за владельцем.

Ответы на (а)–(в):
(а) Вход честный и не зависит от автора. Моя пересборка mob-ref из продукта Impl148h/mob
`6b5ef76` и замороженных носителей своего клона совпала со станцией: `diff -r` rc 0. Против
продукта отличается только добавленный `kompakt-tokens.ts`, у которого нет потребителя (С-13).
`tab-shell.tsx` побайтово равен продукту, sha256 `558f71f3…`. Коммиты продукта сделаны в
работе 148 2026-11-04.
(б) Карта не подогнана. Мой прогон `snyat-karta-mob-ref.py` по станции дал карту, равную карте
дерева (`True`). Семантическая разница против прежней карты — одна цель:
`nadpis 'Profil bearbeiten' → null` и `+accessibilityLabel 'Profil und Einstellungen'`. Это
значение `proposed.kompakt.header.profile.a11y` в `ui-copy.ts:48`, а «Profil bearbeiten» —
`action.F12.A01` (`ui-copy.ts:93`). Остальные поля карты и прочие четыре цели не изменились.
Расхождение с решением оркестратора («Profil bearbeiten») implementer назвал верно.
(в) Видимая надпись через ветку не обходится: M1 и M5 KRASNO, M6 KRASNO, f23–f26 и f34 ok
(красные образцы), st05 и st14 KRASEN. Но сама ветка даёт обход ИМЕНИ: при `nadpis: null`
и без `accessibilityLabel` в карте (M3) иконка без имени проходит, пустое имя (M4)
проходит, а `nadpis: null` у цели с видимой надписью (M2) снимает с неё И-1(г). Это вход
для v+1 в составе Б-7.

Закрыто: Б-5 (patch-id 22/22 различны, связка разобрана побайтово, гейт и нога одним
коммитом — прямо по И-6(д)); Б-6 (оба `--repo` rc 0, 75/75; красное-до — мой прогон r5-дерева
`cf18361c` на том же mob-ref: rc 1, красных 29 — c05, f03, f04, f10–f33, а также d01 и f00); С-9; С-11. Область правки — ЗОНА implementer. Соседи
147/148/149/151/143/159 и `contracts/` против базы не тронуты. SPEC, контракт и дверь равны
frozen/contracts/158/2. CI PR #621 на head = OBJECT: 16 SUCCESS, 1 SKIPPED.

СВЕРКА-СТАНДАРТОВ: не применимо — дифф в харнесе dev-harness (fixtures/ + scripts/);
документов docs/ARCHITECTURE.md / docs/CODING-STANDARDS.md продуктового бэкенда дифф не
касается; mob-ref читается, не правится.

## Паразитная сложность (контракт 050) — новые и раздутые артефакты диффа r5→r6

Ответы на пять вопросов: (1) свойство; (2) состояние; (3) сколько файлов меняется вместе;
(4) глубина; (5) потребитель.

- `probe.istochnik_ref_clean()` (7f81f73c): (1) SPEC §6F — входы f03–f08 «копии ref-clean»;
  (2) явное: путь `REFERENSI[0][1]`, видно в docstring и в причине «станция ref-clean …
  отсутствует»; (3) 1 файл, не выросло; (4) интерфейс 0 аргументов, скрывает выбор станции
  для 9 мест; (5) клетки f03–f08, f10–f33, c05 в `--repo`. ESSENTIAL: более простой формы,
  проходящей обе строки `--repo`, нет (форма Б-6 прошлого круга).
- `STANCIYA_OBRAZTSA` + `istochnik_obrazca()` (2f189b04): (1) только f34, якорь которого лежит
  в экране 148 — это часть Б-7; (2) явная таблица; (3) +1 место на каждый будущий образец
  не-ref-clean; (4) мелкий, 1 запись; (5) f34. Судьба — с Б-7 (v+1); отдельной находки нет.
- `a11yNadpis` + ветка зонда + `Tsel.accessibilityLabel` (2f189b04): (1) в frozen 158/2
  свойства нет — Б-7; (2) поле карты, явное; (3) helpery.ts + зонд + копия st14 = 3; (4) 1
  функция, 17 строк; (5) f34/st14. Предмет Б-7, а не 050.
- `model/mutanty/profil-bez-a11y.py`, клетка f34 (2f189b04): та же судьба (Б-7).
- `stubs/st14-zond-bez-a11y.py` + `stubs/st14-helpery-bez-a11y.ts` (337 строк, копия
  helpery.ts): (1) поимка ветки Б-7; (3) правка хелпера → 2 копии (как у st05); (5) `--stabs`
  SVJAZI. ACCIDENTAL-совет С-14: более простая форма — якорная замена в копии хелпера.
- `probe.otkrytie_tega()` (1d5c2ee0): (1) d01 «каждый литеральный testID интерактивного узла
  есть в карте» (SPEC §4 «Полнота карты — клетка d01»); (2) нет; (3) 1; (4) 1 аргумент
  позиции, разбор тега до `>` вне скобок; (5) d01 в W/--model. ESSENTIAL: окно в 400 символов
  на эталоне B даёт ложный KARTA_NE_POLNA (моя мера: d01 rc 1 у 2f189b04 и rc 0 у 1d5c2ee0).
- `nositeli/mob-ref-provennost.md` (fdeefb02): (1) У-3 — происхождение входа; (2) текст,
  без состояния; (3) правится вместе с рецептом вне дерева; (5) судья (У-3). Не код, ESSENTIAL
  для У-3.
- Удаления (1ff70582 С-9, 775f869e Б-4) интерфейс сужают; `finally ubrat_vremennye()`
  (40ed717c) — та же функция, нового состояния нет.

## Сырые прогоны

Клон `/tmp/dev-harness-verify/Rev158r6/d5cfa96b/repo` (SSH-клон ssh://git@github.com/a3ka/dev-harness.git, свой `.git`, detached на
OBJECT). Тяжёлые режимы шли параллельно в локальных клонах того же OBJECT `runA` (W, --model,
--stabs последовательно), `runB` (--repo ref-clean), `runC` (--repo mob-ref); красное-до — `runD`
на `cf18361c` после окончания B/C. Одновременно жило не больше трёх копий референсов.

### log-W.txt

```text
$ (cwd /tmp/dev-harness-verify/Rev158r6/d5cfa96b/runA @ 1d5c2ee06afa39cfb576b6d2deef1f392fdf1861) bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh 
CASE a01-trek-po-umolchaniju ok
CASE a02-risk-bez-stroki ok
CASE a03-risk-legkij ok
CASE a04-risk-legkij-so-slovom ok
CASE a05-polnyj-vsegda ok
CASE a06-pereklyuchenie ok
CASE a07-tochechnost ok
CASE a08-grammatika ok
CASE a09-dubl ok
CASE a10-sloj-ispolnen-v-polnom ok
CASE a11-sloj-krasen ok
CASE a12-marker-vne-priemki ok
CASE a13-marker-v-priemke ok
CASE a14-sloj-vne-tablicy ok
CASE z01-gate-v-dereve ok
CASE z02-noga-pre-critic ok
CASE b01-ostanovka-podtverzhdena ok
CASE b02-zalipshij-390 ok
CASE b03-vtoroj-boot-port ok
CASE b04-maksimum-dva-avd ok
CASE b05-maska-48 ok
CASE b06-kanon-piny ok
CASE b07-mutant-393-pri-390 ok
CASE c01-literal-nav-height ok
CASE c02-literal-line-height ok
CASE c03-literal-press-long ok
CASE c04-ravnoe-chislo-bez-svjazi ok
CASE d01-karty-polny ok
CASE d02-oracle-tamper ok
CASE d03-pustoj-produkt ok
CASE e01-soglasovano ok
CASE e02-chisla-vne-teksta ok
CASE g01-147-model ok
CASE g02-147-stabs ok
CASE g03-148-model ok
CASE g04-148-stabs ok
CASE g05-149-model ok
CASE g06-149-stabs ok
CASE g07-143-stabs ok
CASE g08-159 ok
клеток 40, зелёных 40, красных 0
RC=0  (wall 440s)
```

### log-model.txt

```text
$ (cwd /tmp/dev-harness-verify/Rev158r6/d5cfa96b/runA @ 1d5c2ee06afa39cfb576b6d2deef1f392fdf1861) bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --model
CASE a01-trek-po-umolchaniju ok
CASE a02-risk-bez-stroki ok
CASE a03-risk-legkij ok
CASE a04-risk-legkij-so-slovom ok
CASE a05-polnyj-vsegda ok
CASE a06-pereklyuchenie ok
CASE a07-tochechnost ok
CASE a08-grammatika ok
CASE a09-dubl ok
CASE a10-sloj-ispolnen-v-polnom ok
CASE a11-sloj-krasen ok
CASE a12-marker-vne-priemki ok
CASE a13-marker-v-priemke ok
CASE a14-sloj-vne-tablicy ok
CASE b01-ostanovka-podtverzhdena ok
CASE b02-zalipshij-390 ok
CASE b03-vtoroj-boot-port ok
CASE b04-maksimum-dva-avd ok
CASE b05-maska-48 ok
CASE b06-kanon-piny ok
CASE b07-mutant-393-pri-390 ok
CASE c01-literal-nav-height ok
CASE c02-literal-line-height ok
CASE c03-literal-press-long ok
CASE c04-ravnoe-chislo-bez-svjazi ok
CASE d01-karty-polny ok
CASE d02-oracle-tamper ok
CASE d03-pustoj-produkt ok
CASE e01-soglasovano ok
CASE e02-chisla-vne-teksta ok
CASE g01-147-model ok
CASE g02-147-stabs ok
CASE g03-148-model ok
CASE g04-148-stabs ok
CASE g05-149-model ok
CASE g06-149-stabs ok
CASE g07-143-stabs ok
клеток 37, зелёных 37, красных 0
RC=0  (wall 446s)
```

### log-stabs.txt

```text
$ (cwd /tmp/dev-harness-verify/Rev158r6/d5cfa96b/runA @ 1d5c2ee06afa39cfb576b6d2deef1f392fdf1861) bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --stabs
CASE a01-trek-po-umolchaniju ok
CASE a02-risk-bez-stroki ok
CASE a03-risk-legkij ok
CASE a04-risk-legkij-so-slovom ok
CASE a05-polnyj-vsegda ok
CASE a06-pereklyuchenie ok
CASE a07-tochechnost ok
CASE a08-grammatika ok
CASE a09-dubl ok
CASE a10-sloj-ispolnen-v-polnom ok
CASE a11-sloj-krasen ok
CASE a12-marker-vne-priemki ok
CASE a13-marker-v-priemke ok
CASE a14-sloj-vne-tablicy ok
CASE b01-ostanovka-podtverzhdena ok
CASE b02-zalipshij-390 ok
CASE b03-vtoroj-boot-port ok
CASE b04-maksimum-dva-avd ok
CASE b05-maska-48 ok
CASE b06-kanon-piny ok
CASE b07-mutant-393-pri-390 ok
CASE c01-literal-nav-height ok
CASE c02-literal-line-height ok
CASE c03-literal-press-long ok
CASE c04-ravnoe-chislo-bez-svjazi ok
CASE d01-karty-polny ok
CASE d02-oracle-tamper ok
CASE d03-pustoj-produkt ok
CASE e01-soglasovano ok
CASE e02-chisla-vne-teksta ok
CASE g01-147-model ok
CASE g02-147-stabs ok
CASE g03-148-model ok
CASE g04-148-stabs ok
CASE g05-149-model ok
CASE g06-149-stabs ok
CASE g07-143-stabs ok
клеток 37, зелёных 37, красных 0
STAB st01-trek-bez-riska.py a02-risk-bez-stroki KRASEN
STAB st01-trek-bez-riska.py a03-risk-legkij KRASEN
STAB st01-trek-bez-riska.py KRASEN
STAB st02-trek-udaljaet-sloj.py a06-pereklyuchenie KRASEN
STAB st02-trek-udaljaet-sloj.py KRASEN
STAB st03-avd-393-bez-podtverzhdenija.py b02-zalipshij-390 KRASEN
STAB st03-avd-393-bez-podtverzhdenija.py b07-mutant-393-pri-390 PROSHYOL
STAB st03-avd-393-bez-podtverzhdenija.py KRASEN
STAB st04-lint-po-chislu.py c01-literal-nav-height KRASEN
STAB st04-lint-po-chislu.py c04-ravnoe-chislo-bez-svjazi KRASEN
STAB st04-lint-po-chislu.py KRASEN
STAB st05-zond-bez-predkov.py f15-tsel-opacity0 KRASEN
STAB st05-zond-bez-predkov.py f16-tsel-predok-opacity0 KRASEN
STAB st05-zond-bez-predkov.py f25-nadpis-vlozhennyj-prozrachnyj KRASEN
STAB st05-zond-bez-predkov.py KRASEN
STAB st06-oracle-s-diska.py d02-oracle-tamper KRASEN
STAB st06-oracle-s-diska.py e01-soglasovano PROSHYOL
STAB st06-oracle-s-diska.py KRASEN
STAB st07-polnyj-bez-ispolnenija.py a10-sloj-ispolnen-v-polnom KRASEN
STAB st07-polnyj-bez-ispolnenija.py a06-pereklyuchenie KRASEN
STAB st07-polnyj-bez-ispolnenija.py a11-sloj-krasen KRASEN
STAB st07-polnyj-bez-ispolnenija.py KRASEN
STAB st08-marker-gde-ugodno.py a12-marker-vne-priemki KRASEN
STAB st08-marker-gde-ugodno.py KRASEN
STAB st09-sovmestnyj-v-toy.py f03-sovmestnyj-chestnyj KRASEN
STAB st09-sovmestnyj-v-toy.py f04-sovmestnyj-vykljuchennaja-tsel KRASEN
STAB st09-sovmestnyj-v-toy.py f05-sovmestnyj-polnyj-sloj KRASEN
STAB st09-sovmestnyj-v-toy.py KRASEN
STAB st10-sovmestnyj-otvergaet.py f03-sovmestnyj-chestnyj KRASEN
STAB st10-sovmestnyj-otvergaet.py f04-sovmestnyj-vykljuchennaja-tsel KRASEN
STAB st10-sovmestnyj-otvergaet.py f05-sovmestnyj-polnyj-sloj KRASEN
STAB st10-sovmestnyj-otvergaet.py KRASEN
STAB st11-sovmestnyj-karta-ref-clean.py f06-sovmestnyj-karta-iz-fajla KRASEN
STAB st11-sovmestnyj-karta-ref-clean.py KRASEN
STAB st12-sovmestnyj-tablica-nomerov.py f06-sovmestnyj-karta-iz-fajla KRASEN
STAB st12-sovmestnyj-tablica-nomerov.py f07-sovmestnyj-nezavisimost-nomera KRASEN
STAB st12-sovmestnyj-tablica-nomerov.py KRASEN
STAB st13-sovmestnyj-karta-po-nomeru.py f06-sovmestnyj-karta-iz-fajla KRASEN
STAB st13-sovmestnyj-karta-po-nomeru.py KRASEN
STAB st14-zond-bez-a11y.py f34-nadpis-a11y-net KRASEN
STAB st14-zond-bez-a11y.py KRASEN
SVJAZI 27
RC=0  (wall 451s)
```

### log-repo-refclean.txt

```text
$ (cwd /tmp/dev-harness-verify/Rev158r6/d5cfa96b/runB @ 1d5c2ee06afa39cfb576b6d2deef1f392fdf1861) bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo /tmp/dev-harness-verify/Arch147t/ref-clean
CASE a01-trek-po-umolchaniju ok
CASE a02-risk-bez-stroki ok
CASE a03-risk-legkij ok
CASE a04-risk-legkij-so-slovom ok
CASE a05-polnyj-vsegda ok
CASE a06-pereklyuchenie ok
CASE a07-tochechnost ok
CASE a08-grammatika ok
CASE a09-dubl ok
CASE a10-sloj-ispolnen-v-polnom ok
CASE a11-sloj-krasen ok
CASE a12-marker-vne-priemki ok
CASE a13-marker-v-priemke ok
CASE a14-sloj-vne-tablicy ok
CASE z01-gate-v-dereve ok
CASE z02-noga-pre-critic ok
CASE b01-ostanovka-podtverzhdena ok
CASE b02-zalipshij-390 ok
CASE b03-vtoroj-boot-port ok
CASE b04-maksimum-dva-avd ok
CASE b05-maska-48 ok
CASE b06-kanon-piny ok
CASE b07-mutant-393-pri-390 ok
CASE c01-literal-nav-height ok
CASE c02-literal-line-height ok
CASE c03-literal-press-long ok
CASE c04-ravnoe-chislo-bez-svjazi ok
CASE c05-slezhenie ok
CASE d01-karty-polny ok
CASE d02-oracle-tamper ok
CASE d03-pustoj-produkt ok
CASE e01-soglasovano ok
CASE e02-chisla-vne-teksta ok
CASE f00-chestnyj-kontrol ok
CASE f01-predposylka ok
CASE f02-sposoby-zony ok
CASE f03-sovmestnyj-chestnyj ok
CASE f04-sovmestnyj-vykljuchennaja-tsel ok
CASE f05-sovmestnyj-polnyj-sloj ok
CASE f06-sovmestnyj-karta-iz-fajla ok
CASE f07-sovmestnyj-nezavisimost-nomera ok
CASE f08-sovmestnyj-dobavlenie-dannyh ok
CASE f10-zona-20 ok
CASE f11-zona-36-min36 ok
CASE f12-zona-rebenok-44 ok
CASE f13-zona-flex-20 ok
CASE f14-zona-hitSlop-otric ok
CASE f15-tsel-opacity0 ok
CASE f16-tsel-predok-opacity0 ok
CASE f17-tsel-display-none ok
CASE f18-tsel-fon-nadpis-transparent ok
CASE f19-tsel-nulevoj-boks ok
CASE f20-tsel-za-ekranom ok
CASE f21-tsel-za-klipom ok
CASE f22-tsel-perekryta ok
CASE f23-nadpis-skrytyj-text ok
CASE f24-nadpis-prozrachnye-bukvy ok
CASE f25-nadpis-vlozhennyj-prozrachnyj ok
CASE f26-nadpis-nulevaja-shirina ok
CASE f27-dejstvie-sdvig ok
CASE f28-dejstvie-na-393 ok
CASE f29-dejstvie-pointer-none ok
CASE f30-cel-disabled ok
CASE f31-cel-otsutstvuet ok
CASE f32-sostojanie-nedostizhimo ok
CASE f33-sostojanie-slito ok
CASE f34-nadpis-a11y-net ok
CASE g01-147-model ok
CASE g02-147-stabs ok
CASE g03-148-model ok
CASE g04-148-stabs ok
CASE g05-149-model ok
CASE g06-149-stabs ok
CASE g07-143-stabs ok
CASE g08-159 ok
клеток 75, зелёных 75, красных 0
RC=0  (wall 741s)
```

### log-repo-mobref.txt

```text
$ (cwd /tmp/dev-harness-verify/Rev158r6/d5cfa96b/runC @ 1d5c2ee06afa39cfb576b6d2deef1f392fdf1861) bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo /tmp/dev-harness-verify/Arch148t/mob-ref
CASE a01-trek-po-umolchaniju ok
CASE a02-risk-bez-stroki ok
CASE a03-risk-legkij ok
CASE a04-risk-legkij-so-slovom ok
CASE a05-polnyj-vsegda ok
CASE a06-pereklyuchenie ok
CASE a07-tochechnost ok
CASE a08-grammatika ok
CASE a09-dubl ok
CASE a10-sloj-ispolnen-v-polnom ok
CASE a11-sloj-krasen ok
CASE a12-marker-vne-priemki ok
CASE a13-marker-v-priemke ok
CASE a14-sloj-vne-tablicy ok
CASE z01-gate-v-dereve ok
CASE z02-noga-pre-critic ok
CASE b01-ostanovka-podtverzhdena ok
CASE b02-zalipshij-390 ok
CASE b03-vtoroj-boot-port ok
CASE b04-maksimum-dva-avd ok
CASE b05-maska-48 ok
CASE b06-kanon-piny ok
CASE b07-mutant-393-pri-390 ok
CASE c01-literal-nav-height ok
CASE c02-literal-line-height ok
CASE c03-literal-press-long ok
CASE c04-ravnoe-chislo-bez-svjazi ok
CASE c05-slezhenie ok
CASE d01-karty-polny ok
CASE d02-oracle-tamper ok
CASE d03-pustoj-produkt ok
CASE e01-soglasovano ok
CASE e02-chisla-vne-teksta ok
CASE f00-chestnyj-kontrol ok
CASE f01-predposylka ok
CASE f02-sposoby-zony ok
CASE f03-sovmestnyj-chestnyj ok
CASE f04-sovmestnyj-vykljuchennaja-tsel ok
CASE f05-sovmestnyj-polnyj-sloj ok
CASE f06-sovmestnyj-karta-iz-fajla ok
CASE f07-sovmestnyj-nezavisimost-nomera ok
CASE f08-sovmestnyj-dobavlenie-dannyh ok
CASE f10-zona-20 ok
CASE f11-zona-36-min36 ok
CASE f12-zona-rebenok-44 ok
CASE f13-zona-flex-20 ok
CASE f14-zona-hitSlop-otric ok
CASE f15-tsel-opacity0 ok
CASE f16-tsel-predok-opacity0 ok
CASE f17-tsel-display-none ok
CASE f18-tsel-fon-nadpis-transparent ok
CASE f19-tsel-nulevoj-boks ok
CASE f20-tsel-za-ekranom ok
CASE f21-tsel-za-klipom ok
CASE f22-tsel-perekryta ok
CASE f23-nadpis-skrytyj-text ok
CASE f24-nadpis-prozrachnye-bukvy ok
CASE f25-nadpis-vlozhennyj-prozrachnyj ok
CASE f26-nadpis-nulevaja-shirina ok
CASE f27-dejstvie-sdvig ok
CASE f28-dejstvie-na-393 ok
CASE f29-dejstvie-pointer-none ok
CASE f30-cel-disabled ok
CASE f31-cel-otsutstvuet ok
CASE f32-sostojanie-nedostizhimo ok
CASE f33-sostojanie-slito ok
CASE f34-nadpis-a11y-net ok
CASE g01-147-model ok
CASE g02-147-stabs ok
CASE g03-148-model ok
CASE g04-148-stabs ok
CASE g05-149-model ok
CASE g06-149-stabs ok
CASE g07-143-stabs ok
CASE g08-159 ok
клеток 75, зелёных 75, красных 0
RC=0  (wall 745s)
```

### log-redbefore-cf18361c-mobref.txt

```text
$ (cwd /tmp/dev-harness-verify/Rev158r6/d5cfa96b/runD @ cf18361cc98684b032c3b8a69632d4f023405c9a) bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo /tmp/dev-harness-verify/Arch148t/mob-ref
CASE a01-trek-po-umolchaniju ok
CASE a02-risk-bez-stroki ok
CASE a03-risk-legkij ok
CASE a04-risk-legkij-so-slovom ok
CASE a05-polnyj-vsegda ok
CASE a06-pereklyuchenie ok
CASE a07-tochechnost ok
CASE a08-grammatika ok
CASE a09-dubl ok
CASE a10-sloj-ispolnen-v-polnom ok
CASE a11-sloj-krasen ok
CASE a12-marker-vne-priemki ok
CASE a13-marker-v-priemke ok
CASE a14-sloj-vne-tablicy ok
CASE z01-gate-v-dereve ok
CASE z02-noga-pre-critic ok
CASE b01-ostanovka-podtverzhdena ok
CASE b02-zalipshij-390 ok
CASE b03-vtoroj-boot-port ok
CASE b04-maksimum-dva-avd ok
CASE b05-maska-48 ok
CASE b06-kanon-piny ok
CASE b07-mutant-393-pri-390 ok
CASE c01-literal-nav-height ok
CASE c02-literal-line-height ok
CASE c03-literal-press-long ok
CASE c04-ravnoe-chislo-bez-svjazi ok
CASE c05-slezhenie KRASNO: ожидался rc=0, факт rc=1 (причины факта: ЗОНД НЕ ИЗМЕРИЛ ЦЕЛЬ gespraech-mitte); нет причины TOKEN_SLEDUET (факт: ЗОНД НЕ ИЗМЕРИЛ ЦЕЛЬ gespraech-mitte)
CASE d01-karty-polny KRASNO: ожидался rc=0, факт rc=1 (причины факта: KARTA_NE_POLNA: цель shell-tab-start карты model/karta-mob-ref.json не найдена в экране mob-ref)
CASE d02-oracle-tamper ok
CASE d03-pustoj-produkt ok
CASE e01-soglasovano ok
CASE e02-chisla-vne-teksta ok
CASE f00-chestnyj-kontrol KRASNO: ожидался rc=0, факт rc=1 (причины факта: NADPIS_NEVIDIMA)
CASE f01-predposylka ok
CASE f02-sposoby-zony ok
CASE f03-sovmestnyj-chestnyj KRASNO: ожидался rc=0, факт rc=1 (причины факта: NADPIS_NEVIDIMA, SOSTOJANIE_NEDOSTIZHIMO, TSEL_OTSVTSTVUET)
CASE f04-sovmestnyj-vykljuchennaja-tsel KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_VYKLYUCHENA (факт: LIVE_PREDPOSYLKA: мутатор не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет маркера ZOND shell-tab-start 390 ok
CASE f05-sovmestnyj-polnyj-sloj ok
CASE f06-sovmestnyj-karta-iz-fajla ok
CASE f07-sovmestnyj-nezavisimost-nomera ok
CASE f08-sovmestnyj-dobavlenie-dannyh ok
CASE f10-zona-20 KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-20.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины ZONA_MENSHE_NORMY (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-20.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f11-zona-36-min36 KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-36-min36.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины ZONA_MENSHE_NORMY (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-36-min36.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f12-zona-rebenok-44 KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-rebenok-44.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины ZONA_MENSHE_NORMY (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-rebenok-44.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f13-zona-flex-20 KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-flex-20.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины ZONA_MENSHE_NORMY (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-flex-20.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f14-zona-hitSlop-otric KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-hitslop-otric.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины ZONA_MENSHE_NORMY (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-hitslop-otric.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f15-tsel-opacity0 KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-opacity0.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-opacity0.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f16-tsel-predok-opacity0 KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-predok-opacity0.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-predok-opacity0.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f17-tsel-display-none KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-display-none.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-display-none.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f18-tsel-fon-nadpis-transparent KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-fon-nadpis-transparent.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-fon-nadpis-transparent.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f19-tsel-nulevoj-boks KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-nulevoj-boks.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-nulevoj-boks.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f20-tsel-za-ekranom KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-za-ekranom.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-za-ekranom.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f21-tsel-za-klipom KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-za-klipom.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-za-klipom.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f22-tsel-perekryta KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-perekryta.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/tsel-perekryta.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f23-nadpis-skrytyj-text KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/nadpis-skrytyj-text.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины NADPIS_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/nadpis-skrytyj-text.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f24-nadpis-prozrachnye-bukvy KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/nadpis-prozrachnye-bukvy.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины NADPIS_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/nadpis-prozrachnye-bukvy.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f25-nadpis-vlozhennyj-prozrachnyj KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/nadpis-vlozhennyj-prozrachnyj.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины NADPIS_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/nadpis-vlozhennyj-prozrachnyj.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f26-nadpis-nulevaja-shirina KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/nadpis-nulevaja-shirina.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины NADPIS_NEVIDIMA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/nadpis-nulevaja-shirina.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f27-dejstvie-sdvig KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/dejstvie-sdvig.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины DEJSTVIE_CHUZHOE (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/dejstvie-sdvig.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f28-dejstvie-na-393 KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/dejstvie-na-393.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины DEJSTVIE_NA_PROFILE_NET (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/dejstvie-na-393.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f29-dejstvie-pointer-none KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/dejstvie-pointer-none.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_VYKLYUCHENA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/dejstvie-pointer-none.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f30-cel-disabled KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/cel-disabled.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_VYKLYUCHENA (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/cel-disabled.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f31-cel-otsutstvuet KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/cel-otsutstvuet.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины TSEL_OTSVTSTVUET (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/cel-otsutstvuet.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f32-sostojanie-nedostizhimo KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/sostojanie-nedostizhimo.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины SOSTOJANIE_NEDOSTIZHIMO (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/sostojanie-nedostizhimo.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE f33-sostojanie-slito KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/sostojanie-slito.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); нет причины SOSTOJANIE_SLITO (факт: LIVE_PREDPOSYLKA: мутатор model/mutanty/sostojanie-slito.py не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1))
CASE g01-147-model ok
CASE g02-147-stabs ok
CASE g03-148-model ok
CASE g04-148-stabs ok
CASE g05-149-model ok
CASE g06-149-stabs ok
CASE g07-143-stabs ok
CASE g08-159 ok
клеток 74, зелёных 45, красных 29
RC=1  (wall 484s)
```

### log-zones-precritic-trek.txt

```text
$ bash scripts/check_zones.sh /tmp/dev-harness-verify/Rev158r6/d5cfa96b/repo   (HEAD 1d5c2ee06afa39cfb576b6d2deef1f392fdf1861)   # | tail -n 15
  ok   контракт 028: коммит 8662a661 (architect) — СПАСЕНО, из суда зон выведен
  ok   контракт 028: коммит dad01175 (architect) — СПАСЕНО, из суда зон выведен
  ok   контракт 031: коммит 136ab1f0 (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 031: коммит 67f7437c (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 031: коммит b11943e1 (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 036: коммит b98896ac (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 043: коммит 8766e769 (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 043: коммит 9c372335 (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 043: коммит fc7c536a (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 045: коммит 9c372335 (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 045: коммит fc7c536a (implementer) — СПАСЕНО, из суда зон выведен

процессных вне суда:

замороженных контрактов: 156 · объявленных авторов: 5 · коммитов в диапазонах: 49675 · проверено по зонам: 12645
RC=0   (wall 547s)

$ bash scripts/pre_critic.sh --repo . contracts/158-ekrannyj-nabor.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
  ok   гейт трека: ТРЕК ЛЁГКИЙ (по умолчанию)
КРИТИК: дверь зелёная
RC=0
$ bash scripts/check_trek_ekrana.sh . contracts/158-ekrannyj-nabor.md
ТРЕК ЛЁГКИЙ (по умолчанию)
RC=0
$ bash scripts/check_trek_ekrana.sh .      # | tail -n 5
ТРЕК ЛЁГКИЙ (по умолчанию)
ТРЕК ЛЁГКИЙ (по умолчанию)
ТРЕК ЛЁГКИЙ (по умолчанию)
ТРЕК ЛЁГКИЙ (по умолчанию)
RC=0

$ gh pr view 621 --repo a3ka/dev-harness --json headRefOid,state,statusCheckRollup
1d5c2ee06afa39cfb576b6d2deef1f392fdf1861
OPEN
SKIPPED=1 SUCCESS=16

$ (своя мера счётов) python3 -c 'import probe; …' в каталоге батареи
KLETKI 75 kejsy 75 set-eq True
bez 40
model 37
repo 75
F+c05 35
stab_vhod 14 svjazi 27
stubs files 15
```

### log-mery-git.txt

```text
$ for c in $(git rev-list --reverse 5d30a306..HEAD); do git show $c | git patch-id --stable; done   # patch-id | sha | shortstat
c1d8979f0d1d5060 613734cc 62 files changed, 6278 insertions(+)
6fd71830f8b38b31 48cea8d5 2 files changed, 74 insertions(+)
553c1bc2a2ffd315 96c01ce3 5 files changed, 25 insertions(+), 10 deletions(-)
42897b1b438dd02b 844f253e 1 file changed, 37 insertions(+), 3 deletions(-)
4bde31e3e9aba56d e7dda92d 2 files changed, 35 insertions(+), 21 deletions(-)
d52fcc2b8777a813 721ec36d 1 file changed, 20 insertions(+), 27 deletions(-)
7fd439d38c356ee3 849eba30 1 file changed, 101 insertions(+), 5 deletions(-)
8521dd275274350c 020febee 1 file changed, 4 insertions(+), 2 deletions(-)
1a4508fe0fc32f0e 8f742eea 2 files changed, 33 insertions(+), 17 deletions(-)
95488dcd2db9464f c7962b56 1 file changed, 6 insertions(+), 2 deletions(-)
bde6240c0b86272b a273e5ad 5 files changed, 159 insertions(+), 44 deletions(-)
dde7951527dc8d4c 90da28f2 4 files changed, 133 insertions(+), 15 deletions(-)
d1fff439536aafa7 b5aa577a 9 files changed, 313 insertions(+), 171 deletions(-)
cfb85ce02a74a44a 775f869e 1 file changed, 3 insertions(+), 9 deletions(-)
f330fea837c76e79 cf18361c 1 file changed, 20 insertions(+), 5 deletions(-)
1d0515261f6bffc2 7f81f73c 1 file changed, 31 insertions(+), 10 deletions(-)
696156be3c5f05e3 1ff70582 1 file changed, 4 insertions(+), 5 deletions(-)
4d059d6496b0be15 40ed717c 1 file changed, 11 insertions(+), 6 deletions(-)
4614f8ffb32dca9c fdeefb02 1 file changed, 43 insertions(+)
ef2bcde7ffb0a655 b46aba07 1 file changed, 14 insertions(+), 13 deletions(-)
4e14c09a243ca46b 2f189b04 8 files changed, 459 insertions(+), 7 deletions(-)
da8267ba2946bc11 1d5c2ee0 1 file changed, 22 insertions(+), 1 deletion(-)
уникальных: 22 из 22; повторов: 0
$ git show 2ea0e47d | git patch-id --stable   # связка r5
a8566d300bc32166
$ git diff --quiet 2ea0e47d 849eba30 -- <зона>
rc=0
$ git diff --quiet f8134ed4 cf18361c -- <зона>   # r5 tip против рекреации до Б-6
rc=0
$ git diff --quiet frozen/contracts/158/2 HEAD -- contracts/158-ekrannyj-nabor.md
rc=0
$ git diff --quiet frozen/contracts/158/2 HEAD -- fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md
rc=0
$ git diff --quiet frozen/contracts/158/2 HEAD -- fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh
rc=0
$ git diff --quiet 5d30a306 HEAD -- fixtures/workshop_project/gespraech_vhod_147 contracts/
rc=0
$ git diff --quiet 5d30a306 HEAD -- fixtures/workshop_project/vkladki_tabov_148 contracts/
rc=0
$ git diff --quiet 5d30a306 HEAD -- fixtures/workshop_project/gespraech_tekst_149 contracts/
rc=0
$ git diff --quiet 5d30a306 HEAD -- fixtures/workshop_project/gespraech_otdacha_151 contracts/
rc=0
$ git diff --quiet 5d30a306 HEAD -- fixtures/workshop_project/mob_ci_143 contracts/
rc=0
$ git diff --quiet 5d30a306 HEAD -- fixtures/workshop_project/pustoj_produkt_159 contracts/
rc=0
$ git diff --name-only 5d30a306 HEAD | grep -v ^fixtures/workshop_project/ekrannyj_nabor_158/
scripts/check_trek_ekrana.sh
scripts/pre_critic.sh
$ git log --format=%an 5d30a306..HEAD | sort | uniq -c
     22 implementer
```

### log-mery-u3.txt

```text
$ git -C /tmp/dev-harness-verify/Impl148h/mob log --oneline -1; git -C /tmp/dev-harness-verify/Impl148h/mob status --porcelain
6b5ef76 148 vkladki-tabov: журнал эмулятора второго профиля — вне дерева продукта
$ sha256sum /tmp/dev-harness-verify/Arch148t/mob-ref/mobile/src/bootstrap/tab-shell.tsx /tmp/dev-harness-verify/Impl148h/mob/mobile/src/bootstrap/tab-shell.tsx
558f71f3499dab79eb9853b85fb34b92e033cba6f1ab2c0a6b9bad292f50e290  /tmp/dev-harness-verify/Arch148t/mob-ref/mobile/src/bootstrap/tab-shell.tsx
558f71f3499dab79eb9853b85fb34b92e033cba6f1ab2c0a6b9bad292f50e290  /tmp/dev-harness-verify/Impl148h/mob/mobile/src/bootstrap/tab-shell.tsx
$ diff -rq -x node_modules /tmp/dev-harness-verify/Impl148h/mob/mobile /tmp/dev-harness-verify/Arch148t/mob-ref/mobile
Only in /tmp/dev-harness-verify/Arch148t/mob-ref/mobile/src/bootstrap: kompakt-tokens.ts
rc=1
(пересборка ревьюером: tar продукта без node_modules + tokens.json носителя 147 + kompakt-tokens.ts носителя 148 из своего клона → diff -r со станцией: rc=0, выполнено выше в сессии)
$ grep -rn kompakt-tokens /tmp/dev-harness-verify/Arch148t/mob-ref/mobile/src /tmp/dev-harness-verify/Rev158r6/d5cfa96b/repo/fixtures/workshop_project/ekrannyj_nabor_158 --include=*.ts --include=*.tsx --include=*.py
rc=1
$ python3 /tmp/dev-harness-verify/scratch158/snyat-karta-mob-ref.py /tmp/dev-harness-verify/Arch148t/mob-ref | сравнить с model/karta-mob-ref.json
цель условная — вне обязательных: shell-back
цель shell-profile-entry: видимая надпись=None доступное имя='Profil und Einstellungen'
цель shell-tab-start: видимая надпись='Start' доступное имя=None
цель shell-tab-vorgaenge: видимая надпись='Vorgänge' доступное имя=None
цель shell-tab-schutz: видимая надпись='Schutz' доступное имя=None
цель shell-tab-post: видимая надпись='Post' доступное имя=None
состояние profil: цель-вход='shell-profile-entry'
snimok == karta dereva: True
$ grep -n 'Profil und Einstellungen\|Profil bearbeiten' /tmp/dev-harness-verify/Arch148t/mob-ref/mobile/src/i18n/ui-copy.ts
48:  'proposed.kompakt.header.profile.a11y': { text: 'Profil und Einstellungen', review_status: 'PROPOSED / PRODUCT_COPY_REVIEW_REQUIRED' },
93:  'action.F12.A01': { text: 'Profil bearbeiten', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
$ (karta b46aba07^ против HEAD — по целям)
прочие поля равны: True
DIFF shell-profile-entry 
 old {'testID': 'shell-profile-entry', 'objazatelna': True, 'sostojanija': ['start', 'profil'], 'nadpis': 'Profil bearbeiten', 'postuslovie': {'tip': 'perehod', 'znachenie': 'profile-surface'}} 
 new {'testID': 'shell-profile-entry', 'objazatelna': True, 'sostojanija': ['start', 'profil'], 'nadpis': None, 'postuslovie': {'tip': 'perehod', 'znachenie': 'profile-surface'}, 'accessibilityLabel': 'Profil und Einstellungen'}
прочие цели равны: True
$ for c in fdeefb02 b46aba07 2f189b04 1d5c2ee0: git worktree + python3 -c "probe.k_d01({})"
fdeefb02 {'rc': 1, 'pri': ['KARTA_NE_POLNA: цель shell-tab-start карты model/karta-mob-ref.json не найдена в экране mob-ref'], 'mark': []}
b46aba07 {'rc': 1, 'pri': ['KARTA_NE_POLNA: цель shell-tab-start карты model/karta-mob-ref.json не найдена в экране mob-ref'], 'mark': []}
2f189b04 {'rc': 1, 'pri': ['KARTA_NE_POLNA: цель shell-tab-start карты model/karta-mob-ref.json не найдена в экране mob-ref'], 'mark': []}
1d5c2ee0 {'rc': 0, 'pri': [], 'mark': []}
$ python3 /tmp/dev-harness-verify/Rev158r6/d5cfa96b/d01_mut.py /tmp/dev-harness-verify/Rev158r6/d5cfa96b/repo/fixtures/workshop_project/ekrannyj_nabor_158
D0 контроль (копия экрана без правки): {'rc': 0, 'pri': [], 'mark': []}
D2 лишняя литеральная цель в экране: {'rc': 1, 'pri': ['KARTA_NE_POLNA: обязательная цель rev-lishnyaya-cel экрана mob-ref не в карте model/karta-mob-ref.json'], 'mark': []}
$ python3 /tmp/dev-harness-verify/Rev158r6/d5cfa96b/mutanty_rev.py /tmp/dev-harness-verify/Rev158r6/d5cfa96b/repo/fixtures/workshop_project/ekrannyj_nabor_158   # M0..M6
=== M0 контроль: честный mob-ref, карта дерева
  ZOND shell-profile-entry 390 ok
  ZOND shell-tab-start 390 ok
  ZOND shell-tab-vorgaenge 390 ok
  ZOND shell-tab-schutz 390 ok
  ZOND shell-tab-post 390 ok
  ZOND shell-profile-entry 393 ok
  ZOND shell-tab-start 393 ok
  ZOND shell-tab-vorgaenge 393 ok
  ZOND shell-tab-schutz 393 ok
  ZOND shell-tab-post 393 ok
  ИТОГ: ok (KRASNO строк: 0)
=== M1 надписи вкладок прозрачны, карта дерева
  ZOND shell-profile-entry 390 ok
  ZOND shell-tab-start 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-vorgaenge 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-schutz 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-post 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-profile-entry 393 ok
  ZOND shell-tab-start 393 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-vorgaenge 393 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-schutz 393 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-post 393 KRASNO NADPIS_NEVIDIMA
  ИТОГ: KRASNO (KRASNO строк: 8)
=== M2 надписи вкладок прозрачны, карта: shell-tab-start nadpis=null
  ZOND shell-profile-entry 390 ok
  ZOND shell-tab-start 390 ok
  ZOND shell-tab-vorgaenge 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-schutz 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-post 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-profile-entry 393 ok
  ZOND shell-tab-start 393 ok
  ZOND shell-tab-vorgaenge 393 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-schutz 393 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-post 393 KRASNO NADPIS_NEVIDIMA
  ИТОГ: KRASNO (KRASNO строк: 6)
=== M3 у иконки снято имя, карта БЕЗ поля accessibilityLabel (nadpis=null)
  ZOND shell-profile-entry 390 ok
  ZOND shell-tab-start 390 ok
  ZOND shell-tab-vorgaenge 390 ok
  ZOND shell-tab-schutz 390 ok
  ZOND shell-tab-post 390 ok
  ZOND shell-profile-entry 393 ok
  ZOND shell-tab-start 393 ok
  ZOND shell-tab-vorgaenge 393 ok
  ZOND shell-tab-schutz 393 ok
  ZOND shell-tab-post 393 ok
  ИТОГ: ok (KRASNO строк: 0)
=== M4 имя иконки = пустая строка в продукте, карта accessibilityLabel=""
  ZOND shell-profile-entry 390 ok
  ZOND shell-tab-start 390 ok
  ZOND shell-tab-vorgaenge 390 ok
  ZOND shell-tab-schutz 390 ok
  ZOND shell-tab-post 390 ok
  ZOND shell-profile-entry 393 ok
  ZOND shell-tab-start 393 ok
  ZOND shell-tab-vorgaenge 393 ok
  ZOND shell-tab-schutz 393 ok
  ZOND shell-tab-post 393 ok
  ИТОГ: ok (KRASNO строк: 0)
=== M5 надписи вкладок прозрачны, карта: shell-tab-start + accessibilityLabel "Start"
  ZOND shell-profile-entry 390 ok
  ZOND shell-tab-start 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-vorgaenge 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-schutz 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-post 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-profile-entry 393 ok
  ZOND shell-tab-start 393 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-vorgaenge 393 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-schutz 393 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-post 393 KRASNO NADPIS_NEVIDIMA
  ИТОГ: KRASNO (KRASNO строк: 8)
=== M6 имя иконки перенесено с хозяина на дочерний Svg, карта дерева
  ZOND shell-profile-entry 390 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-start 390 ok
  ZOND shell-tab-vorgaenge 390 ok
  ZOND shell-tab-schutz 390 ok
  ZOND shell-tab-post 390 ok
  ZOND shell-profile-entry 393 KRASNO NADPIS_NEVIDIMA
  ZOND shell-tab-start 393 ok
  ZOND shell-tab-vorgaenge 393 ok
  ZOND shell-tab-schutz 393 ok
  ZOND shell-tab-post 393 ok
  ИТОГ: KRASNO (KRASNO строк: 2)
```
