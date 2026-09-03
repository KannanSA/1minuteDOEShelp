import SwiftUI

enum PeachTheme {
    static let background = Color(red: 1.00, green: 0.90, blue: 0.82)
    static let wash = Color(red: 1.00, green: 0.84, blue: 0.72)
    static let ring = Color(red: 0.96, green: 0.48, blue: 0.36)
    static let ringSoft = Color(red: 0.98, green: 0.70, blue: 0.56)
    static let ink = Color(red: 0.27, green: 0.14, blue: 0.10)
    static let muted = Color(red: 0.52, green: 0.32, blue: 0.24)
    static let chipFill = Color.white.opacity(0.72)
    static let button = Color(red: 0.27, green: 0.14, blue: 0.10)
}

enum MinuteAction: String, CaseIterable, Identifiable, Codable {
    case breathe = "Breathe"
    case drinkWater = "Drink water"
    case standUp = "Stand up"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .breathe: return "wind"
        case .drinkWater: return "drop.fill"
        case .standUp: return "figure.stand"
        }
    }

    var prompt: String {
        switch self {
        case .breathe: return "Slow in, slower out."
        case .drinkWater: return "One full glass. Unhurried."
        case .standUp: return "Stand. Stretch. Reset."
        }
    }
}
