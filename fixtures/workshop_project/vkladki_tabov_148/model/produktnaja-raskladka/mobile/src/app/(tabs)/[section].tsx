// Динамический маршрут внутри группы (tabs). Сегмент URL — имя раздела из
// TAB_ORDER (start / vorgaenge / schutz / post); невалидный сегмент даёт
// путь Unmatched (expo-router отдаёт 404-слот). Параметр returnTo
// определяет раздел возврата после deep-link.
//
// 118 (круг 1 адверсария, блокер B1): прямой URL /start (и остальных
// секций) НЕ минует допуск. Допуск читается тем же production-источником
// сессии, что у корня `/` (app/onboarding-session, composition-шов
// @pilot/runtime; допуск ПО УМОЛЧАНИЮ среды пробы 108 — валидная сессия
// демо-рантайма — сохраняет прежний TabShell на клетках ROUTE_*).
// Семантика 117 v3 (арбитраж 117↔118 п.2): начальный кадр — First-Run;
// Start — только continue при W1A ∧ current; допуск — только из порта
// сессии. Маршрут судит ТОЛЬКО допуск сессии: доказательство current
// живёт в пути `/` (continue при подтверждённой выдаче), прямой URL не
// вводит второго gate-предиката. При недопуске (pending — порт не
// подключён, отказ/нераспознаваемый payload — W0) маршрут показывает
// поверхность входа (первый кадр First-Run того же PilotApp), НЕ
// TabShell: открытием URL нельзя миновать First-Run → demo →
// Erstinformation → continue.
//
// CMP-MOB-004 (108): для секции start TabShell получает слот
// `startScreen` — компонент StartSectionHost рендерит StartScreen с
// missions/avatarState из runtime.api.listMissions. Composition root
// (этот route-файл) поднимает listMissions-запрос (allowed: app →
// bootstrap @pilot/runtime) и подачу через порт; без слота (frozen
// nav_999 пробы) рендерится только заголовок секции, как было в 999.
//
// CMP-MOB-004 (108, круг 2): composition root — единственный источник
// системного reduceMotion (useSystemReduceMotion — общий с TabShell,
// экспорт из bootstrap/tab-shell) и хранитель черновика композера.
// Черновик живёт здесь, выше слота start: TabShell размонтирует слот
// при смене вкладки/переходе в profile, и без хранения в composition
// root он терялся бы при возврате. Без стораджа (политика «без
// персиста»).
//
// CMP-MOB-004 (108, круг 3): слот start передаётся ВСЕГДА, независимо от
// сегмента маршрута при входе. Вкладки переключает сам TabShell
// (внутренний setSection), поэтому условие `start === 'start'` гасило
// слот при deep-link в другую секцию (грамматика 999:
// complior://vorgaenge?returnTo=start) — секция start показывала только
// заголовок, без присутствия, композера, brief и resume. Рендер слота
// остаётся ограниченным `section === 'start'` внутри TabShell; без слота
// (frozen nav_999 пробы) рендерится только заголовок секции, как в 999.
import { useEffect, useState } from 'react';
import { useLocalSearchParams } from 'expo-router';
import type { MissionBrief } from '@/api/api-client';
import { PilotApp } from '../../bootstrap/pilot-app';
import { TabShell, useSystemReduceMotion, type ShellSection } from '../../bootstrap/tab-shell';
import { useOnboardingSession } from '../onboarding-session';
import { StartSectionHost } from '@/features/start/start-section-host';
import { runtime as shippedRuntime } from '@pilot/runtime';
import { TAB_ORDER } from '../../theme/tokens';
import { VorgaengeListe } from '@/features/missions/components/VorgaengeListe';
import { SchutzUebersicht } from '@/features/protection/components/SchutzUebersicht';
import { PostEingang } from '@/features/post/components/PostEingang';
import { GespraechMitte, type GespraechMitteStatus } from '../../bootstrap/gespraech-mitte';


