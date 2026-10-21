import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useTheme } from '@/theme/context';
import { Button } from '@/ui/button';
import { TextField } from '@/ui/text-field';

const COPY = {
  'frame.F03.01.title': 'Anmelden oder Konto erstellen',
  'frame.F03.01.body':
    'Nutzen Sie den angebotenen Anmeldeweg, um auf Ihre Versicherungen zuzugreifen.',
  'frame.F03.02.title': 'Kontakt bestätigen',
  'frame.F03.02.body':
    'Geben Sie den zugesandten Code ein. Prüfen Sie bei Bedarf Ihre Kontaktdaten.',
  'frame.F03.04.title': 'Zugang wiederherstellen',
  'frame.F03.04.body':
    'Wir führen Sie durch die verfügbaren Schritte zur Wiederherstellung.',
  'action.F03.A01': 'Anmelden',
  'action.F03.A02': 'Zugang wiederherstellen',
  'ui.auth.demo_entry': 'Demo mit Beispieldaten ansehen',
  'ui.auth.code_resend': 'Code erneut senden',
  'ui.auth.code_resend_sent': 'Ein neuer Code wurde gesendet.',
  'ui.auth.code_resend_wait': 'Sie können in {seconds} Sekunden einen neuen Code anfordern.',
  'auth.change_email': 'E-Mail ändern',
  'auth.return': 'Zurück',
} as const;

export type AuthFrame = 'email' | 'code' | 'recovery' | 'unavailable';

export interface AuthScreenProps {
  readonly frame: AuthFrame;
  readonly email: string;
  readonly code: string;
  readonly sent: boolean;
  readonly waitSeconds: number | undefined;
  readonly invalid: boolean;
  readonly unavailableReason: string | null;
  readonly onEmailChange: (value: string) => void;
  readonly onCodeChange: (value: string) => void;
  readonly onDemoEntry: () => void;
  readonly onVerify: () => void;
  readonly onResend: () => void;
  readonly onChangeEmail: () => void;
  readonly onNoAccess: () => void;
  readonly onRecover: () => void;
  readonly onReturn: () => void;
}

const EMAIL_TEST_ID = 'auth-email';
const CODE_TEST_ID = 'auth-code';

// 117 (CMP-MOB-006, слово владельца ~19:28): кадры входа F03.01/F03.02 —
// состав по UX-JSON F01/F03 + каталогу, компоненты продукта на токенах
// D2.2.5.1 (@/ui/button, @/ui/text-field; подпись поля — ключ body кадра),
// заголовок типографикой .title, палитра только через useTheme. Кадры
// F03.04/unavailable — поверхность 995, стили базы не тронуты (frozen 111/1).
const D22_TITLE = {
  fontSize: 28,
  fontWeight: '500',
  lineHeight: 32,
} as const;

export function AuthScreen(props: AuthScreenProps) {
  const {
    frame,
    email,
    code,
    sent,
    waitSeconds,
    invalid,
    unavailableReason,
    onEmailChange,
    onCodeChange,
    onDemoEntry,
    onVerify,
    onResend,
    onChangeEmail,
    onNoAccess,
    onRecover,
    onReturn,
  } = props;

  return (
    <View>
      {frame === 'email' ? (
        <EmailFrame email={email} onEmailChange={onEmailChange} onDemoEntry={onDemoEntry} />
      ) : null}

      {frame === 'code' ? (
        <CodeFrame
          code={code}
          invalid={invalid}
          sent={sent}
          waitSeconds={waitSeconds}
          onCodeChange={onCodeChange}
          onVerify={onVerify}
          onResend={onResend}
          onChangeEmail={onChangeEmail}
          onNoAccess={onNoAccess}
        />
      ) : null}

      {frame === 'unavailable' ? (
        <View testID="auth-unavailable" accessibilityRole="alert">
          <Text style={styles.unavailableTitle}>{unavailableReason ?? 'Kein Zugriff'}</Text>
        </View>
      ) : null}

      {frame === 'recovery' ? (
        <RecoveryFrame onRecover={onRecover} onReturn={onReturn} />
      ) : null}
    </View>
  );
}

interface EmailFrameProps {
  readonly email: string;
  readonly onEmailChange: (value: string) => void;
  readonly onDemoEntry: () => void;
}

function EmailFrame({ email, onEmailChange, onDemoEntry }: EmailFrameProps) {
  const { tokens } = useTheme();
  return (
    <View>
      <Text accessibilityRole="header" style={[styles.title, D22_TITLE, { color: tokens.ink }]}>
        {COPY['frame.F03.01.title']}
      </Text>
      <TextField
        testID={EMAIL_TEST_ID}
        label={COPY['frame.F03.01.body']}
        value={email}
        onChangeText={onEmailChange}
      />
      <Button
        testID="auth-demo-entry"
        variant="primary"
        label={COPY['ui.auth.demo_entry']}
        onPress={onDemoEntry}
      />
    </View>
  );
}

