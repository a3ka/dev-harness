// Эталон 999: TextField — пилюля-поле на panel, подпись ink-muted-класса
// (здесь ink), value/onChangeText пробрасываются, secureTextEntry — опция.
import React from 'react';
import { StyleSheet, Text, TextInput, View } from 'react-native';
import { useTheme } from '../theme/context';

export interface TextFieldProps {
  readonly label: string;
  readonly value: string;
  readonly onChangeText: (text: string) => void;
  readonly secureTextEntry?: boolean;
  readonly testID?: string;
}

export function TextField({ label, value, onChangeText, secureTextEntry = false, testID }: TextFieldProps) {
  const { tokens } = useTheme();
  return (
    <View style={styles.field}>
      <Text style={[styles.label, { color: tokens.ink }]}>{label}</Text>
      <TextInput
        onChangeText={onChangeText}
        secureTextEntry={secureTextEntry}
        style={[styles.input, { backgroundColor: tokens.panel, color: tokens.ink }]}
        testID={testID}
        value={value}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  field: {
    gap: 6,
  },
  label: {
    fontSize: 13,
  },
  input: {
    borderRadius: 999,
    paddingHorizontal: 16,
    paddingVertical: 10,
    fontSize: 16,
  },
});
