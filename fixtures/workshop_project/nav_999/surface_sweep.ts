import { within } from '@testing-library/react-native';
import type { TestInstance } from 'test-renderer';
import { KeyboardAvoidingView, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import source from './source.json';

// 999 CMP-MOB-002, круг 3 (решение арбитража 999): общий обход поверхности
// шва. Единый источник грамматики — source.json: TABS (tabs_order) × MODES
// (modes: reducedMotion × colorScheme). Обход исполняется в КАЖДОМ состоянии
// К1 и наблюдает К3 (контейнеры 3.1–3.3) и К4 (каталог 4.1, акцент-гейт 4.3).
// Образец замера — свидетель арбитража (arb999/witness.test.tsx); здесь
// самостоятельная реализация проб предмета, не копия оракула.

export const TABS = source.tabs_order as readonly string[];
const MODE_SRC = source.modes as { reducedMotion: boolean[]; colorScheme: ('dark' | 'light')[] };
export type Scheme = 'dark' | 'light';
export const MODES: ReadonlyArray<{ rm: boolean; cs: Scheme }> = MODE_SRC.reducedMotion.flatMap((rm) =>
  MODE_SRC.colorScheme.map((cs) => ({ rm, cs })),
);
const TOK = source.tokens as Record<string, Record<Scheme, string>>;
const SECTIONS = source.sections as Record<string, string>;
const COPY = source.copy as Record<string, { text: string }>;
export const CATALOG: Record<string, true> = {};
for (const entry of Object.values(COPY)) CATALOG[entry.text] = true;

type FiberLike = { type?: unknown; return?: FiberLike | null; memoizedProps?: Record<string, unknown> } | null;

export function leaves(node: unknown, out: string[]): void {
  if (typeof node === 'string') {
    out.push(node);
    return;
  }
  if (Array.isArray(node)) {
    node.forEach((child) => leaves(child, out));
    return;
  }
  if (node && typeof node === 'object' && 'children' in (node as Record<string, unknown>)) {
    leaves((node as { children: unknown }).children, out);
  }
}

export function colorOf(node: TestInstance): string | undefined {
  const style = StyleSheet.flatten(node.props.style);
  return typeof style?.color === 'string' ? style.color : undefined;
}

export function backgroundOf(node: TestInstance): string | undefined {
  const style = StyleSheet.flatten(node.props.style);
  return typeof style?.backgroundColor === 'string' ? style.backgroundColor : undefined;
}

// К3.1: ближайший композит над хостом — вверх до первого host-fiber (строковый type).
export function nearestCompositeIs(node: TestInstance, component: unknown): boolean {
  let fiber: FiberLike = (node as unknown as { unstable_fiber?: { return: FiberLike } }).unstable_fiber?.return ?? null;
  while (fiber) {
    if (fiber.type === component) return true;
    if (typeof fiber.type === 'string') return false;
    fiber = fiber.return ?? null;
  }
  return false;
}

// К3.2/3.3: потомок host-узла с данным testID (по host-fiber'ам).
export function isDescendantOfHost(node: TestInstance, hostTestID: string): boolean {
  let fiber: FiberLike = (node as unknown as { unstable_fiber?: { return: FiberLike } }).unstable_fiber?.return ?? null;
  while (fiber) {
    if (typeof fiber.type === 'string' && fiber.memoizedProps?.testID === hostTestID) return true;
    fiber = fiber.return ?? null;
  }
  return false;
}

// К2.1: fiber-проводка onPress до Pressable — fireEvent.press в RNTL 14
// всплывает до пропсов вызова и не различает отвязанный обработчик.
export function wiredOnPress(host: TestInstance): unknown {
  let fiber: FiberLike = (host as unknown as { unstable_fiber?: { return: FiberLike } }).unstable_fiber?.return ?? null;
  while (fiber) {
    if (fiber.memoizedProps && 'onPress' in fiber.memoizedProps) return fiber.memoizedProps.onPress;
    fiber = fiber.return ?? null;
  }
  return undefined;
}

export type SweepView = {
  toJSON: () => unknown;
  root: TestInstance;
  getByTestId: (id: string) => TestInstance;
  queryByTestId: (id: string) => TestInstance | null;
};

export function expectSelected(view: SweepView, id: string): void {
  for (const tab of TABS) {
    expect(view.getByTestId(`shell-tab-${tab}`).props.accessibilityState?.selected).toBe(tab === id);
  }
  expect(view.getByTestId(`section-${id}`)).toBeTruthy();
  expect(within(view.getByTestId(`section-${id}`)).getByText(COPY[SECTIONS[id]].text)).toBeTruthy();
}

export function sweepSurface(view: SweepView, cs: Scheme, contentHost: string): void {
  // К4.1: все непустые строковые листья дерева — из каталога source.json.
  const out: string[] = [];
  leaves(view.toJSON(), out);
  const visible = out.filter((value) => value.length > 0);
  expect(visible.length).toBeGreaterThan(0);
  for (const leaf of visible) expect(CATALOG[leaf] ?? false).toBe(true);
  // К4.3: акцент-гейт по ВСЕМ host-Text/TextInput (обход дерева, не список).
  const textHosts = view.root.queryAll((node) => node.type === 'Text' || node.type === 'TextInput');
  expect(textHosts.length).toBeGreaterThan(0);
  for (const host of textHosts) expect(colorOf(host)).not.toBe(TOK.accent[cs]);
  // К3.1: ближайший композит над каждым хостом шва.
  expect(nearestCompositeIs(view.getByTestId('shell-safe-area'), SafeAreaView)).toBe(true);
  expect(nearestCompositeIs(view.getByTestId('shell-keyboard-container'), KeyboardAvoidingView)).toBe(true);
  // К3.2: контент состояния — потомок ОБОИХ хостов шва.
  const content = view.getByTestId(contentHost);
  expect(isDescendantOfHost(content, 'shell-safe-area')).toBe(true);
  expect(isDescendantOfHost(content, 'shell-keyboard-container')).toBe(true);
  // К3.3: каждый видимый хост шва — потомок host shell-safe-area.
  for (const id of ['shell-back', 'shell-profile-entry', ...TABS.map((tab) => `shell-tab-${tab}`)]) {
    const node = view.queryByTestId(id);
    if (node) expect(isDescendantOfHost(node, 'shell-safe-area')).toBe(true);
  }
}
