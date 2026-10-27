import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Appearance, Image, Linking, Pressable, StyleSheet, Text, View } from 'react-native';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
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

// 117 v4 (класс B, слово владельца 2026-10-27; пересмотры по живым пробам
// run 40434807469 и 40497913252): кадр Splash снимается, ПОКА оверлей на
// экране, но удержание приписано ТОЛЬКО сценарию 117. Env-удержание
// e2e-СБОРКИ (вариант (В)) живьём отклонено: один APK на все шаги CI держал
// оверлей 8 с на КАЖДОМ холодном старте (кадр 118 F02.03-V01-V0 0.000).
// Канал (Г) по host-ссылке complior://e2e-splash-hold живьём отклонён
// пробой (Г) run 40497913252: expo-router разбирает её как ПУТЬ
// /e2e-splash-hold, динамический (tabs)/[section] рендерит null (сегмент
// вне TAB_ORDER), PilotApp НЕ монтируется, hideAsync не вызван — нативный
// splash залип на 15 с, флоу 117 красен. Канал (Г′): ссылка ведёт на
// СУЩЕСТВУЮЩИЙ маршрут — КОРЕНЬ «/» (index.tsx монтирует PilotApp
// безусловно), маркер удержания — в query (openLink; канал живой —
// complior://start в зелёных cmp-mob-002/004); оверлей живёт дольше РОВНО
// на старте с этим URL (Linking.getInitialURL, ТОЧНОЕ равенство; ни один
// другой сценарий литерал не открывает — .maestro, grep). Прод-литерал
// 1200 не сдвинут: таймер по умолчанию стоит сразу (клетки
// SPLASH_OVERLAY_TIMER_HIDE_*; удержанного старта — HOLD_LINK_*).
const SPLASH_HOLD_E2E_LINK = 'complior:///?e2e=splash-hold';
const SPLASH_HOLD_E2E_MS = 8000;

export interface PilotAppPorts {
  readonly auth?: AuthProvider;
  readonly api?: ApiClient;
  readonly entry?: {
    readonly source?: string;
    readonly onboarding?: 'unknown' | 'incomplete' | string;
    readonly pendingIntent?: PendingIntent | null;
  };
  /** 117 v3 (миграция 117/3; арбитраж нарезки 117↔118): admission решает
   * ПОВЕРХНОСТЬ после демо ('W1A' → Erstinformation при ЛЮБОМ gate),
   * gate — ПЕРЕХОД continue → Start (только 'W1A' ∧ 'current'). Источник
   * — сессия пользователя, ВНЕШНЯЯ по отношению к pilot-app (литерал
   * допуска в pilot-app запрещён); gate — ось состояния выдачи 107
   * ('current' = полный CURRENT_CONFIRMED-снимок с точной версией и
   * evidence; предикат — 107/118, второй gate не вводится). Умолчания
   * W0/'null': без внешнего источника — прежний путь B (Г0). */
  readonly onboarding?: {
    readonly admission?: 'W0' | 'W1A';
    readonly gate?: 'null' | 'stale' | 'current';
  };
}

