FAIL

Диапазон: `30acda0..HEAD`. Вердикт вынесен по чистому клону
`tmp/reviewer/repo` до записи этого файла.

## Находки

### 1. Вне зоны: механизм зон и его фикстура

**Класс:** область правки.

`b114c53f04a86df3e633f11c07f09469e49bd9e7` автора `architect` меняет
`scripts/check_zones.sh` и создаёт
`fixtures/check_zones/case_zony_drugogo_kontrakta.sh`. В v4 контракта 002 эти
пути не принадлежат ни `architect`, ни `implementer`; исключение для них не
объявлено. Это не судейский вердикт и не решение арбитража. Механизм зон нельзя
протащить через пачку, границы которой он сам должен проверять.

Сырой вывод:
```text
$ git log --format='COMMIT %H%nAUTHOR %an%nSUBJECT %s' --stat --summary \
    30acda0..HEAD -- fixtures/check_zones/case_zony_drugogo_kontrakta.sh scripts/check_zones.sh
COMMIT b114c53f04a86df3e633f11c07f09469e49bd9e7
AUTHOR architect
SUBJECT Закрыты четыре блокирующих находки критика по контракту 002
 .../check_zones/case_zony_drugogo_kontrakta.sh | 28 ++++++++++++++++++++++
 scripts/check_zones.sh                          | 22 ++++++++++-------
```

### 2. Вне зоны: посторонние overlay/anti-placebo изменения

**Класс:** область правки.

`2a7a150f8a57196c94459b7bcc5480bc0711dc74` автора `architect` меняет
`scripts/overlay.sh` и `fixtures/overlay/case_pin_razoshelsja.sh`; `55cb5a986799d39bb1c8254ba09448c37fdf33b5`
того же автора меняет `scripts/verify_antiplacebo.sh` и создаёт
`fixtures/verify_antiplacebo/case_git_config_zatert.sh`. Ни один из этих путей
не назван зоной v4 или допустимым исключением. Это два самостоятельных предмета,
добавленные в диапазон пакета без объявленной границы.

Сырой вывод:
```text
COMMIT 2a7a150f8a57196c94459b7bcc5480bc0711dc74
AUTHOR architect
SUBJECT KEYED выведен из назначений конфига; исключения учёта — файлом с причиной
 config/metering_exceptions.txt           | 16 +
 fixtures/overlay/case_pin_razoshelsja.sh |  1 +
 scripts/overlay.sh                       | 33 +

COMMIT 55cb5a986799d39bb1c8254ba09448c37fdf33b5
AUTHOR architect
SUBJECT Н-10 закрыт механизмом: локальный git config — в слепок анти-плацебо
 .../verify_antiplacebo/case_git_config_zatert.sh | 44 +
 scripts/verify_antiplacebo.sh                     | 17 +
```

### 3. Чужая авторская зона и не объявленный `HANDOFF.md`

**Класс:** область правки.

`2a7a150f` автора `architect` создаёт `config/metering_exceptions.txt`; `config/`
принадлежит только `implementer`. Отдельно `f4a03a574ca272e5d9c3f15a0b23d772d0a41681`
автора `architect` меняет `HANDOFF.md`, которого v4 не объявляет и который не
является разрешённым `verdicts/**` либо решением арбитража. Последнее независимо
поймано штатным барьером зон.

Сырой вывод:
```text
$ npm run check:zones
  FAIL коммит вне зоны: architect f4a03a57 HANDOFF.md — зона контракта 002: .omp/agents/ AGENTS.md NABLIUDENIA.md contracts/002-approval-mode-steward.md plans/006-approval-mode-and-steward.md roles/arbiter.md scripts/roles.ts
EXIT check:zones=1
```

Полный вычет всех объявленных путей и `verdicts/**` из diff дал ровно следующие
неразрешённые пути; это также подтверждает места находок 1–3:
```text
HANDOFF.md
fixtures/check_zones/case_zony_drugogo_kontrakta.sh
fixtures/overlay/case_pin_razoshelsja.sh
fixtures/verify_antiplacebo/case_git_config_zatert.sh
scripts/check_zones.sh
scripts/overlay.sh
scripts/verify_antiplacebo.sh
```

### 4. `check:decisions` не проходит объявленный чистый запуск `env -i`

**Класс:** невыполненная приёмка / барьер зависит от неоговорённой локали.

