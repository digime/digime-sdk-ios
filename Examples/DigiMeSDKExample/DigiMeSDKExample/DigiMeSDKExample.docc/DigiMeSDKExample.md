# DigiMeSDK Example iOS App

Welcome to the example application for the DigiMeSDK. This example app is designed to showcase the capabilities of the digi.me SDK and to help third-party developers understand how to integrate and utilize the SDK in their iOS applications.

## Features

The example app demonstrates a variety of functionalities provided by the DigiMeSDK, including:

- **Data Import**: Easily import Social, Health & Fitness, Medical, Financial, and Entertainment data.
- **Data Scoping**: Apply limits on your data query by utilizing `ReadOptions` object. This allows for configuring sessions for reading data from service-based data sources more efficiently.
- **Data Export**: Push or export your data to your digi.me library. Supports uploading of various file formats including Image, PDF, and JSON.
- **Fitness Activity Data**: Import fitness activity data such as Steps, Active Energy, Exercise Minutes, and Walking & Running Distance. The app includes features to view this data in chart formats and as aggregated totals.

## Getting Started

### Prerequisites

- Xcode version 11 or later.
- An iOS device or simulator running iOS 13.0 or later.
- Swift Package Manager (SPM) for dependency management.

### Setup Instructions

1. **Clone the Repository**: Start by cloning this repository to your local machine.

    ```bash
    git clone https://github.com/digime/digime-sdk-ios.git
    ```

2. **Open the Project**: Open the `DigiMeSDKExample.xcodeproj` file in Xcode.

3. **Integrate DigiMeSDK**: The project uses Swift Package Manager for integrating the DigiMeSDK. Ensure that the SDK is correctly linked by checking the project's Swift Package dependencies.

4. **Build and Run**: Select your target device or simulator and build and run the application.

### Exploring the App

- Navigate through the app's UI to access different functionalities.
- Use the `ReadOptions` interface to apply filters and customize your data import requests.
- Experiment with data export features to understand the data push capabilities.
- Explore the fitness data section to see how the app visualizes activity data.

## Support and Documentation

For more detailed information about the DigiMe platform and its capabilities, please refer to the [official documentation](https://developers.digi.me).

If you encounter any issues or have questions, please reach out to us at [support@digi.me](mailto:support@digi.me).
