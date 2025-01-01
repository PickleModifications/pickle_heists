import '@mantine/core/styles.css';

import { MantineProvider } from '@mantine/core';
import { ConfigProvider } from './providers/config/Config';
import { useState } from 'react';
import LobbyApp from './components/lobby/Lobby';
import HeistsHUDApp from './components/heists/Heists';

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
        <HeistsHUDApp/>
      </ConfigProvider>
    </MantineProvider>
  );
}