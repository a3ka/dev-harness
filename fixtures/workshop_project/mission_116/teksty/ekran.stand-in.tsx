// Stand-in экрана Mission (F05, CMP-MOB-005): честная модель для
// статической пробы 116. Поведенческие оси issue #9 (черновик держится
// на путях вложения/офлайна/already_accepted и снимается после принятой
// отправки и новой темы; already_accepted без дубля; interrupted не
// завершает миссию; отдельный intent; отозванный источник скрыт) и
// состояния composer без PNG (слово владельца 17:40): каждое состояние
// рендерит СВОЙ блок — testID, className-токены ds/tokens.css, текст —
// ссылки на каталог копии (katalog_kopii.json), не литералы.
import { useState } from 'react';

// Суффикс чипа вложения из компонентов D2.2.5.1 (bundle.js, attachment
// state 'reading'); в каталоге BrokerOS_UI_Copy_DE строки нет — источник
// слова владельца для кадров без PNG.
const CHIP_LESET_SUFFIX = ' · wird gelesen';

// Черновик переживает контролируемый ремоунт (draft_until_admission_
// then_same_mission): хранилище модуля, а не только локальный state.
let draftStore = '';

export function ConversationScreen({ api, copy, docs, response }) {
  const [draft, setDraftState] = useState(draftStore);
  const setDraft = (next) => {
    draftStore = next;
    setDraftState(next);
  };
  const [sendState, setSendState] = useState('draft');
  const [messages, setMessages] = useState([]);
  const [sources] = useState([]);

  const onAttach = (doc) => {
    // черновик НЕ теряется на пути вложения
    setSendState('attachment_pending');
    api.createUpload(doc.missionId, doc.fileName);
  };

  const onSend = async () => {
    const status = await api.postMessage({ text: draft });
    if (status === 'accepted') {
      setDraft('');
      setSendState('sent');
      return;
    }
    if (status === 'already_accepted') {
      // дубль НЕ создаётся: повтор рендерит состояние, без append
      setSendState('already_accepted');
      return;
    }
    setSendState('queued_offline');
  };

  const onNewTopic = async (topic) => {
    // отдельный intent ДО отправки: новая тема ≠ новое сообщение
    const intent = await api.createIntent(topic);
    setDraft('');
    await api.postMessage({ intentId: intent.id });
  };

  // отозванный источник не показывается
  const sourcesVisible = sources.filter((d) => d.revoked !== true);

  return (
    <View>
      {response === 'interrupted' ? (
        <View testID="mission_response_interrupted" className="panel ink line">
          <Text>{copy['frame.F05.05.title'].text}</Text>
          <Text>{copy['frame.F05.05.body'].text}</Text>
        </View>
      ) : null}
      {sendState === 'queued_offline' ? (
        <View testID="mission_queued_offline" className="warm on-warm panel">
          <Text>{copy['state.G06.title'].text}</Text>
          <Pressable testID="mission_offline_retry" onPress={onSend}>
            <Text>{copy['global.retry'].text}</Text>
          </Pressable>
        </View>
      ) : null}
      {sendState === 'attachment_pending' ? (
        <View testID="mission_attachment_foto" className="panel on-card">
          {docs.map((d) => (
            <View key={d.name}>
              <Text testID="mission_chip_wird_gelesen">
                {d.name + CHIP_LESET_SUFFIX}
              </Text>
              <Pressable testID="attachment-complete-UPL-1"
                onPress={() => api.completeUpload(d.name)} />
            </View>
          ))}
        </View>
      ) : null}
      {sendState === 'already_accepted' ? (
        <View testID="mission_already_accepted" className="calm on-calm panel">
          <Text>{copy['frame.F05.02.title'].text}</Text>
          <Pressable onPress={onSend}>
            <Text>{copy['action.F05.A01'].text}</Text>
          </Pressable>
        </View>
      ) : null}
      {sendState === 'draft' ? (
        <View testID="mission_frame_f05_07" className="panel on-card line ink-muted">
          <Text>{copy['frame.F05.07.title'].text}</Text>
          <Text>{copy['frame.F05.07.body'].text}</Text>
        </View>
      ) : null}
      {sourcesVisible.map((d) => (
        <Pressable testID="mission_source_ref" key={d.id}>
          <Text>{d.label}</Text>
        </Pressable>
      ))}
      <Composer
        testID="mission_composer_input"
        value={draft}
        onChangeText={setDraft}
      />
    </View>
  );
}
