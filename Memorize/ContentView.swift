// MARK: - Reusable SettingsCircleButton
struct SettingsCircleButton: View {
    let iconName: String
    @Binding var isOn: Bool
    var action: () -> Void
    var settingsCircleFill: Color
    var settingsCircleStroke: Color
    var settingsIconColor: Color

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                if isOn {
                    Circle()
                        .fill(settingsCircleFill)
                        .frame(width: 60, height: 60)
                }
                Circle()
                    .stroke(settingsCircleStroke, lineWidth: 2)
                    .frame(width: 60, height: 60)
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(settingsIconColor)
                    .opacity(isOn ? 1.0 : 0.4)
            }
        }
    }
}

// MARK: - Reusable SettingsPillButton
struct SettingsPillButton: View {
    let iconName: String
    var action: () -> Void
    var settingsCircleStroke: Color

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(height: 54)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(settingsCircleStroke, lineWidth: 2)
                    )
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(settingsCircleStroke)
            }
            .frame(maxWidth: .infinity, minHeight: 54, maxHeight: 54)
            .padding(.horizontal, 10)
        }
    }
}
import SwiftUI
import Combine
import AVFoundation
import AudioToolbox

struct Card: Identifiable {
    let id = UUID()
    let isMatch: Bool
    var isFaceUp = false
    var isMatched = false
}

struct ContentView: View {
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

    @State private var isHapticsOn = true
    @State private var isThemeOn = false
    @State private var isSoundOn: Bool = true

    @State private var gridSize = 2

    // Track last round's match positions to exclude from next round
    @State private var lastRoundMatchPositions: Set<Int> = []


    // Floating multiplier animation state
    @State private var floatingLevelMultipliers: [UUID] = []
    @State private var floatingMatchMultipliers: [UUID] = []
    @State private var floatingPreviewMultipliers: [UUID] = []

    // Score decay timer
    @State private var scoreDecayCancellable: AnyCancellable?

