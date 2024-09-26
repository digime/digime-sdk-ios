import { registerPlugin } from '@capacitor/core';

import type { DigiMePlugin, DigiMePluginResult } from './definitions';

const DigiPlugin = registerPlugin<DigiMePlugin>('DigiPlugin', {
  web: () => import('./web').then(m => new m.DigiPluginWeb()),
});

export * from './definitions';
export { DigiPlugin };
export type { DigiMePluginResult };

