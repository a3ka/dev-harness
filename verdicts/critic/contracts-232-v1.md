FAIL
OBJECT=da3073572c7fd3daab9cc996756d966f1890e2bc
СУД: репо=dev-harness; предмет=232; фаза=контракт; роль=critic; вызов=1 (полный); сессия=Crit232; модель-факт=openai-codex/gpt-6.1-terra; автор Architect232b — назначение architect zai/glm-5.3; сессионная запись модели автора в доступном model-trace отсутствует.

## Блок

БЛОКИРУЕТ contracts/232-gramm-karta-krome.md:39 — HEAD-only дверь не судит материализуемый вердикт перед коммитом.
ОБЯЗАТЕЛЬСТВО: строки 39–40 требуют вызов check_verdict_karta в pre_judge до успешной материализации при сохранении HEAD-only; строка 64 обещает защиту от материализации нештатной карты. roles/critic.md:304 и frozen 206 требуют вызвать pre_judge перед коммитом; новый корректный вердикт должен иметь исполнимый путь к коммиту.
СОСТОЯНИЕ: реальная операция из frozen 206 — новый вердикт в своей судейской ветке до первого коммита; другой штатный случай — исправляемый вердикт, где HEAD содержит старую корректную карту, а рабочий файл содержит новую нештатную. Батарея помещает целевой вердикт в HEAD до вызова pre_judge (probe.py world), тогда как обязательная модель вызывает существующую HEAD-only дверь.
НАБЛЮДЕНИЕ: на штатной модели 232 в одноразовых Git-мирах корректный новый файл получает rc 1 «вердикт не закоммичен»; некорректная замена существующего файла получает rc 0 и VERDICT_BRANCH, а после коммита та же карта получает rc 1. Следовательно, модель одновременно не допускает честный первый вердикт и допускает материализацию нештатного. Это не таймаут и не искусственная мутация.
ОБХОД: положить в рабочий файл существующего корректного HEAD-вердикта строку `К-05: чисто` без обязательного хвоста; pre_judge проверяет прежний HEAD и печатает успех; затем коммит материализует нештатную карту.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-07
Закрывающее свойство: согласовать порядок и идентичность проверяемого/материализуемого содержимого с frozen HEAD-only и нормой pre_judge до коммита; доказать честный новый файл и отказ плохой новой версии реальной операцией, не ослабляя исторические HEAD-only гарантии. Выбор механизма и, при необходимости, полномочного изменения нормы — не предписывается.

Команды выполнены на модели в одноразовых Git-мирах: штатные probe.py world/installed и реальные Git/pre_judge/check_verdict_karta. ROOT — одноразовая копия заданного OBJECT, tools — копия её scripts с пятью model-носителями.

```text
TMPDIR="$PWD/tmp/critic232" python3 -B "$PWD/tmp/critic232/first_verdict.py"
INPUT verdicts/critic/contracts-178-v1-krug6-fail.md committed= True rc= 0 stdout= 'VERDICT_BRANCH=wip/178/critic\n' stderr= ''
INPUT verdicts/critic/contracts-178-v1-new.md committed= False rc= 1 stdout= '' stderr= 'ОТКАЗ: KARTA_NE_SHTATNA\nкарта не штатная: ОТКАЗ: вердикт не закоммичен (AGENTS п.9): verdicts/critic/contracts-178-v1-new.md нет на HEAD\n'

TMPDIR="$PWD/tmp/critic232" python3 -B "$PWD/tmp/critic232/stale_verdict.py"
working=invalid HEAD=valid rc= 0 stdout= 'VERDICT_BRANCH=wip/178/critic\n' stderr= ''
after commit rc= 1 stdout= '' stderr= 'ОТКАЗ: verdicts/critic/contracts-178-v1-krug6-fail.md: статус вне алфавита (чисто|блок|н/п|ссылка) или нет « — »: К-05: чисто\n'
```

Воспроизведение: штатный `world({'pj':True,'call':'1'})` создаёт валидный коммиченный вердикт и critic-ветку; `put(root,newpath,verdict('2'))` создаёт валидный незакоммиченный файл, затем реальный `pre_judge.sh verdict --repo root --file newpath`. Во втором мире `put(root,target,verdict('1',{5:'чисто'}))`, pre_judge, затем `git add`, `git commit` и реальный `check_verdict_karta.sh root target`. Модель взята из `fixtures/workshop_project/karta_krome_232/model/`, не из production. Полные скрипты — `tmp/critic232/first_verdict.py` и `tmp/critic232/stale_verdict.py` судейской копии.

