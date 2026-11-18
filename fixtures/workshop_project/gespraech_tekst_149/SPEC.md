# SPEC — экран 149 gespraech-tekst-chat (лёгкий трек; что экран добавляет)

Спецификация для implementer. Контракт: `contracts/149-gespraech-tekst-chat.md` (ТРЕК: ЛЁГКИЙ).
Общие свойства экранов (видимость/видимая надпись/зона/действие/достижимость/токен-связь/AVD-канон/маска 48)
судит ОДИН раз набор `fixtures/workshop_project/ekrannyj_nabor_158/` (контракт 158, И-2/И-4);
этот файл несёт ТОЛЬКО экран-уникальное: карта целей, пины, кадры, форма пачки ПОЛНОГО состава, композер, безусловная CI-регистрация (форма А, слово владельца 2026-11-18).

Пачка экрана (эта): `karta.json` (карта целей), `piny.json` (пины: пакет/кадры/токены/маски/AVD/ключи копии), `SPEC.md` (этот файл).
Прежняя полная батарея цикла 2 (probe.py, source.json, osi.md, model/, stubs/, nositeli/, teksty/, produkt/, pachka/, red_gespraech_tekst_149.sh)
остаётся замороженным артефактом закрытого цикла: не воспроизводится, не пересуживается, приёмкой 149 больше не вызывается;
прогоняется набором 158 как регрессия соседа (семья G SPEC 158). НОВЫЕ файлы пачки — karta.json/piny.json/SPEC.md.

## 1. Карта целей (karta.json)

Формат — SPEC набора 158 §4 (ekran/istochnik/profili/sostojanja/tceli). 26 обязательных целей (testID; объединение == pressable-домену 149/1)
× 6 состояний × 2 профиля (390×844, 393×852); пар состояние×цель — 60 на профиль (замер по карте; скриптом, не на глаз):

- `plaschki` (GA-11, вход — начальный, 19 целей): `gespraech-verlauf`, плашки `gespraech-topic-{schaden(+‑speak),auto,umzug,nachwuchs,heirat}(+‑erzaehlen)`,
  `gespraech-vlozhit`, `gespraech-pole`, `gespraech-mikrofon`, оболочка `shell-tab-{start,vorgaenge,schutz,post}` + `gespraech-mitte`;
- `tema-verlauf` (GA-12, вход `gespraech-topic-auto`, 12): Verlauf, чипы `gespraech-chip-{gekauft,geplant}`, `gespraech-lieber-erzaehlen`,
  композер (vlozhit/pole/mikrofon), оболочка; плашки в нём УШЛИ (нет двойного изображения);
- `schreiben-tastatur` (GA-13, вход `gespraech-pole` с черновиком, 5): Verlauf, vlozhit, pole, `gespraech-mikrofon-v-pole`, `gespraech-otpravit`;
  таб-бара НЕТ (под клавиатурой); «Nachricht senden» — только с непустым черновиком;
- `schreiben-temy` (GA-17, вход `gespraech-topic-auto-erzaehlen`, 4): Verlauf, vlozhit, pole, mikrofon; темы-строка над полем со СВОЕЙ темой;
- `foto` (GA-18, вход через меню вложений `gespraech-vlozhit-foto`, 9): Verlauf, композер, оболочка; вложение-фото в Verlauf;
- `dokument` (GA-19, вход `gespraech-vlozhit-dokument`, 11): Verlauf, чипы `gespraech-chip-{vergleichen,nicht}`, композер, оболочка.

Постусловия — в карте (tip: perehod/tema/golos/otpravka/fokus с дословным значением). Ключевая семантика v6 (заморожена, не ослабляется):
чип ответа отправляет СВОЙ ответ — последняя реплика пользователя == ВИДИМОЙ надписи НАЖАТОГО чипа (скрытый/прозрачный Text-потомок надписью
не считается — класс 12 перечня, блокирующая Crit149 v2e), тема разговора == надписи нажатой плашки, отправка композера отправляет ЧЕРНОВИК
(реплика == тексту черновика, поле очищено), erzaehlen открывает письмо со СВОЕЙ темой, голос-цели — мок (норма 28.10).
Кнопки меню вложений (`gespraech-vlozhit-foto/-dokument`) — цели-транзиты: обязательны как входы состояний foto/dokument, судятся достижимостью.
ТестID существующих элементов переиспользуются (`shell-tab-*`, `gespraech-mitte` — слоты 148), новых — `gespraech-*`.