type Frame =
  | 'first-run'
  | 'email'
  | 'code'
  | 'unavailable'
  | 'recovery'
  | 'welcome'
  | 'erstinformation'
  | 'start';


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
export function PilotApp({ auth, api, entry, onboarding }: PilotAppPorts) {
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
    // 117 v4: прод-таймер 1200 ставится СРАЗУ (как в v3 — клетки
    // SPLASH_OVERLAY_TIMER_HIDE_* зелены без ожидания промиса);
    // стартовый URL читается на МОМЕНТ монтирования: пресет Jest даёт
    // мок Linking.getInitialURL (Promise.resolve()), клетки HOLD_LINK/
    // NE_INOJ_URL/NE_NEMARSHRUT подставляют ответ разовым
    // mockImplementationOnce (классы входов ссылки: корень+query —
    // удержание; чужая ссылка и несуществующий маршрут — прод-таймер).
    void SplashScreen.hideAsync();
    let timer = setTimeout(() => setSplashVisible(false), SPLASH_OVERLAY_MS);
    let holdCancelled = false;
    void Linking.getInitialURL().then((initialUrl) => {
      if (holdCancelled || initialUrl !== SPLASH_HOLD_E2E_LINK) return;
      clearTimeout(timer);
      timer = setTimeout(() => setSplashVisible(false), SPLASH_HOLD_E2E_MS);
    });
    return () => {
      holdCancelled = true;
      clearTimeout(timer);
    };
  }, []);
  const [flow, setFlow] = useState<AuthFlowState>(createInitialAuthFlow);
  // 117 v3: допуск маршрута из внешней сессии (порт onboarding); без
  // порта — недопуск (W0/'null'), прежний путь B.
  const onboardingAdmission = onboarding?.admission ?? 'W0';
  const onboardingGate = onboarding?.gate ?? 'null';
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
    // 117 v3 (арбитраж нарезки 117↔118, семантика frozen 118/1 инв. 4–5):
    // admission решает ПОВЕРХНОСТЬ после демо — W1A → кадр
    // 'erstinformation' при ЛЮБОМ gate (при null/stale пользователь видит
    // Erstinformation с маркером gate, Start закрыт); не-W1A — прежний
    // путь B: auth.begin → кадр code (F03.02), поверхность 995, корень
    // #FFFFFF 48/16/16 (Г0). Достижимость F03.02 через демо сохраняется.
    if (onboardingAdmission === 'W1A') {
      setFrame('erstinformation');
      return;
    }
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
  }, [flow.email, runtime.auth, resetChallenge, onboardingAdmission]);

  // 117 v3: продолжение из Erstinformation — ЕДИНСТВЕННЫЙ вход в Start;
  // gate решает ПЕРЕХОД: continue → Start ТОЛЬКО при W1A ∧ current
  // (frozen 118/1 инв. 4–5: при null/stale нажатие continue НЕ даёт
  // перехода, Start отсутствует; второй gate не вводится — предикат
  // 107/118).
  const handleErstinfoContinue = useCallback(() => {
    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {
      setFrame('start');
    }
  }, [onboardingAdmission, onboardingGate]);

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
  // На остальных кадрах (welcome, F03.01/F03.02/F03.04, recovery и т. д.,
  // поверхность 995) — прежний корень 48/16/16 + #FFFFFF: frozen 111/1
  // стр. 41–42/80–83 запрещает рестайлить кадры 995; здесь они лежат
  // на светлом корне, а их собственные стили (auth-screen/welcome-screen)
  // уже заточены под #FFFFFF. 117 v2 (сужение до splash + иконка): вход
  // F03.01/F03.02 выведен в first-run-ekran — корни кадров как на B.
  return (
    <ThemeContext.Provider value={themeValue}>
    <View
      style={
        frame === 'first-run'
          ? [styles.rootFirstRun, { backgroundColor: tokens.ground }]
          : styles.root
      }
    >
      {/* 117 круг 7 (В2-1/В2-2, Rev117r2): стиль статус-бара по схеме
          PilotApp — иконки контрастны ground (dark → light, light → dark);
          вне поддерева оверлея: стиль живёт на всех кадрах, не только
          на splash. */}
      <StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />
      {frame !== 'welcome' && frame !== 'erstinformation' && frame !== 'start' ? (
        <View style={{ paddingTop: frame === 'first-run' ? insets.top : 0 }}>
          <View style={styles.demoBadge} testID="demo-indicator">
            <Text style={styles.demoBadgeText}>Demo</Text>
          </View>
        </View>
      ) : null}

      {frame === 'first-run' ? (
        <FirstRunScreen onEnter={handleFirstRunContinue} />
      ) : null}

      {frame !== 'first-run' && frame !== 'welcome' && frame !== 'erstinformation' && frame !== 'start' ? (
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

      {frame === 'erstinformation' ? (
        <View
          testID="erstinformation-117"
          style={[styles.rootFirstRun, { backgroundColor: tokens.ground }]}
        >
          {/* 117 v3: маркер состояния gate (frozen 118/1 инв. 4: при
              null/stale пользователь ВИДИТ маркер gate, Start закрыт);
              состав экрана Erstinformation (кадры F02.03/F02.08) —
              предмет 118, модель несёт шаг маршрута и маркер. */}
          <View testID={`erstinfo_gate_${onboardingGate}`} />
          <Pressable
            testID="erstinfo_continue_start"
            onPress={handleErstinfoContinue}
            accessibilityRole="button"
          >
            <Text style={{ color: tokens.ink }}>Weiter</Text>
          </Pressable>
        </View>
      ) : null}

      {frame === 'start' ? (
        <View
          testID="start_tabs"
          style={[styles.rootFirstRun, { backgroundColor: tokens.ground }]}
        >
          {/* 117 v3: состав Start (вкладки) судит 118 (testID из его
              замороженной приёмки); модель несёт контейнер назначения. */}
          <View testID="start_tab_start" />
          <View testID="start_tab_vorgaenge" />
          <View testID="start_tab_schutz" />
          <View testID="start_tab_post" />
        </View>
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
