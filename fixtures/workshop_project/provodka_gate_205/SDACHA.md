# СДАЧА 205 Δ2 — адресные стабы всех мутаций критика

Предмет не расширен: четвёртая локация подключения guard — эффективный
`sourceCanon.gate` через настоящий `scripts/profile_resolver.sh`. Модель,
реальная дверь и 24 клетки Δ1 не менялись. Исправлен К-01 Crit205V2:
мутация, уже пойманная клеткой, всё равно получает отдельный исполняемый
стаб. Все привязки и замены живут в stabs.tsv/probe.py, не в контракте.

Текущая дельта: `archive/205/critic-v2-fail-add44016fb:verdicts/critic/contracts-205-v2.md`.
Вердикты v1/v2 прочитаны через git show; v2 доступен в архивной ветке, но не
в HEAD кандидата. Машинная ссылка на предыдущий вердикт снята: вердикты
вызовов 1–3 лежат в истории (FAIL v1 `8a3594320`, FAIL v2
`archive/205/critic-v2-fail-add44016fb`), accept вызова 3/4 ляжет под именем
двери freeze `verdicts/critic/contracts-205-v1.md`; дельта К-01 вызова 2
покрыта стабами и таблицей мутаций листа (числа ниже не менялись).

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
- потолки · bash scripts/check_ceilings.sh . · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/205-provodka-gate-profilja.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/205-provodka-gate-profilja.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: К-01 v2 закрыт запуском всех зарегистрированных мутаций через --stabs; ни одна мутация не оставлена только упоминанием в листе; команды формы перечислены выше · - · -
- К-02 · чисто · вход: задание 205 Δ2, только мутации/лист и счёт приёмки; И1–И7, модель и состав 24 клеток не менялись · - · -
- К-03 · чисто · вход: frozen 038/191/994, неизменённые фразы/порядок/--grammar и регресс семьи 994 · - · -
- К-04 · чисто · вход: изменены только fixtures/workshop_project/provodka_gate_205/ и число в приёмке 205; дверь scripts/check_provodka.sh не правилась · - · -
- К-05 · чисто · вход: строки приёмки — rc-команды; привязки мутаций к клеткам — stabs.tsv и probe.py · - · -
- К-06 · чисто · вход: отсутствие субъекта, таймаут и пустая выборка — rc 2 NOT_IMPLEMENTED; неожиданный результат мутанта не считается поимкой даже при расхождении с честным результатом · - · -
- К-07 · чисто · вход: неизменённая модель сохраняет границы argv через jq -j и read -d ''; LF-GRANITSY остаётся адресным стабом · - · -
- К-08 · чисто · вход: --stabs исполняет MUTACII=21 SVJAZI=27 POIMANY=25 EKVIVALENT=2 ZHIVYH=0; якорь каждой замены имеет ровно одно вхождение в коде модели · - · -
- К-09 · чисто · вход: 24 клетки a1–a8 с a6b/a6c, b1–b3, c1–c3, d1, e1–e3, f1–f4; четыре обязательные мутации v1 и ранее не исполненное отсутствие guard воспроизводятся по настоящим якорям модели · - · -
- К-10 · чисто · вход: rc и полный вывод сравниваются без strip/splitlines; LISHNJAJA-STROKA, STRIP-VYVODA, DIE-ECHO, STDOUT-STDERR-RAZDEL и LF-V-KONCE различают лишний текст, пробельный префикс, продолжение после отказа, оба потока и последний LF · - · -
- К-11 · чисто · вход: honest_expected и mutant_expected сняты в память до invoke; диск субъекта после вызова оракулом не служит · - · -
- К-12 · чисто · вход: настоящий profile_resolver.sh; SYROJ-JSON продолжает различать второй парсер; jq-ошибки ожидаются литерально по наблюдённому выводу реального jq, не фабрикуются двойником · - · -
- К-13 · н/п · секретов в предмете нет · - · -
- К-14 · чисто · вход: перед каждой связью --stabs заново прогоняет её клетку честной моделью; HONEST_CONTROLS=27 ZELENYE=27 KRASNYE=0; strip-relative/strip-dotdot остаются честными эквивалентами суффиксного правила · - · -
- К-15 · чисто · вход: числа из прогонов; независимый счёт POIMAN/EKVIVALENT — cut -f3 stabs.tsv | sort | uniq -c; перечень имён — cut -f1 stabs.tsv | sort -u · - · -
- К-16 · чисто · вход: риск обычный, предмет и граница модели угроз не менялись · - · -
- К-17 · н/п · инфраструктурный предмет, проектная архитектурная модель 188 не меняется · - · -

## Дельта

