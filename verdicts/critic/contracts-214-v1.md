FAIL
OBJECT=c39fb407bf93cdd0a16cff345e38c394de91b3ec

СУД: репо=dev-harness; предмет=214; фаза=контракт; роль=critic; вызов=2 (узкий, по дельте Architect214b); сессия=Crit214b; модель-факт=openai-codex/gpt-6.1-terra; автор Architect214b — openai-codex/gpt-6.1-sol.

Учёт: вызов 1 — FAIL `7c0dd5088`, этот — второй; арбитражей 214 нет (задание). `scripts/models_actual.sh --bind --session Crit214b` и то же для Architect214b: rc 0, allowed, как выше. Разные сессии. HANDOFF суду не предъявлен; задание отдельно оговаривает, что это не блок. Область дополнительного поиска — новый warn-ledger и изменённое чтение D52 в ответ на прежний блок К-03.

БЛОКИРУЕТ contracts/214-vybor-vladelca-risk-repo.md:34-36 — прежний класс конфликта с frozen 211 не закрыт заменой stderr на ledger.
ОБЯЗАТЕЛЬСТВО: `frozen/contracts/211/1^{commit}:contracts/211-d52-bootstrap-sudej.md:26,38,42` сохраняет D52/critic как в базе: D52 использует профиль и legacy `<worktree>`, а предупреждения вне дельты D64 не меняются. Это не ограничение только на stderr. Строка 315 того же frozen-контракта описывает прежнее чтение D52 и отдельный предмет для исправления. Разрешение отдельного системного предмета не является адресной отменой frozen-обязательства. Предыдущий вердикт требовал сохранить действующие обязательства либо законный адресный переход с полномочием владельца.
СОСТОЯНИЕ: реальный Git-мир b37: в OBJECT нет класса, у доверенного владельца нет legacy, у автора рабочий legacy содержит обычный класс; bootstrap critic, frozen-тегов нет. 214 требует использовать доверенный legacy для решения и записать `KLASS_RISKA_NET` в ledger, хотя прежний D52 по авторскому legacy класс определял и предупреждения не формировал.
НАБЛЮДЕНИЕ: два вызова настоящего `--sudit` на одном построении b37 дают rc 0 и одинаковые stdout/пустую stderr, но база добавляет только `START`, а модель 214 добавляет `warn/KLASS_RISKA_NET` и `START` (сырой вывод ниже). Это изменение предупреждений и чтения D52, а не перенос прежнего предупреждения между трубами: его прежде не было вовсе. Зелёная b37/211 сравнивает трубы и START, но не запрещает лишнюю запись warn; неизменность файлов оракула не доказывает неизменность поведения. В :36 автор без полномочного изменения 211 объявляет совместимость только по допуску и трубам, сужая действующее обязательство.
ПРОИСХОЖДЕНИЕ: узкое-закрытие
КЛАСС: К-03
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: обеспечить совместимость с действующим D52 включая предупреждения и источник класса, либо предъявить законный адресный переход изменяемого frozen-обязательства с полномочием владельца и новым судом. Не маскировать конфликт тем, что неизменённая b37 не наблюдает warn.

АРБИТР: созвать арбитра о конечной границе предмета 214; повторный FAIL той же причины К-03, спор — сохраняет ли путь А обязательства D52 при изменении источника и добавлении warn либо необходим адресный переход 211. Сам арбитраж accept не заменяет.

## Карта классов
К-01: чисто — сдаточный лист `--run` rc 0, 12 дверей, дельта 1; `pre_critic` rc 0.
К-02: без изменений с вызова 1.
К-03: блок — новое предупреждение и изменённый источник D52 против frozen 211.
К-04: чисто — `check_precision_gate` rc 0, `OK`.
К-05: без изменений с вызова 1.
К-06: без изменений с вызова 1.
К-07: чисто — `W --model` rc 0, 36/0; регресс 208 и 211 на трёх субъектах rc 0.
К-08: чисто — адресные мутации risk-pipe, quiet-stderr, unknown-safe красные; bootstrap-author краснеет на critic-profile.
К-09: без изменений с вызова 1.
К-10: блок — К-03: эффект ledger не сравнивается исходной b37.
К-11: без изменений с вызова 1.
К-12: без изменений с вызова 1.
К-13: без изменений с вызова 1.
К-14: чисто — входы d52-compat-risk и d52-compat-safe в модели; соседний рискованный класс не меняет выбора трубы.
К-15: чисто — `--model` 36/0, `--stabs` 16/24/0, `--repo .` 36/20.
К-16: без изменений с вызова 1.
К-17: без изменений с вызова 1.

