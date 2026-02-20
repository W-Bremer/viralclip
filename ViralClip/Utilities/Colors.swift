import SwiftUI

extension Color {
    static let appPrimary = Color(hex: "6C5CE7")
    static let appSecondary = Color(hex: "00CEC9")
    static let appBackground = Color(hex: "0D0D0D")
    static let appSurface = Color(hex: "1A1A1A")
    static let appTextPrimary = Color.white
    static let appTextSecondary = Color(hex: "A0A0A0")
    static let appSuccess = Color(hex: "00B894")
    static let appError = Color(hex: "FF6B6B")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.appSurface)
            .cornerRadius(12)
    }
    
    func primaryButton() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.appPrimary)
            .cornerRadius(12)
    }
    
    func secondaryButton() -> some View {
        self
            .font(.headline)
            .foregroundColor(.appPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.appPrimary.opacity(0.1))
            .cornerRadius(12)
    }
}

extension Date {
    var timeAgoDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
