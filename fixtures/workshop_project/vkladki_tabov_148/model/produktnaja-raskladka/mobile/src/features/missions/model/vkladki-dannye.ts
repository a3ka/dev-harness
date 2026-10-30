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

export const VORGAENGE_SPISENOK: readonly VorgangRow[] = [
  { id: 'vorgaenge-stroka-1', title: 'Hausrat-Vergleich', group: 'working' },
  { id: 'vorgaenge-stroka-2', title: 'Kfz-Wechsel', group: 'waiting' },
  { id: 'vorgaenge-stroka-3', title: 'Rechtsschutz-Beratung', group: 'working' },
  { id: 'vorgaenge-stroka-4', title: 'Hausrat-Vertrag', group: 'working' },
];
