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
        HStack(spacing: 50) {

            // Level timer (left)
            CircleProgressView(
                progress: timerProgress,
                label: "Time",
                valueText: "\(Int(ceil(levelTimeRemaining)))"
            )

            // Remaining matches (right)
            CircleProgressView(
                progress: matchesProgress,
                label: "Matches",
                valueText: "\(remainingMatches)"
            )
        }
    }
}
