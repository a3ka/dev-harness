# Пачка gespraech-tekst — текст-чат Gespräch (GA-11/12/13/17/18/19, D 2.4; контракт 149)

## Воля владельца
- Слово 2026-10-28 ~22:50 UTC: «Реализовать эти экраны со всей динамикой и движениями, которые там
  заложены» (docs/owner/2026-10-28-d24-gespraech-final2.md).
- Шаблон 132 v3 (146): пачка несёт dvizhenie; проходимость и второй профиль — слова 2026-10-27.
- Пилот на тестовых данных (норма 28.10): голос-цели — мок-хосты до 150/151.

## Существующее
- Знак — 145 (lib/faden); токены — theme/motion-tokens. Вход-меню — 147; вкладки — 148.
- Композер — ui/conversation-composer (слайс-1): по CHANGELOG D 2.4 поле до шести строк + прокрутка,
  микрофон primary, кнопка голоса в поле — правка этого контракта.
- Источники дизайнера — docs/ux/04_Gespraech_D24 (пины sha256 в dvizhenie; сверены с product main).

## Инварианты
- Экраны GA-11, GA-12, GA-13, GA-17, GA-18, GA-19; кадры 12 + 12 (оба профиля, обе темы; GA-13/17 —
  клавиатурные: зона системной клавиатуры маскируется, платформа — по видео); переходы T30, T32, T37 —
  предмет 149 (T37 на моке GA-33); T34/T08/T17/T18/T19/R2/R2-393 — декларация (∩-правило; численно
  150/151).
- T30: непрозрачный фон закрывает меню ДО построения чата; морф пилюля→поле 450 ease-morph; темы-строка
  над полем с 450. T32: вопрос Complior первым, чипы и «Lieber erzählen?» вместе. Поле растёт до шести
  строк и прокручивается.
- Цели касания ≥ 44 pt, вне safe-area; литералы цветов/размеров — только в аудите токенов.

## Приёмочный критерий
- Валидатор 132 v3: python3 .harness149/scripts/ekran_shablon.py --pack mobile/e2e-gespraech-tekst
  --repo . --harness .harness149 — rc 0 (форма, кадры, сверка, проход, движение, отчёт).
- Численная приёмка: npm --prefix mobile test -- --ci --runInBand --json --outputFile
  e2e-gespraech-tekst/jest-otchet.json gespraech — rc 0, все тесты зелены, отчёт свеж.

## Зоны и исполнители
ЗОНА architect: contracts/149-gespraech-tekst-chat.md fixtures/workshop_project/gespraech_tekst_149/
ЗОНА implementer: mobile/src/features/conversation/ mobile/src/ui/conversation-composer/ mobile/src/mocks/
ЗОНА implementer: mobile/.maestro/ mobile/e2e-gespraech-tekst/

## ПРОВОДКА
- guard=fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh

## Модель угроз
- ЗАЩИЩАЕТ: полнота переходов против пиннованного манифеста (∩-правило); свежесть кадров и отчёта;
  длительности токенами, пружины запрещены; цели касания и safe-area; УД; потолок поля и прокрутку.
- НЕ ЗАЩИЩАЕТ: байты Release-эталонов (vision по SHA256SUMS); системную клавиатуру GA-13/17 (по видео,
  зона маскирована); «ощущение» (владелец); живой эмулятор в e2e/проходе (продуктовый CI экрана).