    var body: some View {
        // Theme colors
        let backgroundColor = isThemeOn ? Color.black : Color.white
        let textColor = isThemeOn ? Color.white : Color.black
        let tileFaceDownColor = isThemeOn ? Color.white : Color.black
        let tileFaceUpColor = isThemeOn ? Color.black : Color.white
        let gridFrameColor = isThemeOn ? Color.white : Color.black
        let heartColor = isThemeOn ? Color.white : Color.black
        let circleStrokeColor = isThemeOn ? Color.white : Color.black
        let circleBackgroundStroke = Color.gray.opacity(0.3)
        let settingsIconColor = isThemeOn ? Color.white : Color.black
        let settingsCircleStroke = isThemeOn ? Color.white : Color.black
        let settingsCircleFill = isThemeOn ? Color.white.opacity(0.13) : Color.black.opacity(0.13)

        ZStack {
            VStack(spacing: 24) {
                // Top section: Hearts, Score, Circles (with equal vertical spacing)
                VStack(spacing: 24) {
                    // Top bar: hearts and settings button
                    ZStack {
                        // Centered hearts
                        HStack(spacing: 20) {
                            ForEach(0..<3) { i in
                                Image(systemName: i < lives ? "heart.fill" : "heart")
                                    .foregroundColor(heartColor)
                                    .font(.system(size: 28))
                                    .scaleEffect(i < lives ? 1.1 : 1)
                                    .animation(.easeInOut(duration: 0.25), value: lives)
                            }
                        }

                        // Settings button on the right
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.easeInOut) {
                                    showingSettings = true
                                }
                                playSettingsClickSound()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 48, height: 48)
                                    Circle()
                                        .stroke(settingsCircleStroke, lineWidth: 2)
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "gearshape.fill")
                                        .font(.title2)
                                        .foregroundColor(settingsIconColor)
                                }
                            }
                            .sheet(isPresented: $showingSettings) {
                                ZStack {
                                    // Glassy effect as background for the entire sheet
                                    Color.clear
                                        .background(.ultraThinMaterial)
                                        .ignoresSafeArea()
                                    VStack(spacing: 28) {
                                        Text("Settings")
                                            .font(.title.bold())
                                            .padding(.top)
                                            .foregroundColor(textColor)
                                        // Top row: Sound, Haptics, Theme (reusable)
                                        HStack(spacing: 40) {
                                            SettingsCircleButton(
                                                iconName: "speaker.wave.2.fill",
                                                isOn: $isSoundOn,
                                                action: {
                                                    playSettingsClickSound()
                                                    isSoundOn.toggle()
                                                    UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
                                                },
                                                settingsCircleFill: settingsCircleFill,
                                                settingsCircleStroke: settingsCircleStroke,
                                                settingsIconColor: settingsIconColor
                                            )
                                            SettingsCircleButton(
                                                iconName: "iphone.radiowaves.left.and.right",
                                                isOn: $isHapticsOn,
                                                action: {
                                                    playSettingsClickSound()
                                                    isHapticsOn.toggle()
                                                    UserDefaults.standard.set(isHapticsOn, forKey: "isHapticsOn")
                                                },
                                                settingsCircleFill: settingsCircleFill,
                                                settingsCircleStroke: settingsCircleStroke,
                                                settingsIconColor: settingsIconColor
                                            )
                                            SettingsCircleButton(
                                                iconName: "circle.lefthalf.filled",
                                                isOn: $isThemeOn,
                                                action: {
                                                    playSettingsClickSound()
                                                    withAnimation(.easeInOut) { isThemeOn.toggle() }
                                                },
                                                settingsCircleFill: settingsCircleFill,
                                                settingsCircleStroke: settingsCircleStroke,
                                                settingsIconColor: settingsIconColor
                                            )
                                        }
                                        // Home/Menu button (pill-shaped, reusable)
                                        SettingsPillButton(
                                            iconName: "house.fill",
                                            action: { playSettingsClickSound() },
                                            settingsCircleStroke: settingsCircleStroke
                                        )
                                        // Restart button (pill-shaped, reusable)
                                        SettingsPillButton(
                                            iconName: "arrow.counterclockwise",
                                            action: { playSettingsClickSound(); resetGame() },
                                            settingsCircleStroke: settingsCircleStroke
                                        )
                                        Spacer()
                                    }
                                }
                                .presentationDetents([.fraction(0.5)])
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                    // Score display in the middle
                    Text("\(animatedScore)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.4), value: animatedScore)

                    // HStack of the 3 circles
                    HStack(spacing: 50) {
                        // Preview circle
                        CircleWithMultiplierView(
                            circle: CircleProgressView(
                                progress: (previewTime - 0.5)/0.3,
                                label: "Preview",
                                valueText: String(format: "%.2f", previewTime),
                                textColor: textColor,
                                strokeColor: circleStrokeColor,
                                backgroundStroke: circleBackgroundStroke
                            ),
                            multiplier: "+\(Int(10 / previewTime))",
                            showMultiplier: !floatingPreviewMultipliers.isEmpty,
                            textColor: textColor
                        )
                        // Level circle
                        CircleWithMultiplierView(
                            circle: CircleProgressView(
                                progress: min(Double(level)/30, 1),
                                label: "Level",
                                valueText: "\(level)",
                                textColor: textColor,
                                strokeColor: circleStrokeColor,
                                backgroundStroke: circleBackgroundStroke
                            ),
                            multiplier: "x\(level)",
                            showMultiplier: !floatingLevelMultipliers.isEmpty,
                            textColor: textColor
                        )
                        // Matches circle
                        CircleWithMultiplierView(
                            circle: CircleProgressView(
                                progress: Double(matchingCardsCount)/15,
                                label: "Matches",
                                valueText: "\(matchingCardsCount)",
                                textColor: textColor,
                                strokeColor: circleStrokeColor,
                                backgroundStroke: circleBackgroundStroke
                            ),
                            multiplier: "x\(matchingCardsCount)",
                            showMultiplier: !floatingMatchMultipliers.isEmpty,
                            textColor: textColor
                        )
                    }
                }

                Spacer()

                if lives == 0 {
                    Text("Game Over")
                        .font(.largeTitle.bold())
                        .foregroundColor(textColor)
                    Button(action: {
                        resetGame()  // Countdown will trigger
                    }) {
                        Text("Play Again")
                            .font(.title2.bold())
                            .foregroundColor(isThemeOn ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(isThemeOn ? Color.white : Color.black, lineWidth: 2)
                            )
                    )
                    .padding(.horizontal)
                }

                Spacer()

                if lives > 0 {
                    GeometryReader { geo in
                        let spacing: CGFloat = 8
                        let totalSpacing = spacing * CGFloat(gridSize - 1)
                        let sideLength = (geo.size.width - totalSpacing) / CGFloat(gridSize)
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(sideLength), spacing: spacing), count: gridSize), spacing: spacing) {
                            ForEach(cards.indices, id: \.self) { index in
                                CardView(
                                    isFaceUp: cards[index].isFaceUp || cards[index].isMatched,
                                    shake: shakeIndex == index,
                                    faceUpColor: tileFaceUpColor,
                                    faceDownColor: tileFaceDownColor,
                                    borderColor: gridFrameColor
                                )
                                .frame(width: sideLength, height: sideLength)
                                .rotation3DEffect(.degrees(cards[index].isFaceUp || cards[index].isMatched ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: cards[index].isFaceUp)
                                .scaleEffect(tappedCard == index ? 0.97 : 1)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: tappedCard)
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
                    .background(backgroundColor)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(gridFrameColor, lineWidth: 3))
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }

