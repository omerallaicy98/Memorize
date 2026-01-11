import SwiftUI

@main
struct MemorizeApp: App {
    @StateObject var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(settings)
        }
    }
}