## 2. Пины (piny.json; ЕДИНЫЙ источник значений)

Пакет D24-Kompakt-1.1 (Complior-mob `docs/ux/05_Kompakt_D24`, коммит 9610dc4): sha256 пяти метафайлов и 24 кадров — в piny.json
(сняты живьём этой пачкой, сверены с frames/SHA256SUMS 24/24 и прямыми байтами). Токены (продукт читает через `mobile/src/theme/` —
владелец файла 148; литерал числа вместо чтения токена — нарушение, связь, а не совпадение):
touch-target.min 44px; typography.body 15/21; nav.height 49px; nav.item.min-height 48px; nav.label 10/12;
motion-fast 150ms; motion-base 250ms; motion-stagger-tight 30ms; motion-morph 450ms; ease-morph cubic-bezier(0.32,0.72,0,1);
ease-standard cubic-bezier(0.2,0.7,0.2,1); press-long 500ms; p-chatcomp-field 10px 14px / radius 22px; p-topic min-height 96px (is-compact 44px).
Композер: потолок поля — токен `calc(6 * 21px)` (=126px при lineHeight 21px): поле растёт до ШЕСТИ строк и ПРОКРУЧИВАЕТСЯ («Помещается всегда»,
CHANGELOG D 2.4); «Nachricht senden» (action.F05.A01) видна только с непустым черновиком (GA-13 есть / GA-11 нет); с черновиком голос — В ПОЛЕ
(GA-13), без — primary-микрофон композера. Зоны hw/hh — manifest.json пакета (сводка в piny.json.zony_dizajna_hw_hh; живой замер: 120 записей,
под 44 pt — 0). Надписи — ключи copy-de.json (piny.json.kopija_kljuchi). Движение (только из токенов, судится юнит-сьютом на фейк-часах):
T30 непрозрачный фон закрывает меню ДО построения чата (нет двойного изображения), морф пилюля→поле — motion-morph ease-morph, темы-строка
после поля; T32 вопрос агента РАНЬШЕ чипов, чипы и «Lieber erzählen?» — один элемент/событие; T37 (мок from-состояния GA-33, живая Leiste — 150)
морф Leiste→поле; УД: видимое ≤ motion-fast, перемещение/морф 0.

## 3. Эталонные кадры и пачка в продукте

