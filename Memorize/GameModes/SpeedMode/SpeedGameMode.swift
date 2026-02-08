import SwiftUI
import Combine

final class SpeedGameMode: ObservableObject, GameMode {
    @Published var cards: [Card] = []
    @Published var gridSize: Int = 0
    @Published var canTap: Bool = false
    @Published var lives: Int = 0
    @Published var score: Int = 0
    @Published var level: Int = 0
    @Published var previewTime: TimeInterval = 0
    @Published var matchingCardsCount: Int = 0
    @Published var showTimer: Bool = true
    @Published private(set) var cardTimers: [Int: TimeInterval] = [:]

    private var timerCancellable: AnyCancellable?
    private var repetitions: Int = 0
    private let maxLevel: Int = 250

    let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    func startGame() {
        level = settings.currentSpeedLevel
        resetCommonState()
        setupLevel()
    }

    func resetGame() {
        level = settings.currentSpeedLevel
        resetCommonState()
        setupLevel()
    }

    private func resetCommonState() {
        lives = 3
        score = 0
        previewTime = 0
        repetitions = 3
        canTap = false
        stopTimer()
    }

    // MARK: - Level setup
    private func setupLevel() {
        stopTimer()
        canTap = false

        gridSize = gridSizeForLevel(level)
        matchingCardsCount = matchingCardsCountForLevel(level, gridSize: gridSize)

        let totalCards = gridSize * gridSize
        cards = (0..<totalCards).map { _ in
            Card(value: nil, isMatch: false)
        }

        let matchIndices = (0..<totalCards).shuffled().prefix(matchingCardsCount)
        for index in matchIndices {
            cards[index].isMatch = true
        }

        generateTimers(for: Array(matchIndices))
        canTap = true
        startTimer()
    }

    // MARK: - Timers
    private func generateTimers(for indices: [Int]) {
        cardTimers.removeAll()

        let totalTime = Double(indices.count) * 2.0   // updated total time
        let minTime: Double = 2.0                     // updated minimum
        let maxTime: Double = 10.0                    // updated maximum

        var weights = indices.map { _ in Double.random(in: 0.5...1.5) }
        let weightSum = weights.reduce(0, +)

        var allocated = weights.map { max(minTime, ($0 / weightSum) * totalTime) }

        for i in allocated.indices {
            allocated[i] = min(allocated[i], maxTime)
        }

        let allocatedSum = allocated.reduce(0, +)
        let correction = totalTime / allocatedSum
        allocated = allocated.map { max(minTime, $0 * correction) }

        for (index, time) in zip(indices, allocated) {
            cardTimers[index] = time
            cards[index].value = time
        }
    }

    private func startTimer() {
        timerCancellable = Timer
            .publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tickTimers()
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func tickTimers() {
        guard canTap else { return }

        for (index, time) in cardTimers {
            guard time > 0 else { continue }
            let newTime = time - 0.05
            cardTimers[index] = newTime
            cards[index].value = max(newTime, 0)

            if newTime <= 0 {
                handleTimerExpired(at: index)
            }
        }
    }

    private func handleTimerExpired(at index: Int) {
        guard cardTimers[index] != nil else { return }
        cardTimers[index] = 0
        cards[index].value = 0
        lives -= 1

        if lives <= 0 {
            canTap = false
            stopTimer()
        }
    }

    // MARK: - User interaction
    func tapCard(at index: Int) {
        guard canTap else { return }
        guard index >= 0 && index < cards.count else { return }

        if cards[index].isMatch {
            cards[index].isMatched = true
            cards[index].isFaceUp = true
            cardTimers[index] = nil

            if cardTimers.isEmpty {
                levelCleared()
            }
        } else {
            lives -= 1
            if lives <= 0 {
                canTap = false
                stopTimer()
            }
        }
    }

    // MARK: - Progression
    private func levelCleared() {
        canTap = false
        stopTimer()
        repetitions -= 1

        if repetitions <= 0 {
            if level <= maxLevel {
                settings.incrementSpeedLevel()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.setupLevel()
            }
        }
    }

    // MARK: - Level math (mirrors Sequence mode)
    private func gridSizeForLevel(_ level: Int) -> Int {
        switch level {
        case 1...9: return 2
        case 10...33: return 3
        case 34...78: return 4
        case 79...150: return 5
        case 151...250: return 6
        default: return 6
        }
    }

    private func matchingCardsCountForLevel(_ level: Int, gridSize: Int) -> Int {
        let baseCount = 2
        let maxCount = gridSize * gridSize
        let levelInGrid: Int

        switch gridSize {
        case 2: levelInGrid = level - 1
        case 3: levelInGrid = level - 10
        case 4: levelInGrid = level - 34
        case 5: levelInGrid = level - 79
        case 6: levelInGrid = level - 151
        default: levelInGrid = 0
        }

        let increment = levelInGrid / 3
        return min(baseCount + increment, maxCount)
    }
}