- К-01 · канон/инструмент · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --stabs · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack LF-GRANITSY · 1 · 1
- К-08 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack PODSTROKA-TOKENA · 1 · 1
- К-08 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack REGISTR-TOKENA · 1 · 1
- К-09 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack LF-GRANITSY · 1 · 1
- К-10 · клетка · bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --attack LISHNJAJA-STROKA · 1 · 1

К-01 закрыт существующим инструментом адресных замен на существующих клетках,
без нового барьера и без смены обязательств. ANY-FIELD расширяет чтение с
элементов gate на строковые значения полей канона; IGNORE-ERRORS отключает
ветвь отказа резолвера; GATE-FIRST учитывает только gate[0]; OMIT-SUFFIX
отключает суффиксное правило. GATE-FIRST семантически совпадает с прежним
ARGV0, но не с честной моделью: это отдельный исполняемый POIMAN-стаб под
именем критика, а не новый класс дефекта и не основание требовать ложный
EKVIVALENT на различающем входе.

OTSUTSTVIE-GUARD использует реальный якорь существования guard-файла:
попытка критика v1 имела ноль вхождений; нынешняя замена исполняется и
отличается от честного контроля. STRIP-VYVODA выдаёт пробел и LF перед
диагностикой: strip()-сверка ошибочно приняла бы такой выход, точная — нет.
Старое want_line in output.splitlines() также пропускало этот выход и
LISHNJAJA-STROKA; проверяющий код обратно на strip/принадлежность не менялся.
DIE-ECHO заменяет вызов die на echo без завершения — это именно изменение
управления, а не утверждение об эквивалентности способов печати.
STDOUT-STDERR-RAZDEL выдаёт разные строки stdout-first/stderr-second в два
потока; сборка probe наблюдается целиком. LF-V-KONCE отдельно убирает LF из
die (printf '%s' вместо printf '%s\n'): честная модель уже добавляет этот
байт, поэтому отдельного «добавить ещё не существовавший LF» здесь нет.

STRIP-RELATIVE и STRIP-DOTDOT остаются EKVIVALENT: токены ./<guard> и
../<guard> уже оканчиваются на /<guard>, и неизменённое правило И1 принимает
их независимо от равенства. Эти мутации исполняются, но не считаются
пойманными или живыми. Остальные новые мутации имеют различимый результат;
отличие от честной модели и точный mutant_expected проверяются раздельно.

Новый предикат зачёта --stabs требует точного результата мутанта, а не
произвольной красноты: ожидания выведены из первого живого предъявления,
записаны литералами/фразами и вычисляются до вызова. Полный вывод в CELL и
STAB сохраняет пробелы и LF, в том числе отсутствие завершающего LF.
Контроль нового предиката на настоящем субъекте: добавка unexpected\n к
STRIP-VYVODA даёт rc 1, exact=false, POIMANY=0, ZHIVYH=1; эквивалентная
печать пробельной строки через printf '%s\n' ' ' остаётся rc 0,
exact=true, POIMANY=1, ZHIVYH=0. Одноразовая проба после прогона удалена.
Для прежних К-07/08/09/10 сохраняется способ «клетка» Δ1: предметом уже была
батарея, её канон — запуск на настоящей модели; все новые тогда клетки
имеют честные положительные соседние входы и адресные мутации.

## Измерения

W = bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh.
W --model: rc 0, KLETKI=24 ZELENYE=24 KRASNYE=0.
W --repo .: rc 1, KLETKI=24 ZELENYE=15 KRASNYE=9 (дверь не менялась).
W --stabs: rc 0, MUTACII=21 SVJAZI=27 POIMANY=25 EKVIVALENT=2 ZHIVYH=0;
HONEST_CONTROLS=27 ZELENYE=27 KRASNYE=0, все exact=true.

Прежние четыре --attack: каждый rc 1; PODSTROKA-TOKENA краснит a6/a6c/a7,
REGISTR-TOKENA — a8, LF-GRANITSY — a6/a6c, LISHNJAJA-STROKA — e1/e2/e3.
Семья 994: rc 0, CASES executed=76 mismatches=0,
LEGACY executed=18 mismatches=0.

pre_critic, check_sdacha --run, check_spec_ready, check_ids, check_ceilings,
check_provodka --grammar, check_precision_gate, check_threat_model: rc 0.
Полный check_provodka до подключения CI остаётся заявленно красным;
послеремонтная приёмка implementer и CI-команда п.8 контракта не менялись.

Рефлексия: ошибка процесса уже названа К-01 — выполненная мутация не была
перенесена в реестр стабов. Закрыта исполняемыми записями; новых процессных
находок сверх неё не заявлено. Общий NABLIUDENIA_ARCHITECT.md пишется только
в main, вне зоны этой изолированной пачки, и здесь не изменялся.
