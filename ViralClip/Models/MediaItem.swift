import Foundation
import Photos

struct MediaItem: Identifiable, Hashable {
    let id: String
    let asset: PHAsset
    let type: MediaType
    let creationDate: Date?
    var thumbnailData: Data?
    
    enum MediaType: String, Codable {
        case image
        case video
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct GeneratedVideo: Identifiable, Codable {
    let id: String
    let createdAt: Date
    var title: String
    var sourceMediaIds: [String]
    var analysisTags: [String]
    var videoURL: URL?
    var thumbnailURL: URL?
    var duration: TimeInterval
    var style: VideoStyle
    
    enum VideoStyle: String, Codable, CaseIterable {
        case trending = "Trending"
        case cinematic = "Cinematic"
        case vlog = "Vlog"
        case meme = "Meme"
        case inspirational = "Inspirational"
    }
}

struct UserPreferences: Codable {
    var preferredStyles: [GeneratedVideo.VideoStyle]
    var targetPlatform: TargetPlatform
    var exportQuality: ExportQuality
    var dailyReminderEnabled: Bool
    var reminderTime: Date
    
    enum TargetPlatform: String, Codable, CaseIterable {
        case tiktok = "TikTok"
        case reels = "Instagram Reels"
        case shorts = "YouTube Shorts"
        case any = "Any"
    }
    
    enum ExportQuality: String, Codable, CaseIterable {
        case high = "High (1080p)"
        case medium = "Medium (720p)"
        case low = "Low (480p)"
    }
    
    static var `default`: UserPreferences {
        UserPreferences(
            preferredStyles: [.trending, .vlog],
            targetPlatform: .any,
            exportQuality: .high,
            dailyReminderEnabled: false,
            reminderTime: Date()
        )
    }
}

struct AIFeatureTag: Identifiable {
    let id = UUID()
    let label: String
    let category: Category
    
    enum Category: String {
        case location = "Location"
        case people = "People"
        case activity = "Activity"
        case mood = "Mood"
        case trending = "Trending"
    }
}