                Spacer(minLength: 16)
            }
            .padding()
            .background(backgroundColor)
            .animation(.easeInOut(duration: 0.3), value: isThemeOn)
            .onAppear {
                // Load haptics preference from UserDefaults on launch
                if UserDefaults.standard.object(forKey: "isHapticsOn") == nil {
                    UserDefaults.standard.set(true, forKey: "isHapticsOn")
                    isHapticsOn = true
                } else {
                    isHapticsOn = UserDefaults.standard.bool(forKey: "isHapticsOn")
                }
                // Load sound preference from UserDefaults
                if UserDefaults.standard.object(forKey: "isSoundOn") == nil {
                    UserDefaults.standard.set(true, forKey: "isSoundOn")
                    isSoundOn = true
                } else {
                    isSoundOn = UserDefaults.standard.bool(forKey: "isSoundOn")
                }
                animatedScore = score
                startGame()
                startScoreDecay()
            }
            // End of onAppear
        // End of VStack

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

    // MARK: - Score Decay Timer
    func startScoreDecay() {
        scoreDecayCancellable?.cancel()
        scoreDecayCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if score > 0 {
                    let newScore = max(Int(Double(score) * 0.99), 0)
                    withAnimation(.easeOut(duration: 0.5)) {
                        score = newScore
                        animatedScore = newScore
                    }
                }
            }
    }

    func startGame() {
        isClear = false
        selectedIndices.removeAll()
        elapsedTime = 0
        startTime = Date()
        // Set dynamic grid size based on level
        if level <= 2 {
            gridSize = 2
        } else if level <= 8 {
            gridSize = 3
        } else if level <= 14 {
            gridSize = 4
        } else if level <= 24 {
            gridSize = 5
        } else {
            gridSize = 6
        }
        // Set dynamic matches (increase every 2 levels, max 15)
        matchingCardsCount = min(15, 1 + (level - 1) / 2)
        // Set dynamic preview time (0.8 -> 0.5 decrement 0.01 per level)
        previewTime = max(0.5, 0.8 - Double(level - 1) * 0.01)
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if let start = startTime, !isClear, lives > 0 {
                    elapsedTime = Date().timeIntervalSince(start)
                } else {
                    timerCancellable?.cancel()
                }
            }

        // SAFE match position generation excluding previous round
        let totalCards = gridSize * gridSize
        var values = Array(repeating: false, count: totalCards)

        // Pick random unique positions for this round, guaranteed within bounds and not in lastRoundMatchPositions
        var matchPositions = Set<Int>()
        let availablePositions = Set(0..<totalCards).subtracting(lastRoundMatchPositions)

        while matchPositions.count < matchingCardsCount && matchPositions.count < availablePositions.count {
            if let randomPos = availablePositions.randomElement() {
                matchPositions.insert(randomPos)
            }
        }

        // Set matches safely
        for pos in matchPositions { values[pos] = true }

        // Save current round positions for next round
        lastRoundMatchPositions = matchPositions

        // Create the new cards array
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

    func tapCard(at index: Int) {
        guard canTap, !cards[index].isMatched, !selectedIndices.contains(index) else { return }
        cards[index].isFaceUp = true
        selectedIndices.append(index)

        if !cards[index].isMatch {
            canTap = false
            shakeIndex = index
            if isHapticsOn {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
            lives -= 1
            if lives == 0 {
                timerCancellable?.cancel()
                scoreDecayCancellable?.cancel()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                cards[index].isFaceUp = false
                shakeIndex = nil
                selectedIndices.removeAll()
                canTap = lives > 0 && !isClear
            }
            return
        }

        // Only trigger the success haptic when all correct tiles have been tapped (i.e., on last correct tile)
        if selectedIndices.count == matchingCardsCount {
            canTap = false
            if selectedIndices.allSatisfy({ cards[$0].isMatch }) {
                for idx in selectedIndices { cards[idx].isMatched = true }
                isClear = true

                // Trigger haptic only for the last correct tile
                if isHapticsOn {
                    if let lastIndex = selectedIndices.last {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }

                // Trigger floating multiplier animations
                floatingLevelMultipliers.append(UUID())
                floatingMatchMultipliers.append(UUID())
                floatingPreviewMultipliers.append(UUID())
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    if !floatingLevelMultipliers.isEmpty { floatingLevelMultipliers.removeFirst() }
                    if !floatingMatchMultipliers.isEmpty { floatingMatchMultipliers.removeFirst() }
                    if !floatingPreviewMultipliers.isEmpty { floatingPreviewMultipliers.removeFirst() }
                }

                let previewFactor = Int(10 / previewTime)
                let calculatedScore = level * matchingCardsCount * previewFactor
                let newScore = score + calculatedScore

                withAnimation(.easeOut(duration: 0.6)) {
                    animatedScore = newScore
                }
                score = newScore
                timerCancellable?.cancel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    level += 1
                    startGame()
                }
            } else {
                lives -= 1
                if lives == 0 {
                    timerCancellable?.cancel()
                    scoreDecayCancellable?.cancel()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for idx in selectedIndices where !cards[idx].isMatched { cards[idx].isFaceUp = false }
                selectedIndices.removeAll()
                canTap = lives > 0 && !isClear
            }
        }
    }
    // MARK: - Settings Click Sound
    func playSettingsClickSound() {
        // Use the loudest system sound available for a click
        // 1104: Tock, 1057: SMS Received 3, 1007: Key Press Click
        // 1057 is quite loud and clear.
        AudioServicesPlaySystemSound(1104)
    }
}

