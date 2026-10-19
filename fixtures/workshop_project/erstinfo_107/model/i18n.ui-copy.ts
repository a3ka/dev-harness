// Реализация CMP-MOB-002: производные runtime-ключи каталога
// BrokerOS_UI_Copy_DE.json (docs/ux/01_UX_Source_of_Truth/), точные
// тексты и review_status verbatim. Источник read-only, новых формулировок
// не вводится; ключ ia115.nav.HEUTE — deprecated, не используется.
// Карта TAB_LABEL_KEYS сопоставляет section id → ключ подписи вкладки,
// SECTION_TITLE_KEYS — section id → ключ заголовка кадра.
// CMP-MOB-003: добавлены ключи Erstinformation (F02.03/F02.05/F02.08,
// disclosure.*) тем же правилом verbatim.
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
  'disclosure.checking': { text: 'Die Bereitstellung Ihrer Erstinformation wird geprüft.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'disclosure.pending': { text: 'Der Nachweis steht noch aus. Wir prüfen die Übermittlung.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'disclosure.failed': { text: 'Die Bereitstellung konnte nicht bestätigt werden. Ihr Anliegen bleibt gespeichert.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'disclosure.retry': { text: 'Bereitstellung erneut prüfen', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'disclosure.updated': { text: 'Für diesen Schritt ist eine neuere Erstinformation erforderlich.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'disclosure.missing': { text: 'Die erforderliche Erstinformation wurde noch nicht bestätigt bereitgestellt.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'disclosure.not_applicable': { text: 'Für diesen Schritt ist keine erneute Bereitstellung erforderlich.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F02.03.title': { text: 'Informationen zu Ihrem Makler', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F02.03.body': { text: 'Hier finden Sie den verantwortlichen Makler und die Erstinformation zum Herunterladen.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F02.05.title': { text: 'Dokument ansehen', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F02.05.body': { text: 'Prüfen Sie Inhalt, Anbieter und Version. Sie können eine Kopie speichern.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F02.08.title': { text: 'Bereitstellung der Erstinformation', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'frame.F02.08.body': { text: 'Hier sehen Sie den aktuellen Stand der Bereitstellung und den verfügbaren Nachweis.', review_status: 'EDITORIAL_DRAFT_REVIEW_REQUIRED' },
  'action.F02.A01': { text: 'Mit einer Aufgabe starten', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
  'action.F02.A02': { text: 'Dokument öffnen', review_status: 'PRODUCT_COPY_REVIEW_REQUIRED' },
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
