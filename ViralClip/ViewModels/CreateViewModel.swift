import Foundation
import Photos
import Combine

@MainActor
class CreateViewModel: ObservableObject {
    @Published var selectedMedia: [MediaItem] = []
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0
    @Published var detectedTags: [AIFeatureTag] = []
    @Published var trendingTags: [AIFeatureTag] = []
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0
    @Published var generatedVideo: GeneratedVideo?
    @Published var showVideoPreview = false
    @Published var selectedStyle: GeneratedVideo.VideoStyle = .trending
    
    @Published var showingMediaPicker = false
    @Published var mediaAuthorizationStatus: PHAuthorizationStatus = .notDetermined
    
    private let photoService: PhotoLibraryService
    private let analysisService: AIAnalysisService
    private let videoService: VideoGenerationService
    
    init(photoService: PhotoLibraryService, analysisService: AIAnalysisService, videoService: VideoGenerationService) {
        self.photoService = photoService
        self.analysisService = analysisService
        self.videoService = videoService
        
        self.mediaAuthorizationStatus = photoService.authorizationStatus
    }
    
    func requestPhotoAccess() async {
        await photoService.requestAccess()
        mediaAuthorizationStatus = photoService.authorizationStatus
    }
    
    func toggleMediaSelection(_ item: MediaItem) {
        if let index = selectedMedia.firstIndex(where: { $0.id == item.id }) {
            selectedMedia.remove(at: index)
        } else {
            selectedMedia.append(item)
        }
    }
    
    func isSelected(_ item: MediaItem) -> Bool {
        selectedMedia.contains { $0.id == item.id }
    }
    
    func clearSelection() {
        selectedMedia.removeAll()
    }
    
    func analyzeSelectedMedia() async {
        guard !selectedMedia.isEmpty else { return }
        
        isAnalyzing = true
        analysisProgress = 0
        detectedTags = []
        
        let tags = await analysisService.analyzeMedia(selectedMedia, photoService: photoService)
        let trending = analysisService.generateTrendingTags()
        
        detectedTags = tags
        trendingTags = trending
        isAnalyzing = false
    }
    
    func generateVideo() async {
        guard !selectedMedia.isEmpty else { return }
        
        isGenerating = true
        generationProgress = 0
        
        let allTags = detectedTags + trendingTags
        
        let video = await videoService.generateVideo(
            from: selectedMedia,
            tags: allTags,
            photoService: photoService,
            style: selectedStyle
        )
        
        generatedVideo = video
        isGenerating = false
        
        if video != nil {
            showVideoPreview = true
        }
    }
    
    func reset() {
        selectedMedia.removeAll()
        detectedTags.removeAll()
        trendingTags.removeAll()
        generatedVideo = nil
        showVideoPreview = false
    }
}
