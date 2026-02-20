import SwiftUI

struct AnalysisView: View {
    @EnvironmentObject var analysisService: AIAnalysisService
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressRing(progress: analysisService.progress)
                .frame(width: 120, height: 120)
            
            if analysisService.isAnalyzing {
                Text("Analyzing your content...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Detecting faces, objects, and scenes")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            } else if analysisService.analysisComplete {
                Text("Analysis Complete!")
                    .font(.headline)
                    .foregroundColor(.appSuccess)
                
                if !analysisService.detectedTags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("We found:")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(analysisService.detectedTags) { tag in
                                AIFeatureTagView(tag: tag)
                            }
                        }
                    }
                    .padding()
                    .background(Color.appSurface)
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct VideoEditorView: View {
    let video: GeneratedVideo
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if let url = video.videoURL {
                        VideoPreviewThumbnail(url: url)
                            .aspectRatio(9/16, contentMode: .fit)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.3), radius: 10)
                    }
                    
                    VStack(spacing: 16) {
                        Text(video.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Label(video.style.rawValue, systemImage: "sparkles")
                                .font(.caption)
                                .foregroundColor(.appPrimary)
                            
                            Spacer()
                            
                            Label(formatDuration(video.duration), systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    .padding()
                    .background(Color.appSurface)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.appPrimary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if let url = video.videoURL {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .foregroundColor(.appPrimary)
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct VideoPreviewThumbnail: View {
    let url: URL
    
    var body: some View {
        ZStack {
            RoundedRectangle(radius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary.opacity(0.4), Color.appSecondary.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Image(systemName: "play.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}
