import SwiftUI

struct EndlessProgressView:View {
    @Binding var previewTime: Double
    @Binding var level: Int
    @Binding var matchingCardsCount: Int
    
    var body: some View {
        ProgressView(
            circleOneProgress: min(max((previewTime - 0.5)/0.3, 0), 1),
            circleOneValue: Int(previewTime),
            circleOneLabel: "Preview",
            circleTwoProgress: min(Double(level)/30, 1),
            circleTwoValue: level,
            circleTwoLabel: "Level",
            circleThreeProgress: Double(matchingCardsCount)/15,
            circleThreeValue: matchingCardsCount,
            circleThreeLabel: "Matches"
        )
    }
}
