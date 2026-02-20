import SwiftUI

struct MediaThumbnailView: View {
    let item: MediaItem
    @ObservedObject var photoService: PhotoLibraryService
    let isSelected: Bool
    @State private var thumbnail: UIImage?
    
    var body: some View {
        ZStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.appSurface)
                    .frame(width: 80, height: 80)
            }
            
            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.appPrimary, lineWidth: 3)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.appPrimary)
                    .background(Circle().fill(.white))
            }
            
            if item.type == .video {
                VStack {
                    HStack {
                        Image(systemName: "video.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(4)
            }
        }
        .frame(width: 80, height: 80)
        .cornerRadius(8)
        .task {
            if thumbnail == nil {
                let size = CGSize(width: 160, height: 160)
                thumbnail = await photoService.loadThumbnail(for: item, size: size)
            }
        }
    }
}

struct AIFeatureTagView: View {
    let tag: AIFeatureTag
    var isTrending: Bool = false
    
    var tagColor: Color {
        if isTrending {
            return .appSecondary
        }
        
        switch tag.category {
        case .location: return .blue
        case .people: return .purple
        case .activity: return .orange
        case .mood: return .pink
        case .trending: return .appSecondary
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if isTrending {
                Image(systemName: "flame.fill")
                    .font(.caption2)
            }
            
            Text(tag.label)
                .font(.caption)
        }
        .foregroundColor(tagColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tagColor.opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tagColor.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ProgressRing: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appSurface, lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}