## Карта классов

К-01: чисто — check_sdacha --run rc 0, двери=7 карта=17/17 дельта=0.
К-02: чисто — R-0168, объект 178 и две операции задания сверены с contracts/232.
К-03: блок — HEAD-only и pre_judge перед коммитом противоречат живому маршруту 206.
К-04: чисто — зоны contracts/232:77–82, context.py rc 0, 72 декларации.
К-05: чисто — критерии contracts/232:50–57 содержат команды и rc.
К-06: чисто — вход: probe.py различает ошибки подготовки rc 2 и расхождение предмета.
К-07: блок — невозможен первый честный вердикт и допускается неконформная замена.
К-08: блок — батарея не предъявляет фактическую материализацию до коммита.
К-09: чисто — вход: живой blob 178, пустой/полный реестр, прямые и ссылочные классы, FAIL/accept.
К-10: блок — проверяется старая карта HEAD вместо материала коммита.
К-11: чисто — вход: независимый normalized178.json и ожидаемые статусы probe.py.
К-12: чисто — вход: validate_std/json и штатная грамматика 193.
К-13: н/п — секретные входы не вводятся.
К-14: чисто — вход: один blob в двух путях, эквивалент JSON и прежняя грамматика.
К-15: чисто — каталог rc 0: 55 клеток, 24 стаба, 38 связей; context.py 72.
К-16: блок — обещанная защита материализации не достигается HEAD-only проверкой.
К-17: н/п — продуктовая модель 188 не объявлена, станционные двери.

## Идентичность и границы

`git hash-object fixtures/workshop_project/karta_krome_232/live178.md` и `git -C /tmp/dev-harness-verify/a178 rev-parse 5cf13779:.harness/verdicts/critic/contracts-178-v1-krug6-fail.md`: `0c079b17b3d1a3fee5cf58c5daf19ea9c156d713`. `sha256sum` файла: `0a7d5c84b0cbebc8e9e61bfd58db185f6d4f38c0ae711842a7b72c820aacae66`. Идентичные байты под другим путём допустимы в объявленной content-addressed границе; иной blob не наследует запись. Коммит OBJECT содержит `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: ... R-0168`. Сессионный trace автора отдельно не доступен; runtime/model-trace.tsv содержит назначения ролей critic terra, architect glm. Самоавторства по доступной истории нет.

## Машинные результаты

Прогоны на SSH-origin клоне OBJECT; выводы ниже — точные итоговые строки, полный вывод процесса судьи: artifact://14230. Shellcheck зафиксирован на `/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`. `--repo` красен по умыслу: нет production-реестра и ноги materialization; все 35 имён совпадают с SDACHA.

```text
SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/232-gramm-karta-krome.md --run
rc=0
СДАЧА: лист зелёный (двери=7 карта=17/17 дельта=0)

bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --model
rc=0
KLETKI 55 KRASNYH 0
bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --stabs
rc=0
STABY 24 SVJAZI 38 ZHIVYH 0
bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --sintaksis
rc=0
SINTAKSIS 13 SHELLCHECK 3 JSON_SCHEMA 1
bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --catalog
rc=0
KLETKI 55 STABY 24 SVJAZI 38
bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --repo .
rc=1
KLETKI 55 KRASNYH 35
python3 -B fixtures/workshop_project/karta_krome_232/context.py
rc=0
ДЕКЛАРАЦИИ 72
bash scripts/pre_critic.sh contracts/232-gramm-karta-krome.md
rc=0
КРИТИК: дверь зелёная
bash scripts/check_precision_gate.sh . contracts/232-gramm-karta-krome.md
rc=0
OK
bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --repo .
rc=0
ИТОГ 193: rc=0 KLETKI=152 ZELENYE=152 KRASNYE=0
bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --repo .
rc=0
KLETKI 100 KRASNYH 0
```

## Собственные мутации

`TMPDIR="$PWD/tmp/critic232/clone/tmp" VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck python3 -B "$PWD/tmp/critic232/attacks.py"`: каждый запуск накладывает один мутант на пять честных model-носителей внутри одноразового клона и вызывает полный `bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --repo <clone>`. Не записи stabs.tsv: (1) проверка дубликата срабатывает только при `len(seen)>1`; (2) проверка сохранения числового вызова только при исходном числе больше 6; (3) `critic` в ветке И пути вместо ИЛИ; (4) нормализация ссылки отбрасывает хвост. Сырой вывод:

