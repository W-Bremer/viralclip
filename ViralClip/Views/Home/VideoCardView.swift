import SwiftUI

struct VideoCardView: View {
    let video: GeneratedVideo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(radius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.3), Color.appSecondary.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(9/16, contentMode: .fit)
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.8))
                
                VStack {
                    Spacer()
                    HStack {
                        if let url = video.videoURL {
                            ShareLink(item: url) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                        
                        Spacer()
                        
                        Text(formatDuration(video.duration))
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                    }
                    .padding(12)
                }
            }
            .cornerRadius(12)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Text(video.createdAt.timeAgoDisplay)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        
                        StyleBadge(style: video.style)
                    }
                }
                
                Spacer()
            }
            
            if !video.analysisTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(video.analysisTags.prefix(5), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .foregroundColor(.appTextSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.appSurface)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StyleBadge: View {
    let style: GeneratedVideo.VideoStyle
    
    var color: Color {
        switch style {
        case .trending: return .appPrimary
        case .cinematic: return .blue
        case .vlog: return .appSecondary
        case .meme: return .orange
        case .inspirational: return .green
        }
    }
    
    var body: some View {
        Text(style.rawValue)
            .font(.caption2)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .cornerRadius(4)
    }
}
