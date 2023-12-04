# Genrefy - Quick Start Digi.me SDK Example

Welcome to "Genrefy," a quick start demo application for the Digi.me SDK. This app serves as a practical example to demonstrate the use of the digi.me "Consent Request" service, which is built around the `api.digi.me` Permissioned Access API component library.

## Features

"Genrefy" offers a simple yet powerful demonstration of how to request user consent and retrieve data within an application:

- **Consent Request**: Seamlessly integrate the digi.me Consent Access flow into your application.
- **Spotify Data Sharing**: Ask users to share their Spotify listening history.
- **Music Genre Graph**: Build and display a visual graph of music genres the user has listened to based on their Spotify data.

## Getting Started

### Prerequisites

- Xcode version 11 or later.
- An iOS device or simulator running iOS 13.0 or later.
- CocoaPods for dependency management.

### Setup Instructions

1. **Clone the Repository**: Clone this repository to your local machine using the following command:

    ```bash
    git clone https://github.com/digime/digime-sdk-ios.git
    ```

2. **Navigate to Project Directory**: Change into the project directory.

    ```bash
    cd Genrefy
    ```

3. **Install Dependencies**: Install the project dependencies via CocoaPods.

    ```bash
    pod install
    ```

    This will create an `.xcworkspace` file. Make sure to open this file in Xcode moving forward, rather than the `.xcodeproj` file.

4. **Open the Workspace**: Open the `Genrefy.xcworkspace` file in Xcode.

5. **Run the App**: Choose your target device or simulator and run the application.

### Exploring Genrefy

- Experience the digi.me Consent Access flow firsthand.
- Authorize "Genrefy" to access your Spotify data.
- View the music genre graph created from your shared data.

## CocoaPods Integration

This example uses CocoaPods to manage and configure dependencies. Here's a snapshot of the `Podfile` used to integrate the Digi.me SDK:

```ruby
platform :ios, '13.0'

target 'Genrefy' do
  use_frameworks!

  # Pods for Genrefy
  pod 'DigiMeSDK'
end
```

Ensure you run `pod install` after cloning the project to fetch the latest Digi.me SDK version.

## Support and Documentation

For more detailed information about the DigiMeSDK and its capabilities, please refer to the [official documentation](https://developers.digi.me).

If you encounter any issues or have questions, please reach out to us at [support@digi.me](mailto:support@digi.me).
