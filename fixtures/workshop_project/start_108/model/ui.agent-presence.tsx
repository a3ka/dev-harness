// CMP-MOB-004: AgentPresence (ui/agent-presence). Спокойное присутствие
// единственного Personal Insurance Agent: состояние аватара idle/working/
// unavailable. F04.V01: присутствие — стартовая поверхность, его не заменяет
// список дел; F04.V03: unavailable показывается честно (не выглядит работающим
// процессом), контекст владельца сохраняется снаружи.
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

import { useTheme } from '../../theme/context';

export type AvatarState = 'idle' | 'working' | 'unavailable';

export interface AgentPresenceProps {
  readonly state?: AvatarState;
  readonly testID?: string;
}

export function AgentPresence({ state = 'idle', testID = 'start-agent-presence' }: AgentPresenceProps) {
  const { tokens } = useTheme();
  return (
    <View
      accessibilityRole="summary"
      testID={testID}
      style={[styles.presence, { backgroundColor: tokens.card, borderColor: tokens.panel }]}
    >
      <View testID={`start-avatar-${state}`} style={[styles.avatar, { borderColor: tokens.ink }]} />
      {/* Состояние присутствия — структурный индикатор; новых немецких
          формулировок не вводится (copy signoff CMP-MOB-089). */}
      <Text testID={`start-agent-state-${state}`} style={[styles.state, { color: tokens['on-card'] }]}>
        {state}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  presence: { alignItems: 'center', borderRadius: 16, borderWidth: 1, gap: 8, padding: 16 },
  avatar: { borderRadius: 28, borderWidth: 2, height: 56, width: 56 },
  state: { fontSize: 12 },
});
