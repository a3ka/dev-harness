# СДАЧА 212 — REPLACE после ленда PR (круг v2)

Правка по трём блокам вердикта критика v1: Б-1 код возврата CLI, Б-2 край
файла при замене, Б-3 неконформные реестры и NUL. Вердикт v1 в дереве OBJECT
не закоммичен, поэтому строка «ПРЕДЫДУЩИЙ ВЕРДИКТ:» не заявляется (прецедент
208/210). Обещание и наблюдение прежние: один прямой main-коммит одной строки
реестра сквозь дверь 031 после удостоверенного ленда, наблюдение — полные
bytes stdout/stderr, HEAD, diff реестра, identity и сохранение пред-состояния
при отказе. Производство этой пачкой не меняется.

Среда формы: TMPDIR — существующий scratch разрешённой копии.
VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck
передаётся через штатный шов validate_std (пин из ops/server/validators.tsv).
Отсутствие валидатора даёт rc 2, не зелёный пропуск. Синтаксис мутантов — bash -n;
пинованный shellcheck применяется к честной модели/обёртке и поставленному субъекту:
намеренное удаление условия может оставить у мутанта неиспользуемую переменную,
это не синтаксический дефект обманки.

Наблюдённые контроли этой редакции: model — 28 предъявлений, красных 0.
stabs — 43 копии, 76 связей, живых 0. Каждая связь судится отдельно, якорь
каждой мутации кратен 1 в тексте модели. Числа — замер этой редакции,
контракт задаёт нижнюю границу и допускает усиление семейства. Source.json
материализован из probe212.py, носители проверяются sha256 до запуска.

## Двери

