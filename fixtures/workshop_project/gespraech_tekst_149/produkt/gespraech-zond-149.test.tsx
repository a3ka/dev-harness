// Исполняемый зонд экрана текст-чата Gespräch (контракт 149, блок 1
// Crit149b — «реальный UI доказуем заявленной командой, а не выводится
// из наличия машины и канона»). Прецедент ispolnimyj_sud 148: живой jest
// на РЕАЛЬНЫХ компонентах R — чат-хост mobile/src/features/conversation/
// chat-host.tsx (экспорт GespraechTekstChat) и композер mobile/src/ui/
// conversation-composer/conversation-composer.tsx (экспорт ChatComposer,
// правка 149 поверх поверхности 108). Судит ПОВЕДЕНИЕМ: состав целей
// рендера (грамматика gespraech-* пачки), реакции нажатий/ввода,
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
// значение ТОКЕНА пакета (typography.body lineHeight, потолок
// calc(6 * lineHeight)): использованная компонентом высота (rendered
// maxHeight поля) обязана равняться токену. Оба числа читаются из
// docs/ux/05_Kompakt_D24/source/tokens.json дерева (батарея копирует
// файл пакета в изолированную копию; Суд подменяет значение на другое
// допустимое — СВЯЗЬ компонента с токеном, не совпадение числа:
// литерал 21, как и 24/20, красен на подмене).
//
// v+1 цикл 2 вызов 2 (вердикт Crit149k2b — класс ПОЛНОТА_ЖИВЫХ_ЦЕЛЕЙ):
// суд достигает КАЖДОГО заявленного состояния пачки (sostojanija —
// конечный домен) и требует НАЛИЧИЕ/ДЕЙСТВИЕ каждого обязательного
// pressable на соответствующем экране; отсутствующая цель — КРАСНА
// (CEL_OTSTUTSVUET), обход «continue — цель вне домена» снят: цель
// выводится из домена только КАРТОЙ состояний, а карта сверяется с
// пачкой (ключи == sostojanija, объединение == pressable ∩ gespraech-*).
// Достижение состояний — переходы флоу пачки (gespraech-tekst.yaml):
// тема → Verlauf с вопросом и чипами; ввод → клавиатурное состояние
// (голос В ПОЛЕ + «Nachricht senden»); «Lieber erzählen?» → письмо;
// «+» → меню вложений → Foto (GA-18) / Brief-Dokument с чипами
// сравнения (GA-19). Таб-бар (shell-tab-*/gespraech-mitte) — зона
// экрана 148, судом хоста не требуется.
//
// v+1 цикл 2 вызов 3 (вердикт Crit149k2c — классы ЛОЖНЫЙ_ОТКАЗ_ЗОНЫ
// и НЕДЕЙСТВУЮЩАЯ_ОБЯЗАТЕЛЬНАЯ_ЦЕЛЬ): (1) эффективная зона — по
// правилам RN-стиля, НЕ «приоритет одного поля»: width/height
// фиксирует размер, minWidth/minHeight — нижний пол, поднимающий
// размер ВВЕРХ; эффективная ось = max(width, minWidth) + hitSlop.
// ДОПУСТИМЫЕ способы задания зоны ≥ токена (width/height 44; полы 44;
// ОДНОВРЕМЕННО width/height и полы в обеих полярностях: 44×44 при
// полах 36 — зона 44; рамка 36 при полах 44 — зона 44) ЗЕЛЕНЫ —
// прежняя формула «minWidth ?? width» красила валидные 44×44
// (ложный отказ, мутант mut-valid-effective-zone). Видимый размер —
// отдельное свойство (пиксельная мера/манифест), зонд его не судит.
// (2) каждая обязательная цель каждого состояния ЖИВА и ДЕЙСТВУЕТ:
// жизненность — disabled/accessibilityState.disabled (RN Pressable
// вливает disabled в accessibilityState хоста), pointerEvents
// none/box-none на себе и none/box-only на предке (семантика RNTL
// is-enabled), onPress отсутствует (поиск — тем же спуском по fiber,
// что и RNTL propagation: Pressable держит onPress на композите);
// действие — СВОЙ тест на каждую пару «состояние × цель»: достижение
// состояния → нажатие → ПОСТУСЛОВИЕ цели (флоу пачки). RNTL
// доставляет press только живым целям (disabled → onStartShouldSet
// Responder false; pointerEvents — блок; onPress нет — обработчик не
// найден), поэтому disabled-кнопка красна И исполнением.
//
// Среда 145/RNTL: ОДИН render на тест — render/unmount циклы внутри
// одного теста дают overlapping act() и пустое дерево (замер этой
// пачки); между тестами авто-cleanup среды корректен; каждое событие
// ЖДЁТСЯ (прецедент pilot.test click).
import fs from 'fs';
import path from 'path';
import type { ReactTestInstance } from 'react-test-renderer';
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
const vvesti = async (id: string, tekst: string) => {
  await fireEvent.changeText(est(id), tekst);
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

// Эффективная hit-area: RN width/height задаёт наружную размерность,
// minWidth/minHeight поднимает нижний пол, hitSlop расширяет её.
// Без явной размерности padding даёт доказуемую нижнюю грань; при
// явной размерности padding входит ВНУТРЬ неё и не удваивается.
// Проценты — от профиля; размер видимой рамки отдельно (манифест).
// При width=height=44 с полами 36 зона 44; при width=height=36
// с полами 44 зона также 44, уменьшенная эффективная зона красна.
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
  const otstup = (os: 'left' | 'right' | 'top' | 'bottom') => {
    const key = os[0].toUpperCase() + os.slice(1);
    const obshchij = os === 'left' || os === 'right'
      ? sloi.paddingHorizontal : sloi.paddingVertical;
    return razmer(sloi['padding' + key] ?? obshchij ?? sloi.padding);
  };
  const os = (razmernost: unknown, pol: unknown, otstupy: number) =>
    Math.max(razmer(razmernost), razmer(pol),
      razmernost === undefined ? otstupy : 0);
  return {
    w: os(sloi.width, sloi.minWidth,
      otstup('left') + otstup('right')) + dop.x,
    h: os(sloi.height, sloi.minHeight,
      otstup('top') + otstup('bottom')) + dop.y,
  };
}

