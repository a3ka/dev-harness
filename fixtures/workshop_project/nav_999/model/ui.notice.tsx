// Эталон 999: Notice — карточка-уведомление на токенах, доступная как alert.
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { useTheme } from '../theme/context';

export interface NoticeProps {
  readonly children: React.ReactNode;
  readonly testID?: string;
}

export function Notice({ children, testID }: NoticeProps) {
  const { tokens } = useTheme();
  return (
    <View
      accessible
      accessibilityRole="alert"
      style={[styles.base, { backgroundColor: tokens.card, borderColor: tokens.panel }]}
      testID={testID}
    >
      <Text style={[styles.text, { color: tokens['on-card'] }]}>{children}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  base: {
    borderRadius: 12,
    borderWidth: 1,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  text: {
    fontSize: 14,
  },
});
