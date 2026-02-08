import SwiftUI

struct SequnceModeProgressView: View {
    @Binding var currentRepetitions: Int
    @Binding var totalRepetitions: Int
    @Binding var remainingSequenceCards: Int
    @Binding var totalSequenceCards: Int

    private var repetitionProgress: Double {
        guard totalRepetitions > 0 else { return 0 }
        return max(min(Double(currentRepetitions) / Double(totalRepetitions), 1), 0)
    }

    private var sequenceProgress: Double {
        guard totalSequenceCards > 0 else { return 0 }
        return max(min(1 - (Double(remainingSequenceCards) / Double(totalSequenceCards)), 1), 0)
    }

    var body: some View {
        HStack(spacing: 50) {

            // Left: Repetitions
            CircleProgressView(
                progress: repetitionProgress,
                label: "Repeat",
                valueText: "\(currentRepetitions)"
            )

            // Right: Remaining sequence cards
            CircleProgressView(
                progress: sequenceProgress,
                label: "Sequence",
                valueText: "\(remainingSequenceCards)"
            )
        }
    }
}