- Red-do · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --repo . · 1 · 1
- Model · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --sintaksis · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/212-replace-posle-lenda.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/212-replace-posle-lenda.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/212-replace-posle-lenda.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/212-replace-posle-lenda.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Ids · bash scripts/check_ids.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/212-replace-posle-lenda.md · 0 · 0
- CI-canon · bash scripts/gen_ci_steps.sh --check · 0 · 0
- Pre-critic · bash scripts/pre_critic.sh contracts/212-replace-posle-lenda.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа исполняются check_sdacha --run rc 0, СДАЧА/ПРОВОДКА, модель угроз и незаполненные требования присутствуют, вердикт v1 не закоммичен в дереве и строкой ПРЕДЫДУЩИЙ ВЕРДИКТ не заявляется (прецедент 208/210) · - · -
- К-02 · чисто · вход: слово владельца 22.11, задание task-arch212 и правка task-arch212b названы в КОНТЕКСТ, место 068, неизменное first-parent признание и отдельный исторический остаток 6eebe0302 названы · - · -
- К-03 · чисто · вход: двери 031/049 и маршруты 068/130/045/071 остаются зависимостями, зона кандидата не касается scripts/check_staged.sh, check_zones.sh, mint_line.sh, gitw, freeze_contract.sh · - · -
- К-04 · чисто · вход: зона architect — только контракт и одна семья fixtures, зона implementer — новый scripts/replace_line.sh, CI-файлы за orchestrator из frozen-пересечений, runtime-REPLACE не выдаёт общей edit-зоны реестра · - · -
- К-05 · чисто · вход: код возврата CLI один в контракте (инвариант 1), модели и клетках по образцу mint_line.sh — отсутствие --nnn rc 1 с usage, N вне грамматики rc 2 NOT_IMPLEMENTED, различено argv-клетками n03 против n01/n02/n04/n05/n06 в прогоне --model rc 0 · - · -
- К-06 · чисто · вход: нет git/bash/python3/двери, потерянный носитель либо якорь либо синтаксис стаба — rc 2 ORACLE_TAMPERED, отсутствие пина shellcheck — rc 2, до реализации --repo — rc 1 SUBJECT_ABSENT как предъявляемое красное · - · -
- К-07 · чисто · вход: клетка r17 строит настоящий git-мир с чужой грамматической последней строкой без конечного LF, честная модель проходит REPLACE прямым коммитом сквозь живую дверь 031, пост-проверка сверяет манифест HEAD байт-в-байт с сохранённым краем (прогон --model rc 0) · - · -
- К-08 · чисто · вход: каждая адресная связь source.json.stab_vhod отдельно обязана отличать мутанта, включая st41 awk дописывает LF, st42 удалена грамматика реестра, st43 удалена проверка NUL и st40 константа номера — 76 связей, живых 0 (прогон --stabs rc 0) · - · -
- К-09 · чисто · вход: клетки r19–r22 предъявляют неконформные реестры NUL, CRLF, лишние поля, пустая строка с именованными отказами и полным побайтовым stderr, состояния миров различны и на разных номерах (прогон --model rc 0) · - · -
- К-10 · чисто · вход: клетка r19 судит полный stderr на NUL-реестре без предупреждения command substitution — NUL проверяется по трубе plumbing до любого $() над манифестом, sravnit сравнивает обе трубы байт-в-байт без нормализации · - · -
- К-11 · чисто · вход: ожидаемые причины, старые/новые tag-object, исходный реестр и статус лежат в памяти до вызова, source.json и носители сверяются sha256 до запуска, мутированный реестр как оракул не перечитывается · - · -
- К-12 · чисто · вход: git DAG, типы и объекты — plumbing настоящего git, дверь миров — живой check_staged.sh дерева, профильный путь — существующий project_paths_resolve, JSON оракула генерируется из единого кода probe212.py · - · -
- К-13 · н/п · секретных входов предмет не объявляет: локальные toy-origin и хеши объектов, не credentials, новых CI secrets не вводится · - · -
- К-14 · чисто · вход: честная модель зелена на всех 28 предъявлениях включая миры без конечного LF — r17 чужой хвост и r18 строка предмета в краю, допуски id-старой стороны и frozen-предыдущей на разных NNN, отказные состояния не разрешаются общей отменой двери (прогон --model rc 0) · - · -
- К-15 · чисто · вход: числа взяты из фактических прогонов этой редакции — MODEL 28 KRASNYH 0, STABY SVJAZI 76 ZHIVYH 0, SINTAKSIS bash -n 44 и shellcheck 2, frozen-текст несёт нижнюю границу и состав не дублирует · - · -
- К-16 · чисто · вход: класс рисковый из закрытого перечня права/безопасность, историческая пара 208 остаётся отдельной owner-зависимостью, second-parent признание не расширено, доверенность origin/PATH/hook и гонка push имеют названных ловцов в НЕ ЗАЩИЩАЕТ · - · -
- К-17 · н/п · отдельные операции и схемы модели 188 этим предметом не заявлены, новых сервисов, ролей и параллельных механизмов тега, реестра, публикации либо признания нет · - · -

## Дельта

- К-05 · снятие · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --model · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --model · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --stabs · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --model · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --stabs · 0 · 0

Блок Б-1 (К-05) закрыт снятием расхождения: contract инвариант 1 и сценарии
приёмки несут один договор mint_line 068 (отсутствие --nnn rc 1 с usage,
негодный N rc 2), модель usage() завершает 1, клетка n03 требует того же,
остальные argv-клетки держат rc 2. Блок Б-2 (К-07, К-14) закрыт клеткой:
модель печатает разделители awk явным printf и сохраняет завершённость файла,
клетки r17/r18 зелены на честной модели, стаб st41-awk-dobavljaet-lf
возвращает дефект v1 и краснеет на обеих связях. Блок Б-3 (К-08, К-09, К-10)
закрыт клеткой: грамматика всего манифеста единым шаблоном и байтовая
проверка NUL идут по трубе plumbing до любого $() над манифестом, клетки
r19–r22 предъявляют NUL, CRLF, лишние поля и пустую строку с именованными
отказами и полным побайтовым stderr, стабы st42-grammatika-udalena и
st43-nul-udalen краснеют каждый на своих входах. Полная матрица остаётся
обязательной дверью Stabs и шагом CI. Предмет, связи и обязательность
матрицы не изменены.
