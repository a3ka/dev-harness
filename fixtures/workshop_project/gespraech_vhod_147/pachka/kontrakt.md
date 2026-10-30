# Пачка gespraech-vhod — экран вход-меню Gespräch (GA-01/15/16, D 2.4; контракт 147)

## Воля владельца
- Слово 2026-10-28 ~22:50 UTC: «Реализовать эти экраны со всей динамикой и движениями, которые там заложены»
  (запись docs/owner/2026-10-28-d24-gespraech-final2.md).
- Шаблон 132 v3 (контракт 146, заморожен 146/1): пачка D 2.4 несёт блок dvizhenie; проходимость и второй
  профиль — слова владельца 2026-10-27 (~22:45 и ~23:45 UTC).

## Существующее
- Движок знака — 145 (mobile/src/lib/faden, заморожен 145/3); токены движения — mobile/src/theme/motion-tokens.ts.
- Оболочка — TabShell (999/995): вкладки, fade-оверлей; центральная кнопка «Gespräch» — предмет 147.
- Источники дизайнера — docs/ux/04_Gespraech_D24 (пины sha256 в dvizhenie; сверены с product main).

## Инварианты
- Экраны GA-01, GA-15, GA-16; кадры 6 + 6 (оба профиля, обе темы); переходы T28, T31, T35 — предмет 147;
  T29, T30, T33 — декларация с мок-целями (численная приёмка: 150, 149, 153).
- Меню читается к 300 мс («Sprechen» первым, шаг stagger-tight); знак камешек → вопрос — морф motion-base
  ease-morph; press-long 500 мс → голос (мок GA-34 до 150); «Уменьшить движение» — без полёта.
- Цели касания не меньше 44 pt и вне safe-area; литералы цветов и размеров — только в аудите токенов.

## Приёмочный критерий
- Валидатор 132 v3: python3 .harness147/scripts/ekran_shablon.py --pack mobile/e2e-gespraech-vhod
  --repo . --harness .harness147 — rc 0 (форма, кадры, сверка, проход, движение, отчёт).
- Численная приёмка движения: npm --prefix mobile test -- --ci --runInBand --json --outputFile
  e2e-gespraech-vhod/jest-otchet.json gespraech — rc 0, все тесты зелены, отчёт свеж.

## Зоны и исполнители
ЗОНА architect: contracts/147-gespraech-vhod-menu.md fixtures/workshop_project/gespraech_vhod_147/
ЗОНА implementer: mobile/src/features/conversation/ mobile/src/bootstrap/tab-shell.tsx mobile/src/mocks/
ЗОНА implementer: mobile/.maestro/ mobile/e2e-gespraech-vhod/

## ПРОВОДКА
- guard=fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh

## Модель угроз
- ЗАЩИЩАЕТ: полнота переходов против пиннованного манифеста (∩-правило, все кадры перехода); свежесть
  кадров и отчёта приёмки; длительности токенами, пружины запрещены; цели касания и safe-area; УД.
- НЕ ЗАЩИЩАЕТ: байты Release-эталонов (vision-судьи по SHA256SUMS); «ощущение» движения (владелец);
  живой эмулятор внутри команд e2e/прохода (продуктовый CI экрана).
