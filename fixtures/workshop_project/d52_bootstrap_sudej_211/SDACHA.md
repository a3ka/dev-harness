# СДАЧА 211 — исправление батареи по Adv211 Б-1/Б-2/Б-3/Б-4

## Существующее и состояние

Контракт `contracts/211-d52-bootstrap-sudej.md` заморожен (`frozen/contracts/211/1`) и не изменён. Предмет, инварианты, порядок судей и принятая владельцем граница `risk_repo=носитель` сохранены. База исправления батареи — `1315a7da8a56ce8fcedb9c894c71ba23596368ef`: реализация Impl211b уже исправляет Б-1/Б-2 в `scripts/zamok_predmeta.sh`; архитектор меняет только эту семью fixtures. Источник блоков — `verdicts/adversary/contracts-211-impl-v1.md` в `a739f6ded4bf91a5b7c830b570448dd34a47a9fe`.

Обещание: класс судей реализации из дерева OBJECT удостоверяется annotated frozen-тегом новой версии, предковостью и равенством непустых перечней имён/blob; профиль и legacy берутся у владельца. Наблюдение: rc, полные stdout/stderr байтами, START по полям JSON и неизменность учёта при отказе. Ожидания зафиксированы в памяти до вызова; диск субъекта не служит оракулом. Модель — прежняя дверь базы 208 (`10ff5df41105e4d65c0f62fa918a76e2c11bd017`) плюс D64 и исправление перечней Б-1/Б-2; D42/D52 и `verdikt_put` сохранены.

Текущее состояние ПОСЛЕ реализации Б-1/Б-2: `--repo .` и `--model` — `KLETKI 43 KRASNYH 0`, rc 0; `--stabs` — `SVJAZI 61 ZHIVYH 0`, rc 0 (56 копий). Прежние 27 клеток и 54 связи сохранены; добавлены 16 клеток и 7 связей. Исторический Red-do на базе до D64 давал 27/13; это не ожидаемый rc нынешнего дерева. На production до исправления Б-1/Б-2 (`64457a6c0d43d20624adf24a9d9f7ade56eaf2bf`) новые предъявления Б-1/Б-2 красны; честная production `1315a7da8` зелена. Ряды Red-do ниже теперь требуют только rc 0: принимать множество {0,1} запрещено.

## Двери

- Red-do — production после исправления Б-1/Б-2, 43/0 · bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo . · 0 · 0
- Model — 43 клетки, обе трубы байтами · bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --model · 0 · 0
- Stabs — SVJAZI 61 ZHIVYH 0 · bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --stabs · 0 · 0
- Sosed-208 — модель как субъект семьи 208, 35/0 · bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --sosed-208 · 0 · 0
- Negativ-208 — ровно r31/r32 · bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --negativ-208 · 0 · 0
- Sintaksis — модель и production · bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --sintaksis · 0 · 0
- Reg-208 — сосед D9/D11 · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo . · 0 · 0
- Reg-167 — обрыв и круги · bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo . · 0 · 0
- Reg-140-model — A2 · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model · 0 · 0
- Reg-higiena — профиль двери · bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/211-d52-bootstrap-sudej.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/211-d52-bootstrap-sudej.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/211-d52-bootstrap-sudej.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/211-d52-bootstrap-sudej.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/211-d52-bootstrap-sudej.md · 0 · 0
- Pre-critic · bash scripts/pre_critic.sh --repo . contracts/211-d52-bootstrap-sudej.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа; штатный SDACHA_OKRUG=1 разрывает рекурсию pre_critic; Red-do требует послереализационный rc 0 · - · -
- К-02 · чисто · вход: frozen/contracts/211/1; новый смысл и новые обязательства не вводятся · - · -
- К-03 · чисто · вход: зона только fixtures/workshop_project/d52_bootstrap_sudej_211/ поверх 1315a7da8; frozen-контракт и production не меняются · - · -
- К-04 · чисто · вход: временные миры под TMPDIR удаляются finally; носители стаба и source.json регенерируются штатным --sgeneriruj-staby · - · -
- К-05 · чисто · вход: инварианты frozen-контракта; отказ-удостоверения и честные эквивалентные записи имеют точные rc/stdout/stderr · - · -
- К-06 · чисто · вход: отсутствие инструмента/дрейф носителей/сломанная мутация — rc 2 ORACLE_TAMPERED или NOT_IMPLEMENTED, отсутствие субъекта — rc 1 SUBJECT_ABSENT · - · -
- К-07 · чисто · вход: --repo запускает настоящий scripts/zamok_predmeta.sh; старая production и три адресных production-мутанта проверяются тем же маршрутом в одноразовых клонах · - · -
- К-08 · чисто · вход: st54/st55/st56 — адресные замены операций; привязки по коду STAB_VHOD и source.json:.stab_vhod, не проза контракта; прежние 54 связи сохранены · - · -
- К-09 · чисто · вход: b28–b33 — отдельный отказ для каждого нового Git-имени; b38–b43 — каждое то же имя честно заморожено; b34 — только mode; b35/b36 — не обычный файл; b37 — достижимый critic/D52 с legacy носителя · - · -
- К-10 · чисто · вход: единый предикат полного равенства обеих труб bytes; st13–st42 сохранены; до сравнения нет decode/strip/newline translation · - · -
- К-11 · чисто · вход: ожидания в памяти до субъекта; sha256 носителей в source.json; мир на клетку, отдельный .git, без обращения к живому состоянию станции · - · -
- К-12 · чисто · вход: настоящий git ls-tree -z, blob-ша и annotated tag; модель кодирует имя shell printf %q для независимого сравнения, mode проверяет отдельно; грамматика Git basename исключает NUL и / · - · -
- К-13 · н/п · вход: секретов в локальных мирах и наружном выводе нет · - · -
- К-14 · чисто · вход: к отказам b28–b33 парные честные b38–b43; b34 допускает executable regular file, b35/b36 отвергают равные nonregular entries; b37 сохраняет D52 · - · -
- К-15 · чисто · вход: живые итоги движка — 43 клетки, 56 стабов, 61 связь, 0 живых; модель — один файл; прежние нижние границы 27/53/54 в frozen-контракте не потолок усиления · - · -
- К-16 · чисто · вход: рисковый предмет допуска судей; принятая владельцем граница risk_repo=носитель неизменна; пределы этой батареи и ловцы — ниже · - · -
- К-17 · чисто · вход: только четыре блока Adv211; новых production-модулей, CI-дверей, норм и требований нет; усиление существующей семьи · - · -

