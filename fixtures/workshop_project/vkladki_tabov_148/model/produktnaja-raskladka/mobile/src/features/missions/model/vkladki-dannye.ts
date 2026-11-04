/**
 * 148 vkladki-tabov: UI-фикстура вкладки Vorgänge (GA-02 — верх списка,
 * GA-09 — тот же список после прокрутки; одна честная модель списка,
 * кадры различаются позицией прокрутки, не подменой данных). Данные
 * SYNTHETIC по построению (прецедент mocks/start-mock): реальные
 * Vorgänge придут с бэкендом разговора (нарезка D 2.4: пилот на
 * тестовых данных); заголовки строк — данные, не копия (как заголовки
 * миссий у 108).
 */
export type VorgangGruppa = 'working' | 'waiting';

export interface VorgangRow {
  readonly id: string;
  readonly title: string;
  readonly group: VorgangGruppa;
}

// v+1 (пакет D24-Kompakt-1.1, GA-02 «ohne «Complior fragen» in der
// Liste»): видимые строки кадра — Rechtsschutz-Beratung и
// Hausrat-Vertrag (цели манифеста 1.1); Hausrat-Vergleich и Kfz-Wechsel
// — ниже прокрутки (GA-09), не цели судимых кадров.
export const VORGAENGE_SPISENOK: readonly VorgangRow[] = [
  { id: 'vorgaenge-stroka-rechtsschutz', title: 'Rechtsschutz-Beratung', group: 'working' },
  { id: 'vorgaenge-stroka-hausrat-vertrag', title: 'Hausrat-Vertrag', group: 'working' },
  { id: 'vorgaenge-stroka-hausrat-vergleich', title: 'Hausrat-Vergleich', group: 'working' },
  { id: 'vorgaenge-stroka-kfz-wechsel', title: 'Kfz-Wechsel', group: 'waiting' },
];
