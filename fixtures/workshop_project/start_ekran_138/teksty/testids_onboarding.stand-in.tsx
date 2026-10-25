// Stand-in источников ПУТИ допуска (не зона 138): Erstinformation — 118
// (onboarding). Продукт несёт эти testID в своих экранах; кнопка First-Run
// (first-run-continue) живёт в auth (buttonTestID) — допуск 135/118 держит
// onboarding вторым деревом-владельцем этого селектора.
<View testID="erstinfo_gate_current" />
<View testID="erstinfo_continue_start" />
