# СДАЧА 205 Δ1 — три блока Crit205V1: границы argv на LF (К-09), подстрока/регистр (К-08), полный вывод (К-10)

Предмет: признание guard, вызываемого gate'ем профиля проекта (`sourceCanon.gate`
эффективного профиля через `scripts/profile_resolver.sh`), четвёртой локацией
подключения в `scripts/check_provodka.sh`. Реальная дверь не заменяется
моделью; модель — эталон переноса для implementer. Этот лист закрывает блоки
вердикта v1 (К-07/К-09 — LF внутри элемента argv; К-08 — подстрока и регистр;
К-10 — сравнение полного вывода) клетками a6/a6b/a6c/a7/a8, мутациями
LF-GRANITSY/PODSTROKA-TOKENA/REGISTR-TOKENA/LISHNJAJA-STROKA и точным
побайтовым сравнением вывода в probe.py; мутации критика strip-relative и
strip-dotdot перенесены в stabs.tsv с ожиданием EKVIVALENT (эквивалентный
мутант с обоснованием правилом суффикса И1: токены `./<guard>` и `../<guard>`
оканчиваются на `/<guard>` и принимаются честной моделью независимо от
равенства — зафиксировано здесь явно, не молчанием). Мутации критика
any-field, ignore-errors, gate-first, omit-suffix уже ловятся клетками батареи
(c3 / e1–e3 / a1,a2,a5 / a3 по вердикту v1) и оставлены без отдельных стабов.

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-205-v1.md

## Двери

- красное-до · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --repo . · 1 · 1
- модель-батареи · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --stabs · 0 · 0
- атака-подстрока · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack PODSTROKA-TOKENA · 1 · 1
- атака-регистр · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack REGISTR-TOKENA · 1 · 1
- атака-lf · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack LF-GRANITSY · 1 · 1
- атака-лишняя-строка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack LISHNJAJA-STROKA · 1 · 1
- регресс-семьи-038-994 · bash fixtures/check_provodka/external_ci_994/probe.sh · 0 · 0
- грамматика-проводки · bash scripts/check_provodka.sh --grammar . contracts/205-provodka-gate-profilja.md · 0 · 0
- готовность-спеки · bash scripts/check_spec_ready.sh . contracts/205-provodka-gate-profilja.md · 0 · 0
- идентификаторы · bash scripts/check_ids.sh . · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери этого листа и команды приёмки п.5–6; pre_critic до сдачи зелён, полный check_provodka до CI-строки красен как заявлено контрактом · - · -
- К-02 · чисто · вход: задание 205 Δ1 (три блока вердикта v1 дословно), И1–И7 с уточнением Δ1 «целый элемент argv, включая LF внутри»; все числа приёмки из живых прогонов Δ1 · - · -
- К-03 · чисто · вход: 038/191/994 названы в «Боль и обещание» и ПЕРЕСЕЧЕНИЕ; замороженные фразы, режим --grammar и оговорка 994 сохранены (И6, И7, приёмка п.4) · - · -
- К-04 · чисто · вход: ЗОНА/ПЕРЕСЕЧЕНИЕ полным перечнем (precision-gate rc 0, приёмка п.6); строка реестра, замер и ci.yml — зона orchestrator · - · -
- К-05 · чисто · вход: каждая строка приёмки — команда с кодом возврата; привязки мутаций к клеткам — только stabs.tsv и probe.py · - · -
- К-06 · чисто · вход: отсутствие субъекта/резолвера, таймаут и пустая выборка дают rc 2 NOT_IMPLEMENTED; rc 2 зачётом поимки не считается · - · -
- К-07 · чисто · вход: модель читает argv gate NUL-разделителем (jq -j + read -d ''), границы элементов сохраняются на LF; различающая клетка a6-lf-vnutri-tokena и честный сосед a6b-chestnyj-sosed судят модель и реализацию (дверь атаки LF-GRANITSY) · - · -
- К-08 · чисто · вход: мутации VETKA-NET, PODSTROKA-BAZY, SLOVO-ERE, SYROJ-JSON, TIHO, ARGV0, PODSTROKA-TOKENA, REGISTR-TOKENA, LF-GRANITSY, LISHNJAJA-STROKA привязаны к коду модели; каждая различается своей клеткой; эквивалентные STRIP-RELATIVE/STRIP-DOTDOT несут ожидание EKVIVALENT с обоснованием правилом суффикса (MUTACII=12 SVJAZI=16 POIMANY=14 EKVIVALENT=2 ZHIVYH=0) · - · -
- К-09 · чисто · вход: ветви локации покрыты клетками a1–a8 (репо-слой, defaults-слой, абсолютный токен, голый argv0, python-расширение, LF до guard, честный сосед, LF после guard, суффикс .bak, регистр), b1–b3, c1–c3, d1, e1–e3, f1–f4 — 24 клетки · - · -
- К-10 · чисто · вход: сравниваются rc и ПОЛНЫЙ вывод байт-в-байт (stdout+stderr, пустой при rc 0); лишняя строка перед/после/внутри красная — LISHNJAJA-STROKA ловится всеми тремя клетками e1–e3 и атакой по всей батарее · - · -
- К-11 · чисто · вход: ожидания — литералы probe.py в памяти до вызова субъекта, выведенные из честной модели; миры строит батарея, оракул с диска проверяемого не снимается · - · -
- К-12 · чисто · вход: грамматика профиля и слияние слоёв — единственный источник profile_resolver.sh, второго парсера в двери нет; адресная мутация SYROJ-JSON различает этот класс · - · -
- К-13 · н/п · секретов в предмете нет · - · -
- К-14 · чисто · вход: перед каждым предъявлением мутации та же клетка прогнана с честной моделью (контроль KLETKI=13 ZELENYE=13 KRASNYE=0); охранительные отрицательные входы (a6/a6c/a7/a8) соседствуют с положительными (a6b, a1–a5) · - · -
- К-15 · чисто · вход: числа KLETKI/ZELENYE/KRASNYE, MUTACII/SVJAZI/POIMANY/EKVIVALENT/ZHIVYH и составы красных клеток атак — из вывода прогонов батареи Δ1; счёт семьи 994 — из её вывода · - · -
- К-16 · чисто · вход: КЛАСС РИСКА обычный с основанием по закрытому перечню; модель угроз — ЗАЩИЩАЕТ 5 / НЕ ЗАЩИЩАЕТ 4 буллета с ловцами · - · -
- К-17 · н/п · срез не меняет проектную архитектурную модель 188; правится инфраструктурная дверь проводки · - · -

