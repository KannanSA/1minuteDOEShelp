import SwiftUI

@main
struct iFatApp: App {
    @StateObject private var store = WellbeingStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
        }
    }
}
