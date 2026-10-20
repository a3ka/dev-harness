// CMP-MOB-004 (108): порт черновика Start (fixtures-модель, в PR
// Complior-mob не копируется). Пост-заморозочное усиление гейта по вердикту
// reviewer круга 1 (R108-1): TabShell размонтирует слот start при смене
// вкладки и переходе в profile — состояние ЛЮБОГО компонента внутри слота
// (включая композер) умирает вместе со слотом. Черновик живёт ВЫШЕ слота:
// route держит draft в собственном состоянии (route не размонтируется при
// смене вкладки) и подаёт его композеру этим контекстом. Вне провайдера
// (экранная семья 324, изолированный рендер StartScreen) композер держит
// собственное состояние — порты StartScreen не расширяются.
import { createContext } from 'react';

export interface StartDraftPort {
  readonly draft: string;
  readonly setDraft: (text: string) => void;
}

export const StartDraftContext = createContext<StartDraftPort | null>(null);
