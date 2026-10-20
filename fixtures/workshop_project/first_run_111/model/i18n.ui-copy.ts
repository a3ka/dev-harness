// Реализация CMP-MOB-002: производные runtime-ключи каталога
// BrokerOS_UI_Copy_DE.json (docs/ux/01_UX_Source_of_Truth/), точные
// тексты и review_status verbatim. Источник read-only, новых формулировок
// не вводится; ключ ia115.nav.HEUTE — deprecated, не используется.
// Карта TAB_LABEL_KEYS сопоставляет section id → ключ подписи вкладки,
// SECTION_TITLE_KEYS — section id → ключ заголовка кадра.
export interface CopyEntry {
  readonly text: string;
  readonly review_status: string;
}

export const uiCopyDe: Readonly<Record<string, CopyEntry>> = {
  'ia115.nav.START': { text: 'Start', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'ia117.nav.VORGAENGE': { text: 'Vorgänge', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'ia115.nav.SCHUTZ': { text: 'Schutz', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'ia115.nav.POST': { text: 'Post', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'frame.F04.01.title': { text: 'Was möchten Sie klären?', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F08.01.title': { text: 'Ihre Vorgänge', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F19.01.title': { text: 'Ihre Absicherung im Überblick', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F16.01.title': { text: 'Ihre Dokumente', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'action.F12.A01': { text: 'Profil bearbeiten', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'global.back': { text: 'Zurück', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  // 111 (CMP-MOB-005): кадр First-Run D2.2.5.1 — promise и вход в F03.01.
  'ui.first_run.promise': { text: 'Sie sagen, was passiert ist. Complior kümmert sich um den Rest.', review_status: 'UX_EDITORIAL_REVIEWED; NATIVE_RELEASE_SIGNOFF_REQUIRED' },
  'ui.first_run.enter_f03': { text: 'Anmelden oder Konto erstellen', review_status: 'UX_EDITORIAL_REVIEWED; NATIVE_RELEASE_SIGNOFF_REQUIRED' },
};

export const TAB_LABEL_KEYS: Readonly<Record<string, string>> = {
  start: 'ia115.nav.START',
  vorgaenge: 'ia117.nav.VORGAENGE',
  schutz: 'ia115.nav.SCHUTZ',
  post: 'ia115.nav.POST',
};

export const SECTION_TITLE_KEYS: Readonly<Record<string, string>> = {
  start: 'frame.F04.01.title',
  vorgaenge: 'frame.F08.01.title',
  schutz: 'frame.F19.01.title',
  post: 'frame.F16.01.title',
};