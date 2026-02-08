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
            }
            else {
                HomepageView()
            }
        }
        else
        {
            VStack(alignment: .leading) {
                VStack{
                    HStack(alignment: .top) {
                        ControlsButtonsView(
                            onHome: { showNewView = true},
                            onRestart: {
                                gameMode.resetGame()}
                        )
                        Spacer()
                        
                        LivesSubView(lives: $gameMode.lives, maxLives: 3)
                        Spacer()
                        
                        SettingsButtonsView()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                
                VStack(alignment: .center) {
                    Text("Level: \(settings.currentSequenceLevel)")
                                    .font(.title)
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                
                if gameMode.lives > 0 {
                    GameGridView(
                        cards: $gameMode.cards,
                        canTap: $gameMode.canTap,
                        gridSize: gameMode.gridSize,
                        previewTime: gameMode.previewTime,
                        showTimer: gameMode.showTimer,
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
                    .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
                }else{
                    settings.mainColor
                            .ignoresSafeArea()
                            .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
                    
                }
            }
            .padding()
            .background(settings.mainColor)
            .onAppear {
                gameMode.startGame()
            }
        }
    }
}
