accept

# Ревьюер — гейт контракта 015, круг 3

Проверено в живом `/home/aka/Documents/dev-harness` на HEAD
`8b9def6f51270743f18c54828b26c8fdcfe8700c`. Рабочее дерево до
вердикта было чистым. Вердикт **accept**: R015-1, R015-2, R015-3 и
R015-4 закрыты указанными ниже наблюдаемыми фактами; новых находок нет.

## Граница и норма

`frozen/contracts/015/2^{}` и HEAD — один коммит `8b9def6`; автор
заморозки v2 — `critic`. В проверенном интервале v1..HEAD код и фикстуры
лежат в объявленных зонах implementer/architect, а вердикты — в своих
каталогах; `check_zones.sh` это подтвердил. Проверка не была подогнана
автором реализации: история `scripts/check_nabludenia.sh` и
`scripts/nabludenia_digest.sh` содержит только implementer-коммиты
`4131f13`, `ab99213`, `024f51e`; красные предъявления независимым
повторным прогоном даёт `verify_antiplacebo.sh` (см. ниже).

Единственная нормативная правка после v1 — `fcf7a1b`, и это именно
разрешённое действие архитектора в зоне контракта:

```text
$ git show --no-patch --format='%H%n%an <%ae>%n%B' fcf7a1b
fcf7a1b665fbffeb380284077622c9daeca7857a
architect <architect@dev-harness.local>
015: изъят case_lishnee_naznachenie (умер с TABLE-сверкой); счёт-строки 12→11/32→31

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/015-jadro-avtonomnosti-nabljudenij.md счёт-строки 12→11/32→31 — смерть case_lishnee_naznachenie предсказана контрактом (§Красное сейчас), синхронизация числа с фактом дерева, не изменение смысла
```

Сырой вывод гейтов (каждая команда запускалась с md5 до и после):

```text
$ bash scripts/check_contract_frozen.sh
  ok   contracts/015-jadro-avtonomnosti-nabljudenij.md — заморожен v2, блоб совпадает побайтово, вердикты v1..v2 разрешают
планов и контрактов на HEAD: 18 · черновиков: 3 · заморожено: 15 · реестр: full
check_contract_frozen_rc=0

$ bash scripts/check_charter.sh
  ok   уставной документ изменён с разрешения владельца: contracts/015-jadro-avtonomnosti-nabljudenij.md в fcf7a1b6
  ok   contracts/015-jadro-avtonomnosti-nabljudenij.md — уставной с frozen/contracts/015/1, коммитов в диапазоне 24, изменений без разрешения нет
уставных документов: 17 · изменений в них: 45 · с разрешения: 45
check_charter_rc=0

$ bash scripts/check_zones.sh
  ok   contracts/015-jadro-avtonomnosti-nabljudenij.md — зона: architect → contracts/015-jadro-avtonomnosti-nabljudenij.md	015
  ok   contracts/015-jadro-avtonomnosti-nabljudenij.md — зона: reviewer → verdicts/review/	015
замороженных контрактов: 14 · объявленных авторов: 6 · коммитов в диапазонах: 332 · проверено по зонам: 242
check_zones_rc=0
```

## Закрытые R015-1..4

### R015-1 — потолок дайджеста и поздние секции

В новом временном git-корне созданы 50 валидных открытых Н-записей,
один draft и `HANDOFF.md` с `## ГДЕ МЫ`. Реальный дайджест:

```text
$ TMPDIR="$D" bash scripts/nabludenia_digest.sh --for-session --root "$T"
открытые с адресами:
Н-1 → контракт 015
…
Н-23 → контракт 015
…и ещё 27

черновики:
черновиков: 1
  draft.md

HANDOFF:
HANDOFF.md §ГДЕ МЫ, строка 1
rc=0
line_count=40
sections=черновики:,HANDOFF:
```

Таким образом переполнение режется внутри секции открытых записей, а не
срезает обязательные поздние секции.

### R015-2 — валидная пост-миграционная Н-14

В отдельном временном корне единственная запись была
`### Н-14. Боль \`ОТКРЫТО — адрес: контракт 015\``; второй файл
наблюдений существовал пустым. Сырой результат:

```text
$ bash scripts/check_nabludenia.sh "$T"
rc=0
```

Это подтверждает границу: барьер судит форму, а TABLE-сверка остаётся
миграционной пробе.

### R015-3 — фикстуры не ослабляют freeze

Предыдущая находка снята нормой правила 3 и историей: изоляционная правка
фикстур не меняла frozen-блоб; пост-freeze красные предъявления разрешены
как усиление гейта. Текущие scoped-прогоны предъявляют каждый красный
вызов повторно, поэтому это не самосертификация фикстуры:

```text
$ bash scripts/verify_antiplacebo.sh --scope check_nabludenia
барьеров: 1 · фикстур: 11 · предъявлено красным повторным прогоном: 11
rc=0
$ bash scripts/verify_antiplacebo.sh --scope drill_gate_draft
барьеров: 1 · фикстур: 7 · предъявлено красным повторным прогоном: 7
rc=0
$ bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
барьеров: 1 · фикстур: 12 · предъявлено красным повторным прогоном: 12
rc=0
$ bash scripts/verify_antiplacebo.sh --scope drill_nabludenia_nechitaemo
барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
rc=0
```

### R015-4 — v2 freeze и счёт

v2 теперь заморожен на HEAD, а `fcf7a1b` несёт разрешение владельца в
том же architect-коммите. Независимая мера текущего дерева согласна с
счёт-строками и подтверждает изъятие case:

```text
$ test ! -e fixtures/check_nabludenia/case_lishnee_naznachenie.sh
case_lishnee_naznachenie_absent_rc=0
$ printf '%s\n' fixtures/*/case_*.sh | wc -l   # по каталогам
check_nabludenia=11
drill_gate_draft=7
drill_startup_digest=12
drill_nabludenia_nechitaemo=1
```

Итого `11 + 7 + 12 + 1 = 31`, в точности как frozen v2.

## Пять зелёных проб

```text
$ bash fixtures/check_nabludenia/probe_nabludenia_krasnoe.sh
ok: барьер зелёный на живом дереве — миграционная пачка в коммите введения
rc=0

$ bash fixtures/drill_gate_draft/probe_gate_draft_krasnyj.sh
ok: дрилл gate-draft зелёный на живом дереве
rc=0

$ bash fixtures/drill_startup_digest/probe_digest_krasnyj.sh
ok: дрилл startup-digest зелёный на живом дереве
rc=0

$ bash scripts/drill_nabludenia_nechitaemo.sh
  ok   зелёный контроль: барьер rc=0 на чистом дереве
  ok   нечитаемое: rc=2 + строка «нечем проверить: NABLIUDENIA.md»
  дрилл nabludenia-nechitaemo: ветвь rc=2 поймана
rc=0

$ bash fixtures/check_nabludenia/probe_migracija_adresov.sh
ok: все ОТКРЫТО-маркеры несут адрес структурной грамматикой; назначение каждой строки §Материал сохранено
rc=0
```

## Md5-сторож

До и после **каждого** из перечисленных гейтов, контрпримеров, scoped- и
пробных прогонов совпали следующие сырые значения:

```text
35ccdd6086b421be5d2a1350e322d608  NABLIUDENIA.md
efeb764152e612608659a2de15b45ec3  NABLIUDENIA_ARCHITECT.md
dfe8272c90232a89af79ed4e85454ff2  HANDOFF.md
```

Следовательно, проверочные запуски не изменили наблюдаемое живое дерево.
