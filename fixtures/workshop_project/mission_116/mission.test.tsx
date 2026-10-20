// 116 (CMP-MOB-005): поведенческая батарея беседы. Оракул — source.json,
// снятый с read-only docs/ Complior-mob 16eb708a ДО запуска субъекта; все
// ожидания — ЛИТЕРАЛЫ ниже (правило 8, Н-351/Н-379/Н-383: ни одна клетка
// не сверяется значением, прочитанным у субъекта). Вход (провайдер темы) —
// themeTokens 999; ожидания — литералы оракула. Свойство «черновик не
// теряется» наблюдается на ВСЕХ путях жизненного цикла (attach, offline,
// повтор already_accepted, новая тема, контролируемый порт), «вложение не
// пропадает и не дублируется» — по состояниям выбора/загрузки/повтора
// (уроки 111: свойство, а не выборка).
import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react-native';
import React from 'react';

import { ConversationScreen } from '@/features/conversation/conversation-screen';
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
const FRAME_F05_06_BODY = 'Öffnen Sie die Quelle, um die Grundlage dieser Aussage zu prüfen.';
const FRAME_F05_07_BODY = 'Ihre Nachricht wurde noch nicht gesendet. Sie können sie weiterbearbeiten.';
const ACTION_F05_A01 = 'Nachricht senden';
const ACTION_F05_A02 = 'Dokument hinzufügen';
const ACTION_F05_A03 = 'Neues Thema';
// Грамматика данных F05 (BrokerOS_Mobile_Design_Data.json#features/F05):
const MISSION_ID = 'MIS-CAR-01';
const NEW_TOPIC_MISSION_ID = 'MIS-NEW-42';
const BASELINE_TURN_TEXT = 'Я купила автомобиль.';
const SOURCE_REF = 'DOC-VEH-01:p1';
const PICKED_FILE = 'fahrschein.pdf';
const ATTACHMENT_PENDING = 'attachment_pending';
const UPLOADED = 'uploaded';

const BASELINE_TURNS = [
  { key: 'srv-1', role: 'user' as const, text: BASELINE_TURN_TEXT, sendState: 'sent' as const },
];

function makePorts() {
  return {
    onSendMessage: jest.fn(async () => 'accepted' as const),
    onAttach: jest.fn(() => ({ attachmentId: 'UPL-1', name: PICKED_FILE })),
    onCompleteUpload: jest.fn(async () => 'uploaded' as const),
    onNewTopic: jest.fn(async () => NEW_TOPIC_MISSION_ID),
  };
}

async function renderConversation(
  scheme: ColorScheme = 'dark',
  overrides: {
    turns?: typeof BASELINE_TURNS;
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