// onPress обязательной цели: Pressable держит обработчик на КОМПОЗИТЕ
// (fiber), хост-элемент — нет. Спуск по fiber — как у RNTL
// (events/propagation findEventHandlerFromFiber): до первой границы
// хоста; иначе цель «нажимается» действием РОДИТЕЛЯ, не своим.
// RNTL не экспортирует тип fiber — непроверяемое сведение к локальной
// форме (библиотечный тип невыразим, чтение только этих полей).
type Fajber = {
  memoizedProps: Record<string, unknown> | null;
  return: Fajber;
  type: unknown;
} | null;
const onPressCele = (el: ReactTestInstance): unknown => {
  if (typeof el.props.onPress === 'function') {
    return el.props.onPress;
  }
  let fiber = (el as unknown as { unstable_fiber?: Fajber })
    .unstable_fiber;
  while (fiber != null && fiber.memoizedProps != null) {
    if (typeof fiber.memoizedProps.onPress === 'function') {
      return fiber.memoizedProps.onPress;
    }
    if (fiber.return === null || typeof fiber.return.type === 'string') {
      break;
    }
    fiber = fiber.return as Fajber;
  }
  return undefined;
};

// блокатор доставки press семантики RNTL (events/is-enabled
// getPointerEventsBlocker): сам — none/box-none, предок — none/box-only
const blokatorNazhatica = (
  el: ReactTestInstance,
  roditel: boolean,
): string | null => {
  const pe = String(
    el.props.pointerEvents ??
      StyleSheet.flatten(el.props.style || []).pointerEvents ??
      '',
  );
  if (pe === 'none' || (!roditel && pe === 'box-none') ||
      (roditel && pe === 'box-only')) {
    return pe;
  }
  if (el.parent === null) {
    return null;
  }
  return blokatorNazhatica(el.parent, true);
};

