// Знак Faden (D 2.4, контракт 145) — RN-компонент на react-native-svg.
// ЭТАЛОН-ФОРМА ПРОДУКТА батареи 145 (канон по арбитражу Astra, B.6–B.8):
// path-данные знака — ТОЛЬКО из порта faden-motion (path(pose)/dotXY),
// никогда литералами; привязка ОС-настройки «Уменьшить движение» —
// AccessibilityInfo (прецедент tab-shell.tsx). КАДРОВЫЙ КОНТРАКТ (судят
// обязательный знаковый тест и живая матрица --live-component):
//   · один createInstance({state,size,emotion}) на монтирование, часы с нуля;
//   · set({state,size,emotion,reducedMotion}) — на монтирование и на каждое
//     изменение этих пропсов/ОС-флага;
//   · на каждый requestAnimationFrame-кадр: advanceTime(DT) + set({}) —
//     та же каденция, что у реплея батареи (драйвер-запись);
//   · служебный проп forceReducedMotion?: boolean переопределяет ОС-настройку
//     (живая матрица L и доводка; обязательный тест его не передаёт).
// testID: faden-sign (контейнер), faden-sign-thread (путь), faden-sign-dot
// (точка). Рантайм-исполнение — jest-expo (job quality) + --live-component;
// чистая батарея компонент структурно не судит (a02 — наличие файлов).
import React, { useEffect, useRef, useState } from 'react';
import { AccessibilityInfo, View } from 'react-native';
import Svg, { Circle, Path } from 'react-native-svg';
import { createInstance, path, dotXY, colors, TIERS, type FadenInstance } from './faden-motion';

export type FadenSignProps = {
  state?: string;
  size?: string;
  emotion?: string;
  theme?: string;
  testID?: string;
  forceReducedMotion?: boolean;
};

const DT = 1000 / 60;

export function FadenSign(props: FadenSignProps) {
  const { state = 'idle', size = 'large', emotion = 'neutral', theme = 'dark', testID = 'faden-sign', forceReducedMotion } = props;
  // ОС-флаг — объектом: каждая публикация значения (промис/событие) даёт новую
  // ссылку, и mount-set происходит ровно дважды (стартовое false, затем ОС) —
  // детерминированное расписание для оракула обязательного теста.
  const [os, setOs] = useState({ v: false });
  const reducedMotion = forceReducedMotion === undefined ? os.v : forceReducedMotion;
  const instRef = useRef<FadenInstance | null>(null);
  if (instRef.current === null) {
    instRef.current = createInstance({ state, size, emotion, autoplay: false });
  }
  const [, setKadr] = useState(0);
  useEffect(() => {
    // УД-привязка: стартовое значение + подписка на смену настройки ОС
    let zakryto = false;
    const podpiska = AccessibilityInfo.addEventListener('reduceMotionChanged', (v: boolean) => { if (!zakryto) setOs({ v }); });
    AccessibilityInfo.isReduceMotionEnabled().then((v: boolean) => { if (!zakryto) setOs({ v }); });
    return () => {
      zakryto = true;
      if (podpiska && typeof podpiska.remove === 'function') podpiska.remove();
    };
  }, []);
  useEffect(() => {
    instRef.current?.set({ state, size, emotion, reducedMotion });
    setKadr((k) => k + 1);
  }, [state, size, emotion, os, reducedMotion]);
  useEffect(() => {
    // кадровый контракт: один кадр = advanceTime(DT) + set({}) (каденция реплея)
    let id = 0;
    const kadr = () => {
      const inst = instRef.current;
      if (inst) { inst.advanceTime(DT); inst.set({}); }
      setKadr((k) => k + 1);
      id = requestAnimationFrame(kadr);
    };
    id = requestAnimationFrame(kadr);
    return () => cancelAnimationFrame(id);
  }, []);
  const p = instRef.current!.pose();
  const d = path(p);
  const dot = dotXY(p);
  // каталоги порта с динамическим ключом (size/tone) — именованные константы,
  // не инлайн-касты (правило проекта); pose-поля — числа носителей столбцов
  const TIRY = TIERS as Record<string, { px: number }>;
  const CVETA = colors(theme, 'ground') as Record<string, string>;
  const STROKE = p.stroke as number;
  const TON = p.tone as string;
  const DOT_SCALE = p.dotScale as number;
  const DOT_OPACITY = p.dotOpacity as number;
  const px = TIRY[size]?.px ?? 160;
  const dotCvet = CVETA[TON] || CVETA.accent;
  return (
    <View testID={testID} accessibilityLabel="Complior">
      <Svg viewBox="0 0 96 96" width={px} height={px}>
        <Path d={d} fill="none" stroke={CVETA.thread} strokeWidth={STROKE} strokeLinecap="round" testID="faden-sign-thread" />
        <Circle cx={dot[0]} cy={dot[1]} r={11 * DOT_SCALE} fill={dotCvet} opacity={DOT_OPACITY} testID="faden-sign-dot" />
      </Svg>
    </View>
  );
}
