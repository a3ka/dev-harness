accept
OBJECT=acb6ec4c5dd9ecbddd96af29b994e54124664506
СУД: репо=dev-harness; предмет=209; роль=critic; вызов=1/2; фаза=v1; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=нет; класс риска=рисковый

Фактическая модель и отсутствие fallback: JSONL сессии Crit209, model_change, session 01a20606-eb1f-72a0-8661-f6052e992bb8. Автор OBJECT — architect. Класс риска подтверждён: засев меняет свидетельство для выдачи паков ролей, включая судей, при сохранении независимой проверки фактической сессии по 104. Сверку записи HANDOFF по трассе завершает оркестратор после суда.

## Карта классов

К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0
К-02: чисто — вход слово владельца 22.11 и сценарий Complior-agent 137 из задания
К-03: чисто — вход договоры 095 104 166 996 и связанные CLI
К-04: чисто — check_precision_gate . contracts/209-zasev-trassy-proekta.md rc 0
К-05: чисто — вход раздел Приёмка и rc-команды W
К-06: чисто — вход ProbeFault и проверка синтаксиса мутантов в probe.py
К-07: чисто — W --model rc 0 на реальной цепочке с транспортным omp
К-08: чисто — W --stabs rc 0 и шесть адресных мутаций ниже
К-09: чисто — W --model клетки source и sud-boundaries rc 0
К-10: чисто — вход World.launch task sud и побайтовые сравнения probe.py
К-11: чисто — вход frozen 204/1 и ожидаемые строки в памяти World
К-12: чисто — вход jq и настоящие models_actual make_task check_sud_model judge_gate
К-13: н/п — секреты не являются предметом засева и мир содержит stub-ключи
К-14: чисто — W --model rc 0 при station и отсутствии ключа и честном связанном суде
К-15: чисто — W --repo 24/4/20 и W --model 24/24/0 и W --stabs 14/14/14/0
К-16: чисто — вход модель угроз контракта и факт --bind только из JSONL
К-17: н/п — архитектурная модель 188 не затрагивается предметом station launcher

## Блоки

Блокирующих находок нет. Засев остаётся трёхполевым и помечен отдельно. Реальный --bind читает JSONL, а проверка 104 и judge_gate отказывают трёхполевому свидетельству. Модель не создаёт JSONL и привязку; честный привязанный суд остаётся зелёным.

## Проверки

- `bash scripts/check_sdacha.sh "$PWD" contracts/209-zasev-trassy-proekta.md --run`: rc 0, «СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=0)».
- W = `bash fixtures/workshop_project/zasev_trassy_209/red_zasev_trassy_209.sh`: `W --repo .` rc 1, KLETKI=24 ZELENYE=4 KRASNYE=20, ожидаемое красное-до; `W --model` rc 0, KLETKI=24 ZELENYE=24 KRASNYE=0; `W --stabs` rc 0, MUTACII=14 SVJAZI=14 POIMANY=14 ZHIVYH=0. Отдельного режима --sintaksis нет.
- `pre_critic`, `check_spec_ready`, `check_ids`, `check_ceilings`, `check_provodka --grammar`, `check_precision_gate`, `check_threat_model`, `check_predposylki`, `gen_ci_steps --check` с аргументами из контракта: каждый rc 0. Precision-gate: сырой вывод `OK`.
- `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck bash scripts/validate_std.sh bash <файл>`: для раннера rc 0 и для model/prepare_model_trace_209.txt rc 0; проверялся штатный пин.

## Собственные адресные мутации

Команда: `TMPDIR="$PWD/.scratch-crit209" python3 "$PWD/.scratch-crit209/attacks.py"` (одноразовый драйвер, по одному миру). Замены якорей в исполняемой модели: инверсия условия непустого архива; инверсия grep реестра; инверсия проверки authority; замена `fact[$1]` на `fact["critic"]`; замена `FILENAME == ARGV[1]` на `NR == FNR`; замена чтения станционного JSONL на архив TSV. Каждой соответствует указанная клетка. Сырой итоговый вывод клеток и драйвера (длинные диагностические строки `209 OUTPUT wanted=... observed=...` двух отказов здесь опущены):

```
ATTACK ARCHIVE-REMOVED @ existing-archive
209 existing-archive KRASNO
RESULT ARCHIVE-REMOVED CAUGHT
ATTACK ROLE-FILTER-INVERTED @ rejestr
209 rejestr KRASNO
RESULT ROLE-FILTER-INVERTED CAUGHT
ATTACK SOURCE-CHECK-INVERTED @ source-case
209 source-case KRASNO
RESULT SOURCE-CHECK-INVERTED CAUGHT
ATTACK DISPLACE-WRONG-ROLE @ vytesnenie
209 vytesnenie KRASNO
RESULT DISPLACE-WRONG-ROLE CAUGHT
ATTACK REPEAT-FIRST-INPUT @ idempotentnost
209 idempotentnost KRASNO
RESULT REPEAT-FIRST-INPUT CAUGHT
ATTACK SOURCE-ARCHIVE @ istochnik
209 istochnik KRASNO
RESULT SOURCE-ARCHIVE CAUGHT
ATTACKS 6 ALIVE 0
RC=0
```

Смежные механизмы дополнительно предъявлены штатными адресными стабами BIND-AS-FACT, JUDGE-ACCEPTS-SEED и JUDGE-GATE-BYPASS: все пойманы на своих клетках. Классы NUL/CRLF/регистр и типы источника предъявлены честной батареей. Отдельная атака гонки не предъявлялась: для одного корня штатный PID-лок захватывается до prepare_model_trace, сторонние параллельные writers названы остатком; иных достижимых условий гонки без выхода за границу не доказано.

## НЕ ЗАЩИЩАЕТ

Сохраняются прямо объявленные контрактом остатки: компрометация доверенной станции и JSONL, отсутствие станционной роли, посторонние конкурентные записи метки/архива и содержательная правдивость модели или вердикта. Ловцы и границы — в contracts/209-zasev-trassy-proekta.md §Модель угроз; конкурентная блокировка новых writers этим предметом не вводится.
