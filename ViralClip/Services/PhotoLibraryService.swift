import Foundation
import Photos
import PhotosUI
import SwiftUI

@MainActor
class PhotoLibraryService: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var mediaItems: [MediaItem] = []
    @Published var isLoading = false
    @Published var selectedItems: [MediaItem] = []
    
    init() {
        checkAuthorization()
    }
    
    func checkAuthorization() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestAccess() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            self.authorizationStatus = status
        }
    }
    
    func loadMedia() async {
        await MainActor.run {
            self.isLoading = true
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 100
        
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        var items: [MediaItem] = []
        
        assets.enumerateObjects { asset, _, _ in
            let mediaType: MediaItem.MediaType = asset.mediaType == .video ? .video : .image
            let item = MediaItem(
                id: asset.localIdentifier,
                asset: asset,
                type: mediaType,
                creationDate: asset.creationDate
            )
            items.append(item)
        }
        
        await MainActor.run {
            self.mediaItems = items
            self.isLoading = false
        }
    }
    
    func loadThumbnail(for item: MediaItem, size: CGSize) async -> UIImage? {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            manager.requestImage(
                for: item.asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    func loadFullImage(for item: MediaItem) async -> UIImage? {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            manager.requestImage(
                for: item.asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    func loadAVAsset(for item: MediaItem) async -> AVAsset? {
        guard item.type == .video else { return nil }
        
        return await withCheckedContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
            
            PHImageManager.default().requestAVAsset(
                forVideo: item.asset,
                options: options
            ) { asset, _, _ in
                continuation.resume(returning: asset)
            }
        }
    }
}
