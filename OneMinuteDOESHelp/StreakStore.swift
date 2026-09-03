import Foundation

@MainActor
final class StreakStore: ObservableObject {
    @Published private(set) var completedDays: Set<Date> = []
    @Published var selectedAction: MinuteAction = .breathe

    private let key = "oneMinute.completedDays"
    private let calendar = Calendar.current

    init() {
        load()
    }

    var todayCompleted: Bool {
        completedDays.contains(dayStamp(Date()))
    }

    func markTodayComplete() {
        completedDays.insert(dayStamp(Date()))
        save()
    }

    func lastSevenDays() -> [(label: String, date: Date, done: Bool)] {
        let symbols = calendar.veryShortWeekdaySymbols
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset - 6, to: calendar.startOfDay(for: Date())) ?? Date()
            let weekday = calendar.component(.weekday, from: date)
            return (symbols[weekday - 1], date, completedDays.contains(dayStamp(date)))
        }
    }

    func currentStreak() -> Int {
        var count = 0
        var day = calendar.startOfDay(for: Date())
        if !completedDays.contains(dayStamp(day)) {
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        while completedDays.contains(dayStamp(day)) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    private func dayStamp(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func load() {
        let values = UserDefaults.standard.array(forKey: key) as? [Double] ?? []
        completedDays = Set(values.map { Date(timeIntervalSince1970: $0) }.map(dayStamp))
    }

    private func save() {
        let values = completedDays.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(values, forKey: key)
    }
}
