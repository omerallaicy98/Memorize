import SwiftUI
import Combine

struct EndlessGameView: View {
    @State private var showNewView = false
    @State private var isLoading = true
    @State private var cards = [Card]()
    @State private var selectedIndices = [Int]()
    @State private var canTap = false
    @State private var isClear = false
    @State private var tappedCard: Int?
    @State private var lives = 3
    @State private var startTime: Date?
    @State private var score = 0
    @State private var animatedScore = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var level = 1
    @State private var previewTime: TimeInterval = 1.5
    @State private var matchingCardsCount = 2
    @State private var shakeIndex: Int?
    @State private var showingSettings = false
    @State private var gridSize = 2
    @State private var lastRoundMatchPositions: Set<Int> = []
    @State private var scoreDecayCancellable: AnyCancellable?
    @EnvironmentObject var settings: AppSettings

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
                HStack(alignment: .top) {
                    ControlsButtonsView(
                        onHome: { showNewView = true},
                        onRestart: { resetGame() }
                    )
                    Spacer()
                    
                    LivesSubView(lives: $lives, maxLives: 3)
                    Spacer()
                    
                    SettingsButtonsView()
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                
                VStack(alignment: .center) {
                    EndlessScoreView(Score: $animatedScore)
                    EndlessProgressView(previewTime: $previewTime, level: $level, matchingCardsCount: $matchingCardsCount)
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                
                VStack {
                    if lives > 0 {
                        GameGridView(
                            cards: $cards,
                            canTap: $canTap,
                            tappedCard: $tappedCard,
                            shakeIndex: $shakeIndex,
                            gridSize: gridSize,
                            onTapCard: { index in
                                tapCard(at: index)
                            }
                        )
                    }
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
            }
            .padding()
            .background(settings.mainColor)
            .animation(.easeInOut(duration: 0.3), value: settings.secondaryColor)
            .onAppear {
                animatedScore = score
                startGame()
                startScoreDecay()
            }
        }
    }


    func resetGame() {
        lives = 3
        level = 1
        score = 0
        animatedScore = 0
        isClear = false
        selectedIndices.removeAll()
        elapsedTime = 0
        startTime = nil
        timerCancellable?.cancel()
        scoreDecayCancellable?.cancel()
        previewTime = 1.5
        matchingCardsCount = 2
        startGame()
        startScoreDecay()
    }

    func startScoreDecay() {
        scoreDecayCancellable?.cancel()
        scoreDecayCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if score > 0 {
                    let newScore = max(Int(Double(score) * 0.97), 0)
                    withAnimation(.easeOut(duration: 0.5)) {
                        score = newScore
                        animatedScore = newScore
                    }
                }
            }
    }

    func tapCard(at index: Int) {
        guard canTap, !cards[index].isMatched, !selectedIndices.contains(index) else { return }
        cards[index].isFaceUp = true
        selectedIndices.append(index)

        if !cards[index].isMatch {
            canTap = false
            shakeIndex = index
            if settings.isHapticsOn { UINotificationFeedbackGenerator().notificationOccurred(.error) }
            withAnimation{
                lives -= 1
            }
            if lives == 0 { timerCancellable?.cancel(); scoreDecayCancellable?.cancel() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                cards[index].isFaceUp = false
                shakeIndex = nil
                selectedIndices.removeAll()
                canTap = lives > 0 && !isClear
            }
            return
        }

        if selectedIndices.count == matchingCardsCount {
            canTap = false
            if selectedIndices.allSatisfy({ cards[$0].isMatch }) {
                for idx in selectedIndices { cards[idx].isMatched = true }
                isClear = true
                if settings.isHapticsOn, let lastIndex = selectedIndices.last {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                let previewFactor = Int(10 / previewTime)
                let calculatedScore = level * matchingCardsCount * previewFactor
                let newScore = score + calculatedScore
                withAnimation(.easeOut(duration: 0.6)) { animatedScore = newScore }
                score = newScore
                timerCancellable?.cancel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    level += 1
                    startGame()
                }
            } else {
                lives -= 1
                if lives == 0 { timerCancellable?.cancel(); scoreDecayCancellable?.cancel() }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for idx in selectedIndices where !cards[idx].isMatched { cards[idx].isFaceUp = false }
                selectedIndices.removeAll()
                canTap = lives > 0 && !isClear
            }
        }
    }

    func startGame() {
        isClear = false
        selectedIndices.removeAll()
        elapsedTime = 0
        startTime = Date()
        if level <= 2 { gridSize = 2 }
        else if level <= 8 { gridSize = 3 }
        else if level <= 14 { gridSize = 4 }
        else if level <= 24 { gridSize = 5 }
        else { gridSize = 6 }

        matchingCardsCount = min(15, 1 + (level-1)/2)
        previewTime = max(0.5, 0.8 - Double(level-1)*0.01)

        timerCancellable?.cancel()
        let totalCards = gridSize * gridSize
        var values = Array(repeating: false, count: totalCards)
        var matchPositions = Set<Int>()
        let availablePositions = Set(0..<totalCards).subtracting(lastRoundMatchPositions)
        while matchPositions.count < matchingCardsCount && matchPositions.count < availablePositions.count {
            if let randomPos = availablePositions.randomElement() {
                matchPositions.insert(randomPos)
            }
        }
        for pos in matchPositions { values[pos] = true }
        lastRoundMatchPositions = matchPositions
        cards = values.map { Card(isMatch: $0) }
        canTap = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for pos in matchPositions { cards[pos].isFaceUp = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 + previewTime) {
            for i in cards.indices { cards[i].isFaceUp = false }
            canTap = true
        }
    }
}

struct Shake: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        let shakes = 7
        let amplitude: CGFloat = 22 // increased amplitude for better visibility
        let translation = amplitude * sin(animatableData * .pi * CGFloat(shakes))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
