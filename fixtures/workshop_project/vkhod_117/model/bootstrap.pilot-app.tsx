import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Appearance, Image, StyleSheet, Text, View } from 'react-native';
import * as SplashScreen from 'expo-splash-screen';
import type { ApiClient } from '@/api/api-client';
import type {
  AuthChallenge,
  AuthProvider,
  AuthResendResult,
  AuthVerifyResult,
} from '@/auth/auth-provider';
import type { Disclosure, Session } from '@/api/generated/api-5_8';
import type { PendingIntent } from '@/navigation/pending-intent';
import { ThemeContext } from '@/theme/context';
import { themeTokens } from '@/theme/tokens';
import { SafeAreaInsetsContext, type EdgeInsets } from 'react-native-safe-area-context';
import { AuthScreen } from '@/features/auth/auth-screen';
import { FirstRunScreen } from '@/features/auth/first-run-screen';
import { WelcomeScreen } from '@/features/onboarding/welcome-screen';
import { runtime as shippedRuntime } from '@pilot/runtime';

// 117 (CMP-MOB-006, арбитраж круга 2): нативный splash удерживается до
// первого JS-кадра; Expo Go (SDK 52+) показывает иконку приложения, а не
// картинку плагина, поэтому кадр Splash.png после нативного знака несёт
// JS-оверлей. Не JS-кадр state-machine: `frame` стартует с 'first-run'
// как в базе, пространство кадров не расширяется.
void SplashScreen.preventAutoHideAsync();

// Литерал таймера автоскрытия оверлея (дельта архитектора круга 4).
const SPLASH_OVERLAY_MS = 1200;

export interface PilotAppPorts {
  readonly auth?: AuthProvider;
  readonly api?: ApiClient;
  readonly entry?: {
    readonly source?: string;
    readonly onboarding?: 'unknown' | 'incomplete' | string;
    readonly pendingIntent?: PendingIntent | null;
  };
}

type Frame = 'first-run' | 'email' | 'code' | 'unavailable' | 'recovery' | 'welcome';

export interface AuthFlowState {
  email: string;
  code: string;
  challenge: string;
  sent: boolean;
  waitSeconds: number | undefined;
  invalid: boolean;
  session: Session | undefined;
  disclosure: Disclosure | undefined;
  unavailableReason: string | null;
}

// 111 (CMP-MOB-005): First-Run по D2.2.5.1 живёт в
// @/features/auth/first-run-screen. PilotApp на кадре first-run
// красит свой корень в tokens.ground текущей схемы (full-bleed
// поверхность 995 не считается — subject = FirstRunScreen) и не
// добавляет отступов; на остальных кадрах (F03.01+, welcome —
// поверхность 995) PilotApp даёт прежний корень 48/16/16 #FFFFFF,
// чтобы кадры 995 не были рестайлены (frozen 111/1 стр. 41–42/80–83).

function createInitialAuthFlow(): AuthFlowState {
  return {
    email: '',
    code: '',
    challenge: '',
    sent: false,
    waitSeconds: undefined,
    invalid: false,
    session: undefined,
    disclosure: undefined,
    unavailableReason: null,
  };
}

function extractWait(resend: AuthResendResult): number | undefined {
  if (!resend.confirmed) return undefined;
  return 'retryAfterSeconds' in resend ? resend.retryAfterSeconds : undefined;
}

/**
 * PilotApp — public composition seam for CMP-MOB-001.
 *
 * Resolver-bound `auth` and `api` come from `@pilot/runtime` by default; tests can
 * inject replacements via props. The actual implementations live in
 * `mobile/src/mocks/runtime.ts` or `mobile/src/bootstrap/http-runtime.ts` and are
 * selected by the alias chosen in `metro.config.js` / `jest.config.js`.
 *
 * The protected Start surface is intentionally NOT reachable. Successful
 * authentication reveals F02.01 only; pending intents carried by the entry port
 * are stored as data and never executed by this composition.
 */
