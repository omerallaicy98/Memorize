import SwiftUI

struct LoadingView: View {
    @State private var animate = false
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
<<<<<<< HEAD
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
=======
        ZStack {
            NeuronBackground()

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
>>>>>>> 1b6e756eee743515d6d5471aa9ef04fc6d136b9a
            }
        }
        .onAppear {
            animate = true
        }
        .transition(.opacity)
    }
}
