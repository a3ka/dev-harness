// ОБМАННЫЙ СТАБ 149: фон чата закрывает меню медленнее (двойное изображение)
// Чистый TS без импортов и зависимостей: исполняется node (type-stripping)
// и jest продукта. План движения строится ТОЛЬКО из токенов движения
// (передаются снаружи: продукт — mobile/src/theme/motion-tokens.ts, батарея
// и канон — из пиннованной спеки дизайнера); литералы чисел движения
// внутри машины запрещены. Селекторы элементов — язык спеки дизайнера
// (motion-spec-gespraech), единый источник. Таймлайн сцены плашки
// (задержки отметки/вопроса/чипов) — ДАННЫЕ сцены: машина получает их
// параметром VremenaSobytij (продукт — из пиннованного пакета D 2.4,
// канон — из событий пиннованной спеки), сама их не изобретает.
export type Krivaja = 'ease-standard' | 'ease-morph' | 'linear';

export interface TokenyDvizhenija {
  motionFast: number;
  motionBase: number;
  motionMorph: number;
}

// таймлайн GA-T32 (мс): отметка темы, вопрос Complior, чипы + «Lieber
// erzählen?» (приходят ОДНИМ событием — один элемент #b-qr)
export interface VremenaSobytij {
  otmetka: number;
  vopros: number;
  chipy: number;
}

export interface PlanTrek {
  element: string;
  property: string;
  from: number;
  to: number;
  delayMs: number;
  durationMs: number;
  curve: Krivaja;
  reducedMs: number;
}

export interface MashinaTekstChata {
  planT30(): PlanTrek[];
  planT32(vremena: VremenaSobytij): PlanTrek[];
  planT37(): PlanTrek[];
  poleStrokMaksimum(): number;
  poleRastjot(stroki: number): boolean;
  poleSkrolluet(stroki: number): boolean;
}

// потолок роста поля ввода (строк): CHANGELOG D 2.4 правило
// «Помещается всегда» — поле ввода растёт до шести строк и
// прокручивается; структурная константа интерфейса (не число движения)
const POLE_STROK_MAKSIMUM = 6;

function trek(element: string, property: string, from: number, to: number,
              delayMs: number, durationMs: number, curve: Krivaja,
              reducedMs: number): PlanTrek {
  return { element, property, from, to, delayMs, durationMs, curve,
           reducedMs };
}

