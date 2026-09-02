import SwiftUI

@main
struct OKGymApp: App {
    @StateObject private var store = GymStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
        }
    }
}
