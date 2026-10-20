FAIL
OBJECT=7a870044f4d041c8b8f88a40cfad338572c61775

Блокирующий обход: настоящий маршрут `mobile/src/app/(tabs)/[section].tsx` всегда создаёт `<StartSectionHost reducedMotion={false} />`. Хотя `TabShell` читает `AccessibilityInfo.isReduceMotionEnabled()`, созданный React element уже несёт неизменяемый false; системная настройка не достигает `StartScreen`. Свидетель RNTL на настоящем `TabRoute` зелёный только потому, что наблюдает дефект: rc=0, `route hard-codes reducedMotion=false for StartScreen`. Обычные пробы 108 также зелёные: static 22/22 rc=0, behavior 324/324 rc=0, static matrix 5/0 rc=0, behavior matrix 39/0 rc=0. Подробный вердикт: `h/verdicts/adversary/contracts-108-krug1-adv108.md`.
