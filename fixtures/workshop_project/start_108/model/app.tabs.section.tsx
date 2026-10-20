// CMP-MOB-004 (108): honest-модель route-файла (tabs)/[section].tsx
// (fixtures-модель, в PR Complior-mob не копируется). Пост-заморозочное
// усиление гейта по вердиктам судей круга 1 (contracts-108-impl-v1):
//
//  - F04.V04 (adversary): route ОБЯЗАН доносить системную настройку
//    reduce motion до StartScreen. Route читает её сам тем же публичным
//    API RN (AccessibilityInfo.isReduceMotionEnabled, Promise<boolean>),
//    каким читает TabShell: пока Promise не разрешён — безопасный true
//    (анимаций нигде нет); после разрешения значение подаётся в слот.
//    Создание элемента слота с константой reducedMotion={false} — обход:
//    TabShell честь настройки отдаёт (shell-faden), экран — нет.
//
//  - R108-1 (reviewer): TabShell размонтирует слот start при смене вкладки
//    и переходе в profile — черновик композера обязан жить ВЫШЕ слота.
//    Route держит draft в собственном состоянии и подаёт композеру через
//    StartDraftContext (Maestro cmp-mob-004-start: написать → вернуться →
//    продолжить). Порты StartScreen не расширяются: вне провайдера композер
//    держит собственное состояние (экранная семья 324).
//
//  - Adv108r2/B-1 (круг 3): слот подаётся TabShell ВСЕГДА, без условия
//    «вход через start». TabShell сам рендерит слот только в секции start;
//    привязка слота к сегменту ВХОДА (start === 'start' ? … : undefined)
//    при deep link из грамматики 999 (complior://vorgaenge?returnTo=start)
//    или входе в другую секцию оставляет секции start один заголовок —
//    без AgentPresence, композера, brief и resume.
//
//  - R108-6 (совет): хост секции — ИНЛАЙН в route-файле; отдельный файл
//    хоста в src/app/ expo-router трактует как маршрут (/start-section),
//    STRUCTURE.md:143 разрешает в app/ только файлы маршрутов.
//
// Подача missions — как у C: runtime.api.listMissions (mock: сценарий
// start-mock; http до CMP-BCK-008/009 — именованный отказ → missions=null,
// безопасный fallback экрана без brief/resume).
import React, { useEffect, useState } from 'react';
import { AccessibilityInfo } from 'react-native';
import { useLocalSearchParams } from 'expo-router';

import type { MissionBrief } from '@/api/api-client';
import { StartDraftContext } from '@/features/start/draft-context';
import { StartScreen } from '@/features/start/start-screen';
import { runtime as shippedRuntime } from '@pilot/runtime';
import { TabShell, type ShellSection } from '../../bootstrap/tab-shell';
import { TAB_ORDER } from '../../theme/tokens';

const SECTIONS = new Set<ShellSection>(TAB_ORDER);

function pick(raw: string | string[] | undefined): ShellSection | null {
  const value = Array.isArray(raw) ? raw[0] : raw;
  return value && SECTIONS.has(value as ShellSection) ? (value as ShellSection) : null;
}

// Считывание системного reduce motion — тот же публичный API и та же
// безопасная семантика, что у TabShell (999): Promise не разрешён — true.
function readSystemReduceMotionInitial(): boolean {
  try {
    const value = AccessibilityInfo.isReduceMotionEnabled();
    if (typeof value === 'boolean') return value;
    if (value && typeof (value as Promise<boolean>).then === 'function') return true;
  } catch {
    return true;
  }
  return true;
}

function useSystemReduceMotion(): boolean {
  const [enabled, setEnabled] = useState<boolean>(() => readSystemReduceMotionInitial());
  useEffect(() => {
    let cancelled = false;
    const apply = (next: boolean) => {
      if (!cancelled) setEnabled(next);
    };
    try {
      const pending = AccessibilityInfo.isReduceMotionEnabled();
      if (pending && typeof (pending as Promise<boolean>).then === 'function') {
        (pending as Promise<boolean>).then(apply).catch(() => apply(true));
      } else if (typeof pending === 'boolean') {
        apply(pending);
      } else {
        apply(true);
      }
    } catch {
      apply(true);
    }
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', apply);
    return () => {
      cancelled = true;
      sub.remove();
    };
  }, []);
  return enabled;
}

// Хост секции start: подключение StartScreen к runtime (listMissions).
// Инлайн в route-файле — файл в src/app/ без default export создаёт
// маршрут-призрак (R108-6).
function StartSectionHost({ reducedMotion }: { readonly reducedMotion: boolean }) {
  const [missions, setMissions] = useState<readonly MissionBrief[] | null>(null);

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

  return (
    <StartScreen
      avatarState="idle"
      missions={missions}
      reducedMotion={reducedMotion}
    />
  );
}

export default function TabRoute() {
  const { section, returnTo } = useLocalSearchParams<{
    section?: string | string[];
    returnTo?: string | string[];
  }>();
  const start = pick(section);
  const ret = pick(returnTo);
  const systemReduceMotion = useSystemReduceMotion();
  // Черновик — состояние route (выше слота): переживает размонтирование
  // слота при смене вкладки и переход в profile (R108-1).
  const [draft, setDraft] = useState('');
  if (!start) return null;
  return (
    <TabShell
      initialSection={start}
      returnSection={ret}
      startScreen={
        <StartDraftContext.Provider value={{ draft, setDraft }}>
          <StartSectionHost reducedMotion={systemReduceMotion} />
        </StartDraftContext.Provider>
      }
    />
  );
}
