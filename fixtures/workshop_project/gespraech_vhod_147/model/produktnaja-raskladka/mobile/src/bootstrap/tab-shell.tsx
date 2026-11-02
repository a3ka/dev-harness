// CMP-MOB-002: шов навигации. Четыре канонические вкладки
// Start/Vorgänge/Schutz/Post в порядке IA 1.17, профиль как вторичный
// маршрут (action.F12.A01), Back возвращает к исходному разделу при
// deep-link, переключение вкладки не отправляет команду. Системная
// настройка reduce motion в RN возвращает Promise<boolean>, поэтому
// читаем её асинхронно: пока Promise не разрешён — декоративное движение
// выключено (безопасный выбор по слову владельца: при системном
// reduceMotion анимаций нет НИГДЕ, включая возврат из profile).
import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  AccessibilityInfo,
  Animated,
  Appearance,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { TAB_ORDER, themeTokens, type ColorScheme, type ShellSectionId, type ThemeTokens } from '../theme/tokens';
import { ThemeContext } from '../theme/context';
import { SECTION_TITLE_KEYS, TAB_LABEL_KEYS, uiCopyDe } from '../i18n/ui-copy';
import { MOTION_TOKENS } from '../theme/motion-tokens';
import kompakt from '../../../docs/ux/05_Kompakt_D24/source/tokens.json';

const ziel = Number(kompakt['touch-target'].min.$value.replace('px', ''));
const navZiel = Number(kompakt.nav['item.min-height'].$value.replace('px', ''));

export type ShellSection = ShellSectionId;

export interface ShellCommand {
  readonly kind: string;
  readonly payload?: unknown;
}

export interface TabShellProps {
  readonly initialSection?: ShellSection;
  readonly returnSection?: ShellSection | null;
  readonly reducedMotion?: boolean;
  readonly colorScheme?: ColorScheme;
  readonly onCommand?: (command: ShellCommand) => void;
  /** CMP-MOB-004 (108): опциональный слот для StartScreen в секции start;
   * подаётся композицией (mobile/src/app/(tabs)/[section].tsx) и не
   * затрагивает frozen nav_999 пробы (без слота — рендерится только
   * заголовок секции, как было в 999). */
  readonly startScreen?: React.ReactNode;
  readonly testID?: string;
}

type RouteState = 'tabs' | 'profile';

function fromSystemAppearance(value: string | null | undefined): ColorScheme {
  return value === 'light' ? 'light' : 'dark';
}

function readSystemColorScheme(): ColorScheme {
  return fromSystemAppearance(Appearance.getColorScheme());
}

function useSystemColorScheme(): ColorScheme {
  const [scheme, setScheme] = useState<ColorScheme>(() => readSystemColorScheme());
  useEffect(() => {
    const sub = Appearance.addChangeListener(({ colorScheme }) => {
      setScheme(fromSystemAppearance(colorScheme));
    });
    return () => sub.remove();
  }, []);
  return scheme;
}

// Считывание системного reduce motion. На устройстве Promise<boolean>;
// пока он не разрешён — анимаций нет (безопасный выбор: чтобы при
// включённой системной настройке не было faden при холодном старте).
// Единственный источник: читают TabShell и composition root
// (mobile/src/app/(tabs)/[section].tsx) — одна функция, не две копии.
function readSystemReduceMotionInitial(): boolean {
  try {
    const value = AccessibilityInfo.isReduceMotionEnabled();
    if (typeof value === 'boolean') return value;
    if (value && typeof (value as Promise<boolean>).then === 'function') return true;
  } catch {
    return true;
  }
  return true;
}

export function useSystemReduceMotion(): boolean {
  const [enabled, setEnabled] = useState<boolean>(() => readSystemReduceMotionInitial());
  useEffect(() => {
    let cancelled = false;
    const apply = (next: boolean) => {
      if (!cancelled) setEnabled(next);
    };
    let pending: unknown;
    try {
      pending = AccessibilityInfo.isReduceMotionEnabled();
      if (pending && typeof (pending as Promise<boolean>).then === 'function') {
        (pending as Promise<boolean>).then(apply).catch(() => apply(true));
      } else if (typeof pending === 'boolean') {
        apply(pending);
      } else {
        apply(true);
      }
    } catch {
      apply(true);
    }
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', apply);
    return () => {
      cancelled = true;
      sub.remove();
    };
  }, []);
  return enabled;
}

