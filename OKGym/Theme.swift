import SwiftUI

enum GymTheme {
    static let black = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let raised = Color(red: 0.11, green: 0.11, blue: 0.11)
    static let volt = Color(red: 0.83, green: 1.00, blue: 0.09)
    static let white = Color.white
    static let mute = Color(red: 0.55, green: 0.55, blue: 0.55)
}

enum SplitDay: String, CaseIterable, Identifiable, Codable {
    case push = "PUSH"
    case pull = "PULL"
    case legs = "LEGS"
    case rest = "REST"

    var id: String { rawValue }
}

struct Lift: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let scheme: String
}

enum WorkoutCatalog {
    static let push: [Lift] = [
        Lift(id: "bench", name: "Bench Press", scheme: "4 × 8"),
        Lift(id: "ohp", name: "Overhead Press", scheme: "3 × 10"),
        Lift(id: "incline", name: "Incline Dumbbell", scheme: "3 × 10"),
        Lift(id: "dip", name: "Weighted Dip", scheme: "3 × 8"),
        Lift(id: "tri", name: "Tricep Pushdown", scheme: "3 × 12"),
        Lift(id: "raise", name: "Lateral Raise", scheme: "3 × 15")
    ]

    static let pull: [Lift] = [
        Lift(id: "dead", name: "Deadlift", scheme: "4 × 5"),
        Lift(id: "row", name: "Barbell Row", scheme: "4 × 8"),
        Lift(id: "pullup", name: "Pull-Up", scheme: "3 × 8"),
        Lift(id: "face", name: "Face Pull", scheme: "3 × 15"),
        Lift(id: "curl", name: "EZ Bar Curl", scheme: "3 × 10")
    ]

    static let legs: [Lift] = [
        Lift(id: "squat", name: "Back Squat", scheme: "4 × 6"),
        Lift(id: "rdl", name: "Romanian Deadlift", scheme: "3 × 8"),
        Lift(id: "lunge", name: "Walking Lunge", scheme: "3 × 10"),
        Lift(id: "legpress", name: "Leg Press", scheme: "3 × 12"),
        Lift(id: "calf", name: "Calf Raise", scheme: "4 × 15")
    ]

    static func lifts(for split: SplitDay) -> [Lift] {
        switch split {
        case .push: return push
        case .pull: return pull
        case .legs: return legs
        case .rest: return []
        }
    }
}
