// 116 (CMP-MOB-005) r5, арбитраж 0259fb00: ИСПОЛНЯЕМАЯ семья поведения и
// рендера беседы (Jest/RNTL, product-CI). Оракул — source.json, снятый с
// read-only docs/ Complior-mob ДО запуска субъекта; все ожидания —
// ЛИТЕРАЛЫ ниже (правило 8: ни одна клетка не сверяется значением,
// прочитанным у субъекта). Клетки K1–K12 — семья r2 (12/12 зелёных на
// базе продукта, замер арбитра); K13 — черновик переживает ремоунт
// (путь вкладки, draftStore); K14–K18 — рендер кадров без PNG (слово
// владельца 17:40): каждое состояние — СВОЙ блок mission_* (testID
// манифеста sostojanija_bez_png), строки каталога побайтово ВНУТРИ блока
// и видимы, чужих Text в поддереве блока нет, множество className-токенов
// РАВНО декларации манифеста (равенство декларацией, не требованием
// палитры — арбитраж 0259fb00 п.3). K19 — новая тема снимает ещё НЕ
// отправленный черновик (блокер круга 3: клетка NEW_TOPIC_SEPARATE_INTENT
// сначала отправляет текст, потому нечувствительна к отсутствию очистки
// в этом переходе; замер критика — mutant 18/19, honest 19/19). Текст
// файла пинуется sha256 в source.json батареи и байт-идентичен в
// продукте (страж формы).
import { cleanup, fireEvent, render, screen, waitFor, within } from '@testing-library/react-native';
import React from 'react';

import {
  ConversationScreen,
  type ConversationTurnData,
  type OutgoingMessage,
} from '@/features/conversation/conversation-screen';
import { ThemeContext } from '@/theme/context';
import { themeTokens, type ColorScheme } from '@/theme/tokens';

// ---- EXPECT: литералы оракула (source.json, побайтово) ----
const GROUND_DARK = '#0a0a0a';
const GROUND_LIGHT = '#f3f2ee';
const INK_DARK = '#f2f1ec';
const INK_LIGHT = '#121211';
const FRAME_F05_01_TITLE = 'Was ist passiert?';
const FRAME_F05_01_BODY = 'Beschreiben Sie, wobei Sie Unterstützung benötigen.';
const FRAME_F05_02_TITLE = 'Gesprächsverlauf';
const FRAME_F05_05_TITLE = 'Antwort wird vorbereitet';
const FRAME_F05_05_BODY = 'Sie können die Bearbeitung unterbrechen. Bereits vorliegende Ergebnisse bleiben sichtbar.';
const FRAME_F05_06_BODY = 'Öffnen Sie die Quelle, um die Grundlage dieser Aussage zu prüfen.';
const FRAME_F05_07_TITLE = 'Nicht gesendeter Entwurf';
const FRAME_F05_07_BODY = 'Ihre Nachricht wurde noch nicht gesendet. Sie können sie weiterbearbeiten.';
const STATE_G06_TITLE = 'Keine Verbindung';
const GLOBAL_RETRY = 'Erneut prüfen';
const ACTION_F05_A01 = 'Nachricht senden';
const ACTION_F05_A02 = 'Dokument hinzufügen';
const ACTION_F05_A03 = 'Neues Thema';
// Суффикс чипа вложения (компоненты D2.2.5.1, attachment state 'reading'):
const CHIP_LESET_SUFFIX = ' · wird gelesen';
// Грамматика данных F05 (BrokerOS_Mobile_Design_Data.json#features/F05):
const MISSION_ID = 'MIS-CAR-01';
const NEW_TOPIC_MISSION_ID = 'MIS-NEW-42';
const BASELINE_TURN_TEXT = 'Я купила автомобиль.';
const SOURCE_REF = 'DOC-VEH-01:p1';
const PICKED_FILE = 'fahrschein.pdf';
const ATTACHMENT_PENDING = 'attachment_pending';
const UPLOADED = 'uploaded';

