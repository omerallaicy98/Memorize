import SwiftUI

struct StrengthModeProgressView: View {
    let remainingTiles: Int
    let requiredTiles: Int

    private var clearedTiles: Int {
        max(requiredTiles - remainingTiles, 0)
    }

    private var progress: Double {
        guard requiredTiles > 0 else { return 0 }
        return min(Double(clearedTiles) / Double(requiredTiles), 1)
    }

    var body: some View {
        ProgressView(
            circleOneProgress: 1,
            circleOneValue: requiredTiles,
            circleOneLabel: "Goal",
            circleTwoProgress: 0,
            circleTwoValue: 0,
            circleTwoLabel: "NA",
            circleThreeProgress: progress,
            circleThreeValue: clearedTiles,
            circleThreeLabel: "Cleared"
        )
    }
}
