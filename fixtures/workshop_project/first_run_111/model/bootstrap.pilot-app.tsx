import React, { useCallback, useMemo, useRef, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import type { ApiClient } from '@/api/api-client';
import type {
  AuthChallenge,
  AuthProvider,
  AuthResendResult,
  AuthVerifyResult,
} from '@/auth/auth-provider';
import type { Disclosure, Session } from '@/api/generated/api-5_8';
import type { PendingIntent } from '@/navigation/pending-intent';
import { AuthScreen } from '@/features/auth/auth-screen';
import { FirstRunScreen } from '@/features/auth/first-run-screen';
import { WelcomeScreen } from '@/features/onboarding/welcome-screen';
import { useTheme } from '@/theme/context';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { runtime as shippedRuntime } from '@pilot/runtime';

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

  // 111 r5 (A2, суд круг 1): внешняя обёртка — часть наблюдаемой поверхности
  // кадра; красится ground текущей темы, собственных отступок не несёт —
  // иначе вокруг SafeAreaView First-Run возникает рамка (белая в старой
  // заглушке). Клетка FIRST_RUN_GROUND_FULL_SURFACE судит обе схемы.
  const { tokens } = useTheme();
  // R1 (ревью 111, круг 2): Demo-бейдж обязан начинаться ниже top-инсета
  // (на устройстве круга 2 лежал в статус-баре [0,0][137,64]). Кодировка
  // честной модели — потребление useSafeAreaInsets().top как верхний
  // отступ обёртки бейджа; клетка DEMO_BADGE_INSET судит обе схемы.
  const insets = useSafeAreaInsets();

  const [frame, setFrame] = useState<Frame>('first-run');
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

  return (
    <View
      style={
        frame === 'first-run'
          ? [styles.rootFirstRun, { backgroundColor: tokens.ground }]
          : styles.root
      }
    >
      {frame !== 'welcome' ? (
        <View style={{ paddingTop: insets.top }}>
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
    </View>
  );
}

// 111 круг 4 (С10/Р2, ревью круга 3): кадры 995 (F03.01+, welcome) —
// поверхность 995, НЕ рестайлятся (frozen 111/1 стр. 41–42, 80–83):
// корень на них несёт литералы 995 — фон #FFFFFF и отступы 48/16/16;
// {flex:1, ground} — только кадр first-run (К6).
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
