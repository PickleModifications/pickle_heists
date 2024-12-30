import '@mantine/core/styles.css';

import { MantineProvider } from '@mantine/core';
import { ConfigProvider } from './providers/config/Config';
import { useState } from 'react';
import LobbyApp from './components/lobby/Lobby';

export type Player = {
  source: number;
  identifier: string;
  name: string;
}

export type Position = {
  x: number;
  y: number;
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