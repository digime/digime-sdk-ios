
# digi-plugin

DigiPlugin Capacitor Plugin for Apple Health Data Retrieval

## Description

This Capacitor plugin facilitates the retrieval of Apple Health data in iOS applications. It provides a bridge between your Ionic/Capacitor app and native iOS code to securely fetch and process health data.

## Install

```bash
npm install digi-plugin
npx cap sync
```

## Setup

Ensure you have the necessary permissions set up in your iOS app to access HealthKit data. In your Info.plist, add the required HealthKit permissions.

## API

<docgen-index>

fetchHealthData(...)

</docgen-index>

<docgen-api>

### fetchHealthData(...)

```typescript
fetchHealthData(options: {
  appId: string;
  identifier: string;
  privateKey: string;
  baseURL: string;
  storageBaseURL: string;
  cloudId: string;
}) => Promise<{ value: string; }>
```

Initiates the process to fetch Apple Health data.

**Param** | **Type** | **Description**
--- | --- | ---
options | `{ appId: string; identifier: string; privateKey: string; baseURL: string; storageBaseURL: string; cloudId: string; }` | Configuration options for data retrieval

**Returns:** `Promise<{ value: string; }>`

</docgen-api>

## Usage

```typescript
import { DigiPlugin } from 'digi-plugin';

async function fetchHealthData() {
  try {
    const result = await DigiPlugin.fetchHealthData({
      appId: "your_app_id",
      identifier: "your_identifier",
      privateKey: "your_private_key",
      baseURL: "your_base_url",
      storageBaseURL: "your_storage_base_url",
      cloudId: "your_cloud_id"
    });
    console.log('Health data fetch initiated:', result.value);
  } catch (error) {
    console.error('Error initiating health data fetch:', error);
  }
}
```

## Running the Example

1. Clone this repository.
2. Navigate to the example directory: `cd example`
3. Install dependencies: `npm install`
4. Run the web version: `ionic serve`

To run on iOS:

1. Add iOS platform: `ionic cap add ios`
2. Build the project: `ionic cap build ios`
3. Open Xcode: `ionic cap open ios`
4. Run the project on a simulator or device from Xcode.

## Notes

- Ensure you have the latest version of Capacitor and Ionic CLI installed.
- This plugin is designed for iOS and requires HealthKit, which is not available on Android or web platforms.
- Make sure to handle the plugin's responses appropriately in your application logic.

## Support

For issues, feature requests, or questions, please file an issue in the GitHub repository.
