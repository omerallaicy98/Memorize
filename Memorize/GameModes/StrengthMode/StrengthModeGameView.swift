import SwiftUI
import Combine

struct StrengthModeGameView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var gameMode = StrengthGameMode(settings: AppSettings.shared)
    @State private var showNewView = false
    @State private var isLoading = true

    var body: some View {
        if showNewView {
            if isLoading {
                LoadingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + settings.loadingTime) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
            } else {
                HomepageView()
            }
        } else {

            VStack(alignment: .center) {
                
                VStack {
                    HStack(alignment: .top) {

                        ControlsButtonsView(
                            onHome: { showNewView = true },
                            onRestart: { gameMode.resetGame() }
                        )

                        Spacer()

                        LivesSubView(
                            lives: $gameMode.lives,
                            maxLives: 3
                        )

                        Spacer()

                        SettingsButtonsView()
                    }

                    Spacer()
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight / 4)
                
                StrengthModeProgressView(
                    remainingTiles: gameMode.matchingCardsCount,
                    requiredTiles: gameMode.totalRequiredTiles
                )
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight / 4)

                
                if gameMode.lives > 0 {
                    GameGridView(
                        cards: gameMode.cards,
                        showTimer: true,
                        gridSize: gameMode.gridSize,
                        canTap: gameMode.canTap,
                        onTapCard: { index in
                            gameMode.tapCard(at: index)

                            if settings.isHapticsOn {
                                let generator = UINotificationFeedbackGenerator()
                                if gameMode.cards[index].isMatched {
                                    generator.notificationOccurred(.success)
                                } else {
                                    generator.notificationOccurred(.error)
                                }
                            }
                        }
                    )
                }
                Spacer()
            }
            .onAppear {
                gameMode.startGame()
            }
        }
    }
}
