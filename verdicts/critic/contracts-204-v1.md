accept
OBJECT=bc07d9e5af9976cd3fff7c9297fb3d5e10680cb0
СУД: repo=dev-harness; предмет=204; роль=critic; вызов=3 (узкий; санкция консультанта сессии по ADR 2026-11-17 на ВЫЗОВ-3-204); фаза=v1; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit204V3; модель-факт=openai-codex/gpt-6.1-terra; SHA=bc07d9e5af9976cd3fff7c9297fb3d5e10680cb0; предыдущий=verdicts/critic/contracts-204-v2.md FAIL eeae2f93c9; исключение=санкция консультанта сессии; класс риска=обычный.

Область: только закрытие К-01 вызова 2 и зависимый регресс; новый полный поиск не проводился. Санкция в задании: «ВЫЗОВ-3-204: один узкий critic на OBJECT bc07d9e5 (tip Arch204f; полный sha — из `git rev-parse`), закрытие К-01 вызова 2 + регресс». Автор OBJECT — architect, отдельная сессия Arch204f. `bash scripts/models_actual.sh --tsv --bind --session Crit204V3` rc 0: `critic openai-codex/gpt-6.1-terra allowed Crit204V3 bc07d9e5af9976cd3fff7c9297fb3d5e10680cb0` (выведено дважды). Дописку и сверку HANDOFF перед материализацией выполняет оркестратор.

## Закрытие К-01

Класс закрыт. `fixtures/workshop_project/karta_vyzova_204/stabs.tsv:10-12` и `fixtures/workshop_project/karta_vyzova_204/probe.py:51-54,277-325`: две мутации вызова 1 предъявляются как адресные стабы по данным и коду, не по прозе (Н-39). На прежнем `3d534e46b3e0ae9ff2318ad5aabdea18e268e0ac` в одноразовом клоне `bash fixtures/workshop_project/karta_vyzova_204/red_karta_vyzova_204.sh --stabs` rc 0: `MUTACII=8 SVJAZI=10 POIMANY=10 ZHIVYH=0`, regex-стаба нет. На OBJECT та же команда rc 0: `MUTACII=9 SVJAZI=11 POIMANY=11 ZHIVYH=0`. Для каждого предъявления код прежде проверяет честную клетку, требует единственный якорь, затем сравнивает полный наблюдаемый результат с `mutant_expected`.

Сырые строки OBJECT:
```text
204 v10-otdelno-ot-v1 ok rc=1 ОТКАЗ: verdicts/critic/contracts-777-v10-call-02.md: отсутствует вызов 1 (К-02)
204 PATERN:PERVAJA-CIFRA -> v10-otdelno-ot-v1 POIMAN rc=0 КАРТА: 17/17 зелёный
204 f4-vedushchie-nuli ok rc=1 ОТКАЗ: последний FAIL: неоднозначный вызов 1
204 PATERN:REGEX-ODNA-CIFRA -> f4-vedushchie-nuli POIMAN rc=0 СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)
```

Дополнительно `PYTHONDONTWRITEBYTECODE=1 python3 "$PWD/.scratch-crit204v3/reproduce.py"` rc 0: одноразовый скрипт импортировал probe.py OBJECT, снимал реальные blob-ы 197, вызывал `mutate`, `observe`, `mutant_expected` и `judge` для каждой клетки с настоящими дверями; scratch удалён. Сырой итог:
```text
ANCHOR PATERN:REGEX-ODNA-CIFRA 1
HONEST PATERN:REGEX-ODNA-CIFRA (1, 'ОТКАЗ: последний FAIL: неоднозначный вызов 1')
EXPECTED PATERN:REGEX-ODNA-CIFRA (0, 'СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)')
MUTANT PATERN:REGEX-ODNA-CIFRA (0, 'СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)')
MUTANT_SUMMARY PATERN:REGEX-ODNA-CIFRA rc 1 KLETKI 22 ZELENYE 19 KRASNYE 3
ANCHOR PATERN:PERVAJA-CIFRA 1
HONEST PATERN:PERVAJA-CIFRA (1, 'ОТКАЗ: verdicts/critic/contracts-777-v10-call-02.md: отсутствует вызов 1 (К-02)')
EXPECTED PATERN:PERVAJA-CIFRA (0, 'КАРТА: 17/17 зелёный')
MUTANT PATERN:PERVAJA-CIFRA (0, 'КАРТА: 17/17 зелёный')
MUTANT_SUMMARY PATERN:PERVAJA-CIFRA rc 1 KLETKI 22 ZELENYE 20 KRASNYE 2
```
Regex-мутант красит f4, v10 и v11; `${faza:0:1}` — v10 и v11, собственная ссылка v10 зелена. Это повтор прежних операций, а не новая широкая атака. Результат адресной клетки совпадает с `mutant_expected`; честная модель в целом 22/22.

