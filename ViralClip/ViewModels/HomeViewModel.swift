import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var videos: [GeneratedVideo] = []
    @Published var isLoading = false
    @Published var selectedVideo: GeneratedVideo?
    @Published var showingVideoPlayer = false
    
    private let videoService: VideoGenerationService
    
    init(videoService: VideoGenerationService) {
        self.videoService = videoService
        self.videos = videoService.generatedVideos
    }
    
    func refresh() {
        videos = videoService.generatedVideos
    }
    
    func deleteVideo(_ video: GeneratedVideo) {
        videoService.deleteVideo(video)
        videos = videoService.generatedVideos
    }
    
    func selectVideo(_ video: GeneratedVideo) {
        selectedVideo = video
        showingVideoPlayer = true
    }
}
