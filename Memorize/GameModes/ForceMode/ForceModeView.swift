import SwiftUI
import Combine

struct ForceModeView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var gameMode = ForceGameMode(settings: AppSettings.shared)
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
                    circleOneProgress: 0,
                    circleOneValue: 0,
                    circleOneLabel: "NA",
                    circleTwoProgress: 0,
                    circleTwoValue: 0,
                    circleTwoLabel: "NA",
//                    circleThreeProgress: 0,
//                    circleThreeValue: 0,
//                    circleThreeLabel: "NA"
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