interface HeaderBarProps {
  readonly backVisible: boolean;
  readonly colorScheme: ColorScheme;
  readonly profileLabel: string;
  readonly tokens: ThemeTokens;
  readonly onBack: () => void;
  readonly onProfile: () => void;
}

function HeaderBar({ backVisible, colorScheme, profileLabel, tokens, onBack, onProfile }: HeaderBarProps) {
  return (
    <View style={styles.header}>
      {backVisible ? (
        <Pressable
          accessibilityLabel={uiCopyDe['global.back'].text}
          accessibilityRole="button"
          onPress={onBack}
          testID="shell-back"
        >
          <Text style={[styles.backLabel, { color: tokens.ink }]}>{uiCopyDe['global.back'].text}</Text>
        </Pressable>
      ) : (
        <View />
      )}
      <Pressable
        accessibilityLabel={profileLabel}
        accessibilityRole="button"
        onPress={onProfile}
        /* 147 (цикл 2, Crit147k2b): зона входа профиля — токен пакета
           D24-Kompakt-1.1 touch-target.min 44px ($value); измеряет зонд
           батареи 147. */
        style={styles.profileZone}
        testID="shell-profile-entry"
      >
        <Text style={[styles.profileLabel, { color: tokens.ink }]}>{profileLabel}</Text>
      </Pressable>
    </View>
  );
}

interface TabBarProps {
  readonly selected: ShellSection;
  readonly inkColor: string;
  readonly onCardColor: string;
  readonly onSelect: (id: ShellSection) => void;
}

function TabBar({ selected, inkColor, onCardColor, onSelect }: TabBarProps) {
  return (
    <View accessibilityRole="tablist" style={styles.tabbar}>
      {TAB_ORDER.map((id) => (
        <Pressable
          accessibilityRole="tab"
          accessibilityState={{ selected: selected === id }}
          key={id}
          onPress={() => onSelect(id)}
          style={styles.tab}
          testID={`shell-tab-${id}`}
        >
          <Text
            style={[
              styles.tabLabel,
              { color: selected === id ? onCardColor : inkColor, fontWeight: selected === id ? '700' : '400' },
            ]}
          >
            {uiCopyDe[TAB_LABEL_KEYS[id]].text}
          </Text>
        </Pressable>
      ))}
    </View>
  );
}

