import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var preferences: UserPreferences
    
    private let preferencesKey = "userPreferences"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = prefs
        } else {
            self.preferences = .default
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: preferencesKey)
        }
    }
    
    func resetToDefaults() {
        preferences = .default
        save()
    }
}
