import SwiftUI
import Combine

final class StrengthGameMode: ObservableObject {

    @Published var cards: [Card] = []
    @Published var gridSize: Int = 0
    @Published var canTap: Bool = false

    @Published var lives: Int = 3
    @Published var score: Int = 0
    @Published var level: Int = 0

    @Published var previewTime: TimeInterval = 0
    @Published var matchingCardsCount: Int = 0

    @Published var totalRequiredTiles: Int = 0

    @Published private(set) var activeTiles: [Int: Int] = [:]

    private var tileTimers: [Int: TimeInterval] = [:]

    private var timerCancellable: AnyCancellable?
    private let tickInterval: TimeInterval = 0.05

    let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    func startGame() {
        level = settings.currentStrengthLevel
        setupLevel()
    }

    func resetGame() {
        level = settings.currentStrengthLevel
        setupLevel()
    }

    private func setupLevel() {
        stopTimer()

        lives = 3
        canTap = true

        gridSize = gridSizeForLevel(level)

        let totalTiles = gridSize * gridSize
        totalRequiredTiles = requiredTilesForLevel(level, totalTiles: totalTiles)
        matchingCardsCount = totalRequiredTiles

        cards = (0..<totalTiles).map { _ in
            Card(isMatch: false, remainingTime: 0, remainingTaps: 0)
        }

        activeTiles.removeAll()
        tileTimers.removeAll()

        startTimer()
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

    private func tick() {
        guard canTap else { return }

        for (index, time) in tileTimers {
            let newTime = time - tickInterval
            tileTimers[index] = newTime
            cards[index].remainingTime = max(newTime, 0)

            if newTime <= 0 {
                deactivateTile(at: index, cleared: false)
            }
        }

        spawnTilesIfNeeded()
    }

    private func spawnTilesIfNeeded() {
        let maxSimultaneous = maxActiveTilesForLevel(level)

        guard activeTiles.count < maxSimultaneous else { return }

        let availableIndices = cards.indices.filter {
            activeTiles[$0] == nil
        }

        guard let index = availableIndices.randomElement() else { return }

        activateTile(at: index)
    }

    private func activateTile(at index: Int) {
        let taps = tapCountForLevel(level)
        let lifetime = Double(taps)

        activeTiles[index] = taps
        tileTimers[index] = lifetime

        cards[index].remainingTime = lifetime
        cards[index].remainingTaps = taps
        cards[index].isMatch = true
    }

    private func deactivateTile(at index: Int, cleared: Bool) {
        activeTiles[index] = nil
        tileTimers[index] = nil

        cards[index].remainingTime = 0
        cards[index].remainingTaps = 0
        cards[index].isMatch = false

        if cleared {
            matchingCardsCount -= 1
            if matchingCardsCount <= 0 {
                levelCleared()
            }
        }
    }
    
    func tapCard(at index: Int) {
        guard canTap else { return }
        guard index >= 0 && index < cards.count else { return }

        guard let remainingTaps = activeTiles[index] else {
            lives -= 1
            if lives <= 0 {
                gameOver()
            }
            return
        }

        let newTaps = remainingTaps - 1
        activeTiles[index] = newTaps
        cards[index].remainingTaps = newTaps

        if newTaps <= 0 {
            deactivateTile(at: index, cleared: true)
        }
    }

    private func levelCleared() {
        canTap = false
        stopTimer()
        settings.incrementStrengthLevel()
    }

    private func gameOver() {
        canTap = false
        lives = 0
        stopTimer()
    }

    private func gridSizeForLevel(_ level: Int) -> Int {
        switch level {
        case 1...9: return 2
        case 10...33: return 3
        case 34...78: return 4
        case 79...150: return 5
        default: return 6
        }
    }

    private func tapCountForLevel(_ level: Int) -> Int {
        return min(2 + level / 15, 8)
    }

    private func requiredTilesForLevel(_ level: Int, totalTiles: Int) -> Int {
        let percentage = min(0.4 + Double(level) * 0.003, 0.8)
        return Int(Double(totalTiles) * percentage)
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
