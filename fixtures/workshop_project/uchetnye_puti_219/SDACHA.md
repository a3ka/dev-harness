# СДАЧА 219 — точные учётные пути

## Ремонт К-08 — Architect219b

База ремонта: 89893e66aaa8de10ef07e9f44122cc6b4f066c5d, ветка wip/219/architect-b. Frozen-контракт и production неизменны. Предъявление Adv219: 159beca827175e64a0ddfd074748df61479f2b1a, verdicts/adversary/contracts-219-impl-v1.md, блок К-08.

Существующее: probe.py уже строит настоящие Git-миры reg-add/remove/replace и снимает независимый H до subject; stabs.tsv связывает каждую мутацию с наблюдением и неизменным контролем. Новые клетки используют эти же операции, но включают правку pauzy в тот же коммит; replace дополнительно правит место и уроки. Парный accounting-data-only меняет все три учётных файла без правки U и требует uchet. Для совместных изменений требуется kod, проверяются оба точных H; независимые H обязаны различаться до вызова субъекта.

model/registry_data_mutation.py содержит старый/новый фрагмент c_klass из находки. Применение требует единственного якоря, --sintaksis компилирует файл и подставляемое тело функции. Привязки к трём новым ветвям находятся в stabs.tsv, не в контракте. source.json и генератор каталога в этой семье отсутствуют: каталог по-прежнему строится непосредственно из CASES/MUTATIONS/stabs.tsv, второй источник чисел не вводится.

Окружение ремонта: TMPDIR=$PWD/tmp, PYTHONDONTWRITEBYTECODE=1; shellcheck 0.11.0 по пути из задания; identity architect. W — прежний red_uchetnye_puti_219.sh.

| Блок | Способ | Команда | rc и сырой итог |
|---|---|---|---|
| К-08, до | замер прежней батареи | W --stabs | 0; KLETKI=31 MUTACII=13 SVJAZI=28; POIMANY=28 ZHIVYH=0 |
| К-08, после | клетка на настоящем Git-входе, отдельное наблюдение каждой операции | W --repo . | 0; KLETKI=35 ZELENYE=35 KRASNYE=0 |
| К-08, честный контроль | существующая модель расширения | W --model | 0; KLETKI=35 ZELENYE=35 KRASNYE=0 |
| К-08, эквивалентная запись | перестановка U и симметрия сравнения | W --model --equivalent | 0; KLETKI=35 ZELENYE=35 KRASNYE=0 |
| К-08, адресная обманка | мутация Adv219 и неизменный контроль | W --stabs | 0; MUTACII=14 SVJAZI=31 POIMANY=31 ZHIVYH=0 |
| Форма | прежние инструменты | W --catalog; W --sintaksis | оба 0; KLETKI=35 MUTACII=14 SVJAZI=31 UCHET=13; SYNTAX rc=0 |
| Совместимость | полная прежняя батарея и проводка | W --model --compat | 0; 087 ok=110 КРАСНО=0, стабы 31/31; COMPAT red_ci_b_087.sh rc=0; COMPAT gen_ci_steps.sh rc=0; COMPAT check_provodka.sh rc=0 |
| Регресс 087 | полная прежняя батарея в отдельном клоне | bash fixtures/ci_b_087/red_ci_b_087.sh "$PWD/tmp/219-087-subject" | 0; ok=110 КРАСНО=0; стаб-пак 31/31 |

Сырые новые предъявления:

```text
REGISTRY_WITH_DATA_IS_UCHET -> registry-add-uchet-with-data: POIMAN; control=accounting-data-only GREEN; ["BYTES expected=(0, b'kod\\n', b'') actual=(0, b'uchet\\n', b'')"]
REGISTRY_WITH_DATA_IS_UCHET -> registry-remove-uchet-with-data: POIMAN; control=accounting-data-only GREEN; ["BYTES expected=(0, b'kod\\n', b'') actual=(0, b'uchet\\n', b'')"]
REGISTRY_WITH_DATA_IS_UCHET -> registry-replace-uchet-with-data: POIMAN; control=accounting-data-only GREEN; ["BYTES expected=(0, b'kod\\n', b'') actual=(0, b'uchet\\n', b'')"]
SVJAZI=31 POIMANY=31 ZHIVYH=0
```

