import SwiftUI
import Combine

struct SequnceGameView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var gameMode = SequenceGameMode(settings: AppSettings.shared)
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
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
                .padding()
            } else {
                HomepageView()
            }
        } else {
            VStack(alignment: .center) {
                ControlsView(
                    onHome: {
                        showNewView = true
                    },
                    onRestart: {
                        gameMode.resetGame()
                    },
                    lives: gameMode.lives
                )
                
                SequnceModeProgressView(
                    currentRepetitions: $gameMode.repetitionsLeft,
                    totalRepetitions: $gameMode.totalRepetitions,
                    remainingSequenceCards: $gameMode.matchingCardsCount,
                    totalSequenceCards: $gameMode.totalSequenceCardsForLevel
                )
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight / 4)
                
                if gameMode.lives > 0 {
                    GridView(
                        cards: gameMode.cards,
                        showTimer: false,
                        gridSize: gameMode.gridSize,
                        canTap: gameMode.canTap,
                        onTapCard: { index in
                            gameMode.tapCard(at: index)
                            
                            if settings.isHapticsOn {
                                let generator = UINotificationFeedbackGenerator()
                                if gameMode.cards[index].isMatch {
                                    let allMatched = gameMode.cards.filter { $0.isMatch }.allSatisfy { $0.isMatched }
                                    if allMatched {
                                        generator.notificationOccurred(.success)
                                    }
                                } else {
                                    generator.notificationOccurred(.error)
                                }
                            }
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