// ---- EXPECT: декларация манифеста sostojanija_bez_png (токены D2.2.5.1) ----
const TOKENY_F05_07 = ['ink-muted', 'line', 'on-card', 'panel'];
const TOKENY_V01 = ['on-warm', 'panel', 'warm'];
const TOKENY_V02 = ['ink', 'line', 'panel'];
const TOKENY_V04 = ['calm', 'on-calm', 'panel'];

const BASELINE_TURNS = [
  { key: 'srv-1', role: 'user' as const, text: BASELINE_TURN_TEXT, sendState: 'sent' as const },
];

function makePorts() {
  return {
    onSendMessage: jest.fn(async (_message: OutgoingMessage) => 'accepted' as const),
    onAttach: jest.fn(() => ({ attachmentId: 'UPL-1', name: PICKED_FILE })),
    onCompleteUpload: jest.fn(async () => 'uploaded' as const),
    onNewTopic: jest.fn(async () => NEW_TOPIC_MISSION_ID),
  };
}

async function renderConversation(
  scheme: ColorScheme = 'dark',
  overrides: {
    turns?: readonly ConversationTurnData[];
    responseState?: 'idle' | 'interrupted';
    sendStatus?: 'accepted' | 'already_accepted' | 'queued_offline';
    uploadStatus?: 'uploaded' | 'failed';
    draftValue?: string;
    draftOnChange?: (next: string) => void;
  } = {},
) {
  const ports = makePorts();
  if (overrides.sendStatus) {
    ports.onSendMessage.mockImplementation(async () => overrides.sendStatus as 'accepted');
  }
  if (overrides.uploadStatus) {
    ports.onCompleteUpload.mockImplementation(async () => overrides.uploadStatus as 'uploaded');
  }
  const utils = await render(
    <ThemeContext.Provider value={{ scheme, tokens: themeTokens[scheme] }}>
      <ConversationScreen
        draftOnChange={overrides.draftOnChange}
        draftValue={overrides.draftValue}
        missionId={MISSION_ID}
        onAttach={ports.onAttach}
        onCompleteUpload={ports.onCompleteUpload}
        onNewTopic={ports.onNewTopic}
        onSendMessage={ports.onSendMessage}
        responseState={overrides.responseState ?? 'idle'}
        turns={overrides.turns ?? BASELINE_TURNS}
      />
    </ThemeContext.Provider>,
  );
  return { ports, ...utils };
}

function styleOf(node: { props: { style?: unknown } }): Record<string, unknown> {
  const style = node.props.style;
  if (Array.isArray(style)) {
    return Object.assign({}, ...style.map((s: unknown) => (s ? s : {})));
  }
  return (style as Record<string, unknown>) ?? {};
}

// Все строки поддерева блока (JSX-комментарий, {false && …}, подмена
// значения — строка отсутствует или чужая; закрытое множество — здесь).
function strokiPoddereva(koren: unknown): string[] {
  const out: string[] = [];
  const hod = (uzel: unknown): void => {
    if (typeof uzel === 'string') {
      out.push(uzel);
      return;
    }
    if (Array.isArray(uzel)) {
      uzel.forEach(hod);
      return;
    }
    if (uzel && typeof uzel === 'object' && 'props' in uzel) {
      hod((uzel as { props: { children?: unknown } }).props.children);
    }
  };
  hod(koren);
  return out;
}

function tokenyKlassa(blok: { props: { className?: string } }): string[] {
  return blok.props.className?.split(/\s+/).filter(Boolean).sort() ?? [];
}

beforeEach(() => {
  jest.clearAllMocks();
});

