import SwiftUI
import PhotosUI

struct CreateView: View {
    @EnvironmentObject var photoService: PhotoLibraryService
    @EnvironmentObject var analysisService: AIAnalysisService
    @EnvironmentObject var videoService: VideoGenerationService
    
    @State private var viewModel: CreateViewModel?
    @State private var isInitialized = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if photoService.authorizationStatus == .authorized ||
                   photoService.authorizationStatus == .limited {
                    mainContent
                } else {
                    permissionRequestView
                }
            }
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if viewModel?.selectedMedia.isEmpty == false {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") {
                            viewModel?.clearSelection()
                        }
                        .foregroundColor(.appPrimary)
                    }
                }
            }
        }
        .onAppear {
            if !isInitialized {
                viewModel = CreateViewModel(
                    photoService: photoService,
                    analysisService: analysisService,
                    videoService: videoService
                )
                isInitialized = true
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if let viewModel = viewModel {
            MainContentView(viewModel: viewModel, photoService: photoService)
        }
    }
    
    @ViewBuilder
    private var permissionRequestView: some View {
        if let viewModel = viewModel {
            PermissionRequestView(viewModel: viewModel)
        } else {
            ProgressView()
        }
    }
}

struct MainContentView: View {
    @ObservedObject var viewModel: CreateViewModel
    @ObservedObject var photoService: PhotoLibraryService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.selectedMedia.isEmpty {
                    selectMediaPrompt
                } else {
                    selectedMediaSection
                    
                    if viewModel.isAnalyzing || viewModel.isGenerating {
                        progressSection
                    } else if !viewModel.detectedTags.isEmpty {
                        tagsSection
                    }
                    
                    if viewModel.detectedTags.isEmpty && !viewModel.isGenerating {
                        analyzeButton
                    } else if !viewModel.isGenerating {
                        generateButton
                    }
                }
            }
            .padding(16)
        }
        .sheet(isPresented: $viewModel.showingMediaPicker) {
            MediaPickerView()
                .environmentObject(photoService)
                .onDisappear {
                    Task {
                        await photoService.loadMedia()
                    }
                }
        }
        .fullScreenCover(isPresented: $viewModel.showVideoPreview) {
            if let video = viewModel.generatedVideo, let url = video.videoURL {
                VideoPlayerView(url: url, isPresented: $viewModel.showVideoPreview)
            }
        }
    }
    
    private var selectMediaPrompt: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.appPrimary)
            
            Text("Select Media")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Choose photos and videos from your camera roll to create amazing content")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                viewModel.showingMediaPicker = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Browse Photos")
                }
                .primaryButton()
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(.vertical, 60)
    }
    
    private var selectedMediaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Selected Media")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.selectedMedia.count) items")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                
                Button("Add More") {
                    viewModel.showingMediaPicker = true
                }
                .font(.subheadline)
                .foregroundColor(.appPrimary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.selectedMedia) { item in
                        MediaThumbnailView(
                            item: item,
                            photoService: photoService,
                            isSelected: viewModel.isSelected(item)
                        )
                        .onTapGesture {
                            viewModel.toggleMediaSelection(item)
                        }
                    }
                }
            }
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            if viewModel.isAnalyzing {
                HStack {
                    ProgressView(value: viewModel.analysisProgress)
                        .tint(.appPrimary)
                    
                    Text("\(Int(viewModel.analysisProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Text("Analyzing your content...")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }
            
            if viewModel.isGenerating {
                HStack {
                    ProgressView(value: viewModel.generationProgress)
                        .tint(.appSecondary)
                    
                    Text("\(Int(viewModel.generationProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Text("Generating your video...")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(12)
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detected Content")
                .font(.headline)
                .foregroundColor(.white)
            
            FlowLayout(spacing: 8) {
                ForEach(viewModel.detectedTags) { tag in
                    AIFeatureTagView(tag: tag)
                }
            }
            
            if !viewModel.trendingTags.isEmpty {
                Text("Trending Formats")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.trendingTags) { tag in
                        AIFeatureTagView(tag: tag, isTrending: true)
                    }
                }
            }
            
            Text("Video Style")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GeneratedVideo.VideoStyle.allCases, id: \.self) { style in
                        StyleSelectorButton(
                            style: style,
                            isSelected: viewModel.selectedStyle == style
                        ) {
                            viewModel.selectedStyle = style
                        }
                    }
                }
            }
        }
    }
    
    private var analyzeButton: some View {
        Button(action: {
            Task {
                await viewModel.analyzeSelectedMedia()
            }
        }) {
            HStack {
                Image(systemName: "brain")
                Text("Analyze Content")
            }
            .primaryButton()
        }
    }
    
    private var generateButton: some View {
        Button(action: {
            Task {
                await viewModel.generateVideo()
            }
        }) {
            HStack {
                Image(systemName: "sparkles")
                Text("Generate Video")
            }
            .primaryButton()
        }
    }
}

struct PermissionRequestView: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.appPrimary)
            
            Text("Photo Access Required")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("We need access to your photos and videos to create content for you")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                Task {
                    await viewModel.requestPhotoAccess()
                }
            }) {
                Text("Grant Access")
                    .primaryButton()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }
}

struct StyleSelectorButton: View {
    let style: GeneratedVideo.VideoStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(style.rawValue)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .appTextSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.appPrimary : Color.appSurface)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.appPrimary : Color.appTextSecondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        
        for (index, subview) in subviews.enumerated() {
            let point = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX)
        }
        
        return (CGSize(width: totalWidth, height: currentY + lineHeight), positions)
    }
}
