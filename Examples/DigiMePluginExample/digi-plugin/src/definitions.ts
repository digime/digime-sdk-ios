export interface DigiMePlugin {
    fetchHealthData(options: {
    appId: string;
    identifier: string;
    privateKey: string;
    baseURL: string;
    storageBaseURL: string;
    cloudId: string;
    }): Promise<{ value: string }>;

    dismissView(): Promise<void>;
}