it('116 mission CONVERSATION_STRUCTURE_DARK — показывает canvas F05.01, историю F05.02 и действия A01/A02/A03', async () => {
    await renderConversation('dark');
    await screen.findByText(FRAME_F05_01_TITLE);
    expect(screen.getByText(FRAME_F05_01_BODY)).toBeTruthy();
    expect(screen.getByText(FRAME_F05_02_TITLE)).toBeTruthy();
    expect(screen.getByText(ACTION_F05_A01)).toBeTruthy();
    expect(screen.getByText(ACTION_F05_A02)).toBeTruthy();
    expect(screen.getByText(ACTION_F05_A03)).toBeTruthy();
    expect(screen.getByText(MISSION_ID)).toBeTruthy();
    const screenRoot = screen.getByTestId('conversation');
    expect(styleOf(screenRoot).backgroundColor).toBe(GROUND_DARK);
    expect(styleOf(screen.getByText(FRAME_F05_01_TITLE)).color).toBe(INK_DARK);
    expect(screen.getByTestId('conversation-canvas')).toBeTruthy();
    expect(screen.getByTestId('conversation-transcript')).toBeTruthy();
    await cleanup();
  });

it('116 mission CONVERSATION_STRUCTURE_LIGHT — та же поверхность в светлой схеме на токенах', async () => {
    await renderConversation('light');
    await screen.findByText(FRAME_F05_01_TITLE);
    expect(screen.getByText(ACTION_F05_A01)).toBeTruthy();
    expect(screen.getByText(MISSION_ID)).toBeTruthy();
    const screenRoot = screen.getByTestId('conversation');
    expect(styleOf(screenRoot).backgroundColor).toBe(GROUND_LIGHT);
    expect(styleOf(screen.getByText(FRAME_F05_01_TITLE)).color).toBe(INK_LIGHT);
    await cleanup();
  });

it('116 mission SEND_SAME_MISSION_AND_DRAFT_CLEARED — отправляет в той же Mission и очищает черновик', async () => {
    const { ports } = await renderConversation('dark');
    const input = screen.getByTestId('start-composer-input');
    await fireEvent.changeText(input, 'Ich habe einen Unfall gehabt.');
    await fireEvent.press(screen.getByTestId('composer-send'));
    await waitFor(() => {
      expect(ports.onSendMessage).toHaveBeenCalledTimes(1);
    });
    const payload = ports.onSendMessage.mock.calls[0][0] as {
      mission_id: string;
      client_message_id: string;
      text: string;
    };
    expect(payload.mission_id).toBe(MISSION_ID);
    expect(payload.client_message_id).not.toBe('');
    expect(payload.text).toBe('Ich habe einen Unfall gehabt.');
    await screen.findByText('Ich habe einen Unfall gehabt.');
    expect(screen.getByText(MISSION_ID)).toBeTruthy();
    await waitFor(() => {
      expect((screen.getByTestId('start-composer-input') as { props: { value?: string } }).props.value).toBe('');
    });
    await cleanup();
  });

it('116 mission ALREADY_ACCEPTED_NO_DUPE — повтор не создаёт дубль; черновик снят', async () => {
    const { ports } = await renderConversation('dark', { sendStatus: 'already_accepted' });
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), 'Noch eine Frage.');
    await fireEvent.press(screen.getByTestId('composer-send'));
    await waitFor(() => {
      expect(ports.onSendMessage).toHaveBeenCalledTimes(1);
    });
    expect(screen.queryByText('Noch eine Frage.')).toBeNull();
    expect(screen.getAllByTestId('conversation-turn')).toHaveLength(1);
    await waitFor(() => {
      expect((screen.getByTestId('start-composer-input') as { props: { value?: string } }).props.value).toBe('');
    });
    await cleanup();
  });

it('116 mission DRAFT_KEPT_ON_ATTACH — добавление вложения не теряет текст черновика', async () => {
    const { ports } = await renderConversation('dark');
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), 'Meine Nachricht bleibt.');
    await fireEvent.press(screen.getByTestId('composer-attach'));
    expect(ports.onAttach).toHaveBeenCalledTimes(1);
    await screen.findByText(PICKED_FILE);
    expect(
      (screen.getByTestId('start-composer-input') as { props: { value?: string } }).props.value,
    ).toBe('Meine Nachricht bleibt.');
    await cleanup();
  });