`mobile/e2e-gespraech-tekst/` — РОВНО 10 файлов ПОЛНОГО состава (форма А, слово владельца 2026-11-18; образец — кандидат `4205358b45` / mob#166): `e2e.sh`, `ekran.json`, `kadry.json` (профиль 390, 12 записей), `kadry-393.json` (профиль 393, 12 записей), `kontrakt.md`, `katalog_kopii.json`, `spec_api.json`, `dvizhenie.mjs`, `prokhod.sh`, `batareja/red_ekrana.sh`. Кадровая пара называется ТОЧНО так — `kadry.json` + `kadry-393.json`, НЕ `kadry_profil.json` (замороженное имя 149-кандидата; переименование не делается). Грамматику файлов пачки судит НЕИЗМЕННЫЙ валидатор 132 v3 пина sha256 `5fd1415e…` (замер кандидата: статика зелена, живое исполнение — работник CI); прежняя трёхфайловая форма v4 и «минимальный ekran.json» — сняты (раздел «Снятие замороженных норм» контракта).

- Пиксельная сверка — ВСЕ 24 кадра зоны: GA-11/12/18/19 (normal) и GA-13/17 (keyboard) × {light,dark} × {390×844,393×852};
  имена == записи frames/frames.json пакета; пины sha256 == piny.json.kadry.sha256 == frames/SHA256SUMS;
  подмена кадра ДРУГИМ кадром того же пакета ловится именем записи (класс 5 перечня).
- Маски сравнения: профиль 390 → chrome_verh_pt 36; профиль 393 → 48; кадры GA-13/GA-17 дополнительно несут маску зоны системной клавиатуры
  [0, 500, <ширина>, низ] — платформа, «принимается по видео»; собственные пиксели приложения вне зоны судятся.
- `e2e.sh` — AVD-канон набора 158 (И-4) и пины piny.json.avd: последовательный жизненный цикл, кадры 390 на эмуляторе работника (порт 5580),
  остановка 390 с ПОДТВЕРЖДЕНИЕМ ухода (adb devices) до запуска 393 (порт 5582), не более двух живых AVD; клавиатура — inputText в поле.
- Живая сверка против настоящих скриншотов — продуктовый работник e2e-gespraech-tekst по лекалу 143/2 (раннер 123 из H-пина, порог 0.600),
  БЕЗУСЛОВНО в PR экрана (§5); живые прогоны e2e.sh на R ветки экрана — оркестратор (норма 146+: диагностический прогон до freeze).

## 4. Юнит-тесты экрана (jest; продукт)

Сьюты в `mobile/src/features/conversation/__tests__/` (gespraech-tekst*.test.tsx — заголовки без `ident(цифра)`, урок 145 v4).
Команда приёмки: `cd mobile && npx jest src/features/conversation` → rc 0. Сьют судит по карте (обе ширины 390/393):

- полнота: все 26 целей карты в своих состояниях; отсутствующая/выключенная цель — падение; каждое состояние достигается СВОИМ входом;
- видимость: хозяин нажатия и его надпись видимы (opacity 0 узла/предка, прозрачный фон+надпись, нулевой бокс, display:none, за клипом — падение);
  надпись-оракул ответа — ТОЛЬКО видимый Text (класс 12: скрытый Text с ожидаемой строкой — падение);
- зона: эффективная зона ИНТЕРАКТИВНОГО хозяина ≥ 44 (width/height, min*, hitSlop, padding, flexBasis — все допустимые способы зелены);
- действие: изолированный колбэк/свежий счётчик на КАЖДУЮ цель, постусловие специфично цели (gekauft ≠ geplant; vergleichen ≠ nicht;
  тема — своей плашки; отправка — черновика; vlozhit — меню; erzaehlen — письмо со своей темой; чужой ответ при нажатии — падение);
- различимость: плашки уходят при теме (нет двойного изображения); otpravit/mikrofon-v-pole — только в schreiben-tastatur;
  «Nachricht senden» — только с черновиком; таб-бар отсутствует в клавиатурных состояниях;
- композер: потолок шести строк из токена (calc(6×lineHeight)) и прокрутка при превышении; высота следует за ПОДМЕНЁННЫМ значением токена
  (21px→23px в одноразовой копии) — связь, не совпадение числа; пробы 108 не трогаются (правка роста/кнопок, не поверхности);
- токен-связь: подмена значения токена в одноразовой копии меняет поведение (потолок поля, зона, высота навигации);
- движение: план из токенов, порядок T30/T32/T37 (§2), чипы одним событием, УД-правила — на фейк-часах (допуск такта 1 мс).

Матрица мутантов и обманные заглушки экрана НЕ заводятся (норма лёгкого трека): красное предъявление экрана — набор 158
(негативные образцы на живом референсе по классам 1–13), не экранная батарея.

## 5. CI-регистрация (БЕЗУСЛОВНАЯ; форма А — слово владельца 2026-11-18, вслед за 147 v5/148 v5)

Пишет implementer ОДНИМ PR экрана (append-only, чужие записи/тела/порядок не меняются), форма судится клетками
`fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py` (прецедент red_ci_147.py):

1. запись `mobile/ci-screens.json`: id `gespraech-tekst`, kontrakty [`149`], status `in-development` (→ `approved` по принятой поставке),
   job `e2e-gespraech-tekst`, pack `mobile/e2e-gespraech-tekst/`, flows [`mobile/.maestro/gespraech-tekst.yaml`,
   `mobile/.maestro/gespraech-tekst-393.yaml`], child_flows [`mobile/.maestro/gespraech-tekst-prokhod.yaml`],
   puti ⊇ {`mobile/src/features/conversation/`, `mobile/src/ui/conversation-composer/`, `mobile/src/mocks/`,
   `mobile/e2e-gespraech-tekst/`}, h_checkout [`.harness149`], output_namespace `mobile/maestro-out-gespraech-tekst`;
2. выход выбора `e2e-gespraech-tekst: ${{ steps.vybor.outputs.e2e-gespraech-tekst }}` в job `select-screens`;
3. имя работника в needs ОБОИХ агрегатов лекала 143/2 (`android-e2e`, `mobile-regression-signal`).

Работник `e2e-gespraech-tekst` — инстанциация лекала 143/2 по образцу кандидата `4205358b45` (дословное тело — MODEL_YML
red_ci_149.py): needs [select-screens, build-apk], if по выходу выбора, APK по имени артефакта сборки с digest-сверкой до
установки, H-checkout a3ka/dev-harness @ `d01c9414ef792ea1382750c825759ab51a418ff4` → `.harness149` (валидатор sha256
`5fd1415e…`), свой AVD порт 5580, setup-node+npm ci (стадия dvizhenie исполняет продуктовый jest — дефект mob#166 закрыт),
run_priemka → `python3 .harness149/scripts/ekran_shablon.py --pack 'mobile/e2e-gespraech-tekst/' --repo . --harness '.harness149'`,
артефакты `maestro-gespraech-tekst-*` с `if-no-files-found: error`, retention 14. Форма: `python3
fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py --repo <R>` → rc 0 REGISTRACIJA_OK; любое отличие от модели —
именованный rc 1; на product main без пачки — rc 1 PACHKA_NEPOLNAJA (честно красная до реализации).

Предпосылка «лёгкий режим валидатора» v4 СНЯТА (слово владельца 2026-11-18): полный состав пачки совместим с неизменным
валидатором, вечно-красный job невозможен; вариант В — отдельный предмет с номером от владельца. `mobile/.maestro/`:
свои флоу + строки исключения config.yaml (прецедент 138). Landing 149 — ПОСЛЕ 148 и 147 (последний из трёх; рестарт на
rebase, конфликт — исполнителя).

## 6. Критерии готовности (сводка; полные rc-команды — контракт §Приёмочный критерий)

1. `bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo <R> --ekran 149` → rc 0 (по готовности
   референсов 158/159; до того — именованный rc 2, не зелень);
2. `cd mobile && npx jest src/features/conversation` → rc 0;
3. пачка mobile/e2e-gespraech-tekst/ — РОВНО 10 файлов полного состава с кадровой парой kadry.json + kadry-393.json;
   имена/пины/маски == piny.json; AVD-канон == piny.json.avd;
4. CI: регистрация БЕЗУСЛОВНА в PR экрана — запись карты + работник по лекалу 143/2 + output выбора + needs агрегатов;
   `python3 fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py --repo <R>` → rc 0 (зелёные пробы: `--model`, `--stabs`);
5. суд: ОДИН круг критика (быстрый процесс) + ревьюер.

Материал: прежняя реализация PR Complior-mob #148 (ветка wip/149/implementer, 21 файл: chat-host/chat-machine/chat-kopija, композер 175 строк
правок, jest-сьют 198 строк, мок, маестро-флоу, e2e) — разрешено брать код; сверь с картой/пинами: чипы GA-19 отправляют СВОЙ ответ
(«Erst mal nicht» ≠ «Ja, vergleichen»), голос в поле GA-13, потолок шести строк из токена, видимость целей и надписей (класс 12/13),
темы-строка GA-17 со своей темой, последовательный AVD.
