// Эталон 999: TabShell — композиционный шов навигации CMP-MOB-002.
// Четыре канонические вкладки Start/Vorgänge/Schutz/Post в порядке IA 1.17,
// профиль — вторичный маршрут; deep link открывает раздел, back возвращает к
// исходному; reduced motion глушит декоративное движение, не действия;
// переключение вкладки не создаёт Mission и не отправляет команду.
// Эталон architect: honest-модель для красных тестов, в PR не копируется.
import React, { useState } from 'react';
import { KeyboardAvoidingView, Platform, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { TAB_ORDER, themeTokens, type ColorScheme, type ShellSectionId } from '../theme/tokens';
import { ThemeContext } from '../theme/context';
import { SECTION_TITLE_KEYS, TAB_LABEL_KEYS, uiCopyDe } from '../i18n/ui-copy';

export type ShellSection = ShellSectionId;

export interface ShellPorts {
  readonly initialSection?: ShellSection;
  readonly returnSection?: ShellSection | null;
  readonly reducedMotion?: boolean;
  readonly colorScheme?: ColorScheme;
  readonly onCommand?: (command: { kind: string; payload?: unknown }) => void;
}

export function TabShell({
  initialSection = 'start',
  returnSection = null,
  reducedMotion = false,
  colorScheme = 'dark',
  onCommand,
}: ShellPorts) {
  const [section, setSection] = useState<ShellSection>(initialSection);
  const [returnTo, setReturnTo] = useState<ShellSection | null>(returnSection);
  const [route, setRoute] = useState<'tabs' | 'profile'>('tabs');
  const tokens = themeTokens[colorScheme];
  const openProfile = () => setRoute('profile');
  const leaveProfile = () => setRoute('tabs');
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

  return (
    <ThemeContext.Provider value={{ scheme: colorScheme, tokens }}>
      <SafeAreaView style={[styles.safe, { backgroundColor: tokens.ground }]} testID="shell-safe-area">
        <View style={styles.header}>
          {showBack ? (
            <Pressable
              accessibilityLabel={uiCopyDe['global.back'].text}
              accessibilityRole="button"
              onPress={goBack}
              testID="shell-back"
            >
              <Text style={[styles.backLabel, { color: tokens.ink }]}>{uiCopyDe['global.back'].text}</Text>
            </Pressable>
          ) : null}
          <Pressable
            accessibilityLabel={uiCopyDe['action.F12.A01'].text}
            accessibilityRole="button"
            onPress={openProfile}
            testID="shell-profile-entry"
          >
            <Text style={[styles.profileLabel, { color: tokens.ink }]}>
              {uiCopyDe['action.F12.A01'].text}
            </Text>
          </Pressable>
        </View>
        {!reducedMotion ? <View style={[styles.faden, { backgroundColor: tokens.accent }]} testID="shell-faden" /> : null}
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          style={styles.body}
          testID="shell-keyboard-container"
        >
          {route === 'profile' ? (
            <View style={styles.section} testID="profile-surface">
              <Text accessibilityRole="header" style={[styles.title, { color: tokens.ink }]}>
                {uiCopyDe['action.F12.A01'].text}
              </Text>
            </View>
          ) : (
            <View style={styles.section} testID={`section-${section}`}>
              <Text accessibilityRole="header" style={[styles.title, { color: tokens.ink }]} testID={`section-title-${section}`}>
                {uiCopyDe[SECTION_TITLE_KEYS[section]].text}
              </Text>
            </View>
          )}
        </KeyboardAvoidingView>
        {route === 'tabs' ? (
          <View accessibilityRole="tablist" style={[styles.tabbar, { backgroundColor: tokens.panel }]}>
            {TAB_ORDER.map((id) => (
              <Pressable
                accessibilityRole="tab"
                accessibilityState={{ selected: section === id }}
                key={id}
                onPress={() => setSection(id)}
                style={styles.tab}
                testID={`shell-tab-${id}`}
              >
                <Text
                  style={[
                    styles.tabLabel,
                    { color: section === id ? tokens['on-card'] : tokens.ink },
                    section === id && styles.tabLabelSelected,
                  ]}
                >
                  {uiCopyDe[TAB_LABEL_KEYS[id]].text}
                </Text>
              </Pressable>
            ))}
          </View>
        ) : null}
      </SafeAreaView>
    </ThemeContext.Provider>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
  },
  header: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  backLabel: {
    fontSize: 15,
  },
  profileLabel: {
    fontSize: 15,
  },
  faden: {
    height: 3,
    marginHorizontal: 16,
  },
  body: {
    flex: 1,
  },
  section: {
    flex: 1,
    gap: 8,
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
  },
  tabbar: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingVertical: 10,
  },
  tab: {
    paddingHorizontal: 12,
    paddingVertical: 6,
  },
  tabLabel: {
    fontSize: 14,
  },
  tabLabelSelected: {
    fontWeight: '700',
  },
});