Независимая мера: wc -l stabs.tsv = 32 с заголовком; каталог печатает SVJAZI=31. Прежние привязки сохранены, новая обманка поймана на каждой из своих ветвей.

Рефлексия для orchestrator (общий журнал только в main): прямой запуск 087 на $PWD при TMPDIR=$PWD/tmp сначала дал rc 1, ok=109 КРАСНО=1, стабы 31/31: К10 делает cp дерева в TMPDIR и получает «cannot copy a directory ... into itself». Причина среды устранена без правки 087: отдельный disposable Git-клон внутри $PWD/tmp, TMPDIR — сосед субъекта, не его потомок. На нём 110/110; --compat также имеет собственный отдельный субъект и прошёл сразу. Это не отказ классификатора и не повод ослаблять клетку. Старые измерения ниже — история первоначальной сдачи, не текущий статус.

## Первоначальная сдача (история)

База: 8b52fade7975034d7cabece67e46c16a7d1abe3b. Первый коммит — побайтовый импорт owner-затравки. Production не меняется architect: модель добавляет точные строки и мигрирует независимый снимок U87 только в отдельном tracked-снимке дерева. Числа и сырые результаты ниже заполняются из прогонов, а не из оценок задания.

Окружение: TMPDIR=/tmp/dev-harness-verify/scratch-arch219, VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Двери содержат ожидаемые rc; наблюдённые результаты — в разделе измерений. Если единственный отказ — отсутствующая строка плана 219, её доставляет owner-PR #1335, а не architect.

## Двери

- честная-модель · bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --model · 0 · 0
- честная-эквивалентная · bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --model --equivalent · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --stabs · 0 · 0
- матрица-087-и-проводка · bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --model --compat · 0 · 0
- синтаксис · bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --sintaksis · 0 · 0
- реестр-привязок · bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --catalog · 0 · 0
- пре-критик · bash scripts/pre_critic.sh contracts/219-uchetnye-puti-ci-klass.md · 0 · 0
- готовность-спеки · bash scripts/check_spec_ready.sh . contracts/219-uchetnye-puti-ci-klass.md · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/219-uchetnye-puti-ci-klass.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/219-uchetnye-puti-ci-klass.md · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/219-uchetnye-puti-ci-klass.md · 0 · 0
- проводка-done · bash scripts/check_provodka.sh . contracts/219-uchetnye-puti-ci-klass.md · 0 · 0
- источники-done · bash scripts/check_project_sources.sh --repo . --contract contracts/219-uchetnye-puti-ci-klass.md --stage done · 0 · 0
- генератор-CI · bash scripts/gen_ci_steps.sh --check · 0 · 0

## Карта классов