Контракт 002 требует `scripts/check_decisions.sh → 0`; шапка барьера обещает
`0` при корректном реестре. С чистым окружением без локали все семь штатных
записей теряют пять обязательных кириллических полей, а значение `основание`
склеивается с продолжением поля. Причина находится в `parse_record`:
`awk` сопоставляет имена через диапазон `[а-яА-ЯёЁ ]`; при C-локали этот разбор
не принимает штатные поля. Барьер не устанавливает требуемую UTF-8 локаль,
хотя `check_approval.sh` устанавливает `LC_ALL="${LC_ALL:-C.UTF-8}"` для
своего изолированного запуска.

Сырой воспроизводимый вывод:
```text
$ env -i PATH=/usr/bin:/bin HOME="$HOME" npm run check:decisions
  FAIL decisions/001-sessiyu-vedet-rol-s-eksplicitnym-model.md: нет поля «дата»
  FAIL decisions/001-sessiyu-vedet-rol-s-eksplicitnym-model.md: нет поля «вопрос»
  FAIL decisions/001-sessiyu-vedet-rol-s-eksplicitnym-model.md: нет поля «решение»
  FAIL decisions/001-sessiyu-vedet-rol-s-eksplicitnym-model.md: нет поля «область»
  FAIL decisions/001-sessiyu-vedet-rol-s-eksplicitnym-model.md: нет поля «условие пересмотра»
  FAIL decisions/001-sessiyu-vedet-rol-s-eksplicitnym-model.md: основание «ca29f7eироли,объявленнойв`.omp/agents/<роль>.md`—полемоделиобязаносуществоватьиуказыватьнастрокуиз`.omp/config.yml`» не похоже на хеш коммита
  ... те же шесть отказов для 002–007 ...

записей: 7 · нарушений: 42
EXIT check:decisions=1

$ env -i PATH=/usr/bin:/bin HOME="$HOME" LANG=C.UTF-8 npm run check:decisions
записей: 7 · нарушений: 0
  ok   реестр решений полон, поля в грамматике, основания разрешимы
EXIT UTF8=0
```

## Прогоны в чистом клоне

Все команды запускались как `env -i PATH="$PATH" HOME="$HOME" npm run <имя>`.
Коды возврата и завершающий сырой вывод:

```text
check:gen                 → 0  харнес соответствует roles/ (7 ролей)
check:ids                 → 0    ok   номера уникальны и согласованы с регистром выдачи
check:decisions           → 1  записей: 7 · нарушений: 42
check:approval            → 0  политика: always-ask · нарушений: 0
                                  ok   always-ask объявлен в конфиге, запуск его наследует, флаги отмены политики отвергнуты
check:contract-frozen     → 0  планов и контрактов на HEAD: 5 · черновиков: 2 · заморожено: 3 · реестр: full
check:zones               → 1  коммит вне зоны: architect f4a03a57 HANDOFF.md
check:charter             → 0  уставных документов: 5 · изменений в них: 5 · с разрешения: 5
check:ci-parity           → 0  workflow-команд: 14 · скриптов в приёмке: 21 · объявленных исключений: 7 · расхождений: 0
check:antiplacebo         → 0  барьеров: 18 · фикстур: 114 · предъявлено красным повторным прогоном: 114
```

`check:approval` и `check:decisions` объявляют коды `0/1/2` в шапках.
`check:approval` назвал зелёный предмет; `check:antiplacebo` предъявил красными
все три `check_approval/case_*.sh` с кодом 1 и названными причинами. История
подтверждает, что `054e72b`, `da4f710` и `ee2dae1` меняли реализацию и её новые
фикстуры до независимого замера закрытия `1c6fcdd`; после него код проверки не
менялся. Это не снимает находку 4: сам штатный барьер не герметичен в требуемом
чистом окружении.

Счётные заявления сверены другой мерой, не выводами барьеров:
```text
$ find decisions -type f -name '*.md' | wc -l                 → 7
$ git tag -l 'id/ADR/*' | wc -l                               → 7
$ find roles -maxdepth 1 -type f -name '*.md' | wc -l         → 7
$ find fixtures/check_approval -maxdepth 1 -name 'case_*.sh' | wc -l → 3
```

`check:charter` принял четыре правки контракта с разрешением владельца. Их тела
ограничивают слово владельца «v2» доведением процедурных зон до замкнутости:
таблица ролей, сам контракт с `NABLIUDENIA.md`, сгенерированные агенты и путь
обещанной фикстуре. Это соответствует прямо заданному толкованию слова владельца;
находки о неразрешённых уставных правках нет.

Пачка не принимается из-за четырёх названных находок: трёх нарушений области и
одной невыполненной проверки в требуемом чистом окружении.