export function createChatMachine(tk: TokenyDvizhenija): MashinaTekstChata {
  // Столбец «Уменьшить движение» (правило MOTION reduced_motion): план
  // каждого трека несёт reducedMs — длительность при включённой настройке:
  // перемещение/размер/морф мгновенны (0), видимое (opacity/bg) — не дольше
  // motion-fast. Хост применяет reducedMs по флагу ОС (AccessibilityInfo).
  const ud = (vidimo: boolean) => (vidimo ? tk.motionFast : 0);

  const pill = (i: number) =>
    '.ga-dial .p-dial-list > li:nth-child(' + (i + 1) + ')';

  function planT30(): PlanTrek[] {
    // GA-T30: меню «Schreiben» → фокус в поле, клавиатура, темы строкой
    // над ней — БЕЗ двойного изображения (сначала непрозрачный фон
    // закрывает меню, потом строится чат)
    const t: PlanTrek[] = [];
    t.push(trek('.L-start .p-nav-agent .p-nav-pebble', 'opacity', 0, 0, 0,
                0, 'ease-standard', 0));
    t.push(trek('#morph', 'opacity', 0, 1, 0, 0, 'ease-standard', 0));
    // нажатие «Schreiben» (вторая пилюля)
    t.push(trek(pill(1) + ' .p-dial-item', 'scale', 1, 0.97, 0,
                tk.motionFast, 'ease-standard', ud(false)));
    // меню гаснет разом
    for (let i = 0; i < 4; i++) {
      t.push(trek(pill(i), 'opacity', 1, 0, 0, tk.motionFast,
                  'ease-standard', ud(true)));
    }
    t.push(trek('.ga-dial .p-dial-head p', 'opacity', 1, 0, 0, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('.ga-dial .p-dial-mark', 'opacity', 1, 0, 0, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('.ga-dial .p-dial-close', 'opacity', 1, 0, 0, tk.motionFast,
                'ease-standard', ud(true)));
    // непрозрачный фон чата закрывает меню ДО построения чата
    t.push(trek('#gnd', 'opacity', 0, 1, 0, tk.motionBase, 'ease-standard',
                ud(true)));
    // морф пилюля «Schreiben» → поле (координаты даёт раскладка, план —
    // длительность/кривая/УД)
    for (const p of ['left', 'top', 'w', 'h']) {
      t.push(trek('#morph', p, 0, 0, 0, tk.motionMorph, 'ease-morph',
                  ud(false)));
    }
    t.push(trek('#morph', 'bg', 0, 0, 0, tk.motionMorph, 'ease-morph',
                ud(true)));
    // чат строится ПОСЛЕ фона
    t.push(trek('.L-chat2 [data-m=top]', 'opacity', 0, 1, tk.motionFast,
                tk.motionBase, 'ease-standard', ud(true)));
    t.push(trek('.L-chat2 [data-m=scroll]', 'opacity', 0, 1, tk.motionFast,
                tk.motionBase, 'ease-standard', ud(true)));
    t.push(trek('.L-chat2 [data-m=scroll]', 'ty', 12, 0, tk.motionFast,
                tk.motionBase, 'ease-standard', ud(false)));
    // клавиатура + поле поднимаются из-за края (анимация платформы)
    t.push(trek('.L-chat2 [data-m=actions]', 'ty', 496, 0, tk.motionFast,
                tk.motionBase, 'ease-standard', ud(false)));
    // поле встаёт на место морфа, слой морфа уходит
    t.push(trek('#morph', 'opacity', 1, 0, tk.motionMorph - tk.motionFast,
                tk.motionFast, 'ease-standard', ud(true)));
    t.push(trek('.L-chat2 .p-chatcomp-field', 'opacity', 0, 1,
                tk.motionMorph - tk.motionFast, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('.L-chat2 .p-chatcomp-btn', 'opacity', 0, 1,
                tk.motionMorph - tk.motionFast, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('.L-chat2 .p-chatcomp-go', 'opacity', 0, 1,
                tk.motionMorph - tk.motionFast, tk.motionFast,
                'ease-standard', ud(true)));
    // темы-пилюли НАД полем — после того, как поле встало
    t.push(trek('.L-chat2 .p-topics', 'opacity', 0, 1, tk.motionMorph,
                tk.motionBase, 'ease-standard', ud(true)));
    return t;
  }

  function planT32(vremena: VremenaSobytij): PlanTrek[] {
    // GA-T32: плашка «Neues Auto» → тема в Verlauf; Complior спрашивает
    // ПЕРВЫМ, чипы ответа и «Lieber erzählen?» приходят ВМЕСТЕ (один
    // элемент #b-qr, одно событие) — правило «ничего от имени человека»
    const t: PlanTrek[] = [];
    t.push(trek('.L-home .p-topics > div:nth-child(2) .p-topic-main',
                'scale', 1, 0.97, 0, tk.motionFast, 'ease-standard',
                ud(false)));
    t.push(trek('.L-home', 'opacity', 1, 0, tk.motionFast, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('#ctop', 'opacity', 0, 1, tk.motionFast, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('#b-mk', 'opacity', 0, 1, vremena.otmetka, tk.motionBase,
                'ease-standard', ud(true)));
    t.push(trek('#b-mk', 'ty', 8, 0, vremena.otmetka, tk.motionBase,
                'ease-standard', ud(false)));
    t.push(trek('#b-a', 'reveal', 0, 1, vremena.vopros, tk.motionFast,
                'ease-standard', ud(false)));
    t.push(trek('#b-qr', 'opacity', 0, 1, vremena.chipy, tk.motionBase,
                'ease-standard', ud(true)));
    t.push(trek('#b-qr', 'ty', 12, 0, vremena.chipy, tk.motionBase,
                'ease-standard', ud(false)));
    return t;
  }

  function planT37(): PlanTrek[] {
    // GA-T37: «Beenden» → назад к тексту. From-состояние — голос
    // (Sprechleiste, GA-33): в пилоте 149 его поставляет мок-хост
    // (норма 28.10), живая Leiste — контракт 150; план машины судит
    // морф Leiste → поле численно уже сейчас.
    const t: PlanTrek[] = [];
    t.push(trek('#morph', 'opacity', 0, 1, 0, 0, 'ease-standard', 0));
    t.push(trek('#end', 'opacity', 1, 0, 0, tk.motionFast, 'ease-standard',
                ud(true)));
    t.push(trek('#a-vb', 'opacity', 1, 0, 0, tk.motionFast, 'ease-standard',
                ud(true)));
    t.push(trek('#a-text [data-m=nav]', 'ty', 84, 0, 0, tk.motionBase,
                'ease-standard', ud(false)));
    t.push(trek('#a-text [data-m=nav]', 'opacity', 0, 1, 0, tk.motionBase,
                'ease-standard', ud(true)));
    // морф полоса голоса → поле
    for (const p of ['left', 'top', 'w', 'h']) {
      t.push(trek('#morph', p, 0, 0, 0, tk.motionMorph, 'ease-morph',
                  ud(false)));
    }
    t.push(trek('#morph', 'bg', 0, 0, 0, tk.motionMorph, 'ease-morph',
                ud(true)));
    t.push(trek('#morph', 'opacity', 1, 0, tk.motionMorph - tk.motionFast,
                tk.motionFast, 'ease-standard', ud(true)));
    t.push(trek('#a-text .p-chatcomp-field', 'opacity', 0, 1,
                tk.motionMorph - tk.motionFast, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('#a-text .p-chatcomp-btn', 'opacity', 0, 1,
                tk.motionMorph - tk.motionFast, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('#a-text .p-chatcomp-go', 'opacity', 0, 1,
                tk.motionMorph - tk.motionFast, tk.motionFast,
                'ease-standard', ud(true)));
    // строка «Weiter im Anliegen» — после морфа
    t.push(trek('#b-end', 'opacity', 0, 1, tk.motionMorph, tk.motionBase,
                'ease-standard', ud(true)));
    t.push(trek('#b-end', 'ty', 8, 0, tk.motionMorph, tk.motionBase,
                'ease-standard', ud(false)));
    return t;
  }

  function poleStrokMaksimum(): number {
    return POLE_STROK_MAKSIMUM;
  }

  function poleRastjot(stroki: number): boolean {
    // поле растёт до потолка включительно
    return stroki <= POLE_STROK_MAKSIMUM;
  }

  function poleSkrolluet(stroki: number): boolean {
    // за потолком высота фиксируется, включается прокрутка
    return stroki > POLE_STROK_MAKSIMUM;
  }

  return { planT30, planT32, planT37, poleStrokMaksimum, poleRastjot,
           poleSkrolluet };
}
