# ViralClip - AI-Powered Short Video Generator

## Project Overview
- **Bundle Identifier**: com.viralclip.app
- **Core Functionality**: Upload photos/videos from camera roll, AI analyzes content and preferences, generates daily viral short-form videos
- **Target Users**: Content creators, influencers, anyone wanting daily social media content
- **iOS Version Support**: iOS 16.0+
- **UI Framework**: SwiftUI

---

## UI/UX Specification

### Screen Structure

1. **OnboardingScreen** - Welcome flow explaining the app
2. **HomeScreen** - Main dashboard with daily video feed
3. **MediaPickerScreen** - Camera roll browser with multi-select
4. **AnalysisScreen** - AI analysis progress and results
5. **VideoEditorScreen** - Fine-tune generated video
6. **SettingsScreen** - Preferences, account, export options

### Navigation Structure
- UITabBarController with 3 tabs:
  - Home (daily videos)
  - Create (media picker)
  - Settings

### Visual Design

**Color Palette**:
- Primary: #6C5CE7 (Purple - brand color)
- Secondary: #00CEC9 (Teal - accent)
- Background: #0D0D0D (Near black)
- Surface: #1A1A1A (Dark gray cards)
- Text Primary: #FFFFFF
- Text Secondary: #A0A0A0
- Success: #00B894
- Error: #FF6B6B

**Typography**:
- Headings: SF Pro Display Bold
- Body: SF Pro Text Regular
- Captions: SF Pro Text Light
- Sizes: 34pt (large title), 24pt (title), 17pt (body), 13pt (caption)

**Spacing**:
- Base unit: 8pt grid
- Screen margins: 16pt
- Card padding: 16pt
- Element spacing: 8pt / 16pt / 24pt

### Views & Components

**MediaThumbnailView**:
- Square aspect ratio with rounded corners (12pt)
- Selection overlay with checkmark
- Duration badge for videos
- Fade-in animation on load

**VideoCardView**:
- 9:16 aspect ratio (vertical video)
- Play button overlay
- Title, date, engagement stats
- Swipe actions (share, delete)

**AIFeatureTag**:
- Pill-shaped badges
- Categories: Location, People, Activity, Mood, Trending

**ProgressRing**:
- Circular progress for AI analysis
- Animated pulse effect

---

## Functionality Specification

### Core Features (Priority Order)

1. **Photo Library Integration** (P0)
   - Request Photos permission
   - PHPickerViewController for multi-select
   - Display media in grid
   - Support images (HEIC, JPEG, PNG) and videos (MOV, MP4)

2. **AI Content Analysis** (P0)
   - Analyze selected media for:
     - Faces/people detection
     - Location/scene recognition
     - Activity detection (sports, travel, food, etc.)
     - Mood/aesthetic classification
   - Build user preference profile over time

3. **Video Generation** (P0)
   - Combine selected media into vertical video
   - Add transitions, captions, music
   - Apply trending formats/styles
   - Export to MP4 (H.264)

4. **Daily Video Feed** (P1)
   - Show generated videos in scrollable feed
   - Swipe to refresh for new content
   - Video player with controls

5. **User Preferences** (P1)
   - Content style preferences
   - Platform targeting (TikTok, Reels, Shorts)
   - Export quality settings

### User Flows

**Flow 1: First Launch**
1. Onboarding screens (3 pages)
2. Photos permission request
3. Empty state prompting to add media

**Flow 2: Create Video**
1. Tap Create tab
2. Select photos/videos from picker
3. Tap "Generate"
4. Show AI analysis progress
5. Display generated video
6. Optionally edit/re-export

**Flow 3: Daily Use**
1. Open app → Home tab
2. See today's generated videos
3. Tap to preview
4. Share to social apps

### Data Handling

**Local Storage**:
- UserDefaults for preferences
- FileManager for cached videos
- Core Data NOT needed (simple data model)

**Cloud/External**:
- For v1: Mock AI responses (local analysis)
- Future: OpenAI Vision API, video generation APIs

### Architecture Pattern
- **MVVM** with Combine
- Views → ViewModels → Services
- Services: PhotoLibraryService, AIAnalysisService, VideoGenerationService

### Error Handling
- Permission denied: Show settings prompt
- Media load failure: Show retry option
- Generation failure: Show error with retry

---

## Technical Specification

### Dependencies (Swift Package Manager)

1. **None required for core** - Using native frameworks

### Native Frameworks Used
- SwiftUI - UI
- PhotosUI - Photo picker
- Photos - Photo library access
- AVFoundation - Video playback/generation
- CoreImage - Image filtering
- Vision - Face/object detection (on-device AI)

### Asset Requirements

**SF Symbols Used**:
- house.fill (Home tab)
- plus.circle.fill (Create tab)
- gearshape.fill (Settings tab)
- photo.on.rectangle (Media picker)
- play.circle.fill (Video play)
- checkmark.circle.fill (Selection)
- arrow.up.circle (Share)
- trash (Delete)

**App Icon**:
- Gradient purple to teal
- Play button motif

---

## File Structure

```
ViralClip/
├── App/
│   └── ViralClipApp.swift
├── Views/
│   ├── MainTabView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── VideoCardView.swift
│   ├── Create/
│   │   ├── CreateView.swift
│   │   ├── MediaPickerView.swift
│   │   └── AnalysisView.swift
│   ├── Editor/
│   │   └── VideoEditorView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       ├── MediaThumbnailView.swift
│       ├── AIFeatureTag.swift
│       └── ProgressRing.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── CreateViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── PhotoLibraryService.swift
│   ├── AIAnalysisService.swift
│   └── VideoGenerationService.swift
├── Models/
│   ├── MediaItem.swift
│   ├── GeneratedVideo.swift
│   └── UserPreferences.swift
├── Utilities/
│   ├── Colors.swift
│   └── Extensions.swift
└── Resources/
    └── Assets.xcassets/
```