- К-01 · чисто · вход: команды формы выше используют штатные pre_critic, check_sdacha, PROVODKA, precision, готовность, потолки и threat-model; новые форматы не вводятся · - · -
- К-02 · чисто · вход: task-architect219.md и полная owner-затравка; обязательные pauzy/mesto и каждый дополнительный кандидат исследованы по коду; план 219 не подделан · - · -
- К-03 · чисто · вход: живые frozen 087/1, 114/1, 083/3, 201/1; точный список U87 мигрирует явно, не ослабляется А8; старые классификации и весь стаб-пак проходят --compat · - · -
- К-04 · чисто · вход: --context вызывает canonical zones_load; architect пишет только контракт и свою семью; implementer мигрирует старый снимок, orchestrator добавляет конфигурацию/проводку · - · -
- К-05 · чисто · вход: каждый И1…И5 привязан к CLI-команде и rc; до-реализации красное предъявляется исторически, а не нестабильной дверью листа · - · -
- К-06 · чисто · вход: отсутствующий Git/пин/источник/валидатор, таймаут команды и неуникальный якорь дают NOT_IMPLEMENTED rc 2; это не поимка дефекта · - · -
- К-07 · чисто · вход: настоящие git init/add/commit/ls-tree и production ci_klass CLI; --compat исполняет прежнюю полную батарею, generator --check и check_provodka в tracked-снимке · - · -
- К-08 · чисто · вход: --stabs удаляет точные новые строки и мутирует существующие операции; честный контроль и ожидаемый эффект разделены кодом/stabs.tsv · - · -
- К-09 · чисто · вход: add/edit/delete включённых данных, mixed code, режим файла, policy/receipt, границы имён, правки U и все точные/родительские PROTECT; прежние виды унаследованы через полную 087 · - · -
- К-10 · чисто · вход: сравниваются rc и полные stdout/stderr bytes; H из независимых NUL-записей Git, strip сверяется по оставшимся байтам/исчезнувшим путям/HEAD · - · -
- К-11 · чисто · вход: старый литерал U87 взят из pinned Git-блоба до субъекта; новые строки из канона проверяющего; ожидания файлов/хеша в памяти до вызова · - · -
- К-12 · чисто · вход: TSV читает csv, Python проверяет compile, Bash — штатный validate_std с bash -n и pinned shellcheck; правила YAML и данные JSON новым парсером не судятся · - · -
- К-13 · н/п · миры несут синтетические публичные значения, токены удалены из окружения; приёмка не требует API-секретов · - · -
- К-14 · чисто · вход: --model --equivalent меняет порядок uchet и симметричную запись точного сравнения; каждый адресный мутант имеет зелёный соседний контроль · - · -
- К-15 · чисто · вход: --catalog сверяет множество мутаций с TSV; счёт данных, клеток и связей печатается кодом; абсолютные sha берутся Git · - · -
- К-16 · чисто · вход: рисковый гейт слияния; risk-legacy и dostavki не исключаются; owner-ложь/будущая смена потребителя/общий uid названы остатками с действующими ловцами · - · -
- К-17 · н/п · проектной архитектурной модели 188 у станционного механизма 087 нет; повторной абстракции не вводится · - · -

## Измерения

СТАТУС: НЕ ГОТОВО К КРИТИКУ. Ожидаемые нули в «Дверях» не заменены единицами ради зелёного листа. Вне зоны 219 выявлена неисправная предпосылка полной матрицы 087: её К10-исп запускает 074, где живая установленная станция не равна пину 2026-10-02. Нужен санкционированный ремонт/разбор владельцем 074; расширять 219 на этот отказ запрещено.

W --repo <runtime-root>: rc 1, KLETKI=31 ZELENYE=20 KRASNYE=11. Красны pause-add/edit/delete, place-add/edit/delete, lessons-add/edit/delete, snapshot-exact и strip-accounting-only. Все кодовые/PROTECT-клетки зелены. Это различие klass=kod вместо uchet и независимого H, не инфраструктурное падение.

W --model: rc 0, KLETKI=31 ZELENYE=31 KRASNYE=0. В обязательном pre_critic встроенный check_sdacha повторно прошёл первые три двери: --model, --model --equivalent, --stabs, и остановился на следующей --compat. Поэтому честная эквивалентная перестановка uchet и симметричное сравнение тоже имеют фактический rc 0.

W --stabs после исправления дифференциального контроля IGNORE_CODE: rc 0, MUTACII=13 SVJAZI=28 POIMANY=28 ZHIVYH=0. Счёт TSV: 29 строк вместе с заголовком; уникальных имён 13. --catalog печатает KLETKI=31 MUTACII=13 SVJAZI=28 UCHET=13. Каждый из 28 адресных отказов имеет свой зелёный честный и неизменённый соседний контроль.