it('116 mission CONTROLLED_DRAFT_PORT — контролируемый черновик: рендер внешнего значения, attach не сбрасывает', async () => {
    const draftOnChange = jest.fn();
    await renderConversation('dark', {
      draftValue: 'Vorentwurf',
      draftOnChange,
    });
    const input = screen.getByTestId('start-composer-input') as { props: { value?: string } };
    expect(input.props.value).toBe('Vorentwurf');
    await fireEvent.press(screen.getByTestId('composer-attach'));
    await screen.findByText(PICKED_FILE);
    expect(draftOnChange).not.toHaveBeenCalledWith('');
    expect((screen.getByTestId('start-composer-input') as { props: { value?: string } }).props.value).toBe('Vorentwurf');
    await cleanup();
  });

it('116 mission ATTACH_PENDING_NOT_READ — выбранный файл отличим от доставленного', async () => {
    await renderConversation('dark');
    await fireEvent.press(screen.getByTestId('composer-attach'));
    await screen.findByText(PICKED_FILE);
    expect(screen.getByTestId('attachment-state').props.children).toBe(ATTACHMENT_PENDING);
    await fireEvent.press(screen.getByTestId('attachment-complete-UPL-1'));
    await waitFor(() => {
      expect(screen.getByTestId('attachment-state').props.children).toBe(UPLOADED);
    });
    await cleanup();
  });

it('116 mission UPLOAD_GATE_AND_RETRY_NO_DUPE — незавершённая загрузка оставляет pending; повтор не дублирует', async () => {
    const { ports } = await renderConversation('dark', { uploadStatus: 'failed' });
    await fireEvent.press(screen.getByTestId('composer-attach'));
    await screen.findByText(PICKED_FILE);
    await fireEvent.press(screen.getByTestId('attachment-complete-UPL-1'));
    await waitFor(() => {
      expect(screen.getByTestId('attachment-state').props.children).toBe(ATTACHMENT_PENDING);
    });
    ports.onCompleteUpload.mockResolvedValue('uploaded');
    await fireEvent.press(screen.getByTestId('attachment-complete-UPL-1'));
    await waitFor(() => {
      expect(screen.getByTestId('attachment-state').props.children).toBe(UPLOADED);
    });
    expect(screen.getAllByTestId('attachment-item')).toHaveLength(1);
    await cleanup();
  });

it('116 mission QUEUED_OFFLINE_DRAFT_KEPT — нет сети: черновик сохранён и не назван доставленным (F05.07)', async () => {
    const { ports } = await renderConversation('dark', { sendStatus: 'queued_offline' });
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), 'Offline Nachricht.');
    await fireEvent.press(screen.getByTestId('composer-send'));
    await waitFor(() => {
      expect(ports.onSendMessage).toHaveBeenCalledTimes(1);
    });
    expect(screen.getByTestId('queued-offline-notice').props.children).toBe(FRAME_F05_07_BODY);
    expect(
      (screen.getByTestId('start-composer-input') as { props: { value?: string } }).props.value,
    ).toBe('Offline Nachricht.');
    expect(screen.queryByText('Offline Nachricht.')).toBeNull();
    await cleanup();
  });

it('116 mission INTERRUPTED_NOT_COMPLETED — interrupted различим и не показан завершённым ответом (F05.05)', async () => {
    await renderConversation('dark', { responseState: 'interrupted' });
    await screen.findByText(FRAME_F05_05_TITLE);
    expect(screen.getByTestId('response-state-token').props.children).toBe('interrupted');
    expect(screen.queryByText('completed')).toBeNull();
    await cleanup();
  });

