// Исполняемый зонд экрана текст-чата Gespräch (контракт 149, блок 1
// Crit149b — «реальный UI доказуем заявленной командой, а не выводится
// из наличия машины и канона»). Прецедент ispolnimyj_sud 148: живой jest
// на РЕАЛЬНЫХ компонентах R — чат-хост mobile/src/features/conversation/
// chat-host.tsx (экспорт GespraechTekstChat) и композер mobile/src/ui/
// conversation-composer/conversation-composer.tsx (экспорт ChatComposer,
// правка 149 поверх поверхности 108). Судит ПОВЕДЕНИЕ: состав целей
// рендера (грамматика gespraech-* пачки) и реакции нажатий/ввода;
// потолок шести строк и прокрутку поля — через интерфейс машины
// (poleSkrolluet), единственный источник числа. Заголовки — без
// численно-буквенных пар (урок 145 v4). Запускается БАТАРЕЕЙ в
// изолированной копии mobile (node_modules — симлинк установки R).
import React from 'react';
import { fireEvent, render, screen } from '@testing-library/react-native';

import { GespraechTekstChat } from '../chat-host';
import { ChatComposer } from '../../../ui/conversation-composer/conversation-composer';

const est = (id: string) => screen.getByTestId(id);
const net = (id: string) => screen.queryByTestId(id);
// среда 145/RNTL: синхронный fireEvent НЕ смывает ре-рендер — каждое
// событие ЖДЁТСЯ (прецедент pilot.test click; замер dbg5 этой пачки)
const nazhat = async (id: string) => {
  await fireEvent.press(est(id));
};

// Зонд-хост: состав целей GA-11 и реакции переходов/отправки.
describe('gespraech-tekst-chat: хост текст-чата', () => {
  it('рендерит плашки тем с голосом и композер (GA-11)', async () => {
    await render(<GespraechTekstChat />);
    expect(est('gespraech-topic-schaden')).toBeTruthy();
    expect(est('gespraech-topic-schaden-speak')).toBeTruthy();
    for (const t of ['auto', 'umzug', 'nachwuchs', 'heirat']) {
      expect(est('gespraech-topic-' + t)).toBeTruthy();
      expect(est('gespraech-topic-' + t + '-erzaehlen')).toBeTruthy();
    }
    expect(est('gespraech-verlauf')).toBeTruthy();
    expect(est('gespraech-vlozhit')).toBeTruthy();
    expect(est('gespraech-pole')).toBeTruthy();
    expect(est('gespraech-mikrofon')).toBeTruthy();
    // «Nachricht senden» появляется только с текстом (GA-11 → GA-13)
    expect(net('gespraech-otpravit')).toBeNull();
    expect(net('gespraech-vopros-agenta')).toBeNull();
  });

  it('тема ведёт в Verlauf: вопрос агента раньше чипов (GA-12)', async () => {
    await render(<GespraechTekstChat />);
    await nazhat('gespraech-topic-auto');
    expect(est('gespraech-vopros-agenta')).toBeTruthy();
    expect(est('gespraech-chip-gekauft')).toBeTruthy();
    expect(est('gespraech-chip-geplant')).toBeTruthy();
    expect(est('gespraech-lieber-erzaehlen')).toBeTruthy();
    // плашки ушли — двойного изображения нет
    expect(net('gespraech-topic-schaden')).toBeNull();
  });

  it('чип ответа даёт следующую реплику разговора', async () => {
    await render(<GespraechTekstChat />);
    await nazhat('gespraech-topic-auto');
    await nazhat('gespraech-chip-gekauft');
    expect(screen.getAllByTestId('gespraech-vopros-agenta').length).toBe(2);
    expect(est('gespraech-soobschenie-polzovatel')).toBeTruthy();
  });

  it('erzaehlen открывает письмо: темы-строка над полем (GA-17)', async () => {
    await render(<GespraechTekstChat />);
    await nazhat('gespraech-topic-auto-erzaehlen');
    expect(est('gespraech-temy-stroka')).toBeTruthy();
    expect(est('gespraech-tema-auto')).toBeTruthy();
  });

  it('вложение открывает панель Dokument (GA-19)', async () => {
    await render(<GespraechTekstChat />);
    await nazhat('gespraech-vlozhit');
    expect(est('gespraech-vlozhenie')).toBeTruthy();
  });

  it('текст и отправка: сообщение в Verlauf, поле очищено', async () => {
    await render(<GespraechTekstChat />);
    await fireEvent.changeText(est('gespraech-pole'), 'Hallo von Ihnen');
    expect(est('gespraech-otpravit')).toBeTruthy();
    await nazhat('gespraech-otpravit');
    expect(est('gespraech-soobschenie-polzovatel')).toBeTruthy();
    expect(net('gespraech-otpravit')).toBeNull();
  });
});

// Зонд-композер: потолок шести строк, прокрутка, голос в поле (И-4).
describe('gespraech-tekst-chat: композер разговора', () => {
  it('кнопки композера: вложение, поле, голос; отправка с текстом', async () => {
    const naGolos = jest.fn();
    const naVlozhit = jest.fn();
    await render(
      <ChatComposer onGolos={naGolos} onVlozhit={naVlozhit} />,
    );
    expect(est('gespraech-vlozhit')).toBeTruthy();
    expect(est('gespraech-pole')).toBeTruthy();
    expect(est('gespraech-mikrofon')).toBeTruthy();
    expect(net('gespraech-otpravit')).toBeNull();
    await nazhat('gespraech-mikrofon');
    expect(naGolos).toHaveBeenCalledTimes(1);
    await nazhat('gespraech-vlozhit');
    expect(naVlozhit).toHaveBeenCalledTimes(1);
    await fireEvent.changeText(est('gespraech-pole'), 'Kurze Frage');
    expect(est('gespraech-otpravit')).toBeTruthy();
  });

  it('поле растёт без прокрутки до потолка строк', async () => {
    await render(<ChatComposer />);
    await fireEvent.changeText(est('gespraech-pole'), 'eine\nzwei\ndrei');
    expect(net('gespraech-pole-skroll')).toBeNull();
  });

  it('за потолком включается прокрутка поля', async () => {
    await render(<ChatComposer />);
    const semi = ['eins', 'zwei', 'drei', 'vier', 'fuenf', 'sechs'];
    await fireEvent.changeText(est('gespraech-pole'), semi.join('\n'));
    expect(net('gespraech-pole-skroll')).toBeNull();
    await fireEvent.changeText(est('gespraech-pole'), semi.concat('sieben').join('\n'));
    const skroll = est('gespraech-pole-skroll');
    expect(skroll.props.scrollEnabled).toBe(true);
    expect(est('gespraech-pole')).toBeTruthy();
  });

  it('отправка передаёт текст и появляется только с черновиком', async () => {
    const naOtpravit = jest.fn();
    await render(<ChatComposer onOtpravit={naOtpravit} />);
    await fireEvent.changeText(est('gespraech-pole'), 'Meine Frage zum Auto');
    await nazhat('gespraech-otpravit');
    expect(naOtpravit).toHaveBeenCalledWith('Meine Frage zum Auto');
  });
});
