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
                
                if lives == 0 {
                    Text("Game Over")
                        .font(.largeTitle.bold())
                        .foregroundColor(settings.secondaryColor)
                    Button(action: { resetGame() }) {
                        Text("Play Again")
                            .font(.title2.bold())
                            .foregroundColor(settings.secondaryColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().stroke(settings.secondaryColor, lineWidth: 2))
                    )
                    .padding(.horizontal)
                }
                Spacer()
                
                if lives > 0 {
                    GeometryReader { geo in
                        let spacing: CGFloat = 8
                        let totalSpacing = spacing * CGFloat(gridSize - 1)
                        let sideLength = (geo.size.width - totalSpacing) / CGFloat(gridSize)
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(sideLength), spacing: spacing), count: gridSize),
                            spacing: spacing
                        ) {
                            ForEach(cards.indices, id: \.self) { index in
                                CardView(
                                    isFaceUp: cards[index].isFaceUp || cards[index].isMatched,
                                    shake: shakeIndex == index
                                )
                                .frame(width: sideLength, height: sideLength)
                                .rotation3DEffect(.degrees(cards[index].isFaceUp || cards[index].isMatched ? 0 : 180), axis: (x:0,y:1,z:0))
                                .scaleEffect(tappedCard == index ? 0.97 : 1)
                                .onTapGesture {
                                    tappedCard = index
                                    tapCard(at: index)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { tappedCard = nil }
                                }
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.width, alignment: .bottom)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .padding()
                    .background(settings.mainColor)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(settings.secondaryColor, lineWidth: 3))
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }
                Spacer(minLength: 16)
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
                    let newScore = max(Int(Double(score) * 0.95), 0)
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

struct Card: Identifiable {
    let id = UUID()
    let isMatch: Bool
    var isFaceUp = false
    var isMatched = false
}

struct CardView: View {
    @EnvironmentObject private var settings: AppSettings
    var isFaceUp: Bool
    var shake: Bool

    var body: some View {
        ZStack {
            // Back of the card
            RoundedRectangle(cornerRadius: 20)
                .fill(settings.secondaryColor)
                .opacity(isFaceUp ? 0 : 1)

            // Front of the card
            RoundedRectangle(cornerRadius: 20)
                .fill(settings.mainColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(settings.secondaryColor, lineWidth: 1)
                )
                .opacity(isFaceUp ? 1 : 0)
        }
        .rotation3DEffect(
            .degrees(isFaceUp ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.4), value: isFaceUp)
        .modifier(Shake(animatableData: shake ? 1 : 0))
        .animation(shake ? .default : .none, value: shake)
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
