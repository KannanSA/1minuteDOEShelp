import Foundation

struct DayCare: Codable, Equatable {
    var feeling: Feeling?
    var completed: Set<CareAct>

    init(feeling: Feeling? = nil, completed: Set<CareAct> = []) {
        self.feeling = feeling
        self.completed = completed
    }

    var count: Int { completed.count }
}

@MainActor
final class WellbeingStore: ObservableObject {
    @Published private var days: [String: DayCare] = [:]

    private let key = "ifat.days"
    private let calendar = Calendar.current
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        load()
        seedPreviewIfEmpty()
    }

    var today: DayCare {
        days[todayKey()] ?? DayCare()
    }

    var careCount: Int { today.count }
    var careTotal: Int { CareAct.allCases.count }
    var ringProgress: Double { Double(careCount) / Double(careTotal) }

    func choose(_ feeling: Feeling) {
        var entry = today
        entry.feeling = feeling
        entry.completed.insert(.feel)
        days[todayKey()] = entry
        save()
    }

    func toggle(_ act: CareAct) {
        guard act != .feel else { return }
        var entry = today
        if entry.completed.contains(act) {
            entry.completed.remove(act)
        } else {
            entry.completed.insert(act)
        }
        days[todayKey()] = entry
        save()
    }

    func lastSevenDays() -> [(label: String, doneCount: Int)] {
        let symbols = calendar.veryShortWeekdaySymbols
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset - 6, to: calendar.startOfDay(for: Date())) ?? Date()
            let weekday = calendar.component(.weekday, from: date)
            let entry = days[formatter.string(from: date)] ?? DayCare()
            return (symbols[weekday - 1], entry.count)
        }
    }

    private func todayKey() -> String {
        formatter.string(from: Date())
    }

    /// First launch shows a lived-in home: feel check + one more care (2 of 3).
    private func seedPreviewIfEmpty() {
        guard days[todayKey()] == nil else { return }
        days[todayKey()] = DayCare(feeling: .steady, completed: [.feel, .move])
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: DayCare].self, from: data) else { return }
        days = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(days) {
            UserDefaults.standard.set(data, forKey: key)
        }
        objectWillChange.send()
    }
}
