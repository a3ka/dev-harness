// Реализация CMP-MOB-002/004: производные runtime-ключи каталога
// BrokerOS_UI_Copy_DE.json (docs/ux/01_UX_Source_of_Truth/), точные
// тексты и review_status verbatim. Источник read-only, новых формулировок
// не вводится; ключ ia115.nav.HEUTE — deprecated, не используется.
// Карта TAB_LABEL_KEYS сопоставляет section id → ключ подписи вкладки,
// SECTION_TITLE_KEYS — section id → ключ заголовка кадра.
// CMP-MOB-004 (108): добавлены ключи Start F04.01/F04.02/F04.03/F04.06/
// F04.07 (title+body) и action.F04.A01/A02/A03 — verbatim из того же
// каталога; review_status сохранён (copy signoff CMP-MOB-089 не заявлен).
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
  'frame.F04.01.body': { text: 'Was ist passiert? Schreiben Sie, sprechen Sie oder fügen Sie ein Foto oder Dokument hinzu.', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'frame.F04.02.title': { text: 'Was ist passiert?', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'frame.F04.02.body': { text: 'Schreiben Sie Ihr Anliegen oder starten Sie ein Gespräch.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F04.03.title': { text: 'Ich höre zu.', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'frame.F04.03.body': { text: 'Sie können das Gespräch jederzeit unterbrechen oder zum Text wechseln.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F04.06.title': { text: 'Hier machen wir weiter.', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'frame.F04.06.body': { text: 'Sehen Sie den aktuellen Stand und setzen Sie Ihr Anliegen fort.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F04.07.title': { text: 'Wie möchten Sie beginnen?', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'frame.F04.07.body': { text: 'Text, Sprache, Foto und Dokument gehören zu demselben Anliegen.', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'action.F04.A01': { text: 'Nachricht schreiben', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'action.F04.A02': { text: 'Sprechen', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'action.F04.A03': { text: 'Vorgang fortsetzen', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'frame.F08.01.title': { text: 'Ihre Vorgänge', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F19.01.title': { text: 'Ihre Absicherung im Überblick', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F16.01.title': { text: 'Ihre Dokumente', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'action.F12.A01': { text: 'Profil bearbeiten', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'global.back': { text: 'Zurück', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
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
