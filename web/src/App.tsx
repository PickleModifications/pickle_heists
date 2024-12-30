import '@mantine/core/styles.css';

import { MantineProvider } from '@mantine/core';
import { ConfigProvider } from './providers/config/Config';

function LobbyApp() {
  return (
    <div>
      <h1>Lobby</h1>
    </div>
  );
}

export default function App() {
  return (
    <MantineProvider>
      <ConfigProvider>
        <LobbyApp/>
      </ConfigProvider>
    </MantineProvider>
  );
}