import SwiftUI

@main
struct OneMinuteDOESHelpApp: App {
    @StateObject private var streak = StreakStore()
    @StateObject private var timer = MinuteTimer()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(streak)
                .environmentObject(timer)
        }
    }
}
