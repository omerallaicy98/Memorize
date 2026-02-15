import SwiftUI
import Combine

final class SpeedGameMode: ObservableObject {
    @Published var cards: [Card] = []
    @Published var gridSize: Int = 0
    @Published var canTap: Bool = false

    @Published var lives: Int = 3
    @Published var level: Int = 0
    
    @Published var totalTime: TimeInterval = 0
    @Published var remainingTime: TimeInterval = 0
    @Published var totalMatchingCards: Int = 0
    @Published var remainingMatchingCards: Int = 0
    
    @Published private(set) var activeTileTimers: [Int: TimeInterval] = [:]
    private var timerCancellable: AnyCancellable?
    private let tickInterval: TimeInterval = 0.05
    private let tileTimerDuration: TimeInterval = 1.0
    private let maxLevel = 250

    let settings: AppSettings
    init(settings: AppSettings) {
        self.settings = settings
    }
    
    func tapCard(at index: Int) {
        guard canTap else { return }
        guard index >= 0 && index < cards.count else { return }
        let wasCorrect = activeTileTimers[index] != nil

        if settings.isHapticsOn {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(wasCorrect ? .success : .error)
        }
        
        if activeTileTimers[index] != nil {
            deactivateTile(at: index)
            remainingMatchingCards -= 1

            if remainingMatchingCards <= 0 {
                levelCleared()
            }
        }
        else {
            lives -= 1
            if lives <= 0 {
                gameOver()
            }
        }
    }
    
    func startGame() {
        level = settings.currentRushLevel
        setupLevel()
    }

    func resetGame() {
        level = settings.currentRushLevel
        setupLevel()
    }
    
    private func gameOver() {
        canTap = false
        lives = 0
        stopTimer()
    }
    
    private func matchingCardsForLevel(_ level: Int, gridSize: Int) -> Int {
        let base = gridSize
        let increment = level / 20
        return min(base + increment, gridSize * 2)
    }
    
    private func setupLevel() {
        stopTimer()

        lives = 3
        canTap = true

        gridSize = settings.getGridSizeForLevel(level)
        remainingMatchingCards = matchingCardsForLevel(level, gridSize: gridSize)
        totalMatchingCards = remainingMatchingCards

        remainingTime = Double(remainingMatchingCards) * 0.5
        totalTime = remainingTime

        let totalCards = gridSize * gridSize
        cards = (0..<totalCards).map { _ in
            Card(isMatch: false, remainingTime: 0, remainingTaps: 0)
        }

        activeTileTimers.removeAll()

        startTimer()
    }

    private func tick() {
        guard canTap else { return }

        remainingTime -= tickInterval
        if remainingTime <= 0 {
            gameOver()
            return
        }

        for index in Array(activeTileTimers.keys) {
            guard let time = activeTileTimers[index] else { continue }

            let newTime = time - tickInterval
            activeTileTimers[index] = newTime
            cards[index].remainingTime = max(newTime, 0)

            if newTime <= 0 {
                deactivateTile(at: index)
                lives -= 1
                if lives <= 0 {
                    gameOver()
                    return
                }
            }
        }

        spawnTilesIfNeeded()
    }

    private func spawnTilesIfNeeded() {
        guard activeTileTimers.count < remainingMatchingCards else { return }

        let activeSet = Set(activeTileTimers.keys)
        let availableIndices = cards.indices.filter { !activeSet.contains($0) }

        guard let index = availableIndices.randomElement() else { return }

        activateTile(at: index)
    }

    private func activateTile(at index: Int) {
        activeTileTimers[index] = tileTimerDuration
        cards[index].remainingTime = tileTimerDuration
        cards[index].isMatch = true
    }

    private func deactivateTile(at index: Int) {
        activeTileTimers[index] = nil
        cards[index].isMatch = false
        cards[index].remainingTime = 0
        cards[index].remainingTaps = 0
    }
    
    private func levelCleared() {
        canTap = false
        stopTimer()

        if level < maxLevel {
            settings.incrementRushLevel()
        }
    }
    
    private func startTimer() {
        timerCancellable = Timer
            .publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
