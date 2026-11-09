// ЕДИНЫЕ хелперы проверки обязательных целей экрана (набор ekrannyj_nabor_158,
// контракт 158 И-1): ОДИН код на все экраны. Исполняются jest живого
// референса (копируются в mobile/src/__nabor158__/). Семантика — SPEC.md §5.
//
// Всё считается из РАЗМЕТКИ (props/style узлов дерева test-renderer), не из
// раскладки Yoga: jest не вычисляет layout, поэтому зона/видимость судятся по
// правилам RN-стиля (явные размеры, clamp min/max, flexBasis по главной оси,
// padding во всех формах, hitSlop), а размеры контента — детерминированной
// оценкой (Text: высота = lineHeight ?? fontSize ?? 14, ширина = знаков ×
// fontSize × 0,5).
import { StyleSheet } from 'react-native';
import type { TestInstance } from 'test-renderer';

export type Uzel = TestInstance;

export interface Zona {
  readonly w: number;
  readonly h: number;
}

type Sloj = Record<string, unknown>;

const TEXT_TIPY = new Set(['Text']);

function svojstva(uzel: Uzel): Record<string, unknown> {
  return ((uzel as unknown as { props?: Record<string, unknown> }).props ?? {});
}

function tipUzla(uzel: Uzel): string {
  const t = (uzel as unknown as { type?: unknown }).type;
  if (typeof t === 'string') return t;
  if (typeof t === 'function') return (t as { displayName?: string; name?: string }).displayName ?? (t as { name?: string }).name ?? '';
  if (t && typeof t === 'object') return ((t as { displayName?: string }).displayName ?? '');
  return '';
}

/** Плоский стиль узла (функциональный style вызывается с pressed=false). */
export function stilUzla(uzel: Uzel): Sloj {
  let style: unknown = svojstva(uzel).style;
  if (typeof style === 'function') {
    try {
      style = (style as (s: { pressed: boolean }) => unknown)({ pressed: false });
    } catch {
      style = undefined;
    }
  }
  return (StyleSheet.flatten(style as never) ?? {}) as Sloj;
}

export function roditel(uzel: Uzel): Uzel | null {
  return (uzel as unknown as { parent: Uzel | null }).parent ?? null;
}

export function deti(uzel: Uzel): Array<Uzel | string> {
  return ((uzel as unknown as { children?: Array<Uzel | string> }).children ?? []);
}

function chislo(znach: unknown): number | undefined {
  if (typeof znach === 'number' && Number.isFinite(znach)) return znach;
  return undefined;
}

function protsent(znach: unknown, baza: number): number | undefined {
  if (typeof znach === 'string' && znach.endsWith('%')) {
    const p = parseFloat(znach);
    if (Number.isFinite(p)) return (p / 100) * baza;
  }
  return undefined;
}

function razmer(znach: unknown, baza: number): number | undefined {
  return chislo(znach) ?? protsent(znach, baza);
}

/** interaktivnyjHozjain: ближайший сам-или-предок с press-обработчиком
 * (Pressable, семейство Touchable, Button). Не найден — null (TSEL_BEZ_HOZJAINA). */
export function interaktivnyjHozjain(uzel: Uzel): Uzel | null {
  let tek: Uzel | null = uzel;
  while (tek !== null) {
    const p = svojstva(tek);
    const otvechaet = typeof p.onStartShouldSetResponder === 'function' &&
      (p.onStartShouldSetResponder as () => boolean)() === true;
    if (otvechaet || p.onPress != null || p.onPressIn != null ||
        p.onPressOut != null || p.onLongPress != null) {
      return tek;
    }
    tek = roditel(tek);
  }
  return null;
}

/** Цепочка отключения: disabled / accessibilityState.disabled / pointerEvents
 * 'none' у узла или ЛЮБОГО предка. */
export function otklyuchenaPoCepi(uzel: Uzel): boolean {
  let tek: Uzel | null = uzel;
  while (tek !== null) {
    const p = svojstva(tek);
    const st = stilUzla(tek);
    const acc = p.accessibilityState as { disabled?: boolean } | undefined;
    if (p.disabled === true || acc?.disabled === true ||
        p.pointerEvents === 'none' || st.pointerEvents === 'none') {
      return true;
    }
    tek = roditel(tek);
  }
  return false;
}

// ── Оценка размеров контента ──────────────────────────────────────────
function stringiPoddereva(uzel: Uzel, sbor: string[]): void {
  for (const r of deti(uzel)) {
    if (typeof r === 'string') sbor.push(r);
    else stringiPoddereva(r, sbor);
  }
}

function otsenkaKontenta(uzel: Uzel): Zona {
  let w = 0;
  let h = 0;
  const obhod = (u: Uzel): void => {
    if (tipUzla(u) === 'Text') {
      const st = stilUzla(u);
      const razmerShrifta = chislo(st.fontSize) ?? 14;
      const strochki: string[] = [];
      stringiPoddereva(u, strochki);
      const dlina = strochki.join('').length;
      w = Math.max(w, dlina * razmerShrifta * 0.5);
      h = Math.max(h, chislo(st.lineHeight) ?? razmerShrifta);
      return;
    }
    for (const r of deti(u)) {
      if (typeof r !== 'string') obhod(r);
    }
  };
  obhod(uzel);
  return { w, h };
}

