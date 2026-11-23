accept
OBJECT=a7e67e8388fc575b7169489fe9f553927f82f414
СУД: repo=dev-harness; предмет=207; роль=critic; вызов=4/4 (форма карты классов; слово владельца 22.11 ~19:38); фаза=v1; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra (runtime, независимая сверка трейса оркестратором необходима); сессия=Crit207V4; SHA=a7e67e8388fc575b7169489fe9f553927f82f414; предыдущий=вызов 3 accept Crit207V3 ba884edf2e (ветка wip/207/critic-v3), суждение не меняется; арбитраж=verdicts/arbitration/predmet-207-schetchik-git.md f803aa2056; исключение=слово владельца на вызов 4; класс риска=обычный.

## Граница суда и решение

Вызов 4 разрешён владельцем только на форму карты классов, суждение вызова 3 не меняется. Карта самодостаточна, без ссылок на прежние карты. Запись HANDOFF и фактическую модель по платформенному трейсу независимо сверяет оркестратор; этот файл не подменяет такую сверку. Критик не автор кандидата.

По вердикту вызова 3 решение Arb207 исполнено в принятой границе; доказанного нарушения нет. Владелец 22.11 ~18:13 принял остаток: «207: принимаю конечную область механического доказательства по решению Arb207 (счёт Git по доверенному dispatch) и остаток — произвольный код вне Git-dispatch и подмена инструментов; timeout 300 сохраняется.» Обязательство одного суда не ослаблено; ловцы остатка названы в contracts/207-check-zones-incr-odin-sud-okna.md:47.

По вызову 3 инвентарь Git снимается до субъекта и сверяется по inode либо SHA256, не basename; probe.py:200-273 разбирает трассу и dispatch. Прежние мутации адресованы в stabs.tsv и PATERNS probe.py: K0-SUDIT-OKNO → k0, REPLAY-TAC → e14, STDOUT-DUBL → e1, GIT-INYM-PUTEM и GIT-LOG-DUBL → c1; также адресованы атаки SORT/DEDUP, FIRST-CONTRACT-AUTHORS, IGNORE-OTHER-ZONES, COMMAND-V/ENV и TRACE2-OFF. Н-39: стабы к ветвям привязывает architect по коду, не проза контракта; контракт несёт инварианты и rc-команды.

## Мутации вызова 3

Вызов 3 изменял probe.py только в памяти одноразовой области, не кандидат и не модель. Команда `python3 -B "$PWD/.scratch-crit207v3/attacks.py"` rc 0; сырой вывод:

```text
identity-basename ('h5-git-log', False, 'ak=0 ≠ 1 (судов окна)', 1.4092650413513184)
adjacent-options ('h6-flag-order', False, 'ak=0 ≠ 1 (судов окна)', 1.3315870761871338)
double-count-alias ('h9-alias', False, 'ak=2 ≠ 1 (судов окна)', 1.2269577980041504)
```

Независимые замены: `return ((stat.st_dev, stat.st_ino) in self.identities or digest in self.digests)` на `return path.name == 'git'`; `if cmd == 'log' and {'--no-walk', '--stdin'} <= flags:` на `if cmd == 'log' and len(args) > 0 and args[0] == '--no-walk' and '--stdin' in flags:`; перед `aliases.append((pid, stamp, cmd))` добавить `counts['ak'] += 1`. Для отдельных копий probe загружался через compile/exec, создавались Battery и Runner, вызывался `git_form_cell` с соответствующим именем и `GIT_FORMS[имя]`. Это отказ честной формы при сломанном измерителе, не мутация production. Драйвер удалён вместе со scratch вызова 3.

СОВЕТ contracts/207-check-zones-incr-odin-sud-okna.md:33 — рассмотреть сохранение этих трёх мутаций измерителя как адресных регрессионных стабов при наличии подходящей архитектуры батареи; h5/h6/h9 уже различают указанные повреждения. См. .review/2026-11-22-144.md.

## Команды и результаты

W = `bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh`. Выполнены в вызове 4 последовательно с TMPDIR внутри копии:

- `W --model` rc 0: `KLETKI=48 ZELENYE=48 KRASNYE=0`.
- `W --stabs` rc 0: `MUTACII=32 SVJAZI=32 POIMANY=32 ZHIVYH=0`.
- `W --repo .` rc 1: `KLETKI=48 ZELENYE=42 KRASNYE=6`, красные ровно c1–c6; это ожидаемое красное до реализации.
- `W --catalog` rc 0: `EQ=16 C=6 H=21 N=4 K0=1 KLETKI=48 STABS=32 PATERNS=30 ANCHORS=1`.
- `bash scripts/pre_critic.sh contracts/207-check-zones-incr-odin-sud-okna.md` rc 0.
- `bash scripts/check_sdacha.sh "$PWD" contracts/207-check-zones-incr-odin-sud-okna.md --run` rc 0.
- `check_spec_ready`, `check_ids`, `check_ceilings`, `check_provodka --grammar`, `check_precision_gate`, `check_threat_model` по командам пункта 6 приёмки — каждый rc 0.

Историческое свидетельство вызова 3, не повторённое в вызове 4: `npm run check:antiplacebo -- --scope check_zones` rc 0, 42/42 предъявлено красным.

## Карта классов

К-01: чисто — pre_critic, check_sdacha --run и двери формы rc 0.
К-02: чисто — вход: решение Arb207 §1–4 и принятое слово владельца в contracts/207-check-zones-incr-odin-sud-okna.md:52.
К-03: чисто — вызов 3, npm run check:antiplacebo -- --scope check_zones rc 0, 42/42.
К-04: чисто — check_precision_gate rc 0, зоны contracts/207-check-zones-incr-odin-sud-okna.md раздел «Зоны и проводка».
К-05: чисто — вход: команды и rc contracts/207-check-zones-incr-odin-sud-okna.md раздел «Приёмка».
К-06: чисто — n1–n4 rc 2 NOT_IMPLEMENTED, --model rc 0.
К-07: чисто — --model k0 и c2 зелёные, 0/0/0/0 и 1/1/0/0 соответственно.
К-08: чисто — --stabs rc 0, git-log и alias дубли пойманы ak=2; мутации вызова 3 h5/h6/h9 красны.
К-09: чисто — --model rc 0; --stabs ловит K0 и REPLAY-TAC.
К-10: чисто — --stabs ловит STDOUT-DUBL по байтам.
К-11: чисто — вход: probe.py eq_cell, канон снимается до субъекта; --repo e1 зелёная.
К-12: чисто — вход: strace и инвентарь inode/SHA256, probe.py:44-273.
К-13: н/п — секреты не предмет.
К-14: чисто — --model h1–h21 зелёны, в том числе alias без двойного счёта.
К-15: чисто — --model 48/48/0, --stabs 32/32/32/0, --repo 48/42/6, --catalog rc 0.
К-16: чисто — вход: класс обычный и принятое владельцем ограничение из контракта.
К-17: н/п — архитектурная модель 188 не меняется, предмет — перенос incr-ветви check_zones.sh.
