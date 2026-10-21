// CMP-MOB-002: пилюля-кнопка на токенах D2.2.5.1. Primary заливается
// primary-цветом с подписью on-primary, secondary — нейтральной panel с
// подписью ink. Доступность: accessibilityRole="button" для screen reader
// и UI-проб; accessibilityState.disabled синхронизирован с пропом —
// screen reader не озвучивает выключенный вариант; Pressable сам снимает
// обработчик при disabled, пробы проверяют, что нажатие вызывает onPress
// ровно один раз (enabled) или ноль (disabled).
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useTheme } from '../theme/context';
import type { ThemeTokens } from '../theme/tokens';

export type ButtonVariant = 'primary' | 'secondary';
// 117 v2 (README Button D2.2.5.1: «size-lg 56 для главного CTA на всю
// ширину»; потребитель передаёт size и block): АДДИТИВНО — без пропов
// поведение и стиль прежние (CMP-MOB-002/999).
export type ButtonSize = 'md' | 'lg';

export interface ButtonProps {
  readonly label: string;
  readonly onPress: () => void;
  readonly variant?: ButtonVariant;
  readonly disabled?: boolean;
  readonly testID?: string;
  readonly size?: ButtonSize;
  readonly block?: boolean;
}

interface ButtonColors {
  readonly background: string;
  readonly foreground: string;
}

function colorsFor(tokens: ThemeTokens, variant: ButtonVariant): ButtonColors {
  if (variant === 'primary') {
    return { background: tokens.primary, foreground: tokens['on-primary'] };
  }
  return { background: tokens.panel, foreground: tokens.ink };
}

function ButtonImpl({
  label,
  onPress,
  variant = 'primary',
  disabled = false,
  testID,
  size = 'md',
  block = false,
}: ButtonProps) {
  const { tokens } = useTheme();
  const palette = colorsFor(tokens, variant);
  return (
    <View style={block ? styles.wrapperBlock : styles.wrapper}>
      <Pressable
        accessibilityRole="button"
        accessibilityState={{ disabled }}
        disabled={disabled}
        onPress={onPress}
        style={[styles.pill, size === 'lg' ? styles.pillLg : null, { backgroundColor: palette.background }]}
        testID={testID}
      >
        <Text style={[styles.label, { color: palette.foreground }]}>{label}</Text>
      </Pressable>
    </View>
  );
}

export const Button = React.memo(ButtonImpl);

const styles = StyleSheet.create({
  wrapper: { alignSelf: 'flex-start' },
  wrapperBlock: { alignSelf: 'stretch' },
  pill: {
    borderRadius: 999,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  pillLg: { alignItems: 'center', height: 56, justifyContent: 'center', paddingVertical: 0 },
  label: { fontSize: 16, fontWeight: '600' },
});
