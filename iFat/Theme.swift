import SwiftUI

enum SageTheme {
    static let cream = Color(red: 0.97, green: 0.94, blue: 0.88)
    static let paper = Color(red: 0.99, green: 0.97, blue: 0.93)
    static let sage = Color(red: 0.47, green: 0.59, blue: 0.49)
    static let sageDeep = Color(red: 0.29, green: 0.42, blue: 0.34)
    static let moss = Color(red: 0.36, green: 0.50, blue: 0.40)
    static let ink = Color(red: 0.22, green: 0.24, blue: 0.20)
    static let muted = Color(red: 0.45, green: 0.46, blue: 0.40)
    static let ringTrack = Color(red: 0.90, green: 0.87, blue: 0.78)
}

enum Feeling: String, CaseIterable, Identifiable, Codable {
    case energised = "Energised"
    case steady = "Steady"
    case tired = "Tired"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .energised: return "sun.max.fill"
        case .steady: return "leaf.fill"
        case .tired: return "moon.fill"
        }
    }

    var note: String {
        switch self {
        case .energised: return "Ride the lift. Keep it kind."
        case .steady: return "A good place to be."
        case .tired: return "Rest is part of the work."
        }
    }
}

enum CareAct: String, CaseIterable, Identifiable, Codable {
    case feel = "Feel check"
    case move = "Move kindly"
    case rest = "Rest a little"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .feel: return "heart.fill"
        case .move: return "figure.walk"
        case .rest: return "cup.and.saucer.fill"
        }
    }
}