## Непосредственное свидетельство

Независимый запуск пары: в каждом отдельном `p.Mir` из `fixtures/workshop_project/d52_bootstrap_sudej_211/probe211.py` вызваны `mir_bootstrap(w, '211', None)`, `legacy_avtora(w, wt, obj, '211')`, `avtor_sdal(w, '211', wt, br)`, затем `sudit(door, w, vyzov(w, 'critic', 'Crit211', obj))`; до вызова сохранено число строк `w.ledg()`, после выведены пары `(t,kod)` новых строк. `door` — сначала production OBJECT, затем `fixtures/workshop_project/doverennyj_vladelec_214/model/zamok_predmeta.sh`. Обе двери запущены на реальных Git-мирах. Команда `TMPDIR="$PWD/tmp/scratch-crit214" python3 -B "$PWD/tmp/ledger214.py"`, rc 0:
```
base rc 0 stdout PUSCHEM Crit211 dev-harness/211 (sudja/critic) stderr b'' events [('START', None)]
model rc 0 stdout PUSCHEM Crit211 dev-harness/211 (sudja/critic) stderr b'' events [('warn', 'KLASS_RISKA_NET'), ('START', None)]
```

`git diff 7c0dd5088 c39fb407bf93cdd0a16cff345e38c394de91b3ec -- fixtures/workshop_project/d52_bootstrap_sudej_211 contracts/211-d52-bootstrap-sudej.md` пуст. Сравнение с исходным тегом frozen 211 показало 74 изменённых/добавленных файла семейства, а не побайтное равенство деревьев; они уже имелись на базе `f82ff8c9d0d4ba45a53b7aa2e712c552141715f9` и не являются дельтой 214. Текст 211 не менялся. `git diff --numstat 7c0dd5088 OBJECT -- fixtures/workshop_project/doverennyj_vladelec_214/probe.py`: `38 0`.

`SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/214-vybor-vladelca-risk-repo.md --run`, rc 0:
```
СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=1)
```
`bash scripts/pre_critic.sh contracts/214-vybor-vladelca-risk-repo.md`, rc 0: `КРИТИК: дверь зелёная`. `bash scripts/check_precision_gate.sh "$PWD" contracts/214-vybor-vladelca-risk-repo.md`, rc 0: `OK`.

W = `bash fixtures/workshop_project/doverennyj_vladelec_214/red_doverennyj_vladelec_214.sh`. `W --regress` rc 0: на базе, production и модели 214 каждый прогон 208 дал `SUBJEKT 208: KLETKI 35 KRASNYH 0`, каждый 211 — `SUBJEKT 211: KLETKI 59 KRASNYH 0`; после каждого — `FROZEN211_UNCHANGED 76`; итог `REGRESSION_FAMILIES 2 SUBJECTS 3 KRASNYH 0`. `W --model` rc 0: `KLETKI 36 KRASNYH 0`. `W --stabs` rc 0: `KLETKI 36 KRASNYH 0`, все 24 связи RED, итог `STABS 16 LINKS 24 ZHIVYH 0` (включая s13/frozen211-b37 и s13/d52-compat-safe). `W --repo .` rc 1: `KLETKI 36 KRASNYH 20`, ожидаемая краснота до реализации, включая d52-compat-safe/risk без обязательного новой спецификацией warn.

Адресные атаки в четырёх одноразовых клонах, каждая — единственная замена существующей операции модели, вызов настоящей клетки `probe.case`: (1) из предиката тихой совместимости убрать `risikovyj`; (2) убрать `2>/dev/null` у `predupr`; (3) `kr='risikovyj'` заменить на `obychnyj`; (4) при D52 передать в `klass_riska` вместо `risk_repo` `r_wt`. Команда `TMPDIR="$PWD/tmp/scratch-crit214" python3 -B "$PWD/tmp/attack214c.py"`, rc 0, сырой вывод:
```
risk-pipe d52-compat-risk RED errors=1
quiet-stderr d52-compat-safe RED errors=1
unknown-safe unknown-legacy RED errors=2
bootstrap-author d52-compat-safe LIVE errors=0
bootstrap-author critic-profile RED errors=1
```
Последний LIVE относится к одной клетке, не всей батарее; существующая critic-profile ловит эту замену. Первый черновой запуск атак имел rc 1 из-за двукратного якоря четвёртой замены; адресный якорь уточнён в приведённом прогоне. Это не предметный отказ.