## Дельта

Б-1 — клетка: b28–b33 добавляют по одному рисковому файлу после F (кириллица, пробел, кавычка, обратный слеш, TAB, LF). Каждая требует rc 1, пустой stdout, KLASS_RISKA_NET + ADVERSARIJ_DO_REVJUERA, неизменный учёт. b38–b43 замораживают то же имя и требуют чистый PUSCHEM rc 0. st54 возвращает цитирующий ls-tree без -z и прежний фильтр имён; привязан только к входам, на которых имя действительно теряется (не к пробелу).

Б-2 — клетка: b34 независимо сверяет два настоящих ls-tree -z: ровно 100644→100755, остальные байты записи неизменны; ожидает чистый PUSCHEM rc 0. st55 ошибочно включает mode в сравнение, b34 красна. Соседние b35/b36 держат одинаковый симлинк/каталог с именем 211-dir.md уже в обоих деревьях: равенство записей не удостоверяет неканонический тип, требуется отказ-удостоверения. Модель обрабатывает перечни NUL-безопасно, сравнивает имена/blob без mode, но разрешает только regular-file modes.

Б-3 — клетка: b37 воспроизводит поддерживаемый critic/D52 без frozen-тегов, текст без класса, legacy ordinary только у носителя $wt; ожидает пустой stderr. st56 меняет ровно owner="${4:-$wt}" на owner="${4:-$REPO}" и даёт ложное предупреждение; b37 его различает. Прежние st50/b27 (D42) сохранены.

Б-4 — канон/инструмент: оба ряда Red-do переведены с 1·1 на 0·0 под production с исправлением Б-1/Б-2; историческое красное не выдаётся за нынешнюю приёмку. check_sdacha --run и pre_critic прогоняются на этом состоянии.

- К-01 · канон/инструмент · bash scripts/pre_critic.sh contracts/211-d52-bootstrap-sudej.md · 0 · 0
- К-15 · канон/инструмент · bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo . · 0 · 0

## НЕ ЗАЩИЩАЕТ

Б-1: конечный набор POSIX/Git-имён не доказывает эквивалентность произвольной обработки всех допустимых байтов; NUL и / не являются basename. Ловцы иных конформных имён и мутаций — adversary/reviewer на реальном git-мире.

Б-2: отдельные 100644/100755/120000/040000 не доказывают поведение всех типов Git и файловых систем; ловцы иных типов и платформ — adversary/reviewer. Равенство только mode не заменяет равенство имён/blob.

Б-3: b37 проверяет сохранение источника D52, не доверенность контролируемого автором носителя. Принятая владельцем граница risk_repo=носитель и чтение незакоммиченных профиля/legacy остаются; ловцы — adversary/reviewer, системное исправление только отдельным предметом.

Сохранены границы frozen-контракта: живость origin-тега (оркестратор), свежесть origin-view (208/172), байтовая форма учёта (отдельный предмет), проектный реестр (registry-profile), конечность матрицы (adversary/reviewer).

СВЕРХ БЛОКОВ: новых обязательств и дверей нет; контракт, production и CI-реестры не изменены.
