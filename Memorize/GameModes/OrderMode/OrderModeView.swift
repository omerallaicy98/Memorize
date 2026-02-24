import SwiftUI
import Combine

struct OrderModeView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var gameMode = OrderGameMode()
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
                        gameMode.startGame(settings.currentOrderLevel)
                    },
                    lives: gameMode.lives,
                    level: settings.currentOrderLevel
                )
                
                ProgressView(
                    circleOneProgress: Double(max(gameMode.currentRound - 1, 0)) / Double(gameMode.totalRounds),
                    circleOneValue: gameMode.totalRounds - gameMode.currentRound + 1,
                    circleOneLabel: "Rounds",
                    circleTwoProgress: Double(gameMode.currentMatchIndex) / Double(gameMode.sequenceLength),
                    circleTwoValue: gameMode.sequenceLength - gameMode.currentMatchIndex,
                    circleTwoLabel: "Sequnce"
                )
                
                if gameMode.lives > 0 {
                    GridView(
                        cards: gameMode.cards,
                        showTimer: false,
                        gridSize: gameMode.gridSize,
                        canTap: gameMode.canTap,
                        levelCleared: gameMode.isLevelPassed,
                        onTapCard: { index in
                            let card = gameMode.cards[index]
                            gameMode.handleTap(on: card)
                        }
                    )
                }
            }
            .onAppear {
                gameMode.startGame(settings.currentOrderLevel)
            }
            .onChange(of: gameMode.isLevelPassed) { dummy in
                if gameMode.isLevelPassed {
                    settings.incrementOrderLevel()
                }
            }
        }
    }
}
