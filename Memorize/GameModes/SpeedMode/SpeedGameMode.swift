import SwiftUI
import Combine

final class SpeedGameMode: ObservableObject {

    // MARK: - GameMode conformance
    @Published var cards: [Card] = []
    @Published var gridSize: Int = 0
    @Published var canTap: Bool = false

    @Published var lives: Int = 3
    @Published var score: Int = 0
    @Published var level: Int = 0

    @Published var previewTime: TimeInterval = 0
    @Published var matchingCardsCount: Int = 0
    @Published var initialMatchingCardsCount: Int = 0
    @Published var levelTotalTime: TimeInterval = 0
    @Published var showTimer: Bool = true

    // MARK: - Speed mode state
    @Published var levelTimeRemaining: TimeInterval = 0
    @Published private(set) var activeTileTimers: [Int: TimeInterval] = [:]

    private var timerCancellable: AnyCancellable?
    private let tickInterval: TimeInterval = 0.05
    private let tileTimerDuration: TimeInterval = 1.0
    private let maxLevel = 250

    let settings: AppSettings

    // MARK: - Init
    init(settings: AppSettings) {
        self.settings = settings
    }

    // MARK: - Lifecycle
    func startGame() {
        level = settings.currentSpeedLevel
        setupLevel()
    }

    func resetGame() {
        level = settings.currentSpeedLevel
        setupLevel()
    }

    // MARK: - Level setup
    private func setupLevel() {
        stopTimer()

        lives = 3
        canTap = true

        gridSize = gridSizeForLevel(level)
        matchingCardsCount = matchingCardsForLevel(level, gridSize: gridSize)
        initialMatchingCardsCount = matchingCardsCount

        levelTimeRemaining = levelTimerForLevel(level, matches: matchingCardsCount)
        levelTotalTime = levelTimeRemaining

        let totalCards = gridSize * gridSize
        cards = (0..<totalCards).map { _ in
            Card(isMatch: false, remainingTime: 0, remainingTaps: 0)
        }

        activeTileTimers.removeAll()

        startTimer()
    }

    // MARK: - Timer loop
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

    private func tick() {
        guard canTap else { return }

        // Level timer
        levelTimeRemaining -= tickInterval
        if levelTimeRemaining <= 0 {
            gameOver()
            return
        }

        // Tile timers
        for (index, time) in activeTileTimers {
            let newTime = time - tickInterval
            activeTileTimers[index] = newTime
            cards[index].remainingTime = max(newTime, 0)

            if newTime <= 0 {
                deactivateTile(at: index)
            }
        }

        spawnTilesIfNeeded()
    }

    // MARK: - Tile activation
    private func spawnTilesIfNeeded() {
        let maxSimultaneous = maxActiveTilesForLevel(level)

        guard activeTileTimers.count < maxSimultaneous else { return }

        let availableIndices = cards.indices.filter {
            !activeTileTimers.keys.contains($0)
        }

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

    // MARK: - User interaction
    func tapCard(at index: Int) {
        guard canTap else { return }
        guard index >= 0 && index < cards.count else { return }

        if activeTileTimers[index] != nil {
            // Correct tap
            deactivateTile(at: index)
            matchingCardsCount -= 1

            if matchingCardsCount <= 0 {
                levelCleared()
            }
        } else {
            // Wrong tap
            lives -= 1
            if lives <= 0 {
                gameOver()
            }
        }
    }

    // MARK: - End states
    private func levelCleared() {
        canTap = false
        stopTimer()

        if level < maxLevel {
            settings.incrementSpeedLevel()
        }
    }

    private func gameOver() {
        canTap = false
        lives = 0
        stopTimer()
    }

    // MARK: - Difficulty logic
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

    private func matchingCardsForLevel(_ level: Int, gridSize: Int) -> Int {
        let base = gridSize
        let increment = level / 20
        return min(base + increment, gridSize * 2)
    }

    private func levelTimerForLevel(_ level: Int, matches: Int) -> TimeInterval {
        let base = Double(matches) * 1.8
        let pressure = Double(maxActiveTilesForLevel(level)) * 1.2
        let buffer = max(2.0, 5.0 - Double(level) * 0.02)
        return base + pressure + buffer
    }

    private func maxActiveTilesForLevel(_ level: Int) -> Int {
        switch level {
        case 1...20: return 1
        case 21...60: return 2
        case 61...120: return 3
        default: return 4
        }
    }
}
