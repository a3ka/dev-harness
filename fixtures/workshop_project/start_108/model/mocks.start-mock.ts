/**
 * CMP-MOB-004: mock-сценарии Start (features F04) для расширенного mock
 * ApiClient (`mocks/runtime.ts`). Сценарии замкнуты грамматикой оракула
 * 108: presence ∈ {EMPTY, PRESENT} × mission_states (10 значений OpenAPI).
 * Ответы mock — SYNTHETIC по построению (прецедент 995/107): реальная
 * выдача CMP-BCK-008/009 этим файлом не заявляется.
 */
import type { MissionBrief, MissionState } from '@/api/api-client';

export const MISSION_STATES: readonly MissionState[] = [
  'RECEIVED',
  'WORKING',
  'NEEDS_INFORMATION',
  'ADVISER_REVIEW',
  'NEEDS_APPROVAL',
  'WAITING_EXTERNAL',
  'COMPLETED',
  'PARTIAL',
  'BLOCKED',
  'CANCELLED',
];

export const MISSION_ID = 'MIS-CAR-01';
export const UPDATED_AT = '2026-10-09T12:00:00Z';

export type Presence = 'EMPTY' | 'PRESENT';

let scenario: { presence: Presence; state: MissionState } = { presence: 'PRESENT', state: 'WORKING' };

/** Сценарий для runtime.listMissions (по умолчанию — доступное дело). */
export function setScenario(presence: Presence, state: MissionState): void {
  scenario = { presence, state };
}

/** Сценарий снимка listMissions: EMPTY → items [], PRESENT → дело MIS-CAR-01. */
export function missionsFor(presence: Presence, state: MissionState): MissionBrief[] {
  if (presence === 'EMPTY') return [];
  return [{ mission_id: MISSION_ID, state, updated_at: UPDATED_AT }];
}

/** Текущий снимок для runtime.listMissions (mock-режим, сценарий setScenario). */
export function missionsSnapshot(): { items: MissionBrief[] } {
  const { presence, state } = scenario;
  return { items: missionsFor(presence, state) };
}
