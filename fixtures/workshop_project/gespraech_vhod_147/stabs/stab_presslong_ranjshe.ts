// ОБМАННЫЙ СТАБ 147: порог голоса раньше press-long
// Машина вход-меню Gespräch (модель 147; канон интерфейса предмета).
// Чистый TS без импортов и зависимостей: исполняется node (type-stripping)
// и jest продукта. План движения строится ТОЛЬКО из токенов движения
// (передаются снаружи: продукт — mobile/src/theme/motion-tokens.ts, батарея
// и канон — из пиннованной спеки дизайнера); литералы чисел движения
// внутри машины запрещены (кроме структурных индексов порядка пилюль).
// Селекторы элементов — язык спеки дизайнера (motion-spec-gespraech),
// единый источник: .ga-dial .p-dial-list > li:nth-child(N) и т.п.
export type Krivaja = 'ease-standard' | 'ease-morph' | 'linear';

export interface TokenyDvizhenija {
  motionFast: number;
  motionBase: number;
  staggerTight: number;
  pressLong: number;
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

export interface MashinaMenju {
  planOpen(): PlanTrek[];
  planClose(): PlanTrek[];
  planHold(): PlanTrek[];
  planVoice(): PlanTrek[];
  holdResult(heldMs: number): 'menu' | 'voice';
}

const PILLI = 4; // Sprechen, Schreiben, Foto, Brief/Dokument

function trek(element: string, property: string, from: number, to: number,
              delayMs: number, durationMs: number, curve: Krivaja,
              reducedMs: number): PlanTrek {
  return { element, property, from, to, delayMs, durationMs, curve,
           reducedMs };
}

export function createMenuMachine(tk: TokenyDvizhenija): MashinaMenju {
  // Столбец «Уменьшить движение» (правило MOTION reduced_motion): план
  // каждого трека несёт reducedMs — длительность при включённой настройке:
  // перемещение/размер/морф мгновенны (0), видимое (opacity) — не дольше
  // motion-fast. Хост применяет reducedMs по флагу ОС (AccessibilityInfo).
  const ud = (vidimo: boolean) => (vidimo ? tk.motionFast : 0);

  const pill = (i: number) =>
    '.ga-dial .p-dial-list > li:nth-child(' + (i + 1) + ')';

  function planOpen(): PlanTrek[] {
    const t: PlanTrek[] = [];
    // камешек: нажатие + уступает место «×»
    t.push(trek('.L-start .p-nav-agent .p-nav-pebble', 'scale', 1, 0.94, 0,
                tk.motionFast, 'ease-standard', ud(false)));
    t.push(trek('.L-start .p-nav-agent .p-nav-pebble', 'opacity', 1, 0, 0,
                tk.motionFast, 'ease-standard', ud(true)));
    // «×» на месте камешка
    t.push(trek('.ga-dial .p-dial-close', 'opacity', 0, 1, 0, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('.ga-dial .p-dial-close', 'rot', -45, 0, 0, tk.motionBase,
                'ease-standard', ud(false)));
    t.push(trek('.ga-dial .p-dial-close', 'scale', 0.6, 1, 0, tk.motionBase,
                'ease-standard', ud(false)));
    // фон
    t.push(trek('#scrim', 'opacity', 0, 1, 0, tk.motionBase, 'ease-standard',
                ud(true)));
    // знак летит из камешка к вопросу — морф (координаты даёт раскладка,
    // план — длительность/кривая/УД)
    for (const p of ['left', 'top', 'w', 'h']) {
      t.push(trek('#mkg', p, 0, 0, 0, tk.motionBase, 'ease-morph',
                  ud(false)));
    }
    // вопрос над меню
    t.push(trek('.ga-dial .p-dial-head p', 'opacity', 0, 1, tk.staggerTight,
                tk.motionFast, 'ease-standard', ud(true)));
    t.push(trek('.ga-dial .p-dial-head p', 'ty', 0, 0, tk.staggerTight,
                tk.motionFast, 'ease-standard', ud(false)));
    // пилюли сверху вниз, «Sprechen» первым: задержка (i+2)*stagger-tight
    for (let i = 0; i < PILLI; i++) {
      const d = (i + 2) * tk.staggerTight;
      t.push(trek(pill(i), 'opacity', 0, 1, d, tk.motionFast,
                  'ease-standard', ud(true)));
      t.push(trek(pill(i), 'ty', 0, 0, d, tk.motionBase, 'ease-standard',
                  ud(false)));
    }
    return t;
  }

  function planClose(): PlanTrek[] {
    // закрытие (GA-T31): меню и пилюли гаснут разом за motion-fast,
    // морф и «×» — motion-base, камешек возвращается после motion-fast
    const t: PlanTrek[] = [];
    t.push(trek('.ga-dial .p-dial-close', 'opacity', 1, 0, 0, tk.motionFast,
                'ease-standard', ud(true)));
    for (let i = 0; i < PILLI; i++) {
      t.push(trek(pill(i), 'opacity', 1, 0, 0, tk.motionFast,
                  'ease-standard', ud(true)));
      t.push(trek(pill(i), 'ty', 0, 0, 0, tk.motionFast, 'ease-standard',
                  ud(false)));
    }
    t.push(trek('.ga-dial .p-dial-head p', 'opacity', 1, 0, 0, tk.motionFast,
                'ease-standard', ud(true)));
    t.push(trek('#scrim', 'opacity', 1, 0, 0, tk.motionBase, 'ease-standard',
                ud(true)));
    t.push(trek('.ga-dial .p-dial-close', 'rot', 0, -45, 0, tk.motionBase,
                'ease-standard', ud(false)));
    t.push(trek('.ga-dial .p-dial-close', 'scale', 1, 0.6, 0, tk.motionBase,
                'ease-standard', ud(false)));
    for (const p of ['left', 'top', 'w', 'h']) {
      t.push(trek('#mkg', p, 0, 0, 0, tk.motionBase, 'ease-morph',
                  ud(false)));
    }
    t.push(trek('.L-start .p-nav-agent .p-nav-pebble', 'opacity', 0, 1,
                tk.motionFast, tk.motionFast, 'ease-standard', ud(true)));
    return t;
  }

  function planHold(): PlanTrek[] {
    // камешек растёт, пока палец держит (press-long, линейный прогресс)
    return [trek('.L-start .p-nav-agent .p-nav-pebble', 'scale', 1, 1.06, 0,
                 tk.pressLong, 'linear', ud(false))];
  }

  function planVoice(): PlanTrek[] {
    // отпускание после press-long: чат с Sprechleiste (мок GA-34 до 150)
    const t: PlanTrek[] = [];
    t.push(trek('.L-start .p-nav-agent .p-nav-pebble', 'opacity', 1, 0,
                tk.pressLong, tk.motionFast, 'ease-standard', ud(true)));
    t.push(trek('#voice', 'opacity', 0, 1, tk.pressLong, tk.motionBase,
                'ease-standard', ud(true)));
    t.push(trek('#ctop', 'opacity', 0, 1, tk.pressLong + tk.motionFast,
                tk.motionBase, 'ease-standard', ud(true)));
    t.push(trek('#a-vb', 'ty', 0, 0, tk.pressLong + tk.motionFast,
                tk.motionBase, 'ease-standard', ud(false)));
    t.push(trek('#a-vb', 'opacity', 0, 1, tk.pressLong + tk.motionFast,
                tk.motionBase, 'ease-standard', ud(true)));
    t.push(trek('#b-hint', 'opacity', 0, 1, tk.pressLong + tk.motionBase,
                tk.motionBase, 'ease-standard', ud(true)));
    t.push(trek('#b-hint', 'ty', 0, 0, tk.pressLong + tk.motionBase,
                tk.motionBase, 'ease-standard', ud(false)));
    return t;
  }

  function holdResult(heldMs: number): 'menu' | 'voice' {
    // отпускание до press-long — это касание: меню (T35 interrupt)
    return heldMs >= tk.pressLong * 0.8 ? 'voice' : 'menu';
  }

  return { planOpen, planClose, planHold, planVoice, holdResult };
}