it('116 mission NEW_TOPIC_SEPARATE_INTENT — новая тема — отдельный intent без приватного контекста', async () => {
    const { ports } = await renderConversation('dark');
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), 'Erste Frage alt.');
    await fireEvent.press(screen.getByTestId('composer-send'));
    await screen.findByText('Erste Frage alt.');
    await fireEvent.press(screen.getByTestId('composer-new-topic'));
    await waitFor(() => {
      expect(ports.onNewTopic).toHaveBeenCalledTimes(1);
    });
    await waitFor(() => {
      expect(screen.getByText(NEW_TOPIC_MISSION_ID)).toBeTruthy();
    });
    expect(screen.queryByText(BASELINE_TURN_TEXT)).toBeNull();
    expect(screen.queryByText('Erste Frage alt.')).toBeNull();
    expect(
      (screen.getByTestId('start-composer-input') as { props: { value?: string } }).props.value,
    ).toBe('');
    await cleanup();
  });

it('116 mission NEW_TOPIC_DRAFT_KEPT — новая тема снимает ещё НЕ отправленный черновик', async () => {
    const { ports } = await renderConversation('dark');
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), 'Privater alter Entwurf.');
    await fireEvent.press(screen.getByTestId('composer-new-topic'));
    await waitFor(() => {
      expect(ports.onNewTopic).toHaveBeenCalledTimes(1);
    });
    await screen.findByText(NEW_TOPIC_MISSION_ID);
    expect(
      (screen.getByTestId('start-composer-input') as { props: { value?: string } }).props.value,
    ).toBe('');
    await cleanup();
  });

it('116 mission REVOKED_SOURCE_CLOSED — отозванный источник не открывается; доступный — открывается (F05.06)', async () => {
    await renderConversation('dark', {
      turns: [
        {
          key: 'srv-src',
          role: 'agent' as const,
          text: 'Aussage mit Quelle.',
          sourceRef: SOURCE_REF,
          sourceState: 'revoked' as const,
        },
      ],
    });
    await screen.findByText('Aussage mit Quelle.');
    expect(screen.queryByTestId('fact-source-open')).toBeNull();
    expect(screen.getByText(`${SOURCE_REF}:revoked`)).toBeTruthy();
    await cleanup();
    await renderConversation('dark', {
      turns: [
        {
          key: 'srv-src',
          role: 'agent' as const,
          text: 'Aussage mit Quelle.',
          sourceRef: SOURCE_REF,
          sourceState: 'available' as const,
        },
      ],
    });
    await screen.findByText('Aussage mit Quelle.');
    expect(screen.getByTestId('fact-source-open')).toBeTruthy();
    expect(screen.getByText(FRAME_F05_06_BODY)).toBeTruthy();
    await cleanup();
  });

it('116 mission DRAFT_SURVIVES_REMOUNT — черновик переживает ремоунт (путь вкладки, draftStore)', async () => {
    await renderConversation('dark');
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), 'Wechsel der Registerkarte.');
    expect(
      (screen.getByTestId('start-composer-input') as { props: { value?: string } }).props.value,
    ).toBe('Wechsel der Registerkarte.');
    await cleanup();
    await renderConversation('dark');
    expect(
      (screen.getByTestId('start-composer-input') as { props: { value?: string } }).props.value,
    ).toBe('Wechsel der Registerkarte.');
    await cleanup();
  });

it('116 mission RENDER_F05_07_DRAFT_FRAME — кадр без PNG F05.07: блок, строки каталога, токены декларации', async () => {
    await renderConversation('dark');
    const blok = screen.getByTestId('mission_frame_f05_07');
    expect(blok).toBeVisible();
    expect(within(blok).getByText(FRAME_F05_07_TITLE)).toBeVisible();
    expect(within(blok).getByText(FRAME_F05_07_BODY)).toBeVisible();
    expect(strokiPoddereva(blok).sort()).toEqual([FRAME_F05_07_BODY, FRAME_F05_07_TITLE].sort());
    expect(tokenyKlassa(blok)).toEqual(TOKENY_F05_07);
    await cleanup();
  });