```text
ATTACK duplicate-second
rc= 1 stdout:
REPO duplicate-sha RED API_RC,API_REASON,CLI_RC,CLI_REASON rc= 0 stdout= b'\xd0\x9a\xd0\x90\xd0\xa0\xd0\xa2\xd0\x90: 17/17 \xd0\xb7\xd0\xb5\xd0\xbb\xd1\x91\xd0\xbd\xd1\x8b\xd0\xb9\n' stderr= b''
KLETKI 55 KRASNYH 1
stderr:

ATTACK numeric-call-six
rc= 1 stdout:
REPO change-call RED API_RC,API_REASON,CLI_RC,CLI_REASON rc= 0 stdout= b'\xd0\x9a\xd0\x90\xd0\xa0\xd0\xa2\xd0\x90: 17/17 \xd0\xb7\xd0\xb5\xd0\xbb\xd1\x91\xd0\xbd\xd1\x8b\xd0\xb9\n' stderr= b''
KLETKI 55 KRASNYH 1
stderr:

ATTACK critic-both-only
rc= 1 stdout:
REPO pj-role-bypass RED PJ_RC,PJ_REASON,PJ_REFUSAL_FORM rc= 0 stdout= b'VERDICT_BRANCH=wip/178/reviewer\n' stderr= b''
KLETKI 55 KRASNYH 1
stderr:

ATTACK drop-reference-tail
rc= 1 stdout:
REPO live-registered RED API_RC,RESOLVED_MAP,CLI_RC,CLI_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-krug6-fail.md: KARTA_REGISTRY_INVALID: normalization differs from deterministic source\n'
REPO live-installed-default RED API_RC,RESOLVED_MAP,CLI_RC,CLI_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-krug6-fail.md: KARTA_REGISTRY_INVALID: normalization differs from deterministic source\n'
REPO identical-other-path RED API_RC,RESOLVED_MAP,CLI_RC,CLI_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-other.md: KARTA_REGISTRY_INVALID: normalization differs from deterministic source\n'
REPO index-call6 RED API_RC,RESOLVED_MAP,CLI_RC,CLI_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-krug7.md: KARTA_REGISTRY_INVALID: normalization differs from deterministic source\n'
REPO last-fail6 RED API_RC,RESOLVED_MAP rc= 1 stdout= b'KARTA_REGISTRY_INVALID: normalization differs from deterministic source' stderr= b''
REPO config-add-only RED API_RC,RESOLVED_MAP,CLI_RC,CLI_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-krug6-fail.md: KARTA_REGISTRY_INVALID: normalization differs from deterministic source\n'
REPO config-remove-only RED FIRST_API_RC,FIRST_RESOLVED_MAP,FIRST_CLI_RC,FIRST_CLI_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-krug6-fail.md: \xd0\x9a-05: \xd1\x81\xd1\x81\xd1\x8b\xd0\xbb\xd0\xba\xd0\xb0 \xd0\xb2\xd0\xbd\xd0\xb5 \xd0\xb3\xd1\x80\xd0\xb0\xd0\xbc\xd0\xbc\xd0\xb0\xd1\x82\xd0\xb8\xd0\xba\xd0\xb8\n'
REPO config-new-blob-only RED API_RC,RESOLVED_MAP,CLI_RC,CLI_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-krug6-fail.md: KARTA_REGISTRY_INVALID: normalization differs from deterministic source\n'
REPO config-equivalent RED API_RC,RESOLVED_MAP,CLI_RC,CLI_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-krug6-fail.md: KARTA_REGISTRY_INVALID: normalization differs from deterministic source\n'
REPO subject-empty-bait RED API_RC,RESOLVED_MAP,CLI_RC,CLI_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-krug6-fail.md: KARTA_REGISTRY_INVALID: normalization differs from deterministic source\n'
REPO pj-live-registered RED PJ_RC,PJ_OUTPUT rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: KARTA_NE_SHTATNA\n\xd0\xba\xd0\xb0\xd1\x80\xd1\x82\xd0\xb0 \xd0\xbd\xd0\xb5 \xd1\x88\xd1\x82\xd0\xb0\xd1\x82\xd0\xbd\xd0\xb0\xd1\x8f: \xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: verdicts/critic/contracts-178-v1-krug6-fail.md: KARTA_REGISTRY_INVALID: normalization differs from deterministic source\n'
KLETKI 55 KRASNYH 11
stderr:
```