export function TabShell({
  initialSection = 'start',
  returnSection = null,
  reducedMotion: reducedMotionPort,
  colorScheme: colorSchemePort,
  onCommand,
  startScreen,
  testID,
}: TabShellProps) {
  const systemReduceMotion = useSystemReduceMotion();
  const systemColorScheme = useSystemColorScheme();

  const reducedMotion = reducedMotionPort ?? systemReduceMotion;
  const colorScheme = colorSchemePort ?? systemColorScheme;
  const tokens = themeTokens[colorScheme];

  const [section, setSection] = useState<ShellSection>(initialSection);
  const [returnTo, setReturnTo] = useState<ShellSection | null>(returnSection);
  const [route, setRoute] = useState<RouteState>('tabs');
  const [menu, setMenu] = useState<'closed' | 'open' | 'vorgang'>('closed');

  const onCommandRef = useRef(onCommand);
  useEffect(() => {
    onCommandRef.current = onCommand;
  }, [onCommand]);

  const leaveProfile = () => setRoute('tabs');
  const openProfile = () => setRoute('profile');

  const selectSection = (id: ShellSection) => {
    setSection(id);
  };

  const goBack = () => {
    if (route === 'profile') {
      leaveProfile();
      return;
    }
    if (returnTo !== null) {
      setSection(returnTo);
      setReturnTo(null);
    }
  };

  const showBack = route === 'profile' || returnTo !== null;
  const fadenKey = `${route}|${section}|${returnTo ?? '_'}`;

  const fadeAnim = useMemo(() => new Animated.Value(1), []);
  useEffect(() => {
    if (!reducedMotion ? true : false) {
      fadeAnim.setValue(0.25);
      const anim = Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 180,
        useNativeDriver: true,
      });
      anim.start();
      const stop = () => anim.stop();
      return stop;
    }
    return undefined;
  }, [fadenKey, fadeAnim, reducedMotion]);

  const profileTitle = uiCopyDe['action.F12.A01'].text;

  const header = (
    <HeaderBar
      backVisible={showBack}
      colorScheme={colorScheme}
      tokens={tokens}
      onBack={goBack}
      onProfile={openProfile}
      profileLabel={profileTitle}
    />
  );

  const fadenView = reducedMotion ? null : (
    <Animated.View
      style={[styles.faden, { backgroundColor: tokens.accent, opacity: fadeAnim }]}
      testID="shell-faden"
    />
  );

  const body = (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      style={styles.body}
      testID="shell-keyboard-container"
    >
      {route === 'profile' ? (
        <View style={styles.section} testID="profile-surface">
          <Text accessibilityRole="header" style={[styles.title, { color: tokens.ink }]}>
            {profileTitle}
          </Text>
        </View>
      ) : (
        <View style={styles.section} testID={`section-${section}`}>
          <Text
            accessibilityRole="header"
            style={[styles.title, { color: tokens.ink }]}
            testID={`section-title-${section}`}
          >
            {uiCopyDe[SECTION_TITLE_KEYS[section]].text}
          </Text>
          {section === 'start' && startScreen ? startScreen : null}
          {section === 'start' ? (
            <>
              <Pressable testID="gespraech-vorgaenge-ansehen"
                onPress={() => setMenu('vorgang')} style={styles.ziel}>
                <Text>Vorgänge ansehen</Text>
              </Pressable>
              <Pressable testID="gespraech-mitte"
                onPress={() => setMenu('open')}
                onLongPress={() => onCommandRef.current?.({ kind: 'voice' })}
                delayLongPress={Number(MOTION_TOKENS['press-long'].replace('ms', ''))}
                style={styles.ziel}><Text>Gespräch</Text></Pressable>
              {menu !== 'closed' ? (
                <View testID="gespraech-menu">
                  {(['sprechen', 'schreiben', 'foto', 'dokument'] as const).map((id) => (
                    <Pressable key={id} testID={`gespraech-menu-${id}`}
                      onPress={() => { onCommandRef.current?.({ kind: id }); setMenu('closed'); }}
                      style={styles.ziel}><Text>{id}</Text></Pressable>
                  ))}
                  <Pressable testID="gespraech-menu-close"
                    onPress={() => setMenu('closed')} style={styles.ziel}>
                    <Text>×</Text>
                  </Pressable>
                  {menu === 'vorgang' ? (
                    <Pressable testID="gespraech-menu-ansehen"
                      onPress={() => { setSection('vorgaenge'); setMenu('closed'); }}
                      style={styles.ziel}><Text>Ansehen</Text></Pressable>
                  ) : null}
                </View>
              ) : null}
            </>
          ) : null}
        </View>
      )}
    </KeyboardAvoidingView>
  );

  const tabbarWrap = route === 'tabs' ? (
    <View style={[styles.tabbarBg, { backgroundColor: tokens.panel }]}>
      <TabBar
        inkColor={tokens.ink}
        onCardColor={tokens['on-card']}
        selected={section}
        onSelect={selectSection}
      />
    </View>
  ) : null;

  return (
    <ThemeContext.Provider value={{ scheme: colorScheme, tokens }}>
      <SafeAreaView style={[styles.safe, { backgroundColor: tokens.ground }]} testID={testID ?? 'shell-safe-area'}>
        {header}
        {fadenView}
        {body}
        {tabbarWrap}
      </SafeAreaView>
    </ThemeContext.Provider>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  header: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  backLabel: { fontSize: 15 },
  profileLabel: { fontSize: 15 },
  faden: {
    height: 3,
    marginHorizontal: 16,
  },
  body: { flex: 1 },
  section: {
    flex: 1,
    gap: 8,
    padding: 16,
  },
  title: { fontSize: 24, fontWeight: '600' },
  tabbarBg: { paddingVertical: 8 },
  tabbar: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  tab: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    minHeight: navZiel,
    minWidth: ziel,
  },
  profileZone: { minHeight: ziel, minWidth: ziel },
  ziel: { minHeight: ziel, minWidth: ziel },
  tabLabel: { fontSize: 14 },
});