## Регресс

W = `bash fixtures/workshop_project/karta_vyzova_204/red_karta_vyzova_204.sh`; S = `bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh`. Все прогоны с TMPDIR внутри копии, на OBJECT до добавления вердикта.

- W `--model` rc 0: `KLETKI=22 ZELENYE=22 KRASNYE=0`.
- W `--stabs` rc 0: `MUTACII=9 SVJAZI=11 POIMANY=11 ZHIVYH=0`.
- W `--repo .` rc 1: `KLETKI=22 ZELENYE=13 KRASNYE=9`, ожидаемое состояние до реализации.
- W `--regress193 --model` rc 0: `KLETKI=152 ZELENYE=152 KRASNYE=0`; S `--model` rc 0: те же 152/152; S `--stabs` rc 0: `OBMANOK=59 POIMANY=59 ZHIVYH=0`.
- `bash scripts/check_sdacha.sh . contracts/204-karta-vyzova-po-faze.md --run` rc 0: `СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=0)`.
- `bash scripts/pre_critic.sh contracts/204-karta-vyzova-po-faze.md` rc 0; `bash scripts/check_spec_ready.sh . contracts/204-karta-vyzova-po-faze.md` rc 0; `bash scripts/check_ids.sh .` rc 0; `bash scripts/check_ceilings.sh .` rc 0; `bash scripts/check_provodka.sh --grammar . contracts/204-karta-vyzova-po-faze.md` rc 0; `bash scripts/check_precision_gate.sh . contracts/204-karta-vyzova-po-faze.md` rc 0.
- `contracts/204-karta-vyzova-po-faze.md:62-64` и `fixtures/workshop_project/karta_vyzova_204/SDACHA.md:45-55`: заявленные 22/13/9 и 9/11/11/0 совпадают с указанными результатами раннера.

## Карта классов

К-01: чисто — блок вызова 2 закрыт: W --stabs rc 0, обе мутации и честные контроли исполнены.
К-02: чисто — без изменений с вызова 2.
К-03: чисто — W --regress193 --model rc 0, 152/152.
К-04: чисто — без изменений с вызова 2.
К-05: чисто — без изменений с вызова 2.
К-06: чисто — без изменений с вызова 2.
К-07: чисто — W --model rc 0 22/22, W --regress193 --model rc 0 152/152.
К-08: чисто — повтор ${faza:0:1} rc 1, 20/22; regex rc 1, 19/22.
К-09: чисто — v10/v11 красны при усечении, честная модель W --model rc 0.
К-10: чисто — вход: сравнение `mutant_expected` с полным результатом в probe.py и фактические результаты f4/v10 выше.
К-11: чисто — без изменений с вызова 2.
К-12: чисто — без изменений с вызова 2.
К-13: н/п — секреты не предмет.
К-14: чисто — W --stabs rc 0, честные f4 и v10 перед мутациями зелёные.
К-15: чисто — W --model 22/22, --repo 13/22, --stabs 9/11/11/0, соответствуют контракту и листу.
К-16: чисто — без изменений с вызова 2.
К-17: н/п — архитектурная модель 188 не изменяется.
