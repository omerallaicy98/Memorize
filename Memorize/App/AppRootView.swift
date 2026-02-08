import SwiftUI

struct AppRootView: View {
    @State private var isLoading = true
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if isLoading {
                    LoadingView()
                        .transition(.opacity)
                } else {
                    HomepageView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                if settings.geometrySet == 0 {
                    settings.computeGeometry(for: geo)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + settings.loadingTime) {
                    withAnimation(.easeOut(duration: settings.loadingTransitionTime)) {
                        isLoading = false
                    }
                }
            }
        }
    }
}
