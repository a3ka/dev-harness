import React, { useRef, useState } from 'react';
import { View, Text, TextInput, Pressable } from 'react-native';
import source from './__tests__/source.json';

interface Reply { status?: string; confirmed?: boolean; evidence: string; retryAfterSeconds?: number; challenge?: string }
interface Ports {
  auth?: { begin(email: string): Promise<Reply>; verify(challenge: string, code: string): Promise<Reply>; resend(challenge: string): Promise<Reply>; recover(): Promise<Reply> };
  api?: { getSession(): Promise<unknown>; getDisclosure(id: string): Promise<unknown>; execute(): Promise<unknown> };
  entry?: { source: string; onboarding: string; pendingIntent: unknown };
}
const demoAuth = {
  begin: async (email: string) => ({ challenge: email, evidence: 'SYNTHETIC' }),
  verify: async () => ({ status: 'authenticated', evidence: 'SYNTHETIC' }),
  resend: async () => ({ confirmed: true, evidence: 'SYNTHETIC' }),
  recover: async () => ({ status: 'unavailable', evidence: 'SYNTHETIC' }),
};
const demoApi = { getSession: async () => source.session, getDisclosure: async () => source.disclosure, execute: async () => undefined };

// Interactive reference ONLY. Never shipped as product or used as expected-output oracle.
export function PilotApp({ auth = demoAuth, api = demoApi, entry }: Ports) {
  const mutant = process.env.PILOT_995_MODEL;
  const [frame, setFrame] = useState('first');
  const [email, setEmail] = useState('');
  const [challenge, setChallenge] = useState('');
  const [code, setCode] = useState('');
  const [invalid, setInvalid] = useState(false);
  const [sent, setSent] = useState(false);
  const [wait, setWait] = useState<number | undefined>();
  const [leak, setLeak] = useState('');
  const generation = useRef(0);
  const copy: Record<string, string> = source.copy;
  const button = (id: string, label: string, press: () => void) => <Pressable testID={id} accessibilityRole="button" onPress={press}><Text>{label}</Text></Pressable>;
  async function begin() {
    if (mutant === 'http-default') await fetch('http://127.0.0.1:9/auth');
    const result = await auth.begin(email); setChallenge(result.challenge || email); setFrame('code');
  }
  async function verify() {
    const current = generation.current;
    const result = await auth.verify(challenge, code);
    if (mutant === 'secret') { console.info(code); setLeak(code); }
    if (current !== generation.current && mutant !== 'stale-email') return;
    if (result.status !== 'authenticated' && mutant !== 'accept-invalid' && mutant !== 'accept-denied') { setInvalid(true); return; }
    if (mutant !== 'skip-reads') { await api.getSession(); await api.getDisclosure('example'); }
    if (mutant === 'replay' && entry?.pendingIntent) await api.execute();
    setCode(''); setFrame(mutant === 'start' ? 'start' : 'welcome');
  }
  async function resend() {
    if (mutant === 'eager-sent') setSent(true);
    const result = await auth.resend(challenge);
    setSent(mutant === 'never-sent' ? false : result.confirmed === true);
    setWait(mutant === 'fake-wait' ? 30 : mutant === 'drop-wait' ? undefined : result.retryAfterSeconds);
  }
  return <View><Text>Demo</Text>{leak ? <Text>{leak}</Text> : null}
    {frame === 'first' && button('first-run-continue', 'Weiter', () => setFrame('email'))}
    {frame === 'email' && <View><Text>{copy['frame.F03.01.title']}</Text><TextInput testID="auth-email" value={email} onChangeText={setEmail} />{button('auth-demo-entry', copy['ui.auth.demo_entry'], begin)}</View>}
    {frame === 'code' && <View><Text>{copy['frame.F03.02.title']}</Text><TextInput testID="auth-code" secureTextEntry value={code} onChangeText={setCode} />
      {button('auth-verify', copy['action.F03.A01'], verify)}
      {button('auth-resend', copy['ui.auth.code_resend'], resend)}
      {button('auth-change-email', 'E-Mail ändern', () => { generation.current++; setCode(''); setSent(false); setWait(undefined); setFrame('email'); })}
      {button('auth-no-access', copy['action.F03.A02'], () => setFrame('recovery'))}
      {invalid && <Text testID="auth-invalid">Ungültiger Code</Text>}
      {sent && <Text>{copy['ui.auth.code_resend_sent']}</Text>}
      {(sent || wait !== undefined) && mutant !== 'unmarked' && <Text>SYNTHETIC</Text>}
      {wait !== undefined && <View testID="auth-cooldown"><Text>{copy['ui.auth.code_resend_wait'].replace('{seconds}', String(wait))}</Text></View>}
    </View>}
    {frame === 'recovery' && <View testID="F03.04"><Text accessibilityRole="header">{copy['frame.F03.04.title']}</Text>
      {mutant !== 'missing-a07' && <View testID="recovery-A07"><Text>{copy['frame.F03.04.body']}</Text></View>}
      {button('auth-recover', copy['action.F03.A02'], async () => { await auth.recover(); })}
      {button('auth-return', 'Zurück', () => setFrame('email'))}
    </View>}
    {frame === 'welcome' && <View testID="F02.01"><Text>{copy['frame.F02.01.body']}</Text></View>}
    {frame === 'start' && <Text testID="protected-start">Start</Text>}
  </View>;
}