W --model --compat: rc 1, полный существующий red_ci_b_087.sh: ok=109 КРАСНО=1, стаб-пак 31/31. А8 и все classifier-клетки зелены; красна только К10-исп. gen_ci_steps.sh --check rc 0; check_provodka.sh rc 0. Сначала обнаружена ошибка среды самой новой пробы: archive не нёс историю, C-locale ломал кириллический grep -i, очищенная identity ломала orch_restart. Исправлено полноценным disposable clone с собственной .git, C.UTF-8 и явной identity architect; чужие клетки/пины не менялись.

Адресная диагностика (временный diagnose.py удалён) дала:
`k5b: станция /usr/local/sbin/orch-peak разошлась со снимком 2026-10-02`.
Это живая сверка fixtures/ops_server/red_server_obvjazka_074.sh:590–600, вызываемая безусловно в :855; чтение новых реестров здесь отсутствует. На прежнем C-locale дополнительно краснела симуляционная диффпроба к6 и Р4-норма 079 из-за снятой identity; эти ошибки среды исправлены, а установленный orch-peak из зоны 219 не переписывается.

Базовый полный fixtures/_krasnye_079.sh на неизменной production до подстановки: rc 0 (31 адресный стаб пойман). Это не объявление зелени всего К10. Последующий обязательный pre_critic при исправленной среде всё ещё rc 1, 170.67 с, точный отказ:
`ОТКАЗ: сдаточный лист красен (rc=1): ОТКАЗ: строка 12: фактический rc=1 ≠ заявленного 0: bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --model --compat`.
Отказ не списан на отсутствующую строку плана: до неё фактическая блокировка иная.

W --sintaksis: rc 0 (Python compile без pycache, bash -n и pinned shellcheck). Отдельные check_provodka.sh <root> <contract> и check_project_sources.sh --stage done: оба rc 0. Двери формы pre_critic до листа также прошли. Architect не вызывает платного судью при этом красном листе.

Отдельный обязательный check_sdacha.sh <runtime-root> <contract> --run: rc 1, 118.83 с, дословно:
`ОТКАЗ: строка 12: фактический rc=1 ≠ заявленного 0: bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --model --compat`.

Уточнение блокера по независимой мере: sha256 установленного /usr/local/sbin/orch-peak И файла ops/server/root/orch-peak в repo одинаковы: 5f2a1f443352f8f4a68200abccf9fca8bc8238cd8b73c4c9011a8891815b7bf6. Это же фиксированный PIN батареи 074:176, но её отдельный SNAP:194 ждёт 6b4f2261c100eeb56c7e1e1aeaa6a4b8d3e3b40a046cb854c08056004720c37f. Следовательно, переустанавливать root-часть наугад нельзя: разбор требует санкционированного согласования live-снимка 074. Ни PIN, ни SNAP, ни станция здесь не менялись.

Независимый счёт: wc -l stabs.tsv = 29; cut -f1 stabs.tsv | sort -u | wc -l = 14 вместе с заголовком, то есть 28 привязок и 13 уникальных мутаций. du -sh runtime-root = 159M.

## Рефлексия для orchestrator

Заданный WORKTREE является адресом доставки, но фактическая изолированная копия omp имеет другой абсолютный cwd. Правки сделаны только в выданной runtime-копии на wip/219/architect; итог содержит её pwd и полный SHA. Перенос источников в чужой адрес без санкции не выполняется.

Расширение одной строки конфигурации не равно отсутствию миграции: точная А8 старой батареи закрепляет первоначальное U. Эта зависимость обнаружена до реализации и включена в зону implementer; иначе первая реализация была бы неизбежно красной по чужому снимку.

Новая А-NN запись в wip не создаётся: журнал разрешён только коммитом main, вне зоны architect219. Наблюдение процесса передаётся этим листом; общий номер резервирует ведущая сессия при переносе.
