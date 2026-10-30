// Копия экрана текст-чата Gespräch (контракт 149, референс-раскладка).
// Каталожные ключи — verbatim из среза каталога копии пачки
// (mobile/e2e-gespraech-tekst/katalog_kopii.json, срез BrokerOS_UI_Copy_DE);
// предложенные строки плашек/чипов (вне машинной зелени пачки) — из
// макетов D 2.4 (GA-11/GA-12), ловец — копи-ревью (контракт §НЕ ЗАЩИЩАЕТ).
// Продукт подключает копию через ui-copy (зона implementer); референс
// держит её одним модулем, чтобы зонд батареи не зависел от проводки
// i18n продукта.
export interface ZapisKopii {
  readonly text: string;
}

export const katalogKopii: Readonly<Record<string, ZapisKopii>> = {
  'frame.F04.01.title': { text: 'Was möchten Sie klären?' },
  'action.F04.A01': { text: 'Nachricht schreiben' },
  'action.F05.A01': { text: 'Nachricht senden' },
  'action.F05.A02': { text: 'Dokument hinzufügen' },
  'ia115.entry.speak': { text: 'Sprechen' },
  'frame.F05.02.title': { text: 'Gesprächsverlauf' },
  'ia115.nav.START': { text: 'Start' },
  'ia117.nav.VORGAENGE': { text: 'Vorgänge' },
  'ia115.nav.SCHUTZ': { text: 'Schutz' },
  'ia115.nav.POST': { text: 'Post' },
  'ui.mission.group.working': { text: 'In Arbeit' },
};

// Предложенные строки (PROPOSED, вне каталога): плашки тем GA-11,
// чипы ответа и «Lieber erzählen?» GA-12, темы-строка GA-17.
export const predlozheno = {
  srochno: 'Schaden melden',
  temy: [
    { id: 'auto', nadpis: 'Neues Auto' },
    { id: 'umzug', nadpis: 'Umzug' },
    { id: 'nachwuchs', nadpis: 'Nachwuchs' },
    { id: 'heirat', nadpis: 'Heirat' },
  ],
  erzaehlen: 'erzählen',
  chipy: [
    { id: 'gekauft', nadpis: 'Gekauft' },
    { id: 'geplant', nadpis: 'Geplant' },
  ],
  lieber: 'Lieber erzählen?',
  voprosTemy: 'Wann haben Sie das Auto gekauft?',
  voprosWeiter: 'Möchten Sie noch etwas ergänzen?',
} as const;
