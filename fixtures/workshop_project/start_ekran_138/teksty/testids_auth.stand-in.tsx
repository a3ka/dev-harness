// Носители пути допуска в auth (135): demo-вход — testID; кнопка First-Run —
// buttonTestID (продукт: first-run-screen.tsx передаёт Cta, который рендерит
// testID={buttonTestID}, auth-parts.tsx; замкнутый алфавит имён — прецедент
// 118). Допуск 135/118: onboarding остаётся вторым деревом-владельцем.
<View testID="auth-demo-entry" />
<Cta buttonTestID="first-run-continue" />