// --- карта домена суда: состояние пачки → обязательные цели ----------
// Единый источник домена — ПАЧКА (ekran.json): sostojanija объявляет
// состояния, prokhodimost.pressable — цели; судятся цели грамматики
// gespraech-* (таб-бар — зона 148). Принадлежность цели состоянию —
// по манифесту пакета 1.1 (touch_targets экранов GA-11…GA-19; carte
// целей батареи — KARTA_CELEJ_PRESS probe.py, та же атрибуция).
// Тест домена (ниже) сверяет карту с пачкой ТОЧНО: ключи == sostojanija,
// объединение == pressable ∩ gespraech-*, без повторов.
const SOSTOJANIJA_I_TSELI: Readonly<Record<string, readonly string[]>> = {
  // GA-11: плашки тем (+ срочная с голосом), композер без черновика
  plaschki: [
    'gespraech-verlauf',
    'gespraech-topic-schaden',
    'gespraech-topic-schaden-speak',
    'gespraech-topic-auto',
    'gespraech-topic-auto-erzaehlen',
    'gespraech-topic-umzug',
    'gespraech-topic-umzug-erzaehlen',
    'gespraech-topic-nachwuchs',
    'gespraech-topic-nachwuchs-erzaehlen',
    'gespraech-topic-heirat',
    'gespraech-topic-heirat-erzaehlen',
    'gespraech-vlozhit',
    'gespraech-pole',
    'gespraech-mikrofon',
  ],
  // GA-12: тема в Verlauf, вопрос агента, чипы ответа + «Lieber…?»
  'tema-verlauf': [
    'gespraech-verlauf',
    'gespraech-chip-gekauft',
    'gespraech-chip-geplant',
    'gespraech-lieber-erzaehlen',
    'gespraech-vlozhit',
    'gespraech-pole',
    'gespraech-mikrofon',
  ],
  // GA-13: черновик в поле — голос В ПОЛЕ и «Nachricht senden»
  'schreiben-tastatur': [
    'gespraech-verlauf',
    'gespraech-vlozhit',
    'gespraech-pole',
    'gespraech-mikrofon-v-pole',
    'gespraech-otpravit',
  ],
  // GA-17: темы-строка над полем, поле в фокусе, без черновика
  'schreiben-temy': [
    'gespraech-verlauf',
    'gespraech-vlozhit',
    'gespraech-pole',
    'gespraech-mikrofon',
  ],
  // GA-18: Foto в Verlauf, агент подтверждает
  foto: [
    'gespraech-verlauf',
    'gespraech-vlozhit',
    'gespraech-pole',
    'gespraech-mikrofon',
  ],
  // GA-19: Brief/Dokument — агент спрашивает, чипы сравнения
  dokument: [
    'gespraech-verlauf',
    'gespraech-chip-vergleichen',
    'gespraech-chip-nicht',
    'gespraech-vlozhit',
    'gespraech-pole',
    'gespraech-mikrofon',
  ],
};

const chitatPachku = (): {
  minimum: number;
  celi: string[];
  sostojanija: string[];
} => {
  const tok = JSON.parse(fs.readFileSync(TOKENY_PAKETA, 'utf8'));
  const ekran = JSON.parse(fs.readFileSync(EKRAN_PACHKI, 'utf8'));
  const celi: string[] = (ekran.prokhodimost.pressable as Array<
    { id: string }
  >).map((x) => x.id);
  if (celi.length === 0) {
    throw new Error('ekran.json пачки: пустой список pressable');
  }
  const sostojanija: string[] = ekran.sostojanija;
  if (!Array.isArray(sostojanija) || sostojanija.length === 0) {
    throw new Error('ekran.json пачки: пустой список sostojanija');
  }
  return {
    minimum: px(tok['touch-target'].min.$value as string),
    celi,
    sostojanija,
  };
};