struct CircleProgressView: View {
    var progress: Double
    var label: String
    var valueText: String? = nil
    var textColor: Color = .black
    var strokeColor: Color = .black
    var backgroundStroke: Color = Color.gray.opacity(0.3)

    @State private var animatedValue: Double = 0

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(backgroundStroke, lineWidth: 4)
                    .frame(width: 60, height: 60)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                // Animate number inside the circle
                if let valueText = valueText {
                    Text(label == "Preview" ? String(format: "%.2f", animatedValue) : String(format: "%.0f", animatedValue))
                        .font(.subheadline.bold())
                        .foregroundColor(textColor)
                        .onAppear { animatedValue = Double(valueText) ?? 0 }
                        .onChange(of: Double(valueText) ?? 0) { newValue in
                            withAnimation(.easeOut(duration: 0.5)) { animatedValue = newValue }
                        }
                }
            }
            Text(label)
                .font(.caption)
                .foregroundColor(textColor.opacity(0.7))
        }
    }
}

struct CardView: View {
    var isFaceUp: Bool
    var shake: Bool
    var faceUpColor: Color = .white
    var faceDownColor: Color = .black
    var borderColor: Color = .black

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isFaceUp ? faceUpColor : faceDownColor)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: isFaceUp ? 1 : 0))
            .modifier(Shake(animatableData: CGFloat(shake ? 1 : 0)))
            .animation(.easeInOut(duration: 0.3), value: isFaceUp)
    }
}

struct Shake: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        let shakes = 5
        let amplitude: CGFloat = 8
        let translation = amplitude * sin(animatableData * .pi * CGFloat(shakes))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// Floating multiplier view for animated floating text above circles
struct FloatingMultiplier: View, Identifiable {
    let id = UUID()
    let text: String
    var body: some View {
        Text(text)
            .font(.caption.bold())
            .foregroundColor(.black)
            .shadow(radius: 2)
    }
}

// Groups a circle and its floating multiplier, keeping the multiplier positioned relative to the circle.
struct CircleWithMultiplierView: View {
    var circle: CircleProgressView
    var multiplier: String?
    var showMultiplier: Bool
    var textColor: Color = .black  // Add dynamic color

    var body: some View {
        ZStack(alignment: .topTrailing) {
            circle
            if showMultiplier, let multiplier = multiplier {
                Text(multiplier)
                    .font(.caption.bold())
                    .foregroundColor(textColor)
                    .opacity(showMultiplier ? 1 : 0)
                    .scaleEffect(showMultiplier ? 1.0 : 0.85)
                    .offset(x: 14, y: showMultiplier ? -18 : -6)
                    .animation(
                        .easeInOut(duration: 0.6).delay(showMultiplier ? 0.05 : 0),
                        value: showMultiplier
                    )
            }
        }
    }
}
