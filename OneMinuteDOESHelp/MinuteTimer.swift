import Combine
import Foundation

/// Wall-clock 60-second timer. Remaining time is derived from an end date
/// so it keeps counting correctly while the display refreshes.
@MainActor
final class MinuteTimer: ObservableObject {
    static let duration: TimeInterval = 60

    @Published private(set) var remaining: TimeInterval = MinuteTimer.duration
    @Published private(set) var isRunning = false
    @Published private(set) var isComplete = false

    private var endDate: Date?
    private var ticker: AnyCancellable?
    private let endDateKey = "oneMinute.timer.endDate"

    var progress: Double {
        min(1, max(0, (Self.duration - remaining) / Self.duration))
    }

    var remainingWholeSeconds: Int {
        Int(ceil(remaining - 0.000_1))
    }

    init() {
        restoreIfNeeded()
    }

    func start() {
        guard !isRunning else { return }
        isComplete = false
        remaining = Self.duration
        let end = Date().addingTimeInterval(Self.duration)
        endDate = end
        UserDefaults.standard.set(end.timeIntervalSince1970, forKey: endDateKey)
        isRunning = true
        startTicking()
    }

    func stop() {
        ticker?.cancel()
        ticker = nil
        endDate = nil
        UserDefaults.standard.removeObject(forKey: endDateKey)
        isRunning = false
        isComplete = false
        remaining = Self.duration
    }

    func acknowledgeCompletion() {
        isComplete = false
        remaining = Self.duration
    }

    private func restoreIfNeeded() {
        let stored = UserDefaults.standard.double(forKey: endDateKey)
        guard stored > 0 else { return }
        let end = Date(timeIntervalSince1970: stored)
        endDate = end
        let left = end.timeIntervalSinceNow
        if left > 0 {
            remaining = left
            isRunning = true
            isComplete = false
            startTicking()
        } else {
            remaining = 0
            isRunning = false
            isComplete = true
            UserDefaults.standard.removeObject(forKey: endDateKey)
            endDate = nil
        }
    }

    private func startTicking() {
        ticker?.cancel()
        ticker = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.tick(now: now)
            }
    }

    private func tick(now: Date) {
        guard let endDate else { return }
        let left = endDate.timeIntervalSince(now)
        if left <= 0 {
            remaining = 0
            isRunning = false
            isComplete = true
            ticker?.cancel()
            ticker = nil
            self.endDate = nil
            UserDefaults.standard.removeObject(forKey: endDateKey)
        } else {
            remaining = left
        }
    }
}