interface CodeFrameProps {
  readonly code: string;
  readonly invalid: boolean;
  readonly sent: boolean;
  readonly waitSeconds: number | undefined;
  readonly onCodeChange: (value: string) => void;
  readonly onVerify: () => void;
  readonly onResend: () => void;
  readonly onChangeEmail: () => void;
  readonly onNoAccess: () => void;
}

function CodeFrame({
  code,
  invalid,
  sent,
  waitSeconds,
  onCodeChange,
  onVerify,
  onResend,
  onChangeEmail,
  onNoAccess,
}: CodeFrameProps) {
  const { tokens } = useTheme();
  const showCooldown = waitSeconds !== undefined;
  return (
    <View>
      <Text accessibilityRole="header" style={[styles.title, D22_TITLE, { color: tokens.ink }]}>
        {COPY['frame.F03.02.title']}
      </Text>
      <TextField
        testID={CODE_TEST_ID}
        label={COPY['frame.F03.02.body']}
        secureTextEntry
        value={code}
        onChangeText={onCodeChange}
      />
      <Button
        testID="auth-verify"
        variant="primary"
        label={COPY['action.F03.A01']}
        onPress={onVerify}
      />
      <Pressable testID="auth-resend" accessibilityRole="button" onPress={onResend}>
        <Text style={[styles.linkText, { color: tokens['accent-text'] }]}>{COPY['ui.auth.code_resend']}</Text>
      </Pressable>
      <Pressable testID="auth-change-email" accessibilityRole="button" onPress={onChangeEmail}>
        <Text style={[styles.linkText, { color: tokens['accent-text'] }]}>{COPY['auth.change_email']}</Text>
      </Pressable>
      <Pressable testID="auth-no-access" accessibilityRole="button" onPress={onNoAccess}>
        <Text style={[styles.linkText, { color: tokens['accent-text'] }]}>{COPY['action.F03.A02']}</Text>
      </Pressable>
      {invalid ? (
        <Text testID="auth-invalid" style={styles.invalid}>
          Ungültiger Code
        </Text>
      ) : null}
      {sent ? <Text style={styles.notice}>{COPY['ui.auth.code_resend_sent']}</Text> : null}
      {sent || showCooldown ? <Text style={styles.syntheticMark}>SYNTHETIC</Text> : null}
      {showCooldown ? (
        <View testID="auth-cooldown" style={styles.cooldown}>
          <Text>
            {COPY['ui.auth.code_resend_wait'].replace('{seconds}', String(waitSeconds))}
          </Text>
        </View>
      ) : null}
    </View>
  );
}

interface RecoveryFrameProps {
  readonly onRecover: () => void;
  readonly onReturn: () => void;
}

function RecoveryFrame({ onRecover, onReturn }: RecoveryFrameProps) {
  return (
    <View testID="F03.04">
      <Text accessibilityRole="header" style={styles.title}>
        {COPY['frame.F03.04.title']}
      </Text>
      <View testID="recovery-A07">
        <Text style={styles.body}>{COPY['frame.F03.04.body']}</Text>
      </View>
      <Pressable testID="auth-recover" accessibilityRole="button" onPress={onRecover}>
        <Text style={styles.buttonText}>{COPY['action.F03.A02']}</Text>
      </Pressable>
      <Pressable testID="auth-return" accessibilityRole="button" onPress={onReturn}>
        <Text style={styles.linkText}>{COPY['auth.return']}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  title: {
    fontSize: 22,
    fontWeight: '600',
    color: '#111111',
    marginBottom: 12,
  },
  input: {
    borderWidth: 1,
    borderColor: '#999999',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
    color: '#111111',
    marginBottom: 12,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
    backgroundColor: '#111111',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8,
    marginBottom: 8,
    overflow: 'hidden',
    textAlign: 'center',
  },
  linkText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#1144CC',
    marginTop: 4,
    marginBottom: 8,
  },
  invalid: {
    fontSize: 14,
    fontWeight: '600',
    color: '#B00020',
    marginTop: 8,
  },
  notice: {
    fontSize: 14,
    color: '#1144CC',
    marginTop: 8,
  },
  syntheticMark: {
    fontSize: 12,
    color: '#777777',
    marginTop: 4,
  },
  cooldown: {
    marginTop: 8,
    padding: 8,
    borderRadius: 6,
    backgroundColor: '#F2F2F2',
  },
  unavailableTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#B00020',
  },
  body: {
    fontSize: 14,
    color: '#333333',
  },
});