export function PilotApp({ auth, api, entry }: PilotAppPorts) {
  const runtime = useMemo(
    () => ({ auth: auth ?? shippedRuntime.auth, api: api ?? shippedRuntime.api }),
    [auth, api],
  );
  // `entry` is consumed as data only — pending intents are stored, never executed.
  // DIRECT / onboarding state is exposed through testID handles, not on-screen text.
  void entry;
  // 117 круг 6 (Р1, Rev117/Adv117): тема ОС проводится на production-входе.
  // Вход приложения — app/index (реэкспорт PilotApp), _layout — Stack без
  // темы: выше PilotApp провайдера НЕТ, а контекст темы по умолчанию dark
  // (theme/context.ts). Когда выше нет явного провайдера (значение
  // контекста — умолчание dark/dark-токены), PilotApp сам проводит схему
  // ОС: Appearance.getColorScheme + подписка на изменения, и публикует
  // ThemeContext для своего дерева (в т.ч. оверлей и кадры F03).
  // Явный провайдер выше (пробы шва/TabShell) сохраняет приоритет.
  const outerTheme = React.useContext(ThemeContext);
  const outerIsDefault =
    outerTheme.scheme === 'dark' && outerTheme.tokens === themeTokens.dark;
  const [osScheme, setOsScheme] = useState<'dark' | 'light'>(() =>
    Appearance.getColorScheme() === 'light' ? 'light' : 'dark');
  useEffect(() => {
    const sub = Appearance.addChangeListener(({ colorScheme }: { colorScheme: string | null }) => {
      setOsScheme(colorScheme === 'light' ? 'light' : 'dark');
    });
    return () => sub.remove();
  }, []);
  const themeValue = outerIsDefault
    ? { scheme: osScheme, tokens: themeTokens[osScheme] }
    : outerTheme;
  const { tokens, scheme } = themeValue;

  // 111 r3 (R1, совет С7): Demo-бейдж обязан лежать НИЖЕ top-инсета —
  // на устройстве круга 2 бейдж [0,0][137,64] лежал в статус-баре,
  // выпадая из safe-области кадра. Обёртка с paddingTop=insets.top:
  // бейдж всегда стартует от безопасного верха; К7 (DEMO_BADGE_INSET)
  // судит обе схемы и оба литерала мока (47, 59) — отслеживание
  // убивает хардкод измеренного значения.
  //
  // 111 r5 (С11): инсет бейджа — только на кадре first-run. Обёртка стоит
  // и на кадрах 995 (F03.01+), где она сдвигала колонку на величину
  // top-инсета (замер: y заголовка F03.01 222 → 358, т. е. +136 px),
  // а frozen 111/1 стр. 41–42/80–83 оставляет эти кадры поверхностью
  // 995. На них отступ равен 0 — раскладка базы B 76ac10fa.
  //
  // Чтение через useContext напрямую (НЕ useSafeAreaInsets) даёт безопасный
  // fallback {top:0,...}, когда SafeAreaProvider отсутствует (995 pilot.test
  // рендерит <PilotApp /> без обёртки — прямой хук бросает, обёрнутая
  // реализация деградирует до отступа 0; в проде PilotApp стоит под
  // expo-router/entry, который публикует SafeAreaProvider).
  const insets: EdgeInsets = React.useContext(SafeAreaInsetsContext) ?? {
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
  };

  const [frame, setFrame] = useState<Frame>('first-run');
  // 117: JS-оверлей кадра Splash.png — автоскрытие таймером-литералом;
  // hideAsync ПОСЛЕ монтирования оверлея (в его effect), чтобы между
  // нативным знаком и первым JS-кадром не было пустого кадра.
  const [splashVisible, setSplashVisible] = useState(true);
  useEffect(() => {
    void SplashScreen.hideAsync();
    const timer = setTimeout(() => setSplashVisible(false), SPLASH_OVERLAY_MS);
    return () => clearTimeout(timer);
  }, []);
  const [flow, setFlow] = useState<AuthFlowState>(createInitialAuthFlow);
  const verifyGeneration = useRef({ current: 0 });

  // ЕДИНЫЙ reset-хелпер состояния challenge + подъём поколения (995, A1/B1″):
  // вызывается каждым переход-обработчиком, отменяющим/заменяющим challenge.
  // e-mail сохраняется — новый begin печатается с уже введённого адреса.
  const resetChallenge = useCallback(() => {
    verifyGeneration.current.current += 1;
    setFlow((current) => ({ ...createInitialAuthFlow(), email: current.email }));
  }, []);

  const handleFirstRunContinue = useCallback(() => {
    setFrame('email');
  }, []);

  const handleEmailChange = useCallback((value: string) => {
    setFlow((current) => ({ ...current, email: value }));
  }, []);

  const handleCodeChange = useCallback((value: string) => {
    setFlow((current) => ({ ...current, code: value, invalid: false }));
  }, []);

  const handleDemoEntry = useCallback(async () => {
    resetChallenge();
    const generation = verifyGeneration.current.current;
    const result: AuthChallenge = await runtime.auth.begin(flow.email);
    if (generation !== verifyGeneration.current.current) return;
    if (result.status === 'unavailable') {
      setFlow((current) => ({ ...current, challenge: result.challenge, unavailableReason: 'Kein Zugriff' }));
      setFrame('unavailable');
      return;
    }
    setFlow((current) => ({ ...current, challenge: result.challenge, unavailableReason: null }));
    setFrame('code');
  }, [flow.email, runtime.auth, resetChallenge]);

  const handleVerify = useCallback(async () => {
    const generation = verifyGeneration.current.current;
    const result: AuthVerifyResult = await runtime.auth.verify(flow.challenge, flow.code);
    if (generation !== verifyGeneration.current.current) return;
    if (result.status !== 'authenticated') {
      setFlow((current) => ({ ...current, invalid: result.status === 'invalid' }));
      return;
    }
    const [session, disclosure] = await Promise.all([
      runtime.api.getSession(),
      runtime.api.getDisclosure('example'),
    ]);
    if (generation !== verifyGeneration.current.current) return;
    setFlow((current) => ({
      ...current,
      code: '',
      invalid: false,
      sent: false,
      waitSeconds: undefined,
      session,
      disclosure,
    }));
    setFrame('welcome');
  }, [flow.challenge, flow.code, runtime.api, runtime.auth]);

  const handleResend = useCallback(async () => {
    const generation = verifyGeneration.current.current;
    const result = await runtime.auth.resend(flow.challenge);
    if (generation !== verifyGeneration.current.current) return;
    setFlow((current) => ({
      ...current,
      sent: result.confirmed ?? false,
      waitSeconds: extractWait(result),
    }));
  }, [flow.challenge, runtime.auth]);

  const handleChangeEmail = useCallback(() => {
    resetChallenge();
    setFlow((current) => ({ ...current, email: '' }));
    setFrame('email');
  }, [resetChallenge]);

  const handleNoAccess = useCallback(() => {
    resetChallenge();
    setFrame('recovery');
  }, [resetChallenge]);

  const handleRecover = useCallback(async () => {
    await runtime.auth.recover();
  }, [runtime.auth]);

  const handleReturn = useCallback(() => {
    resetChallenge();
    setFrame('email');
  }, [resetChallenge]);

  const authFrame: 'email' | 'code' | 'unavailable' | 'recovery' =
    frame === 'code'
      ? 'code'
      : frame === 'unavailable'
      ? 'unavailable'
      : frame === 'recovery'
      ? 'recovery'
      : 'email';

  // 111 r4 (P2, контрольная форма): корень кадра зависит от кадра.
  // На first-run — full-bleed #0A0A0A (ground текущей темы), без отступов
  // (К6 FIRST_RUN_GROUND_FULL_SURFACE требует paddingTop/horizontal/bottom
  // undefined или 0 и backgroundColor === tokens.ground).
  // 117 (CMP-MOB-006, слова владельца (А) 18:15 и ~19:28): тот же
  // full-bleed ground несут кадры входа F03.01/F03.02 (email/code) — вход
  // по токенам и компонентам D2.2.5.1. Остальные кадры (welcome, F03.04
  // recovery, unavailable — поверхность 995) — прежний корень 48/16/16 +
  // #FFFFFF: frozen 111/1 стр. 41–42/80–83. Splash 117 целиком нативный
  // (app.json), JS-кадра нет — первый кадр остаётся first-run.
  const isD22Frame = frame === 'first-run' || frame === 'email' || frame === 'code';
  // 117 круг 6 (Р4, Rev117): кадры входа F03.01/F03.02 — safe-area и
  // колонка: корень несёт top-инсет (paddingTop >= insets.top; на стенде
  // 1080×2400 statusBars [0..136], заголовок обязан лежать ниже) и
  // горизонтальные отступы колонки 16 (D2.2.5.1 gutters). First-run
  // остаётся full-bleed без отступов (frozen 111/1, К6).
  return (
    <ThemeContext.Provider value={themeValue}>
    <View
      style={
        isD22Frame
          ? [styles.rootFirstRun, {
              backgroundColor: tokens.ground,
              paddingTop: frame === 'first-run' ? 0 : insets.top,
              paddingHorizontal: frame === 'first-run' ? 0 : 16,
            }]
          : styles.root
      }
    >
      {frame !== 'welcome' ? (
        <View style={{ paddingTop: frame === 'first-run' ? insets.top : 0 }}>
          <View style={styles.demoBadge} testID="demo-indicator">
            <Text style={styles.demoBadgeText}>Demo</Text>
          </View>
        </View>
      ) : null}

      {frame === 'first-run' ? (
        <FirstRunScreen onEnter={handleFirstRunContinue} />
      ) : null}

      {frame !== 'first-run' && frame !== 'welcome' ? (
        <AuthScreen
          frame={authFrame}
          email={flow.email}
          code={flow.code}
          sent={flow.sent}
          waitSeconds={flow.waitSeconds}
          invalid={flow.invalid}
          unavailableReason={flow.unavailableReason}
          onEmailChange={handleEmailChange}
          onCodeChange={handleCodeChange}
          onDemoEntry={() => {
            void handleDemoEntry();
          }}
          onVerify={() => {
            void handleVerify();
          }}
          onResend={() => {
            void handleResend();
          }}
          onChangeEmail={handleChangeEmail}
          onNoAccess={handleNoAccess}
          onRecover={() => {
            void handleRecover();
          }}
          onReturn={handleReturn}
        />
      ) : null}

      {frame === 'welcome' && (flow.session || flow.disclosure) ? (
        <WelcomeScreen demoVisible={Boolean(flow.session)} />
      ) : null}

      {splashVisible ? (
        <View
          testID="splash-overlay"
          pointerEvents="none"
          style={[StyleSheet.absoluteFill, {
            backgroundColor: tokens.ground,
            zIndex: 1000,
            width: '100%',
            height: '100%',
          }]}
        >
          {/* 117 круг 6 (Р6, Rev117): композит вписан по ОКНУ — бокс
              Image жёстко следует боксу оверлея (width/height 100%),
              contain масштабирует по ширине окна (2.769 px/px артборда
              при 1080×2400) и центрирует; без явного бокса растр
              рендерился собственным размером 390×844 dp с прижимом к
              углу (масштаб 2.63, сдвиг теглайна 28 px). */}
          <Image
            source={
              scheme === 'dark'
                ? require('../../assets/images/splash-composite-dark.png')
                : require('../../assets/images/splash-composite-light.png')
            }
            resizeMode="contain"
            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}
          />
        </View>
      ) : null}
    </View>
    </ThemeContext.Provider>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    paddingTop: 48,
    paddingHorizontal: 16,
    paddingBottom: 16,
    backgroundColor: '#FFFFFF',
  },
  rootFirstRun: {
    flex: 1,
  },
  demoBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    backgroundColor: '#F2F2F2',
    borderRadius: 4,
    alignSelf: 'flex-start',
    marginBottom: 12,
  },
  demoBadgeText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#444444',
  },
});

export const F02_TEST_ID = 'F02.01';