it('116 mission RENDER_V01_QUEUED_OFFLINE — кадр без PNG V01: offline-блок с каталогом и retry', async () => {
    const { ports } = await renderConversation('dark', { sendStatus: 'queued_offline' });
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), 'Offline Nachricht.');
    await fireEvent.press(screen.getByTestId('composer-send'));
    await waitFor(() => {
      expect(ports.onSendMessage).toHaveBeenCalledTimes(1);
    });
    const blok = screen.getByTestId('mission_queued_offline');
    expect(blok).toBeVisible();
    expect(within(blok).getByText(STATE_G06_TITLE)).toBeVisible();
    expect(within(blok).getByText(GLOBAL_RETRY)).toBeVisible();
    expect(strokiPoddereva(blok).sort()).toEqual([GLOBAL_RETRY, STATE_G06_TITLE].sort());
    expect(tokenyKlassa(blok)).toEqual(TOKENY_V01);
    await cleanup();
  });

it('116 mission RENDER_V02_INTERRUPTED — кадр без PNG V02: блок прерывания, каталог, ток ≠ completed', async () => {
    await renderConversation('dark', { responseState: 'interrupted' });
    const blok = screen.getByTestId('mission_response_interrupted');
    expect(blok).toBeVisible();
    expect(within(blok).getByText(FRAME_F05_05_TITLE)).toBeVisible();
    expect(within(blok).getByText(FRAME_F05_05_BODY)).toBeVisible();
    expect(strokiPoddereva(blok).sort()).toEqual(
      [FRAME_F05_05_BODY, FRAME_F05_05_TITLE, 'interrupted'].sort(),
    );
    expect(tokenyKlassa(blok)).toEqual(TOKENY_V02);
    expect(screen.getByTestId('response-state-token').props.children).toBe('interrupted');
    await cleanup();
  });

it('116 mission RENDER_V04_ALREADY_ACCEPTED — кадр без PNG V04: блок уже-принято, каталог, дубля нет', async () => {
    const { ports } = await renderConversation('dark', { sendStatus: 'already_accepted' });
    await fireEvent.changeText(screen.getByTestId('start-composer-input'), 'Noch eine Frage.');
    await fireEvent.press(screen.getByTestId('composer-send'));
    await waitFor(() => {
      expect(ports.onSendMessage).toHaveBeenCalledTimes(1);
    });
    const blok = screen.getByTestId('mission_already_accepted');
    expect(blok).toBeVisible();
    expect(within(blok).getByText(FRAME_F05_02_TITLE)).toBeVisible();
    expect(within(blok).getByText(ACTION_F05_A01)).toBeVisible();
    expect(strokiPoddereva(blok).sort()).toEqual([ACTION_F05_A01, FRAME_F05_02_TITLE].sort());
    expect(tokenyKlassa(blok)).toEqual(TOKENY_V04);
    expect(screen.queryByText('Noch eine Frage.')).toBeNull();
    expect(screen.getAllByTestId('conversation-turn')).toHaveLength(1);
    await cleanup();
  });

it('116 mission RENDER_V03_CHIP_LESET — чип V03: имя файла + суффикс wird gelesen, побайтово', async () => {
    await renderConversation('dark');
    await fireEvent.press(screen.getByTestId('composer-attach'));
    const chip = await screen.findByTestId('mission_chip_wird_gelesen');
    expect(chip).toBeVisible();
    expect(strokiPoddereva(chip)).toEqual([PICKED_FILE + CHIP_LESET_SUFFIX]);
    expect(screen.getByText(PICKED_FILE + CHIP_LESET_SUFFIX)).toBeVisible();
    await cleanup();
  });
