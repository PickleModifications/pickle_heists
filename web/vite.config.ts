import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  base: '/nui',
  build: {
    outDir: '../nui',
    emptyOutDir: true, // also necessary
  },
})
