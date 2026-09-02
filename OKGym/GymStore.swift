import Foundation

@MainActor
final class GymStore: ObservableObject {
    /// Featured session on the home screen, per product spec.
    let todaySplit: SplitDay = .push

    @Published private(set) var completedDays: Set<String> = []
    @Published var checkedLiftIDs: Set<String> = []
    @Published var sessionActive = false

    private let completedKey = "okgym.completedDays"
    private let liftsKey = "okgym.checkedLifts"
    private let calendar = Calendar.current
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var todayLifts: [Lift] { WorkoutCatalog.lifts(for: todaySplit) }

    init() {
        load()
    }

    func startWorkout() {
        sessionActive = true
    }

    func toggleLift(_ lift: Lift) {
        if checkedLiftIDs.contains(lift.id) {
            checkedLiftIDs.remove(lift.id)
        } else {
            checkedLiftIDs.insert(lift.id)
        }
        persistLifts()
    }

    func finishWorkout() {
        completedDays.insert(todayKey())
        sessionActive = false
        persistDays()
    }

    func weekStrip() -> [(label: String, done: Bool, isToday: Bool)] {
        let symbols = calendar.veryShortWeekdaySymbols
        let today = calendar.startOfDay(for: Date())
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset - 6, to: today) ?? today
            let weekday = calendar.component(.weekday, from: date)
            let key = formatter.string(from: date)
            return (symbols[weekday - 1].uppercased(), completedDays.contains(key), calendar.isDate(date, inSameDayAs: today))
        }
    }

    private func todayKey() -> String {
        formatter.string(from: Date())
    }

    private func load() {
        completedDays = Set(UserDefaults.standard.stringArray(forKey: completedKey) ?? [])
        checkedLiftIDs = Set(UserDefaults.standard.stringArray(forKey: liftsKey) ?? [])
    }

    private func persistDays() {
        UserDefaults.standard.set(Array(completedDays), forKey: completedKey)
    }

    private func persistLifts() {
        UserDefaults.standard.set(Array(checkedLiftIDs), forKey: liftsKey)
    }
}