## Дельта

Блоки вердикта v1 закрыты клетками (способ — клетка: новый проверяющий код
батареи; причина отказа от канона/инструмента — предметом уже является
батарея, сравнение с каноном здесь и есть её запуск):

- К-07 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack LF-GRANITSY · 1 · 1
- К-08 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack PODSTROKA-TOKENA · 1 · 1
- К-08 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack REGISTR-TOKENA · 1 · 1
- К-09 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack LF-GRANITSY · 1 · 1
- К-10 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack LISHNJAJA-STROKA · 1 · 1

Доказательство дельты по классу шире примера: каждая обманка критика
воспроизведена адресной мутацией модели по коду (якорь ровно один,
mutated_model отказывает при ≠1), её мутация прогнана и по связанной клетке
(--stabs), и по ВСЕЙ батарее (--attack); честный эквивалент каждой новой
ветки — положительный сосед (a6b/a1–a5 зелёные на мутациях сравнения,
e-семья зелёная на честной модели), и каждая новая клетка прогнана с честной
моделью до предъявления мутанта. Составы красных клеток атак: LF-GRANITSY →
a6-lf-vnutri-tokena, a6c-lf-posle-guarda; PODSTROKA-TOKENA → a7-suffiks-bak,
a6-lf-vnutri-tokena, a6c-lf-posle-guarda (подстрока принимает и LF-двойников
— обе клетки остаются красными на мутанте, что и делает их различающими для
этого класса тоже); REGISTR-TOKENA → a8-registr; LISHNJAJA-STROKA → e1, e2,
e3. Мутации критика strip-relative/strip-dotdot — эквивалентные мутанты с
обоснованием правилом суффикса (перенесены в stabs.tsv с ожиданием
EKVIVALENT, пойманы быть не могут и не считаются живыми).

## Красное-до и приёмка после ремонта

Реальный `--repo .` до реализации обязан дать rc 1 на девяти клетках
четвёртой локации; это историческое предъявление, не машинный ряд, меняющийся
после ремонта. После переноса блока модели implementer та же команда обязана
дать rc 0, KRASNYE=0 — это команда нового CI self-test (приёмка п.8
контракта). Семья 038/994 зелёна до и после (приёмка п.4); полный
check_provodka на 205 красен до CI-строки orchestrator — заявленное
состояние черновика.

## Измерения пачки Δ1

W --repo . (текущая дверь, база не менялась): rc 1, KLETKI=24 ZELENYE=15
KRASNYE=9; красные — a1-gate-profilja, a2-gate-v-defoltsah,
a3-absoljutnyj-token, a4-gate-argv0, a5-gate-py, a6b-chestnyj-sosed (ложное
«guard не подключён»), e1-ne-json, e2-sloj-net, e3-kanon-vne-alfavita (старая
фраза вместо именованного отказа профиля); охранительные a6/a6c/a7/a8 зелёны
и на двери.

W --model: rc 0, KLETKI=24 ZELENYE=24 KRASNYE=0. W --stabs: rc 0,
MUTACII=12 SVJAZI=16 POIMANY=14 EKVIVALENT=2 ZHIVYH=0; честный контроль
исполнен перед каждым предъявлением (KLETKI=13 ZELENYE=13 KRASNYE=0).
Атаки: --attack PODSTROKA-TOKENA rc 1 (красные a7, a6, a6c); --attack
REGISTR-TOKENA rc 1 (a8); --attack LF-GRANITSY rc 1 (a6, a6c); --attack
LISHNJAJA-STROKA rc 1 (e1, e2, e3).

Регресс семьи: bash fixtures/check_provodka/external_ci_994/probe.sh — rc 0
(CASES executed=76 mismatches=0, LEGACY executed=18 mismatches=0).

Живой профиль станции: HARNESS_PROJECT_LAYER_ROOT="$PWD" bash
scripts/profile_resolver.sh --repo "$PWD" — rc 0, sourceCanon не объявлен;
diff модели и scripts/check_provodka.sh базы — ровно вставленный блок
четвёртой локации (37 строк), bash -n модели зелён.

check_sdacha --run на 205: rc 0. check_spec_ready: rc 0; check_ids: rc 0;
check_provodka --grammar: rc 0.

Рефлексия процесса: запись А-NN в NABLIUDENIA_ARCHITECT.md не делалась —
журнал общий и коммитится только в main (арбитраж merge-wip-protiv-main),
эта пачка изолирована на wip-ветке; замеренное трение (вердикт критика не
достижим в архитекторской ветке HEAD, из-за чего двери дельты check_sdacha
требует черри-пика коммита вердикта) передано оркестратору докладом пачки.
