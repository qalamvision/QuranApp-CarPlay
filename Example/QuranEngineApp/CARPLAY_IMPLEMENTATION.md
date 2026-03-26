# CarPlay Integration Guide for Quran App

## Overview
This guide explains the CarPlay integration that has been added to the Quran app, enabling users to browse and play Quran chapters directly from their car's display.

## Files Created/Modified

### 1. **Info.plist** (Modified)
Added CarPlay scene configuration:
```xml
<key>CPTemplateApplicationSceneSessionRoleApplication</key>
<array>
    <dict>
        <key>UISceneConfigurationName</key>
        <string>CarPlay Configuration</string>
        <key>UISceneDelegateClassName</key>
        <string>$(PRODUCT_MODULE_NAME).CarPlaySceneDelegate</string>
    </dict>
</array>
```

### 2. **AppDelegate.swift** (Modified)
Updated to initialize CarPlay support:
- Calls `setupCarPlaySupport()` during app launch
- Initializes the `MediaPlayerManager` singleton

### 3. **MediaPlayerManager.swift** (New)
Core media playback controller:
- Manages audio playback using `AVAudioPlayer`
- Handles remote command controls (play, pause, next, previous, skip)
- Updates Now Playing information for lock screen and CarPlay
- Maintains current chapter state and chapter list
- Provides public methods: `playChapter()`, `play()`, `pause()`, `playNext()`, `playPrevious()`, `skipForward()`, `skipBackward()`

**Key Features:**
- Remote transport controls integration
- Now Playing info center updates
- Audio player delegation for auto-play next chapter

### 4. **CarPlaySceneDelegate.swift** (New)
Handles CarPlay scene lifecycle:
- Connects to CarPlay display when available
- Builds and displays chapter list template
- Manages template transitions
- Handles chapter selection
- Cleans up on CarPlay disconnect

**Key Methods:**
- `templateApplicationScene(_:didConnect:)` - Sets up CarPlay UI
- `templateApplicationScene(_:didDisconnect:)` - Cleans up resources

### 5. **CarPlayTemplateBuilder.swift** (New)
Builds CarPlay UI templates:
- Creates chapter list template with all 114 Quran chapters
- Creates now playing template with chapter information
- Manages Media Player info updates
- Provides reusable template construction

## How It Works

### User Flow
1. **Car Connection**: When user connects iPhone to CarPlay-compatible car system
2. **Chapter List**: CarPlay displays all 114 Quran chapters in a scrollable list
3. **Selection**: User taps a chapter to start playback
4. **Playback**: Chapter audio plays with controls:
   - Play/Pause buttons
   - Next/Previous chapter navigation
   - Skip forward/backward (15 seconds)
5. **Lock Screen**: Now Playing info appears on device lock screen
6. **Remote Controls**: All controls work from steering wheel or car display

## Data Structure

### ChapterInfo
```swift
struct ChapterInfo {
    let id: Int          // Unique chapter ID
    let number: Int      // Chapter number (1-114)
    let name: String     // Chapter name in English
    let audioURL: URL?   // Audio file URL
}
```

## Integration Steps for Your App

### Step 1: Connect Audio Sources
Update `getAudioURLForChapter()` in `CarPlaySceneDelegate` to return actual audio URLs:
```swift
private func getAudioURLForChapter(_ number: Int) -> URL? {
    // Return your audio file URL or construct from remote server
    // Example:
    // return Bundle.main.url(forResource: "chapter_\(number)", withExtension: "m4b")
    // or
    // return URL(string: "https://your-server.com/audio/chapter_\(number).m4b")
}
```

### Step 2: Load Chapters Dynamically
Replace the hardcoded `createChapters()` with your actual data source:
```swift
private func createChapters() -> [ChapterInfo] {
    // Load from your Quran data provider
    // e.g., container.readingResources or your API
}
```

### Step 3: Configure Reciters
The app has `reciters.plist` - integrate it to support multiple reciters:
- Allow user to select reciter in iPhone app
- Pass selected reciter to `getAudioURLForChapter()`

### Step 4: Audio Session Setup
Add audio session configuration in `MediaPlayerManager`:
```swift
import AVFoundation

func setupAudioSession() {
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
    try? session.setActive(true)
}
```

## Remote Control Commands

The following remote commands are supported:
- **Play** - Start playback
- **Pause** - Pause playback
- **Next Track** - Play next chapter
- **Previous Track** - Play previous chapter
- **Skip Forward** - Skip 15 seconds ahead
- **Skip Backward** - Skip 15 seconds back

## Testing on Simulator

1. In Xcode, go to **Devices & Simulators**
2. Select an iOS 15+ simulator
3. Open Simulator's **Hardware > External Displays > CarPlay**
4. Run the app - CarPlay scene will automatically appear

## Testing on Real Device with Car

1. Update bundle identifier to match your provisioning profile
2. Add CarPlay capability in Xcode project settings
3. Connect iPhone to CarPlay-compatible car system
4. App will automatically appear in CarPlay menu

## Notes

- Requires iOS 15.0 or later (as per your Podfile)
- Chapter list includes all 114 chapters with Arabic names
- Now Playing info syncs with lock screen and car display
- Audio player supports background playback (with proper background modes)

## Future Enhancements

1. **Bookmarks** - Remember last played chapter per user
2. **Search** - Quick chapter search on CarPlay
3. **Reciter Selection** - Switch between different reciters
4. **Settings** - Adjust playback speed, repeat modes
5. **Favorites** - Mark frequently played chapters
6. **Translation Display** - Show translations on CarPlay display
7. **Offline Sync** - Cache chapters for offline playback

## Files to Monitor

When updating your app's chapter or audio data:
- `MediaPlayerManager.swift` - Update if chapter structure changes
- `CarPlaySceneDelegate.swift` - Update if chapter list source changes
- `CarPlayTemplateBuilder.swift` - Update if UI template needs customization

## Security & Privacy

- No tracking or analytics on CarPlay usage
- Local playback only (no streaming to remote servers by default)
- User controls all chapter selection
