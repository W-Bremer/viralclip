import SwiftUI
import PhotosUI

struct MediaPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var photoService: PhotoLibraryService
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if photoService.mediaItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 50))
                            .foregroundColor(.appTextSecondary)
                        
                        Text("No photos found")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Button("Load Photos") {
                            Task {
                                isLoading = true
                                await photoService.loadMedia()
                                isLoading = false
                            }
                        }
                        .foregroundColor(.appPrimary)
                    }
                } else {
                    photoGrid
                }
            }
            .navigationTitle("Select Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.appPrimary)
                }
            }
            .task {
                if photoService.mediaItems.isEmpty {
                    isLoading = true
                    await photoService.loadMedia()
                    isLoading = false
                }
            }
        }
    }
    
    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2)
            ], spacing: 2) {
                ForEach(photoService.mediaItems) { item in
                    MediaGridItem(item: item, photoService: photoService)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }
}

struct MediaGridItem: View {
    let item: MediaItem
    @ObservedObject var photoService: PhotoLibraryService
    @State private var thumbnail: UIImage?
    @State private var isAppearing = false
    
    var body: some View {
        ZStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.appSurface)
            }
            
            if item.type == .video {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "video.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                        
                        if let date = item.creationDate {
                            Text(formatDate(date))
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(4)
                    .padding(6)
                }
            }
        }
        .task {
            if thumbnail == nil {
                let size = CGSize(width: 200, height: 200)
                thumbnail = await photoService.loadThumbnail(for: item, size: size)
                withAnimation(.smooth) {
                    isAppearing = true
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "m:ss"
        return formatter.string(from: date)
    }
}
