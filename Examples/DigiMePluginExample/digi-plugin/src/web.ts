import { WebPlugin } from '@capacitor/core';

import type { DigiMePlugin } from './definitions';

export class DigiPluginWeb extends WebPlugin implements DigiMePlugin {
    async fetchHealthData(options: {
    appId: string;
    identifier: string;
    privateKey: string;
    baseURL: string;
    storageBaseURL: string;
    cloudId: string;
    }): Promise<{ value: string }> {
        console.log('Fetch Health Data', options);
        return { value: 'Health data fetch initiated (web implementation)' };
    }

    async dismissView(): Promise<void> {
        console.log('Dismiss View called (web implementation)');
    }
}
