import SwiftUI

struct MainProgressView:View {
    @State private var animatedValue: Double = 0
    @Binding var level: Int?
    var label: String = "Progress"
    @EnvironmentObject private var settings: AppSettings
    
    var body: some View {
        let progress = min(Double(level!)/1000, 1)
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(settings.secondaryColor.opacity(0.1), lineWidth: 4)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(settings.secondaryColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120, height: 120)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                if let valueText = level {
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
