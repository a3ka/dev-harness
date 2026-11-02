// Исполняемый зонд экрана текст-чата Gespräch (контракт 149, блок 1
// Crit149b — «реальный UI доказуем заявленной командой, а не выводится
// из наличия машины и канона»). Прецедент ispolnimyj_sud 148: живой jest
// на РЕАЛЬНЫХ компонентах R — чат-хост mobile/src/features/conversation/
// chat-host.tsx (экспорт GespraechTekstChat) и композер mobile/src/ui/
// conversation-composer/conversation-composer.tsx (экспорт ChatComposer,
// правка 149 поверх поверхности 108). Судит ПОВЕДЕНИЕ: состав целей
// рендера (грамматика gespraech-* пачки) и реакции нажатий/ввода;
// потолок шести строк и прокрутку поля — через интерфейс машины
// (poleSkrolluet), единственный источник числа строк. Заголовки — без
// численно-буквенных пар (урок 145 v4). Запускается БАТАРЕЕЙ в
// изолированной копии mobile (node_modules — симлинк установки R).
//
// v+1 цикл 2 (вердикт Crit149k2a — классы РЕАЛЬНАЯ_ЗОНА_КАСАНИЯ и
// РЕАЛЬНЫЙ_ТОКЕН_ПОЛЯ): (1) зона нажатия на реальном компоненте — по
// карте pressable ПАЧКИ (ekran.json пачки — конечный домен), на ОБОИХ
// профилях (390/393 — ширина контейнера, проценты разрешаются ею):
// зона = min-полы стиля (+hitSlop) ≥ touch-target.min ТОКЕНА ПАКЕТА;
// видимая рамка (width/height) зоной не является и не требуется;
// уменьшение полов при неизменной пачке — красно. (2) потолок поля —
// значение ТОКЕНА пакета (typography.body lineHeight 21px, потолок
// calc(6 * 21px)): использованная компонентом высота (rendered
// maxHeight поля) обязана равняться токену; литерал 24/20 вместо 21
// красен. Оба числа читаются из docs/ux/05_Kompakt_D24/source/tokens.json
// дерева (батарея копирует файл пакета в изолированную копию).
// Среда 145/RNTL: ОДИН render на тест — render/unmount циклы внутри
// одного теста дают overlapping act() и пустое дерево (замер этой
// пачки); между тестами авто-cleanup среды корректен.
import fs from 'fs';
import path from 'path';
import React from 'react';
import { fireEvent, render, screen } from '@testing-library/react-native';
import { StyleSheet, View } from 'react-native';

import { GespraechTekstChat } from '../chat-host';
import { ChatComposer } from '../../../ui/conversation-composer/conversation-composer';

const est = (id: string) => screen.getByTestId(id);
const net = (id: string) => screen.queryByTestId(id);
// среда 145/RNTL: синхронный fireEvent НЕ смывает ре-рендер — каждое
// событие ЖДЁТСЯ (прецедент pilot.test click; замер dbg5 этой пачки)
const nazhat = async (id: string) => {
  await fireEvent.press(est(id));
};

// --- пакет D24-Kompakt-1.1: токены и карта pressable (конечный домен) ---
const TOKENY_PAKETA = path.join(
  __dirname, '..', '..', '..', '..', '..',
  'docs', 'ux', '05_Kompakt_D24', 'source', 'tokens.json');
const EKRAN_PACHKI = path.join(
  __dirname, '..', '..', '..', '..',
  'e2e-gespraech-tekst', 'ekran.json');

function px(znach: string): number {
  const m = znach.match(/^(\d+(?:\.\d+)?)px$/);
  if (m === null) {
    throw new Error('пакет: ждали Npx, получили ' + znach);
  }
  return parseFloat(m[1]);
}

// зона нажатия элемента: min-полы стиля + hitSlop; проценты — от
// ширины профиля; видимая рамка (width/height) НЕ участвует (слово
// владельца 2026-11-02: рамка < 44 при зоне ≥ 44 — не находка, зона
// меньше 44 — находка)
function zonaNazhatija(id: string, shirinaProfilja: number) {
  const el = est(id);
  const sloi = StyleSheet.flatten(el.props.style || []);
  const slop: unknown = el.props.hitSlop;
  const dop =
    slop === undefined
      ? { x: 0, y: 0 }
      : typeof slop === 'number'
        ? { x: 2 * slop, y: 2 * slop }
        : {
            x: Number((slop as Record<string, number>).left || 0) +
              Number((slop as Record<string, number>).right || 0),
            y: Number((slop as Record<string, number>).top || 0) +
              Number((slop as Record<string, number>).bottom || 0),
          };
  const razmer = (znach: unknown): number => {
    if (typeof znach === 'number') {
      return znach;
    }
    if (typeof znach === 'string' && znach.endsWith('%')) {
      return (parseFloat(znach) / 100) * shirinaProfilja;
    }
    return 0;
  };
  return {
    w: razmer(sloi.minWidth ?? sloi.width) + dop.x,
    h: razmer(sloi.minHeight ?? sloi.height) + dop.y,
  };
}

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

