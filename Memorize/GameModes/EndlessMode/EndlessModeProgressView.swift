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