// суд состояния: КАЖДАЯ обязательная цель НАЛИЧНА (отсутствие —
// CEL_OTSTUTSVUET, выхода «цель не отрисована — вне домена» НЕТ),
// ЖИВА и в зоне (вызов 3, Crit149k2c НЕДЕЙСТВУЮЩАЯ_ОБЯЗАТЕЛЬНАЯ_ЦЕЛЬ:
// наличие и размер без действия не засчитываются — выключенная цель
// красна ИМЕННОЙ причиной): поле ввода (TextInput) судится только
// наличием — потолок/прокрутка отдельным контуром (машина/токен),
// ввод — судом действия; остальные — жизненностью и зоной ≥ нормы
const sudSostojanija = (shirina: number, sostojanie: string) => {
  const nabor = chitatPachku();
  const narushenija: string[] = [];
  for (const id of SOSTOJANIJA_I_TSELI[sostojanie]) {
    const el = screen.queryByTestId(id);
    if (el === null) {
      narushenija.push('CEL_OTSTUTSVUET: ' + id + ' [' + sostojanie + ']');
      continue;
    }
    if (String(el.type) === 'TextInput') {
      continue;
    }
    // жизненность: RN 0.86 Pressable вливает disabled (и
    // accessibilityState.disabled) в accessibilityState ХОСТА —
    // выключенная цель видна, зонна и всё равно красна
    const az = (el.props.accessibilityState ??
      {}) as Record<string, unknown>;
    if (el.props.disabled === true || az.disabled === true) {
      narushenija.push(
        'CEL_VYKLUCHENA: ' + id + ' [' + sostojanie + '] disabled',
      );
      continue;
    }
    const blokator = blokatorNazhatica(el, false);
    if (blokator !== null) {
      narushenija.push(
        'CEL_OBEZDVIZHENA: ' + id + ' [' + sostojanie +
          '] pointerEvents ' + blokator,
      );
      continue;
    }
    if (onPressCele(el) === undefined) {
      narushenija.push(
        'CEL_BEZ_DEJSTVIJA: ' + id + ' [' + sostojanie +
          '] onPress отсутствует',
      );
      continue;
    }
    const zona = zonaNazhatija(id, shirina);
    if (!(zona.w >= nabor.minimum && zona.h >= nabor.minimum)) {
      narushenija.push(
        'ZONA_MENSHE_NORMY: ' + id + ' [' + sostojanie + ']: зона ' +
        zona.w + 'x' + zona.h + ' < touch-target.min ' + nabor.minimum,
      );
    }
  }
  return narushenija;
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

  it('вложение «+» открывает меню: Foto ведёт в Verlauf (GA-18)', async () => {
    await render(<GespraechTekstChat />);
    await nazhat('gespraech-vlozhit');
    // меню вложений — имена флоу пачки (gespraech-tekst.yaml)
    expect(est('gespraech-vlozhenie')).toBeTruthy();
    expect(est('gespraech-vlozhit-foto')).toBeTruthy();
    expect(est('gespraech-vlozhit-dokument')).toBeTruthy();
    await nazhat('gespraech-vlozhit-foto');
    expect(est('gespraech-vlozhenie-foto')).toBeTruthy();
    // агент подтверждает (GA-18: «Complior bestätigt»)
    expect(est('gespraech-vopros-agenta')).toBeTruthy();
  });

  it('Brief-Dokument: агент спрашивает, чипы сравнения действуют (GA-19)', async () => {
    await render(<GespraechTekstChat />);
    await nazhat('gespraech-vlozhit');
    await nazhat('gespraech-vlozhit-dokument');
    expect(est('gespraech-vlozhenie-brief')).toBeTruthy();
    expect(est('gespraech-vopros-agenta')).toBeTruthy();
    expect(est('gespraech-chip-vergleichen')).toBeTruthy();
    expect(est('gespraech-chip-nicht')).toBeTruthy();
    // ДЕЙСТВИЕ обязательного pressable: чип — ответ агенту
    await nazhat('gespraech-chip-vergleichen');
    expect(est('gespraech-soobschenie-polzovatel')).toBeTruthy();
    expect(screen.getAllByTestId('gespraech-vopros-agenta').length).toBe(2);
  });

  it('текст и отправка: сообщение в Verlauf, поле очищено', async () => {
    await render(<GespraechTekstChat />);
    await vvesti('gespraech-pole', 'Hallo von Ihnen');
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
    await vvesti('gespraech-pole', 'Kurze Frage');
    expect(est('gespraech-otpravit')).toBeTruthy();
    // голос В ПОЛЕ (GA-13): с черновиком кнопка голоса — в ряду поля
    expect(est('gespraech-mikrofon-v-pole')).toBeTruthy();
    await nazhat('gespraech-mikrofon-v-pole');
    expect(naGolos).toHaveBeenCalledTimes(2);
  });

  it('поле растёт без прокрутки до потолка строк', async () => {
    await render(<ChatComposer />);
    await vvesti('gespraech-pole', 'eine\nzwei\ndrei');
    expect(net('gespraech-pole-skroll')).toBeNull();
  });

  it('за потолком включается прокрутка поля', async () => {
    await render(<ChatComposer />);
    const semi = ['eins', 'zwei', 'drei', 'vier', 'fuenf', 'sechs'];
    await vvesti('gespraech-pole', semi.join('\n'));
    expect(net('gespraech-pole-skroll')).toBeNull();
    await vvesti('gespraech-pole', semi.concat('sieben').join('\n'));
    const skroll = est('gespraech-pole-skroll');
    expect(skroll.props.scrollEnabled).toBe(true);
    expect(est('gespraech-pole')).toBeTruthy();
  });

  it('отправка передаёт текст и появляется только с черновиком', async () => {
    const naOtpravit = jest.fn();
    await render(<ChatComposer onOtpravit={naOtpravit} />);
    await vvesti('gespraech-pole', 'Meine Frage zum Auto');
    await nazhat('gespraech-otpravit');
    expect(naOtpravit).toHaveBeenCalledWith('Meine Frage zum Auto');
  });
});

