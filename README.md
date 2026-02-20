# ViralClip

AI-powered short video generator for iOS.

## Overview

ViralClip turns your camera roll photos and videos into viral short-form content using AI. The app:
- Accesses your photo library
- Uses Vision framework for on-device AI analysis (faces, objects, scenes)
- Generates vertical videos ready for TikTok, Reels, and Shorts
- Learns your preferences over time

## Features

- **Photo Library Integration** - Browse and select photos/videos from camera roll
- **AI Content Analysis** - Detects people, locations, activities, and moods
- **Video Generation** - Creates edited vertical videos with transitions
- **Daily Feed** - View and manage generated videos
- **Customization** - Choose video styles (Trending, Cinematic, Vlog, Meme, Inspirational)
- **Settings** - Target platform, export quality, notifications

## Requirements

- iOS 16.0+
- Xcode 15+
- Swift 5.9+

## How to Run

1. Open `ViralClip.xcodeproj` in Xcode
2. Select a simulator or your device
3. Press Cmd+R to build and run

## Project Structure

```
ViralClip/
├── App/                    # App entry point
├── Models/                 # Data models
├── Services/               # Business logic (Photo, AI, Video)
├── ViewModels/             # MVVM view models
├── Views/                  # SwiftUI views
│   ├── Home/              # Video feed
│   ├── Create/            # Media selection & generation
│   ├── Editor/            # Video editing
│   ├── Settings/          # App preferences
│   └── Components/        # Reusable UI components
├── Utilities/             # Extensions and helpers
└── Resources/             # Assets
```

## Tech Stack

- **SwiftUI** - UI framework
- **Vision** - On-device AI (face detection, object classification)
- **AVFoundation** - Video playback and composition
- **Photos/PhotosUI** - Photo library access

## Notes

- Video generation uses AVFoundation for basic composition
- For production, integrate with cloud AI services (OpenAI, Runway, etc.)
- App requires Photos permission to access camera roll

## License

MIT
