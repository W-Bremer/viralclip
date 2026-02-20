import SwiftUI
import AVKit

struct HomeView: View {
    @EnvironmentObject var videoService: VideoGenerationService
    @State private var homeViewModel: HomeViewModel?
    @State private var selectedVideo: GeneratedVideo?
    @State private var showingPlayer = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if videoService.generatedVideos.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(videoService.generatedVideos) { video in
                            VideoCardView(video: video)
                                .onTapGesture {
                                    selectedVideo = video
                                    showingPlayer = true
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        videoService.deleteVideo(video)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    ShareLink(item: video.videoURL ?? URL(fileURLWithPath: "")) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color.appBackground)
            .navigationTitle("Today's Videos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Refresh
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingPlayer) {
                if let video = selectedVideo, let url = video.videoURL {
                    VideoPlayerView(url: url, isPresented: $showingPlayer)
                }
            }
        }
        .onAppear {
            homeViewModel = HomeViewModel(videoService: videoService)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            
            Text("No videos yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Create your first viral video by tapping the Create tab")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 80)
        .frame(maxWidth: .infinity)
    }
}

struct VideoPlayerView: View {
    let url: URL
    @Binding var isPresented: Bool
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        player?.pause()
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
        .onAppear {
            player = AVPlayer(url: url)
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
    }
}
