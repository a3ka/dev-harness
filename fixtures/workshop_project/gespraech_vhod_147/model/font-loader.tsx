import { useFonts } from 'expo-font';
import React from 'react';

export function FontReady({ children }: { children: React.ReactNode }) {
  const [ready] = useFonts({ 'DM Sans': require('../../../../mobile/assets/fonts/DMSans-Variable.ttf') });
  return ready ? <>{children}</> : null;
}