const SECTIONS: Readonly<Record<string, ShellSection>> = TAB_ORDER.reduce(
  (acc, id) => {
    acc[id] = id as ShellSection;
    return acc;
  },
  {} as Record<string, ShellSection>,
);

function pick(raw: string | string[] | undefined): ShellSection | null {
  const value = Array.isArray(raw) ? raw[0] : raw;
  return value && value in SECTIONS ? (value as ShellSection) : null;
}

export default function TabRoute() {
  const { section, returnTo, mitte: mitteParam } = useLocalSearchParams<{
    section?: string | string[];
    returnTo?: string | string[];
    mitte?: string | string[];
  }>();
  const start = pick(section);
  const ret = pick(returnTo);
  // Допуск маршрута — из той же сессии, что у корня `/` (B1): pending
  // (порт не подключён) и W0 (отказ/нераспознаваемый payload,
  // идентификация) недопуском остаются. Идентификация вводится в
  // PilotApp этого же маршрута — сессия читается в момент действия.
  const session = useOnboardingSession();
  const reducedMotion = useSystemReduceMotion();
  const [draft, setDraft] = useState('');
  const [missions, setMissions] = useState<readonly MissionBrief[] | null>(null);
  // 148 vkladki-tabov: состояние Mitte для кадра GA-03 (бейдж) — параметр
  // маршрута ?mitte=needs (e2e-наблюдаем, прецедент demo-параметров);
  // переключение нажатием Mitte — видимый мок-отклик до контракта меню
  // 147 (мок-цель по zamenjaet, нарезка D 2.4). Хуки — до условных
  // возвратов (rules-of-hooks).
  const mitteIzMarshruta = Array.isArray(mitteParam) ? mitteParam[0] : mitteParam;
  const [mittePerekljuchen, setMittePerekljuchen] = useState(false);
  const [postFiltr, setPostFiltr] = useState<'all' | 'received' | 'sent'>('all');
  const mitteStatus: GespraechMitteStatus =
    mitteIzMarshruta === 'needs'
      ? 'needs_action'
      : mittePerekljuchen
        ? 'needs_action'
        : 'working';


  useEffect(() => {
    let cancelled = false;
    void (async () => {
      try {
        const page = await shippedRuntime.api.listMissions();
        if (!cancelled) setMissions(page.items);
      } catch {
        // Именованный отказ http-runtime до CMP-BCK-008/009: missions=null
        // (безопасный fallback: присутствие и композер, без brief/resume).
        if (!cancelled) setMissions(null);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  if (!start) return null;
  if (session.onboarding?.admission !== 'W1A') {
    // Недопуск: поверхность входа (первый кадр First-Run PilotApp с
    // портом этой же сессии) — легитимный путь к Start остаётся
    // First-Run → demo → Erstinformation → continue при current.
    return (
      <PilotApp
        onIdentityInput={session.onIdentityInput}
        onboarding={session.onboarding}
      />
    );
  }
  // 148 vkladki-tabov: Mitte и контент вкладок — слоты TabShell; нажатие
  // Mitte — видимый мок-отклик (переключение статуса/бейджа GA-02↔GA-03)
  // до контракта меню 147 (мок-цель по zamenjaet, нарезка D 2.4).
  return (
    <TabShell
      initialSection={start}
      mitte={
        <GespraechMitte
          onPress={() => setMittePerekljuchen(!mittePerekljuchen)}
          reducedMotion={reducedMotion}
          status={mitteStatus}
        />
      }
      reducedMotion={reducedMotion}
      returnSection={ret}
      sectionScreens={{
        post: <PostEingang filtr={postFiltr} onFiltr={setPostFiltr} />,
        schutz: <SchutzUebersicht />,
        vorgaenge: <VorgaengeListe />,
      }}
      startScreen={
        <StartSectionHost
          composerOnChange={setDraft}
          composerValue={draft}
          missions={missions}
          reducedMotion={reducedMotion}
        />
      }
    />
  );
}
