# 118 — Erstinformation (экран по шаблону 132)
КЛАСС ЗАДАЧИ: КОДОВЫЙ. id/CONTRACT/118; до V-2.
КОНТЕКСТ: docs/owner/2026-10-20-mob-po-maketu.md §Б,В: demo → Erstinformation → Start; кадры по PNG.

## Воля владельца
F03 (135) → Erstinformation (118) → Start; themes dark/light.
## Существующее
107/erstinfo_107: gate/ack/version, F02.03/05/08 route остаются.
123: scripts/sverka_maketa.py; frozen 132/1: форма, кадры, зоны.
117/2 Г0: pilot-app.tsx вне зоны. PNG: mob docs/ux/03_Mobility_Slice1/screens/F02.*.
## Предмет и граница
Пачка mobile/e2e-erstinformation/, UI F02.03/F02.08; F02.05 у 107.
16 кадров: F02.03-V01 MISSING, V02 OUTDATED (full+V0); F02.08-V01…V04
CHECKING/PENDING/CURRENT_CONFIRMED/FAILED; dark/light для каждого.
Copy/review_status: BrokerOS_UI_Copy_DE.json; API: getDisclosureGate.
## Инварианты
1. ekran.json: 17 полей 132, ekran=erstinformation; 16 кадров, PNG sha из source.json.
2. zamenjaet=null: живого манифеста этого экрана нет; ne_trogaet — обе чужие пачки 132.
3. Цвет/размер — лишь в docs/ux/03_Mobility_Slice1/ds/tokens.css, не пачке.
4. demo → F02.03 → F02.08 → Start лишь по gate 107; null/stale блокирует.
5. Android e2e: transition и assertVisible СВОЕГО testID перед каждым takeScreenshot;
   свежие кадры двух тем не byte-copy PNG; каждый score 123 ≥ 0.600.

## Приёмочный критерий
W = bash fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh.
Нет scripts/ekran_shablon.py: W → rc 1 SHABLON_ABSENT, 17 CASE KRASNO.
Эталон 132: W --model → rc 0, 17 CASE ok; 16 честных KADR score 1.000.
11 стабов: W --stabs → rc 0, 17 CASE ok; 14 STAB KRASEN, SVJAZI 14.
Продукт C: W → rc 0; mobile.yml android-e2e rc 0; на ТЕХ ЖЕ свежих кадрах
123 и побайтово пинованная проверка происхождения → rc 0; нарушение → rc 1.

## Зоны и исполнители
ЗОНА architect: contracts/118-erstinformation.md fixtures/workshop_project/erstinformation_118/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА implementer: mobile/src/features/onboarding/ mobile/src/app/ mobile/.maestro/
ЗОНА implementer: mobile/e2e-erstinformation/ .github/workflows/mobile.yml
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/features/onboarding/ — 107 UI 107, gate остаётся.
ПЕРЕСЕЧЕНИЕ implementer: mobile/src/app/ — 107 route Erstinformation, без чужих экранов.
ПЕРЕСЕЧЕНИЕ implementer: mobile/.maestro/ — 107 новый flow, старый остаётся.
ПЕРЕСЕЧЕНИЕ implementer: mobile/.maestro/ — 117 новый flow, старый остаётся.
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 107 шаги 107 сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 117 шаги 117 сохраняются.
ПРЕДПОСЫЛКИ:
- setting CI: Android emulator, Maestro, H-checkout, пробы 107/117; новых secrets нет.

## ПРОВОДКА
ПРОВОДКА:
- guard=fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh
ПРОВОДКА-ЭНФОРСМЕНТ: CI --stabs до ленда 132, затем W; mob CI: e2e+123+H-check.

## Модель угроз
ЗАЩИЩАЕТ:
- stale/чужой/низкий кадр, literal, замену, объём; переход/testID и byte-copy PNG.
НЕ ЗАЩИЩАЕТ:
- перекодированный replay; ловец — Maestro и кадры эмулятора CI.

## Незаполненные требования:
нет
