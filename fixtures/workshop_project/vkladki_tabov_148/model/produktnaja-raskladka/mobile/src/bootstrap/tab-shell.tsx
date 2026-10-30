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
  /** CMP-MOB-002/D2.4 (148): опциональный слот для StartScreen в секции start;
   * подаётся композицией (mobile/src/app/(tabs)/[section].tsx) и не
   * затрагивает frozen nav_999 пробы (без слота — рендерится только
   * заголовок секции, как было в 999). */
  readonly startScreen?: React.ReactNode;
  /** 148 vkladki-tabov: слоты КОНТЕНТА вкладок vorgaenge/schutz/post
   * (GA-02/03/04/09); подаются композицией, как startScreen (108).
   * Без слотов — только заголовок секции (frozen nav_999/copy_999
   * поверхность не меняется: контент живёт вне каталога 999). */
  readonly sectionScreens?: Readonly<Partial<Record<ShellSection, React.ReactNode>>>;
  /** 148 vkladki-tabov: центральная кнопка «Gespräch» (Mitte, GA-02/03/
   * 04/09) — ReactNode-слот МЕЖДУ вкладками vorgaenge и schutz; НЕ
   * accessibilityRole="tab" (замороженная грамматика 999: role=tab —
   * ровно четыре канонические вкладки TAB_ORDER). Без слота — барьер
   * не рендерится (frozen 999). */
  readonly mitte?: React.ReactNode;
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
  readonly mitte?: React.ReactNode;
}

function TabBar({ selected, inkColor, onCardColor, onSelect, mitte }: TabBarProps) {
  return (
    <View accessibilityRole="tablist" style={styles.tabbar}>
      {TAB_ORDER.map((id) => (
        <React.Fragment key={id}>
          {id === 'schutz' && mitte ? mitte : null}
          <Pressable
            accessibilityRole="tab"
            accessibilityState={{ selected: selected === id }}
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
        </React.Fragment>
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
  sectionScreens,
  mitte,
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
          {/* 148 vkladki-tabov (GA-02/03/04/09): контентный слот вкладки
              ЗАМЕНЯЕТ заголовок секции — макет D 2.4 несёт свой заголовок
              (имя вкладки + подзаголовок, кадры GA-02/03/04). Без слота —
              заголовок секции по замороженной грамматике 999
              (SECTION_CONTENT_COPY: пробы рендерят TabShell без слотов). */}
          {section !== 'start' && sectionScreens?.[section] ? (
            sectionScreens[section]
          ) : (
            <>
              <Text
                accessibilityRole="header"
                style={[styles.title, { color: tokens.ink }]}
                testID={`section-title-${section}`}
              >
                {uiCopyDe[SECTION_TITLE_KEYS[section]].text}
              </Text>
              {/* CMP-MOB-004 (108): опциональный слот StartScreen в секции start.
                  Подаётся композицией через prop startScreen; без слота —
                  только заголовок секции (замороженные пробы nav_999). */}
              {section === 'start' && startScreen ? startScreen : null}
            </>
          )}
        </View>
      )}
    </KeyboardAvoidingView>
  );

  const tabbarWrap = route === 'tabs' ? (
    /* 148 vkladki-tabov (GA-09 «Tab-Leiste bleibt, Inhalt läuft darunter»):
       лейсте — оверлей нижнего края поверх body: контент вкладки
       прокручивается ПОД ней (SafeAreaView остаётся ближайшим
       композитом-хозяином шва — грамматика контейнеров 999 сохранена). */
    <View
      style={[
        styles.tabbarBg,
        styles.tabbarOverlay,
        { backgroundColor: tokens.panel },
      ]}
    >
      <TabBar
        inkColor={tokens.ink}
        mitte={mitte}
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
  /* 148 (GA-09): оверлей — контент прокручивается под лейсте. */
  tabbarOverlay: { bottom: 0, left: 0, position: 'absolute', right: 0 },
  tabbar: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  tab: {
    paddingHorizontal: 12,
    paddingVertical: 6,
  },
  tabLabel: { fontSize: 14 },
});
