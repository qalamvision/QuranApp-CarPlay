<p align="center">
    <img src="https://github.com/quran/quran-ios/assets/5665498/636ff859-78e9-40aa-96ea-db013197b6fc" width="350pt">
</p>

QuranEngine, Quran.com-ios App (w/ CarPlay)
=========================

This repository is a fork of `quran/quran-ios` that adds a working Apple CarPlay integration to the included example app (`Example/QuranEngineApp`).

CarPlay does **not** currently exist in upstream `quran/quran-ios`, so the changes here are a new integration built in this fork.

## CarPlay preview

<img width="682" height="413" alt="Image" src="https://github.com/user-attachments/assets/84d8796d-0f4c-468a-b331-2ad9b64c33dc" />
<img width="800" height="480" alt="Image" src="https://github.com/user-attachments/assets/ff601e8f-22c8-48d0-9058-578df670c783" />
<img width="800" height="480" alt="Image" src="https://github.com/user-attachments/assets/afd3a276-ed70-4a22-86c8-2e0c1afdab28" />

## What’s working

Verified on a physical device:

- Surah browsing from CarPlay
- Reciter selection from CarPlay
- Playback scope selection using the app’s existing audio-end behavior:
  - Juz
  - Surahs
  - Page
- CarPlay transport controls without needing to open the phone UI first
- Now Playing metadata showing the current surah and reciter
- Shared playback state between the phone UI and CarPlay

## How it works (high level)

- CarPlay and the in-app audio banner share a single `AudioPlaybackController`.
- CarPlay transport controls call that shared controller directly.
- `MPNowPlayingInfoCenter` is updated from the shared playback state.
- CarPlay uses a `CPTabBarTemplate` with **Surahs**, **Reciters**, and **Playback** tabs.

## Apple CarPlay entitlement (required)

To run CarPlay on-device, you must have the CarPlay capability enabled for your Apple Developer team.

1. Request CarPlay access from Apple for your developer account / team (this is a manual approval process).
2. After approval, enable the **CarPlay** capability for the app identifier in Certificates, Identifiers & Profiles.
3. Regenerate/download provisioning profiles so they include the CarPlay entitlement.
4. In Xcode, ensure the app target has the **CarPlay** capability enabled and uses a provisioning profile that contains the entitlement.

If the entitlement is missing, CarPlay scenes may not appear when connecting to a vehicle/head unit or simulator.

## Code changes

Key implementation points:

- `AudioPlaybackController` is now the shared source of truth for playback state, remote transport controls, and Now Playing metadata.
- CarPlay UI is built with list templates and a tab bar root.

Relevant files changed in this fork:

- `Core/QueuePlayer/NowPlayingUpdater.swift`
- `Example/QuranEngineApp.xcodeproj/project.pbxproj`
- `Example/QuranEngineApp/Classes/CarPlaySceneDelegate.swift`
- `Example/QuranEngineApp/Classes/CarPlayTemplateBuilder.swift`
- `Features/AudioBannerFeature/AudioBannerBuilder.swift`
- `Features/AudioBannerFeature/AudioBannerViewModel.swift`
- `Features/AudioBannerFeature/AudioPlaybackController.swift`

Commits:

- `ba55096` Add shared CarPlay audio playback support
- `2e84cb5` Persist What’s New state per release

## Installation

The upstream repository can be installed via Swift Package Manager:

```swift
.package(url: "https://github.com/quran/quran-ios", branch: "main")
```

Then use one or more of the available targets as dependency, for example:

```swift
.product(name: "AppStructureFeature", package: "quran-ios"),
```

> Please note that upstream does not support CocoaPods or Carthage.

## Repository Structure and Architecture

The library consists of 6 top-level directories:

* **Core**: General purpose libraries that work with any app. The only exception is the Localization library, which we aim to make more universal.

* **Model**: Contains simple entities that facilitate building a Quran App. These entities mostly work together without including extensive logic.

* **Data**: This directory includes SQLite, CoreData, and Networking libraries that abstract away the underlying technologies used.

* **Domain**: This is where the business logic of the app resides. It depends on Model and Data to serve such business logic.

* **UI**: Houses the design system used by the App (we call it NoorUI). We are gradually shifting towards using SwiftUI in all our components, except for the navigation aspect - we will continue using UIKit for that. UI does not depend on Domain nor Data, but can depend on Core and Model.

* **Features**: Comprises the screens making up the app. They rely on all other components to create our Quran apps. Features can encompass other features to create higher-level features. For example, `AppStructureFeature` hosts all other features to create the app.

> UI and Features do not yet contain tests, and makes up around 50% of the source code. We are keen on adding tests to them in the future inshaa'Allah.

Here is a visual representation of the architecture:

<img width="438" alt="architecture" src="https://github.com/quran/quran-ios/assets/5665498/1135c102-c20b-456f-9f96-3c5b4faee0dc">

This dependency order is enforced in `Package.swift` in the upstream repository.

# Contributions

Contributions are welcome.

## Intended Use

We are re-open sourcing the app because we see a lot of benefits in allowing developers to build on top of what we have already built. This way, developers don't have to re-implement the foundation and can innovate more on the idea itself.

We welcome all types of use. However, we kindly ask that you don't use the QuranEngineApp example and republish it without making any modifications. You may also need to bring your own data.

## License

* QuranEngine is available under Apache-2.0 license. See the LICENSE file for more info.
* Madani images from quran images project on github.
* Translation, tafsir and Arabic data come from tanzil and King Saud University.
