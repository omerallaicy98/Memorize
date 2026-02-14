import SwiftUI

struct SpeedModeProgressView: View {
    @EnvironmentObject var settings: AppSettings
    let levelTimeRemaining: Double
    let levelTotalTime: Double
    let remainingMatches: Int
    let totalMatches: Int

    private var timerProgress: Double {
        guard levelTotalTime > 0 else { return 0 }
        return max(min(levelTimeRemaining / levelTotalTime, 1), 0)
    }

    private var matchesProgress: Double {
        guard totalMatches > 0 else { return 0 }
        return max(min(1 - (Double(remainingMatches) / Double(totalMatches)), 1), 0)
    }

    var body: some View {
        ProgressView(
            circleOneProgress: timerProgress,
            circleOneValue: Int(levelTimeRemaining),
            circleOneLabel: "Time",
            circleTwoProgress: 0,
            circleTwoValue: 0,
            circleTwoLabel: "NA",
            circleThreeProgress: matchesProgress,
            circleThreeValue: remainingMatches,
            circleThreeLabel: "Matches"
        )
    }
}
