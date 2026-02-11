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
        HStack(spacing: 50) {
            CircleProgressView(
                progress: 1,
                label: "Goal",
                valueText: "\(requiredTiles)"
            )
            
            CircleProgressView(
                progress: progress,
                label: "Cleared",
                valueText: "\(clearedTiles)"
            )
        }
    }
}
