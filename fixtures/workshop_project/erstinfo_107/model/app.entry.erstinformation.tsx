// CMP-MOB-003: honest-модель route-файла Erstinformation (fixtures, в PR
// Complior-mob не копируется). Пост-заморозочное усиление гейта по вердикту
// адверсария contracts-107-impl-v3: C стартует в W0 и не имеет достижимого
// перехода в W1A (единственный setter W1A висит на Continue, видимой только
// при уже W1A и доказанном gate), поэтому корректный CURRENT_CONFIRMED runtime
// не достигает экрана. Источник admission — ПОРТ composition root: Session
// OpenAPI 5.8.2 поля допуска/волны не несит (api/generated/api-5_8.ts:
// principal_ref/display_name/auth_time/expires_at/locale/
// disclosure_requirements/home_widget_snapshot; слово консультанта по форку
// n107-impl-krug3). W0 — только пока сессия не прочитана; getDisclosureGate
// вызывается ПОСЛЕ чтения admission=W1A. Это исполнение слова владельца
// «W0 по умолчанию», не отмена.
import React, { useCallback, useEffect, useReducer } from 'react';
import { View } from 'react-native';
import type {
  Admission,
  ApiClient,
  DisclosureGateSnapshot,
} from '@/api/api-client';
import { Erstinformation, type DisclosurePayload } from '@/features/onboarding/erstinformation';
import { runtime as shippedRuntime } from '@pilot/runtime';

// Single seam between route and the public runtime; admission подаётся этим
// же composition-швом (порт), пока CMP-BCK-008/024 не несёт поле допуска.
const api: ApiClient = shippedRuntime.api;

const DISCLOSURE_REF = 'disc-erst-001';
const DOCUMENT_REF = 'doc-erstinformation';
const DISCLOSURE_VERSION = 2;

type GateState =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'ready'; snap: DisclosureGateSnapshot }
  | { kind: 'failed' };

type GateAction =
  | { type: 'fetch-start' }
  | { type: 'fetch-ok'; snap: DisclosureGateSnapshot }
  | { type: 'fetch-fail' };

function gateReducer(state: GateState, action: GateAction): GateState {
  switch (action.type) {
    case 'fetch-start':
      return { kind: 'loading' };
    case 'fetch-ok':
      return { kind: 'ready', snap: action.snap };
    case 'fetch-fail':
      return { kind: 'failed' };
    default:
      return state;
  }
}

const initialGateState: GateState = { kind: 'idle' };

// W0 по умолчанию (слово владельца): до прочтения сессии и подъёма из порта.
const initialAdmission: Admission = 'W0';

async function fetchGate(apiClient: ApiClient): Promise<DisclosureGateSnapshot | null> {
  try {
    return await apiClient.getDisclosureGate();
  } catch {
    return null;
  }
}

export default function ErstinformationEntry() {
  const [gateState, dispatch] = useReducer(gateReducer, initialGateState);
  const [admission, setAdmission] = useReducer(
    (_state: Admission, action: Admission): Admission => action,
    initialAdmission,
  );

  // Сессия читается на mount; admission поднимается из порта composition root
  // только ПОСЛЕ прочтения сессии (граница W0). Отказ сессии оставляет W0.
  useEffect(() => {
    let cancelled = false;
    void (async () => {
      try {
        await api.getSession();
      } catch {
        // сессия не прочитана — admission остаётся W0, gate не потребляется.
        setAdmission('W0');
        return;
      }
      if (cancelled) {
        return;
      }
      setAdmission(shippedRuntime.admission());
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  // getDisclosureGate потребляется ТОЛЬКО при W1A; ровно один вызов на подъём
  // admission (зависимость эффекта — admission, не gate-состояние).
  useEffect(() => {
    if (admission !== 'W1A') {
      return undefined;
    }
    let cancelled = false;
    const run = async () => {
      dispatch({ type: 'fetch-start' });
      const snap = await fetchGate(api);
      if (cancelled) return;
      if (snap) {
        dispatch({ type: 'fetch-ok', snap });
      } else {
        dispatch({ type: 'fetch-fail' });
      }
    };
    void run();
    return () => {
      cancelled = true;
    };
  }, [admission]);

  // Recheck — та же граница W0→W1A: пока admission W0, getDisclosureGate
  // не потребляется и reducer остаётся в idle.
  const recheck = useCallback(async () => {
    if (admission !== 'W1A') {
      return;
    }
    dispatch({ type: 'fetch-start' });
    const snap = await fetchGate(api);
    if (snap) {
      dispatch({ type: 'fetch-ok', snap });
    } else {
      dispatch({ type: 'fetch-fail' });
    }
  }, [admission]);

  // Тонкая делегация в runtime: экран сам гасит rejection терминальным
  // .catch ПОСЛЕ recheck (инвариант 5).
  const handleAcknowledge = useCallback(
    (ref: string, version: number) => api.acknowledgeDisclosure(ref, version),
    [],
  );

  const handleOpenDocument = useCallback((documentRef: string, _version: number) => {
    // PDF-viewer вне предмета 107; колбэк подан, вызов наблюдаем пробами.
    void documentRef;
  }, []);

  // Continue — бизнес-шаг onboarding-цепочки, вне предмета 107. Подъём
  // admission через Continue нечестен: admission приходит из порта после
  // чтения сессии (обход адверсария «недостижимый W1A» закрыт портом).
  const handleContinue = useCallback(() => {
    void undefined;
  }, []);

  // Disclosure payload читается из runtime один раз на mount; пока читается,
  // экран получает плейсхолдер той же формы (без ветвления по loading).
  const [disclosure, setDisclosure] = React.useState<DisclosurePayload | null>(null);

  useEffect(() => {
    let cancelled = false;
    const load = async () => {
      try {
        const payload = await api.getDisclosure(DISCLOSURE_REF);
        if (cancelled) return;
        setDisclosure({
          disclosure_ref: DISCLOSURE_REF,
          document_ref: payload.document_ref ?? DOCUMENT_REF,
          version: payload.version ?? DISCLOSURE_VERSION,
          responsible_entity: 'Makler Meier GmbH',
          source_ref: 'source://broker-portal/erstinformation',
        });
      } catch {
        if (!cancelled) {
          setDisclosure(null);
        }
      }
    };
    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  const gate: DisclosureGateSnapshot | null =
    gateState.kind === 'ready' ? gateState.snap : null;

  return (
    <View>
      <Erstinformation
        gate={gate}
        disclosure={
          disclosure ?? {
            disclosure_ref: DISCLOSURE_REF,
            document_ref: DOCUMENT_REF,
            version: DISCLOSURE_VERSION,
            responsible_entity: 'Makler Meier GmbH',
            source_ref: 'source://broker-portal/erstinformation',
          }
        }
        admission={admission}
        onAcknowledge={handleAcknowledge}
        onRecheck={recheck}
        onOpenDocument={handleOpenDocument}
        onContinue={handleContinue}
      />
    </View>
  );
}
