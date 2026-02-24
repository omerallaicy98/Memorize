import SwiftUI
import Combine

struct EndlessGameView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var gameMode = EndlessGameMode()
    @State private var showHomeView = false
    @State private var isLoading = true
    
    @State private var animatedScore = 0
    @State private var scoreDecayCancellable: AnyCancellable?
    
    
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
        else
        {
            VStack(alignment: .center) {
                ControlsView(
                    onHome: {
                        showHomeView = true
                    },
                    onRestart: {
                        gameMode.resetGame()
                        startScoreDecay()
                    },
                    lives: gameMode.lives,
                    level: settings.currentOrderLevel
                )
                
                EndlessScoreView(Score: $animatedScore)
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
                        showTimer: false,
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

struct EndlessScoreView: View {
    @Binding var Score: Int
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        Text("\(Score)")
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .foregroundColor(settings.secondaryColor)
            .contentTransition(.numericText())
    }
}
