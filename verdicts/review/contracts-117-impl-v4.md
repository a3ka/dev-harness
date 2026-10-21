accept
OBJECT=7e10a3762723322a5483567e86955953a4c58804

Суд Rev117v3 (reviewer), круг 2 по кадрам. Предмет — 117 v2 «Splash + иконка по макету D2.2.5.1»
(Complior-mob#114, `cmp-mob-117/vkhod` @ OBJECT). Контракт — `frozen/contracts/117/2`. Разделы (1)(2)(3) и
реслоп. Находки в формате reslop: `/tmp/dev-harness-verify/Rev117v3/.review/2026-10-21-01.md` (status: ready).
Блокирующих находок нет. Все изображения я смотрел сам (`read` PNG), а затем мерил своими скриптами
(`canon_cmp.py`, `sign_cmp.py`, `frame_cmp.py`) на одноразовой копии `Rev117v3/mob`.

## (1) Б-1/Б-2 закрыты
- Иконка и производные (icon, android-icon-foreground, android-icon-monochrome, favicon): верхний конец дуги
  круглый, как в каноне. Пиксели, которые есть только у круглого конца: 3369/3369, 2253/2253, 2253/2253, 14/14.
  Красный контроль на 7a976e2: 0/3369, 5/2253, 5/2253, 0/14. Согласие с круглым каноном 0.9996–0.9997
  (favicon 0.9964). Фон adaptive (`android-icon-background.png`) в OBJECT не менялся.
- Знак нативного splash `splash-sign-{dark,light}.png`: IoU с кропом артборда 0.985 / 0.982 (было 0.935 / 0.937).
  Профиль верхнего конца совпадает с артбордом до ±1 px.
- Монохром с точкой #d6f75a: контракт v2 и канон это НЕ нарушают. Инв. 1/3 требуют производную исходника,
  `raster_117.mono_ink` #ffffff задан только для дуги. Отдано владельцу вопросом В-2 реслопа, за него не решаю.

## (2) Кадры эмулятора против макетов — расхождений нет
| Кадр | Скриншот эмулятора | Макет | Мой замер |
| --- | --- | --- | --- |
| Splash dark | `/tmp/dev-harness-verify/J117b/frames/dark/2026-10-21_214551/117 — splash + First-Run после снятия оверлея (схема устройства)/takeScreenshot/vkhod-117-splash.png` | `/tmp/dev-harness-verify/Impl117/mob/docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/Splash.png` | фон #0a0a0a; IoU знака 0.994, wordmark 0.921, tagline 0.953; лучший сдвиг dx=0 dy=0 (поиск ±12 px); точка #d6f75a; отличается 0.27 % кадра |
| Splash light | `/tmp/dev-harness-verify/J117b/frames/light/2026-10-21_214608/117 — splash + First-Run после снятия оверлея (схема устройства)/takeScreenshot/vkhod-117-splash.png` | `…/screens/Splash-Hell.png` | фон #f3f2ee; IoU 0.994 / 0.925 / 0.947; dx=0 dy=0; точка #d6f75a; 0.26 % |

На кадрах есть знак, wordmark «complior» и tagline «Versicherung. Erledigt.», тема своя, чужого экрана нет.
Статус-бар контрастен ground (оговорено инв. 6). Мягкость глифов — следствие литерала 390×844 (инв. 4б), это
не FAIL (В-3). Мера 123 (`sverka-123.tsv`: Splash dark 0.783 OK, Splash light 0.782 OK, порог 0.600) моему
замеру не противоречит.

## (3) Реализация против контракта v2
- Область правки: `git diff --stat 4569c3f HEAD` (main, влитый в ветку) показывает 13 файлов, все в ЗОНЕ
  implementer. Сам OBJECT трогает 6 PNG: icon, adaptive fg/mono, favicon, splash-sign ×2. Тесты и фикстуры
  не тронуты.
- `git diff --exit-code --stat 8748a7a3352c… HEAD -- mobile/src/features/auth/` → rc_auth=0, вывод пуст.
- Батарея 117 из H HEAD (последняя правка vkhod_117 — a110ccd96, автор architect; implementer не автор ни
  одного коммита батареи) на моей копии OBJECT: `vkhod_static_probe.py` → `static 40/40` rc=0,
  `vkhod_probe.py` → `behavioral 26/26` rc=0. После проб `git status --short --untracked-files=all` показывает
  только `?? mobile/node_modules` (симлинк инфраструктуры). Первый запуск static был rc=1 с RED
  SPLASH_FRAME_SVERKA_123_*: в моём экспорте H не было `mob_sverka_123/`. После экспорта стало 40/40.
- app.json соответствует инв. 1/2 (icon.png, adaptive #0A0A0A, ios.icon снят, корень светлый + dark,
  imageWidth 181, contain, automatic). pilot-app.tsx и Maestro после прошлого круга не менялись.
- Б-3: тег `frozen/contracts/123/2` = c20e8663. Байты `scripts/sverka_maketa.py` и
  `fixtures/workshop_project/mob_sverka_123/` на пине e79c1069 совпадают с тегом (diff rc0, пусто). Остаток —
  совет С-1 перепинить на тег.
- Атомарность: OBJECT — один коммит одной задачи (Б-1/Б-2), со ссылкой на 117. Нормативные документы не тронуты.

## Паразитная сложность (050)
- Семья из 6 PNG OBJECT. (1) Инв. 1/2/3: растр канона, знак артборда. (2) Состояния нет. (3) Меняются те же
  6 файлов, число не выросло. (4) Интерфейса нет. (5) Потребители: ICON_RASTER_WHOLE, ADAPTIVE_*_RASTER,
  FAVICON_RASTER_WHOLE, SPLASH_SIGN_RASTER_*, SPLASH_NATIVE_GENERATED_*. **ESSENTIAL**. Других новых
  артефактов OBJECT не вводит.

## Находки (все не блок, подробно в реслопе)
С-1 перепин `.harness123` на коммит тега; В-1 ПЕРЕСЕЧЕНИЕ шагов 123 (оркестратор/арбитр, перенесено);
С-2 устаревший комментарий mobile.yml; В-2 цветная точка монохрома (владельцу); В-3 мягкость глифов
(владельцу); В-4 сентинел темы против «явный провайдер сохраняет приоритет» (владельцу, вопрос №4 контракта);
С-3 пробел меры butt-cap (архитектору, Н-39).

NOT_RUN: первый красный прогон android-e2e (6/6 maestro) — артефактов `maestro-117-*` этого прогона на диске
нет, сеть запрещена. Судил только перезапуск 39678745649 (SUCCESS dark/light).
