# Пачка gespraech-tekst — текст-чат Gespräch (D 2.4 · Kompakt-1.1; контракт 149)

## Воля владельца
- Слово 2026-10-28: «Реализовать эти экраны со всей динамикой и движениями»
  (docs/owner/2026-10-28-d24-gespraech-final2.md).
- Шаблон 132 v3 (146): пачка несёт dvizhenie; проходимость и второй профиль — слова 2026-10-27.
- Пилот на тестовых данных: голос-цели — мок-хосты до 150/151.
- Слово 2026-11-02: v+1 — пакет D24-Kompakt-1.1 (ЗАМЕНЯЕТ 1.0): версия, токены, кадры; зоны — hw/hh.

## Существующее
- Знак — 145 (lib/faden); токены — theme/motion-tokens. Вход-меню — 147; вкладки — 148.
- Композер — ui/conversation-composer (слайс-1): поле до шести строк + прокрутка, микрофон primary,
  кнопка голоса в поле (CHANGELOG D 2.4) — правка этого контракта.
- Движение — docs/ux/04_Gespraech_D24 (финал 2; пакет 1.1 движение не меняет); кадры/токены/зоны —
  пакет docs/ux/05_Kompakt_D24 (имена кадров frames.json, sha frames/SHA256SUMS; hw/hh манифеста).

## Инварианты
- Экраны GA-11, GA-12, GA-13, GA-17, GA-18, GA-19; кадры 12 + 12 (имена пакета 1.1: GA-11/12/18/19
  normal, GA-13/17 keyboard × light/dark × профиль; клавиатурная зона маскируется — по видео);
  переходы T30, T32, T37 — предмет 149 (T37 на моке GA-33); T34/T08/T17/T18/T19/R2/R2-393 —
  декларация (∩-правило; численно 150/151).
- T30: непрозрачный фон закрывает меню ДО чата; морф пилюля→поле 450 ease-morph; темы-строка над
  полем с 450. T32: вопрос Complior первым, чипы и «Lieber erzählen?» вместе. Поле — до шести строк
  и прокрутка.
- Цели касания — зона нажатия hw/hh ≥ 44 (видимая рамка меньше — не находка; реализация — настоящая
  hit-area), вне safe-area; литералы — только в аудите токенов.

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
- ЗАЩИЩАЕТ: полнота переходов (∩-правило); свежесть кадров и отчёта; длительности токенами, пружины
  запрещены; цели касания (зоны hw/hh) и safe-area; УД; потолок поля.
- НЕ ЗАЩИЩАЕТ: байты Release-эталонов (vision); клавиатуру GA-13/17 (по видео, зона маскирована);
  «ощущение» (владелец); живой эмулятор в e2e/проходе (продуктовый CI экрана).
