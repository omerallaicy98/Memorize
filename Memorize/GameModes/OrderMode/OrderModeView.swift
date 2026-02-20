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
                    lives: gameMode.lives
                )
                
                ProgressView(
                    circleOneProgress: Double(gameMode.currentMatchIndex / gameMode.sequenceLength),
                    circleOneValue: gameMode.currentMatchIndex,
                    circleOneLabel: "Sequnce",
                    circleTwoProgress: 0,
                    circleTwoValue: 0,
                    circleTwoLabel: "NA",
                    circleThreeProgress: Double(gameMode.currentRound / gameMode.totalRounds),
                    circleThreeValue: gameMode.currentRound,
                    circleThreeLabel: "Round"
                )
                
                if gameMode.lives > 0 {
                    GridView(
                        cards: gameMode.cards,
                        showTimer: false,
                        gridSize: gameMode.gridSize,
                        canTap: gameMode.canTap,
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