function napravlenieKonteynera(uzel: Uzel): { row: boolean; w?: number; h?: number } {
  let tek = roditel(uzel);
  while (tek !== null) {
    const st = stilUzla(tek);
    if (Object.keys(st).length > 0 || tipUzla(tek) === 'View') {
      const dir = st.flexDirection === 'row' || st.flexDirection === 'row-reverse';
      return { row: dir, w: chislo(st.width), h: chislo(st.height) ?? chislo(st.minHeight) };
    }
    tek = roditel(tek);
  }
  return { row: false };
}

function paddingOsi(st: Sloj, nachalo: string, konets: string, os: string): number {
  const obshchij = chislo(st.padding) ?? 0;
  const po_osi = chislo(st[os]) ?? obshchij;
  return (chislo(st[nachalo]) ?? po_osi) + (chislo(st[konets]) ?? po_osi);
}

function hitSlopUzla(uzel: Uzel): { x: number; y: number } {
  const s = svojstva(uzel).hitSlop;
  if (s == null) return { x: 0, y: 0 };
  if (typeof s === 'number') return { x: 2 * s, y: 2 * s };
  const o = s as Record<string, number>;
  return {
    x: Number(o.left || 0) + Number(o.right || 0),
    y: Number(o.top || 0) + Number(o.bottom || 0),
  };
}

/** zonaKasanija: эффективный бокс (px) ХОЗЯИНА по правилам RN-стиля
 * (SPEC §5): явный width/height (border-box) → flexBasis по главной оси
 * контейнера → flex:n в ряду → auto = контент + padding; clamp min/max;
 * hitSlop добавляется (отрицательный — сужает). */
export function zonaKasanija(hozjain: Uzel, shirinaProfilja: number): Zona {
  const st = stilUzla(hozjain);
  const kont = napravlenieKonteynera(hozjain);
  const kontent = otsenkaKontenta(hozjain);
  const padW = paddingOsi(st, 'paddingLeft', 'paddingRight', 'paddingHorizontal');
  const padH = paddingOsi(st, 'paddingTop', 'paddingBottom', 'paddingVertical');
  let w = razmer(st.width, shirinaProfilja);
  let h = razmer(st.height, 0);
  const basis = chislo(st.flexBasis);
  if (basis !== undefined) {
    if (kont.row && w === undefined) w = basis;
    if (!kont.row && h === undefined) h = basis;
  }
  const flexN = chislo(st.flex);
  if (flexN !== undefined && flexN > 0 && kont.row && w === undefined) {
    w = kont.w ?? shirinaProfilja;
    if (h === undefined && kont.h !== undefined) h = kont.h;
  }
  if (w === undefined) w = kontent.w + padW;
  if (h === undefined) h = kontent.h + padH;
  const minW = razmer(st.minWidth, shirinaProfilja);
  const maxW = razmer(st.maxWidth, shirinaProfilja);
  const minH = razmer(st.minHeight, 0);
  const maxH = razmer(st.maxHeight, 0);
  if (minW !== undefined) w = Math.max(w, minW);
  if (maxW !== undefined) w = Math.min(w, maxW);
  if (minH !== undefined) h = Math.max(h, minH);
  if (maxH !== undefined) h = Math.min(h, maxH);
  const slop = hitSlopUzla(hozjain);
  return { w: w + slop.x, h: h + slop.y };
}

// ── Видимость ─────────────────────────────────────────────────────────
function prozrachnyjCvet(cvet: unknown): boolean {
  if (typeof cvet !== 'string') return false;
  const s = cvet.trim().toLowerCase();
  if (s === 'transparent') return true;
  if (/^#[0-9a-f]{8}$/.test(s) && s.slice(7) === '00') return true;
  const m = s.match(/^rgba\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*([0-9.]+)\s*\)$/);
  if (m && parseFloat(m[1]) === 0) return true;
  return false;
}

function pokryvayuschijBrat(uzel: Uzel, shirina: number, vysota: number): boolean {
  // Непрозрачный абсолютный узел, идущий в дереве ПОЗЖЕ цели и закрывающий её
  // бокс (прямая видимость): проверяется у каждого предка цели.
  let potomok: Uzel = uzel;
  let tek = roditel(uzel);
  while (tek !== null) {
    const bratya = deti(tek).filter((r): r is Uzel => typeof r !== 'string');
    const i = bratya.indexOf(potomok);
    for (let j = i + 1; j < bratya.length; j++) {
      const sb = stilUzla(bratya[j]);
      if (sb.position !== 'absolute') continue;
      const fon = sb.backgroundColor;
      if (fon === undefined || prozrachnyjCvet(fon)) continue;
      if (chislo(sb.opacity) === 0) continue;
      const zalivka = chislo(sb.top) === 0 && chislo(sb.left) === 0 &&
        chislo(sb.right) === 0 && chislo(sb.bottom) === 0;
      const bW = razmer(sb.width, shirina) ?? 0;
      const bH = razmer(sb.height, vysota) ?? 0;
      if (zalivka || (bW >= shirina && bH >= vysota && bW > 0)) return true;
    }
    potomok = tek;
    tek = roditel(tek);
  }
  return false;
}

