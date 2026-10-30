// Чат-хост текст-чата Gespräch (контракт 149, референс-раскладка; зона
// mobile/src/features/conversation/, файл канонического пути). Состояния
// экрана — sostojanija пачки (plaschki/tema-verlauf/schreiben-temy/
// foto/dokument); testID — грамматика проходимости пачки (gespraech-*,
// единый источник mobile/e2e-gespraech-tekst/ekran.json). Числа движения
// хост не изобретает: планы переходов — машина chat-machine.ts (её судит
// численный канон пачки); рендер здесь — структурный (зонд батареи 149
// судит поведение: состав целей и реакции нажатий, прецедент 148).
import React, { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { ChatComposer } from '../../ui/conversation-composer/conversation-composer';
import { useTheme } from '../../theme/context';
import { katalogKopii, predlozheno } from './chat-kopija';

type Sostojanie = 'plaschki' | 'tema-verlauf' | 'schreiben-temy' | 'dokument';

interface Soobschenie {
  readonly ot: 'polzovatel' | 'agent';
  readonly tekst: string;
}

export interface GespraechTekstChatProps {
  readonly testID?: string;
}

export function GespraechTekstChat({
  testID = 'gespraech-tekst-chat',
}: GespraechTekstChatProps) {
  const { tokens } = useTheme();
  const [sostojanie, setSostojanie] = useState<Sostojanie>('plaschki');
  const [tema, setTema] = useState<string>('');
  const [verlauf, setVerlauf] = useState<Soobschenie[]>([]);
  const [draft, setDraft] = useState('');
  const [voprosy, setVoprosy] = useState<string[]>([]);

  const sprashivat = (vopros: string) => {
    setVoprosy((pred) => pred.concat([vopros]));
  };

  const otpravit = (tekst: string) => {
    setVerlauf((pred) => pred.concat([{ ot: 'polzovatel', tekst }]));
    setDraft('');
    // отправка открывает разговор (GA-11 → GA-13 → Verlauf, T32)
    setSostojanie('tema-verlauf');
  };

  const nazhatTemy = (id: string, nadpis: string) => {
    setTema(nadpis);
    setSostojanie('tema-verlauf');
    setVerlauf([]);
    setVoprosy([]);
    sprashivat(predlozheno.voprosTemy);
  };

  const nazhatChip = (nadpis: string) => {
    setVerlauf((pred) => pred.concat([{ ot: 'polzovatel', tekst: nadpis }]));
    sprashivat(predlozheno.voprosWeiter);
  };

  const obolochka = { borderColor: tokens.panel };
  const nadpis = { color: tokens.ink };

  return (
    <View testID={testID} style={[styles.ekran, { backgroundColor: tokens.ground }]}>
      <View style={styles.verh}>
        <Pressable
          accessibilityLabel={katalogKopii['frame.F05.02.title'].text}
          accessibilityRole="button"
          onPress={() => setSostojanie('tema-verlauf')}
          style={({ pressed }) => [
            styles.knopka_verh, obolochka, { opacity: pressed ? 0.7 : 1 },
          ]}
          testID="gespraech-verlauf"
        >
          <Text style={nadpis}>{katalogKopii['frame.F05.02.title'].text}</Text>
        </Pressable>
        {sostojanie === 'tema-verlauf' ? (
          <Text style={[styles.tema, nadpis]} testID="gespraech-tema-verh">
            {tema}
          </Text>
        ) : null}
      </View>

      {sostojanie === 'plaschki' ? (
        <ScrollView testID="gespraech-plaschki">
          <Text style={[styles.zagolovok, nadpis]}>
            {katalogKopii['frame.F04.01.title'].text}
          </Text>
          <Pressable
            accessibilityRole="button"
            onPress={() => nazhatTemy('schaden', predlozheno.srochno)}
            style={({ pressed }) => [
              styles.plashka, styles.plashka_srochnaja, obolochka,
              { opacity: pressed ? 0.7 : 1 },
            ]}
            testID="gespraech-topic-schaden"
          >
            <Text style={nadpis}>{predlozheno.srochno}</Text>
            <Pressable
              accessibilityLabel={katalogKopii['ia115.entry.speak'].text}
              accessibilityRole="button"
              onPress={() => nazhatTemy('schaden', predlozheno.srochno)}
              style={({ pressed }) => [
                styles.knopka_golosa, { opacity: pressed ? 0.7 : 1 },
              ]}
              testID="gespraech-topic-schaden-speak"
            >
              <Text style={nadpis}>
                {katalogKopii['ia115.entry.speak'].text}
              </Text>
            </Pressable>
          </Pressable>
          {predlozheno.temy.map((t) => (
            <View key={t.id} style={[styles.plashka, obolochka]}>
              <Pressable
                accessibilityRole="button"
                onPress={() => nazhatTemy(t.id, t.nadpis)}
                style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}
                testID={'gespraech-topic-' + t.id}
              >
                <Text style={[styles.tema, nadpis]}>{t.nadpis}</Text>
                <Text style={nadpis}>
                  {katalogKopii['ui.mission.group.working'].text}
                </Text>
              </Pressable>
              <Pressable
                accessibilityLabel={predlozheno.erzaehlen + ' ' + t.nadpis}
                accessibilityRole="button"
                onPress={() => {
                  setTema(t.nadpis);
                  setSostojanie('schreiben-temy');
                }}
                style={({ pressed }) => [
                  styles.knopka_erzaehlen, obolochka,
                  { opacity: pressed ? 0.7 : 1 },
                ]}
                testID={'gespraech-topic-' + t.id + '-erzaehlen'}
              >
                <Text style={nadpis}>{predlozheno.erzaehlen}</Text>
              </Pressable>
            </View>
          ))}
        </ScrollView>
      ) : null}

      {sostojanie === 'tema-verlauf' || sostojanie === 'schreiben-temy' ? (
        <ScrollView style={styles.verlauf} testID="gespraech-verlauf-spisok">
          {verlauf.map((s, i) => (
            <Text
              key={i}
              style={[styles.soobschenie, nadpis]}
              testID={'gespraech-soobschenie-' + s.ot}
            >
              {s.tekst}
            </Text>
          ))}
          {voprosy.map((v, i) => (
            <Text
              key={'v' + i}
              style={[styles.vopros, nadpis]}
              testID="gespraech-vopros-agenta"
            >
              {v}
            </Text>
          ))}
          {voprosy.length > 0 && verlauf.length === 0 ? (
            <View style={[styles.chipy, obolochka]} testID="gespraech-chipy">
              {predlozheno.chipy.map((c) => (
                <Pressable
                  key={c.id}
                  accessibilityRole="button"
                  onPress={() => nazhatChip(c.nadpis)}
                  style={({ pressed }) => [
                    styles.chip, obolochka, { opacity: pressed ? 0.7 : 1 },
                  ]}
                  testID={'gespraech-chip-' + c.id}
                >
                  <Text style={nadpis}>{c.nadpis}</Text>
                </Pressable>
              ))}
              <Pressable
                accessibilityRole="button"
                onPress={() => setSostojanie('schreiben-temy')}
                style={({ pressed }) => [
                  styles.chip, obolochka, { opacity: pressed ? 0.7 : 1 },
                ]}
                testID="gespraech-lieber-erzaehlen"
              >
                <Text style={nadpis}>{predlozheno.lieber}</Text>
              </Pressable>
            </View>
          ) : null}
        </ScrollView>
      ) : null}

      {sostojanie === 'schreiben-temy' ? (
        <View style={[styles.temy_stroka, obolochka]} testID="gespraech-temy-stroka">
          {predlozheno.temy.map((t) => (
            <Pressable
              key={t.id}
              accessibilityRole="button"
              onPress={() => nazhatTemy(t.id, t.nadpis)}
              style={({ pressed }) => [
                styles.tema_piljulja, obolochka, { opacity: pressed ? 0.7 : 1 },
              ]}
              testID={'gespraech-tema-' + t.id}
            >
              <Text style={nadpis}>{t.nadpis}</Text>
            </Pressable>
          ))}
        </View>
      ) : null}

      {sostojanie === 'dokument' ? (
        <View style={[styles.vlozhenie, obolochka]} testID="gespraech-vlozhenie">
          <Text style={nadpis}>
            {katalogKopii['action.F05.A02'].text}
          </Text>
        </View>
      ) : null}

      <ChatComposer
        onChangeText={setDraft}
        onGolos={() => setSostojanie('schreiben-temy')}
        onOtpravit={otpravit}
        onVlozhit={() => setSostojanie('dokument')}
        value={draft}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  ekran: { flex: 1, gap: 8, padding: 16 },
  verh: { flexDirection: 'row', gap: 8 },
  zagolovok: { fontSize: 22, fontWeight: '700' },
  plashka: { borderRadius: 12, borderWidth: 1, flexDirection: 'row', gap: 8,
             justifyContent: 'space-between', marginBottom: 8, padding: 12 },
  plashka_srochnaja: { borderWidth: 2 },
  tema: { fontSize: 16, fontWeight: '600' },
  verlauf: { flex: 1 },
  soobschenie: { borderRadius: 10, marginBottom: 6, padding: 10 },
  vopros: { borderRadius: 10, marginBottom: 6, padding: 10 },
  chipy: { borderRadius: 10, borderWidth: 1, flexDirection: 'row',
           flexWrap: 'wrap', gap: 8, padding: 10 },
  chip: { borderRadius: 8, borderWidth: 1, minHeight: 44, paddingHorizontal: 12,
          justifyContent: 'center' },
  temy_stroka: { borderRadius: 10, borderWidth: 1, flexDirection: 'row',
                 gap: 8, padding: 8 },
  tema_piljulja: { borderRadius: 8, borderWidth: 1, minHeight: 44,
                   justifyContent: 'center', paddingHorizontal: 12 },
  vlozhenie: { borderRadius: 10, borderWidth: 1, padding: 16 },
  knopka_verh: { borderRadius: 8, borderWidth: 1, minHeight: 44,
                 justifyContent: 'center', paddingHorizontal: 12 },
  knopka_golosa: { borderRadius: 8, borderWidth: 1, minHeight: 44,
                   minWidth: 44, justifyContent: 'center',
                   paddingHorizontal: 8 },
  knopka_erzaehlen: { borderRadius: 8, borderWidth: 1, minHeight: 44,
                      justifyContent: 'center', paddingHorizontal: 12 },
});
