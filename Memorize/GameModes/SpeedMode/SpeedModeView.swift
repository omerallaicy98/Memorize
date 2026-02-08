import SwiftUI
import Combine

struct SpeedGameView: View {

    @EnvironmentObject var settings: AppSettings
    @StateObject private var gameMode = SpeedGameMode(settings: AppSettings.shared)

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
            VStack(alignment: .leading) {

                // MARK: - Top controls
                VStack {
                    HStack(alignment: .top) {
                        ControlsButtonsView(
                            onHome: { showNewView = true },
                            onRestart: { gameMode.resetGame() }
                        )

                        Spacer()

                        LivesSubView(lives: $gameMode.lives, maxLives: 3)

                        Spacer()

                        SettingsButtonsView()
                    }

                    Spacer()
                }
                .frame(
                    maxWidth: settings.screenWidth,
                    maxHeight: settings.ScreenHeight * 0.25
                )

                // MARK: - Level indicator
                VStack {
                    Text("Level: \(settings.currentSpeedLevel)")
                        .font(.title)
                }
                .frame(
                    maxWidth: settings.screenWidth,
                    maxHeight: settings.ScreenHeight * 0.15
                )

                // MARK: - Game grid
                if gameMode.lives > 0 {
                    GameGridView(
                        cards: $gameMode.cards,
                        canTap: $gameMode.canTap,
                        gridSize: gameMode.gridSize,
                        previewTime: 0,
                        showTimer: gameMode.showTimer,
                        onTapCard: { index in
                            gameMode.tapCard(at: index)

                            if settings.isHapticsOn {
                                let generator = UINotificationFeedbackGenerator()
                                if gameMode.cards[index].isMatch {
                                    generator.notificationOccurred(.success)
                                } else {
                                    generator.notificationOccurred(.error)
                                }
                            }
                        }
                    )
                    .frame(
                        maxWidth: settings.screenWidth,
                        maxHeight: settings.ScreenHeight * 0.5
                    )
                }

                Spacer()
            }
            .padding()
            .onAppear {
                gameMode.startGame()
            }
        }
    }
}