// Зонд зоны касания и токена поля (v+1 цикл 2, Crit149k2a).
describe('gespraech-tekst-chat: зона касания и токен поля на компоненте', () => {
  const PROFLI = [390, 393];

  const naborZon = (): { minimum: number; celi: string[] } => {
    const tok = JSON.parse(fs.readFileSync(TOKENY_PAKETA, 'utf8'));
    const ekran = JSON.parse(fs.readFileSync(EKRAN_PACHKI, 'utf8'));
    const celi: string[] = (ekran.prokhodimost.pressable as Array<
      { id: string }
    >).map((x) => x.id);
    if (celi.length === 0) {
      throw new Error('ekran.json пачки: пустой список pressable');
    }
    return { minimum: px(tok['touch-target'].min.$value as string), celi };
  };

  const proveritSostojanie = (shirina: number, gde: string) => {
    const nabor = naborZon();
    const narushenija: string[] = [];
    for (const id of nabor.celi) {
      const el = screen.queryByTestId(id);
      if (el === null) {
        continue; // цель этого состояния не отрисована — вне домена
      }
      // поле ввода — TextInput: его потолок/прокрутка — отдельный
      // контур (машина/токен), не зона кнопки
      if (String(el.type) === 'TextInput') {
        continue;
      }
      const zona = zonaNazhatija(id, shirina);
      if (!(zona.w >= nabor.minimum && zona.h >= nabor.minimum)) {
        narushenija.push(
          id + ' [' + gde + ']: зона ' + zona.w + 'x' + zona.h +
          ' < touch-target.min ' + nabor.minimum,
        );
      }
    }
    return narushenija;
  };

  for (const shirina of PROFLI) {
    const vid = 'профиль-' + String(shirina);
    it('зоны плашек тем и чипов не меньше touch-target.min (' + vid + ')', async () => {
      await render(
        <View style={{ width: shirina }} testID={vid}>
          <GespraechTekstChat />
        </View>,
      );
      // состояние GA-11 (plaschki)
      expect(proveritSostojanie(shirina, vid)).toEqual([]);
      // состояние GA-12 (tema-verlauf: вопрос агента + чипы)
      await nazhat('gespraech-topic-auto');
      expect(proveritSostojanie(shirina, vid)).toEqual([]);
    });

    it('зоны письма, тем-строки и отправки не меньше touch-target.min (' + vid + ')', async () => {
      await render(
        <View style={{ width: shirina }} testID={vid}>
          <GespraechTekstChat />
        </View>,
      );
      // состояние GA-13/17 (schreiben-temy: темы-строка над полем,
      // «Nachricht senden» с текстом) — композер внутри хоста
      await nazhat('gespraech-topic-auto-erzaehlen');
      await fireEvent.changeText(est('gespraech-pole'), 'Zeile');
      expect(est('gespraech-otpravit')).toBeTruthy();
      expect(proveritSostojanie(shirina, vid)).toEqual([]);
    });
  }

  it('высота потолка поля на компоненте равна токену пакета calc(6 * lineHeight(body))', async () => {
    const paket = JSON.parse(fs.readFileSync(TOKENY_PAKETA, 'utf8'));
    const stroka = px(paket.typography.body.$value.lineHeight as string);
    const potolok = paket.component['.p-chatcomp-input:not(.is-empty)']
      .$value['max-height'] as string;
    const m = potolok.match(/^calc\(6 \* (\d+)px\)$/);
    expect(m).not.toBeNull();
    expect(m ? parseInt(m[1], 10) : 0).toBe(stroka);
    await render(<ChatComposer />);
    const semi = ['eins', 'zwei', 'drei', 'vier', 'fuenf', 'sechs', 'sieben'];
    await fireEvent.changeText(est('gespraech-pole'), semi.join('\n'));
    const sloi = StyleSheet.flatten(est('gespraech-pole').props.style || []);
    // использованная компонентом высота == значению токена (6 * 21 = 126);
    // литерал 24 (144) или 20 (120) вместо 21 — красен
    expect(sloi.maxHeight).toBe(6 * stroka);
  });
});