/** vidimostUzla: false, если (а) сам или ЛЮБОЙ предок display:'none' или
 * opacity 0; (б) нулевой width/height; (в) бокс целиком вне вьюпорта
 * профиля; (г) бокс целиком за клипом предка (overflow hidden); (д) бокс
 * перекрыт непрозрачным узлом; (е) прозрачный фон при невидимом
 * содержимом. */
export function vidimostUzla(uzel: Uzel, shirina: number, vysota = 844): boolean {
  let tek: Uzel | null = uzel;
  while (tek !== null) {
    const st = stilUzla(tek);
    if (st.display === 'none') return false;
    if (chislo(st.opacity) === 0) return false;
    tek = roditel(tek);
  }
  const st = stilUzla(uzel);
  if (chislo(st.width) === 0 || chislo(st.height) === 0) return false;
  if (st.position === 'absolute') {
    const left = chislo(st.left);
    const top = chislo(st.top);
    const bW = razmer(st.width, shirina) ?? 0;
    const bH = razmer(st.height, vysota) ?? 0;
    if (left !== undefined && (left + bW <= 0 || left >= shirina)) return false;
    if (top !== undefined && (top + bH <= 0 || top >= vysota)) return false;
    // за клипом предка с известным боксом
    let ancestor = roditel(uzel);
    while (ancestor !== null) {
      const sa = stilUzla(ancestor);
      if (sa.overflow === 'hidden') {
        const aW = chislo(sa.width);
        const aH = chislo(sa.height);
        if (aW !== undefined && left !== undefined && left >= aW) return false;
        if (aH !== undefined && top !== undefined && top >= aH) return false;
      }
      ancestor = roditel(ancestor);
    }
  }
  if (pokryvayuschijBrat(uzel, shirina, vysota)) return false;
  if (prozrachnyjCvet(st.backgroundColor)) {
    // прозрачный фон допустим, пока есть видимые буквы
    if (!estVidimyjTekst(uzel, shirina, vysota)) return false;
  }
  return true;
}

function estVidimyjTekst(uzel: Uzel, shirina: number, vysota: number): boolean {
  return vidimyeStroki(uzel, shirina, vysota).join('').length > 0;
}

/** Видимые буквы поддерева: строки-листья, чей ближайший Text-носитель
 * видим (сам Text-узел с буквами, а не видимый предок) и не прозрачен. */
export function vidimyeStroki(uzel: Uzel, shirina: number, vysota = 844,
                              cvetPredka?: unknown): string[] {
  const rezultat: string[] = [];
  const obhod = (u: Uzel, cvet: unknown): void => {
    const st = stilUzla(u);
    const sobstvennyj = tipUzla(u) === 'Text' && st.color !== undefined ? st.color : cvet;
    for (const r of deti(u)) {
      if (typeof r === 'string') {
        if (!TEXT_TIPY.has(tipUzla(u))) continue;
        if (prozrachnyjCvet(sobstvennyj)) continue;
        if (!vidimostUzla(u, shirina, vysota)) continue;
        if (chislo(st.width) === 0 || chislo(st.height) === 0) continue;
        rezultat.push(r);
      } else {
        obhod(r, sobstvennyj);
      }
    }
  };
  obhod(uzel, cvetPredka);
  return rezultat;
}

/** vidimajaNadpis: среди букв-носителей хозяина собранная ВИДИМАЯ строка
 * равна ожиданию (скрытые/прозрачные/нулевые Text игнорируются). */
export function vidimajaNadpis(uzel: Uzel, ozhidanie: string, shirina: number,
                               vysota = 844): boolean {
  return vidimyeStroki(uzel, shirina, vysota).join('') === ozhidanie;
}

/** a11yNadpis: доступное имя цели — для целей-ИКОНОК, у которых видимой
 * надписи нет: имя обязано быть предъявлено узлом цели или её хозяином
 * (accessibilityLabel). Иначе имя не предъявлено — надпись не найдена.
 * Ветка объявляется ТОЛЬКО картой (SPEC §4: поле accessibilityLabel цели);
 * для целей с видимой надписью она не действует — их надпись судится
 * vidimajaNadpis. */
export function a11yNadpis(uzel: Uzel, hozjain: Uzel | null,
                            ozhidanie: string): boolean {
  const svoe = svojstva(uzel).accessibilityLabel;
  if (typeof svoe === 'string') return svoe === ozhidanie;
  if (hozjain !== null) {
    const imyaHozjaina = svojstva(hozjain).accessibilityLabel;
    if (typeof imyaHozjaina === 'string') return imyaHozjaina === ozhidanie;
  }
  return false;
}
