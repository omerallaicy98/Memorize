import SwiftUI

struct LoadingView: View {
    @State private var animate = false
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(settings.secondaryColor)
                    .frame(width: 18, height: 18)
                    .scaleEffect(animate ? 1.6 : 1)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever()
                        .delay(Double(index) * 0.15),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
        .transition(.opacity)
    }
}
