import { fireEvent, render, screen } from '@testing-library/react-native';

import { StartScreen } from '../start-screen';

async function openStart() {
  await render(<StartScreen />);
  const button = screen.getByRole('button', { name: 'Prüfung starten' });
  expect(button).toBeEnabled();
  expect(screen.queryByText('Prüfung abgeschlossen')).toBeNull();
  return button;
}

async function complete() {
  await fireEvent.press(await openStart());
  expect(screen.getByText('Prüfung abgeschlossen')).toBeOnTheScreen();
}

describe('991 rehearsal', () => {
  it('R1 starts incomplete and completes only after a press', async () => {
    await complete();
  });

  it('R2 resets when a new screen session starts', async () => {
    await complete();
    await screen.unmount();
    await openStart();
  });
});
