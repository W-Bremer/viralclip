import Foundation
import AVFoundation
import UIKit
import Photos

@MainActor
class VideoGenerationService: ObservableObject {
    @Published var isGenerating = false
    @Published var progress: Double = 0
    @Published var currentVideo: GeneratedVideo?
    @Published var generatedVideos: [GeneratedVideo] = []
    
    private let fileManager = FileManager.default
    private var videosDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let videosDir = paths[0].appendingPathComponent("GeneratedVideos", isDirectory: true)
        
        if !fileManager.fileExists(atPath: videosDir.path) {
            try? fileManager.createDirectory(at: videosDir, withIntermediateDirectories: true)
        }
        
        return videosDir
    }
    
    init() {
        loadGeneratedVideos()
    }
    
    func generateVideo(from items: [MediaItem], tags: [AIFeatureTag], photoService: PhotoLibraryService, style: GeneratedVideo.VideoStyle = .trending) async -> GeneratedVideo? {
        await MainActor.run {
            self.isGenerating = true
            self.progress = 0
        }
        
        let videoId = UUID().uuidString
        let videoURL = videosDirectory.appendingPathComponent("\(videoId).mp4")
        
        do {
            let composition = AVMutableComposition()
            
            guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                  let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                throw VideoError.failedToCreateComposition
            }
            
            var currentTime = CMTime.zero
            let totalItems = Double(items.count)
            
            for (index, item) in items.enumerated() {
                let progressValue = Double(index) / totalItems * 0.8
                await MainActor.run {
                    self.progress = progressValue
                }
                
                if item.type == .video {
                    if let asset = await photoService.loadAVAsset(for: item) {
                        let duration = try await asset.load(.duration)
                        if let assetVideoTrack = try await asset.loadTracks(withMediaType: .video).first {
                            try videoTrack.insertTimeRange(
                                CMTimeRange(start: .zero, duration: duration),
                                of: assetVideoTrack,
                                at: currentTime
                            )
                            
                            if let audioAssetTrack = try await asset.loadTracks(withMediaType: .audio).first {
                                try? audioTrack.insertTimeRange(
                                    CMTimeRange(start: .zero, duration: duration),
                                    of: audioAssetTrack,
                                    at: currentTime
                                )
                            }
                            
                            currentTime = CMTimeAdd(currentTime, duration)
                        }
                    }
                } else {
                    if let image = await photoService.loadFullImage(for: item) {
                        let imageDuration = CMTime(seconds: 3, preferredTimescale: 600)
                        let imageSize = CGSize(width: 1080, height: 1920)
                        
                        if let imageGenerator = generateImageVideo(from: image, size: imageSize, duration: imageDuration) {
                            if let imageTrack = try await imageGenerator.loadTracks(withMediaType: .video).first {
                                try videoTrack.insertTimeRange(
                                    CMTimeRange(start: .zero, duration: imageDuration),
                                    of: imageTrack,
                                    at: currentTime
                                )
                                currentTime = CMTimeAdd(currentTime, imageDuration)
                            }
                        }
                    }
                }
            }
            
            await MainActor.run {
                self.progress = 0.9
            }
            
            let video = GeneratedVideo(
                id: videoId,
                createdAt: Date(),
                title: generateTitle(for: style, tags: tags),
                sourceMediaIds: items.map { $0.id },
                analysisTags: tags.map { $0.label },
                videoURL: videoURL,
                thumbnailURL: nil,
                duration: currentTime.seconds,
                style: style
            )
            
            try await exportVideo(composition: composition, to: videoURL)
            
            await MainActor.run {
                self.generatedVideos.insert(video, at: 0)
                self.currentVideo = video
                self.isGenerating = false
                self.progress = 1.0
                self.saveGeneratedVideos()
            }
            
            return video
            
        } catch {
            print("Video generation error: \(error)")
            await MainActor.run {
                self.isGenerating = false
            }
            return nil
        }
    }
    
    private func generateImageVideo(from image: UIImage, size: CGSize, duration: CMTime) -> AVAsset? {
        let composition = AVMutableComposition()
        
        guard let track = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return nil
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.renderSize = size
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        
        let scale = min(size.width / image.size.width, size.height / image.size.height)
        let scaledSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        let transform = CGAffineTransform.identity
            .translatedBy(x: (size.width - scaledSize.width) / 2, y: (size.height - scaledSize.height) / 2)
            .scaledBy(x: scale, y: scale)
        
        layerInstruction.setTransform(transform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        return composition
    }
    
    private func generateTitle(for style: GeneratedVideo.VideoStyle, tags: [AIFeatureTag]) -> String {
        let tagNames = tags.prefix(2).map { $0.label }
        
        switch style {
        case .trending:
            return "#\(tagNames.joined(separator: " #"))"
        case .cinematic:
            return tagNames.isEmpty ? "Cinematic Moment" : "The \(tagNames[0]) Story"
        case .vlog:
            return tagNames.isEmpty ? "My Day" : "Day with \(tagNames[0])"
        case .meme:
            return "When \(tagNames.first ?? "you") hits different 😂"
        case .inspirational:
            return tagNames.isEmpty ? "Rise & Grind" : "The \(tagNames[0]) Journey"
        }
    }
    
    private func exportVideo(composition: AVMutableComposition, to url: URL) async throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw VideoError.exportFailed
        }
        
        exportSession.outputURL = url
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        await exportSession.export()
        
        if exportSession.status != .completed {
            throw exportSession.error ?? VideoError.exportFailed
        }
    }
    
    private func loadGeneratedVideos() {
        let defaultsKey = "generatedVideos"
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let videos = try? JSONDecoder().decode([GeneratedVideo].self, from: data) else {
            return
        }
        
        let existingVideos = videos.filter { video in
            if let url = video.videoURL {
                return fileManager.fileExists(atPath: url.path)
            }
            return false
        }
        
        generatedVideos = existingVideos
    }
    
    private func saveGeneratedVideos() {
        let defaultsKey = "generatedVideos"
        if let data = try? JSONEncoder().encode(generatedVideos) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
    
    func deleteVideo(_ video: GeneratedVideo) {
        if let url = video.videoURL {
            try? fileManager.removeItem(at: url)
        }
        generatedVideos.removeAll { $0.id == video.id }
        saveGeneratedVideos()
    }
    
    enum VideoError: Error {
        case failedToCreateComposition
        case exportFailed
    }
}
