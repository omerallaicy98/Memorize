import SwiftUI

struct EndlessProgressView:View {
    @Binding var previewTime: Double
    @Binding var level: Int
    @Binding var matchingCardsCount: Int
    
    var body: some View {
        HStack(spacing: 50) {
            CircleProgressView(
                progress: min(max((previewTime - 0.5)/0.3, 0), 1),
                label: "Preview",
                valueText: String(format: "%.2f", previewTime),
            )
            CircleProgressView(
                progress: min(Double(level)/30, 1),
                label: "Level",
                valueText: "\(level)",
            )
            CircleProgressView(
                progress: Double(matchingCardsCount)/15,
                label: "Matches",
                valueText: "\(matchingCardsCount)",
            )
        }
    }
}

struct CircleProgressView: View {
    @EnvironmentObject private var settings: AppSettings
    var progress: Double
    var label: String
    var valueText: String? = nil

    @State private var animatedValue: Double = 0

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(settings.secondaryColor.opacity(0.1), lineWidth: 4)
                    .frame(width: 60, height: 60)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(settings.secondaryColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                // Animate number inside the circle
                if let valueText = valueText {
                    Text(label == "Preview" ? String(format: "%.2f", animatedValue) : String(format: "%.0f", animatedValue))
                        .font(.subheadline.bold())
                        .foregroundColor(settings.secondaryColor)
                        .onAppear { animatedValue = Double(valueText) ?? 0 }
                        .onChange(of: Double(valueText) ?? 0) { newValue in
                            withAnimation(.easeOut(duration: 0.5)) { animatedValue = newValue }
                        }
                }
            }
            Text(label)
                .font(.caption)
                .foregroundColor(settings.secondaryColor.opacity(0.7))
        }
    }
}
