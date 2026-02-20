import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    @StateObject private var photoService = PhotoLibraryService()
    @StateObject private var analysisService = AIAnalysisService()
    @StateObject private var videoService = VideoGenerationService()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            CreateView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(Color.appPrimary)
        .environmentObject(photoService)
        .environmentObject(analysisService)
        .environmentObject(videoService)
    }
}

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    let pages: [(title: String, description: String, icon: String)] = [
        ("Welcome to ViralClip", "Turn your camera roll into viral content", "sparkles"),
        ("AI-Powered", "We analyze your photos & videos to understand your style", "brain.head.profile"),
        ("Daily Videos", "Get fresh content ready to post every single day", "calendar.badge.clock")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 24) {
                        Image(systemName: pages[index].icon)
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.appPrimary, Color.appSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(pages[index].title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(pages[index].description)
                            .font(.body)
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer()
            
            VStack(spacing: 16) {
                PageIndicator(currentPage: currentPage, totalPages: pages.count)
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        appState.hasCompletedOnboarding = true
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .primaryButton()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.appBackground)
    }
}

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.appPrimary : Color.appTextSecondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.smooth, value: currentPage)
            }
        }
    }
}