// Зонд домена, состояний, зон касания и токена поля (v+1 цикл 2).
describe('gespraech-tekst-chat: домен, состояния, зоны и токен поля', () => {
  it('карта суда покрывает состояния и цели pressable пачки точно', () => {
    const nabor = chitatPachku();
    // ключи карты == sostojanija пачки (конечный домен состояний)
    expect(Object.keys(SOSTOJANIJA_I_TSELI).slice().sort())
      .toEqual(nabor.sostojanija.slice().sort());
    // объединение обязательных целей == целям пачки МИНУС таб-бар
    // (ряд y=796 манифеста GA-11: shell-tab-* и gespraech-mitte —
    // поверхность TabShell 148 / меню 147, судом ХОСТА не требуется;
    // список таб-бара обязан существовать в пачке — иначе исключение
    // протухло и тест красен); цель МОЖЕТ быть обязательна в нескольких
    // состояниях (экран повторяет «+»/поле/голос), повтор ВНУТРИ
    // состояния — ошибка карты)
    const tabBar = [
      'shell-tab-start', 'shell-tab-vorgaenge', 'gespraech-mitte',
      'shell-tab-schutz', 'shell-tab-post',
    ];
    for (const id of tabBar) {
      expect(nabor.celi.indexOf(id)).toBeGreaterThanOrEqual(0);
    }
    for (const spisok of Object.values(SOSTOJANIJA_I_TSELI)) {
      expect(new Set(Array.from(spisok)).size).toBe(spisok.length);
    }
    const vse = Object.values(SOSTOJANIJA_I_TSELI).reduce(
      (a, b) => a.concat(Array.from(b)), [] as string[]);
    const celiPachki = nabor.celi
      .filter((id) => tabBar.indexOf(id) < 0).sort();
    expect(Array.from(new Set(vse)).sort()).toEqual(celiPachki);
  });

  const PROFLI = [390, 393];
  for (const shirina of PROFLI) {
    const vid = 'профиль-' + String(shirina);
    it('достигает все состояния пачки; обязательные цели наличны, зоны ≥ touch-target.min (' + vid + ')', async () => {
      await render(
        <View style={{ width: shirina }} testID={vid}>
          <GespraechTekstChat />
        </View>,
      );
      // plaschki (GA-11)
      expect(sudSostojanija(shirina, 'plaschki')).toEqual([]);
      // erzaehlen → schreiben-temy (GA-17): темы-строка над полем
      await nazhat('gespraech-topic-auto-erzaehlen');
      expect(sudSostojanija(shirina, 'schreiben-temy')).toEqual([]);
      // тема-пилюля → tema-verlauf (GA-12): вопрос и чипы
      await nazhat('gespraech-tema-auto');
      expect(sudSostojanija(shirina, 'tema-verlauf')).toEqual([]);
      // черновик → schreiben-tastatur (GA-13): голос В ПОЛЕ, отправка
      await vvesti('gespraech-pole', 'Zeile');
      expect(sudSostojanija(shirina, 'schreiben-tastatur')).toEqual([]);
      // отправка — сообщение в ленте
      await nazhat('gespraech-otpravit');
      expect(est('gespraech-soobschenie-polzovatel')).toBeTruthy();
      // «+» → меню вложений (флоу пачки: vlozhit-foto/-dokument)
      await nazhat('gespraech-vlozhit');
      expect(est('gespraech-vlozhit-foto')).toBeTruthy();
      expect(est('gespraech-vlozhit-dokument')).toBeTruthy();
      // Foto → Verlauf с подтверждением (GA-18)
      await nazhat('gespraech-vlozhit-foto');
      expect(sudSostojanija(shirina, 'foto')).toEqual([]);
      // Brief-Dokument → вопрос агента и чипы сравнения (GA-19)
      await nazhat('gespraech-vlozhit');
      await nazhat('gespraech-vlozhit-dokument');
      expect(sudSostojanija(shirina, 'dokument')).toEqual([]);
      expect(screen.getAllByTestId('gespraech-vopros-agenta').length)
        .toBeGreaterThan(0);
    });
  }

  // Каждая цель начального состояния получает собственный свежий render:
  // выключенная или обездвиженная цель не прячется за успехом соседней.
  const nachalnye = SOSTOJANIJA_I_TSELI.plaschki;
  for (const shirina of PROFLI) {
    for (const id of nachalnye) {
      it('доставляет действие ' + id + ' в профиле ' + shirina, async () => {
        await render(
          <View style={{ width: shirina }}>
            <GespraechTekstChat />
          </View>,
        );
        expect(sudSostojanija(shirina, 'plaschki')).toEqual([]);
        if (id === 'gespraech-pole') {
          await vvesti(id, 'Frage');
          expect(est('gespraech-otpravit')).toBeTruthy();
          return;
        }
        await nazhat(id);
        if (id === 'gespraech-vlozhit') {
          expect(est('gespraech-vlozhenie')).toBeTruthy();
        } else if (id === 'gespraech-verlauf') {
          expect(est('gespraech-verlauf-spisok')).toBeTruthy();
        } else if (id === 'gespraech-mikrofon' ||
                   id.endsWith('-erzaehlen')) {
          expect(est('gespraech-temy-stroka')).toBeTruthy();
        } else {
          expect(est('gespraech-vopros-agenta')).toBeTruthy();
        }
      });
    }
  }

  // Цели остальных состояний: один render на пару состояние × цель.
  for (const shirina of PROFLI) {
    for (const sostojanie of Object.keys(SOSTOJANIJA_I_TSELI)) {
      if (sostojanie === 'plaschki') {
        continue;
      }
      for (const id of SOSTOJANIJA_I_TSELI[sostojanie]) {
        it('нажимает ' + id + ' в ' + sostojanie + ' / ' + shirina,
          async () => {
            await render(
              <View style={{ width: shirina }}>
                <GespraechTekstChat />
              </View>,
            );
            if (sostojanie === 'tema-verlauf') {
              await nazhat('gespraech-topic-auto');
            } else if (sostojanie === 'schreiben-temy' ||
                       sostojanie === 'schreiben-tastatur') {
              await nazhat('gespraech-topic-auto-erzaehlen');
              if (sostojanie === 'schreiben-tastatur') {
                await vvesti('gespraech-pole', 'Zeile');
              }
            } else {
              await nazhat('gespraech-vlozhit');
              await nazhat(sostojanie === 'foto'
                ? 'gespraech-vlozhit-foto' : 'gespraech-vlozhit-dokument');
            }
            expect(sudSostojanija(shirina, sostojanie)).toEqual([]);
            if (id === 'gespraech-pole') {
              await vvesti(id, 'Neue Frage');
              expect(est(id).props.value).toBe('Neue Frage');
            } else {
              await nazhat(id);
              if (id === 'gespraech-vlozhit') {
                expect(est('gespraech-vlozhenie')).toBeTruthy();
              } else if (id.startsWith('gespraech-chip-') ||
                         id === 'gespraech-otpravit') {
                expect(est('gespraech-soobschenie-polzovatel')).toBeTruthy();
              } else if (id === 'gespraech-lieber-erzaehlen' ||
                         id.startsWith('gespraech-mikrofon')) {
                expect(est('gespraech-temy-stroka')).toBeTruthy();
              } else if (id === 'gespraech-verlauf') {
                expect(est('gespraech-verlauf-spisok')).toBeTruthy();
                if (sostojanie === 'schreiben-temy' ||
                    sostojanie === 'schreiben-tastatur') {
                  expect(net('gespraech-temy-stroka')).toBeNull();
                } else if (sostojanie === 'foto') {
                  expect(net('gespraech-vlozhenie-foto')).toBeNull();
                } else if (sostojanie === 'dokument') {
                  expect(net('gespraech-vlozhenie-brief')).toBeNull();
                }
              }
            }
          });
      }
    }
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
    await vvesti('gespraech-pole', semi.join('\n'));
    const sloi = StyleSheet.flatten(est('gespraech-pole').props.style || []);
    // использованная компонентом высота == ЗНАЧЕНИЮ ТОКЕНА (файл
    // читают и компонент, и зонд — при подмене значения батареей
    // высота обязана СЛЕДОВАТЬ за токеном: литерал 21, как и 24/20,
    // красен — совпадение текущего числа связи не доказывает)
    expect(sloi.maxHeight).toBe(6 * stroka);
  });
});
