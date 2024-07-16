import { registerPlugin } from '@capacitor/core';

import type { DigiMePlugin } from './definitions';

const DigiPlugin = registerPlugin<DigiMePlugin>('DigiPlugin', {
web: () => import('./web').then(m => new m.DigiPluginWeb()),
});

export * from './definitions';
export { DigiPlugin };
