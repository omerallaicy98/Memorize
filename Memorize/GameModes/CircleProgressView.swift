import SwiftUI

struct CircleProgressView: View {
    @EnvironmentObject private var settings: AppSettings
    var progress: Double
    var label: String
    var valueText: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(settings.secondaryColor.opacity(0.1), lineWidth: 4)
                    .frame(width: 60, height: 60)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(settings.secondaryColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: progress)
                Text("\(valueText)")
                    .font(.subheadline.bold())
                    .foregroundColor(settings.secondaryColor)
                    .animation(.easeOut(duration: 0.5))
            }
            Text(label)
                .font(.caption)
                .foregroundColor(settings.secondaryColor.opacity(0.7))
        }
    }
}
