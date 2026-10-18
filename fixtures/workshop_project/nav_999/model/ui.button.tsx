// Эталон 999: Button на токенах D2.2.5.1. Primary — единственный основной CTA
// (лаймовая пилюля dark / чёрная light), подпись on-primary. Secondary — panel+ink.
import React from 'react';
import { Pressable, StyleSheet, Text } from 'react-native';
import { useTheme } from '../theme/context';

export interface ButtonProps {
  readonly label: string;
  readonly onPress: () => void;
  readonly variant?: 'primary' | 'secondary';
  readonly disabled?: boolean;
  readonly testID?: string;
}

export function Button({ label, onPress, variant = 'primary', disabled = false, testID }: ButtonProps) {
  const { tokens } = useTheme();
  const surface = variant === 'primary' ? tokens.primary : tokens.panel;
  const labelColor = variant === 'primary' ? tokens['on-primary'] : tokens.ink;
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ disabled }}
      disabled={disabled}
      onPress={onPress}
      style={[styles.base, { backgroundColor: surface }]}
      testID={testID}
    >
      <Text style={[styles.label, { color: labelColor }]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    borderRadius: 999,
    paddingHorizontal: 20,
    paddingVertical: 12,
    alignSelf: 'flex-start',
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
  },
});
