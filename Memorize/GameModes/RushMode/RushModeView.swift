import SwiftUI
import Combine

struct RushModeView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var gameMode = SpeedGameMode(settings: AppSettings.shared)
    @State private var showHomeView = false
    @State private var isLoading = true
    
    var body: some View {
        if showHomeView {
            if isLoading {
                LoadingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + settings.loadingTime) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
            }
            else {
                HomepageView()
            }
        }
        else {
            VStack(alignment: .center) {
                ControlsView(
                    onHome: {
                        showHomeView = true
                    },
                    onRestart: {
                        gameMode.resetGame()
                    },
                    lives: gameMode.lives,
                    level: settings.currentOrderLevel
                )
                
                ProgressView(
                    circleOneProgress: gameMode.remainingTime / gameMode.totalTime,
                    circleOneValue: Int(gameMode.remainingTime),
                    circleOneLabel: "Time",
                    circleTwoProgress: 0,
                    circleTwoValue: 0,
                    circleTwoLabel: "NA",
//                    circleThreeProgress: Double(gameMode.remainingMatchingCards) / Double(gameMode.totalMatchingCards),
//                    circleThreeValue: gameMode.remainingMatchingCards,
//                    circleThreeLabel: "Matches"
                )

                if gameMode.lives > 0 {
                    GridView(
                        cards: gameMode.cards,
                        showTimer: true,
                        gridSize: gameMode.gridSize,
                        canTap: gameMode.canTap,
                        levelCleared: false,
                        onTapCard: { index in
                            gameMode.tapCard(at: index)
                        }
                    )
                }
            }
            .onAppear {
                gameMode.startGame()
            }
        }
    }
}
