export interface DigiMePluginResult {
  success: boolean;
  values?: string[];
  error?: string;
}

export interface DigiMePlugin {
  fetchHealthData(options: {
      cloudId: string;
  }): Promise<DigiMePluginResult>;

  dismissView(): Promise<void>;
}
