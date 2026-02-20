import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(UserPreferences.TargetPlatform.allCases, id: \.self) { platform in
                        Button(action: {
                            viewModel.preferences.targetPlatform = platform
                            viewModel.save()
                        }) {
                            HStack {
                                Text(platform.rawValue)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if viewModel.preferences.targetPlatform == platform {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.appPrimary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Target Platform")
                        .foregroundColor(.appTextSecondary)
                }
                .listRowBackground(Color.appSurface)
                
                Section {
                    ForEach(UserPreferences.ExportQuality.allCases, id: \.self) { quality in
                        Button(action: {
                            viewModel.preferences.exportQuality = quality
                            viewModel.save()
                        }) {
                            HStack {
                                Text(quality.rawValue)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if viewModel.preferences.exportQuality == quality {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.appPrimary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Export Quality")
                        .foregroundColor(.appTextSecondary)
                }
                .listRowBackground(Color.appSurface)
                
                Section {
                    Toggle(isOn: $viewModel.preferences.dailyReminderEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.appPrimary)
                            Text("Daily Reminder")
                                .foregroundColor(.white)
                        }
                    }
                    .tint(.appPrimary)
                    .onChange(of: viewModel.preferences.dailyReminderEnabled) { _, _ in
                        viewModel.save()
                    }
                    
                    if viewModel.preferences.dailyReminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $viewModel.preferences.reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .foregroundColor(.white)
                        .onChange(of: viewModel.preferences.reminderTime) { _, _ in
                            viewModel.save()
                        }
                    }
                } header: {
                    Text("Notifications")
                        .foregroundColor(.appTextSecondary)
                }
                .listRowBackground(Color.appSurface)
                
                Section {
                    ForEach(GeneratedVideo.VideoStyle.allCases, id: \.self) { style in
                        let isSelected = viewModel.preferences.preferredStyles.contains(style)
                        
                        Button(action: {
                            if isSelected {
                                viewModel.preferences.preferredStyles.removeAll { $0 == style }
                            } else {
                                viewModel.preferences.preferredStyles.append(style)
                            }
                            viewModel.save()
                        }) {
                            HStack {
                                Text(style.rawValue)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isSelected ? .appPrimary : .appTextSecondary)
                            }
                        }
                    }
                } header: {
                    Text("Preferred Styles")
                        .foregroundColor(.appTextSecondary)
                }
                .listRowBackground(Color.appSurface)
                
                Section {
                    Button(action: {
                        viewModel.resetToDefaults()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.appError)
                            Text("Reset to Defaults")
                                .foregroundColor(.appError)
                        }
                    }
                    
                    Button(action: {
                        appState.hasCompletedOnboarding = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.uturn.backward")
                                .foregroundColor(.orange)
                            Text("Restart Onboarding")
                                .foregroundColor(.orange)
                        }
                    }
                } header: {
                    Text("Actions")
                        .foregroundColor(.appTextSecondary)
                }
                .listRowBackground(Color.appSurface)
                
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(.white)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.appTextSecondary)
                    }
                } header: {
                    Text("About")
                        .foregroundColor(.appTextSecondary)
                }
                .listRowBackground(Color.appSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Settings")
        }
    }
}
