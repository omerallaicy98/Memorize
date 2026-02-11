import SwiftUI
import Combine

struct EndlessGameView: View {
    @State private var showNewView = false
    @State private var isLoading = true
    
    @State private var animatedScore = 0
    @State private var scoreDecayCancellable: AnyCancellable?
    
    @EnvironmentObject var settings: AppSettings
    @StateObject private var gameMode = EndlessGameMode()
    
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
                                gameMode.resetGame()
                                startScoreDecay() }
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
                    EndlessScoreView(Score: $animatedScore)
                    EndlessProgressView(previewTime: $gameMode.previewTime, level: $gameMode.level, matchingCardsCount: $gameMode.matchingCardsCount)
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                
                if gameMode.lives > 0 {
                    GameGridView(
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
                    .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
                }else{
                    settings.mainColor
                            .ignoresSafeArea()
                            .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
                    
                }
            }
            .padding()
            .onAppear {
                animatedScore = gameMode.score
                gameMode.startGame()
                startScoreDecay()
            }
            .onChange(of: gameMode.score) { newScore in
                withAnimation(.easeOut(duration: 0.5)) {
                    animatedScore = newScore
                }
            }
            .onChange(of: gameMode.lives) { newLives in
                if newLives <= 0 {
                    scoreDecayCancellable?.cancel()
                }
            }
            .onChange(of: gameMode.lives) { newLives in
                if newLives == 3 {
                    startScoreDecay()
                }
            }
        }
    }

    func startScoreDecay() {
        scoreDecayCancellable?.cancel()
        scoreDecayCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if gameMode.lives <= 0 {
                    scoreDecayCancellable?.cancel()
                    return
                }
                if gameMode.score > 0 {
                    let newScore = max(Int(Double(gameMode.score) * 0.97), 0)
                    withAnimation(.easeOut(duration: 0.5)) {
                        gameMode.score = newScore
                        animatedScore = newScore
                    }
                }
            }
    }
}
