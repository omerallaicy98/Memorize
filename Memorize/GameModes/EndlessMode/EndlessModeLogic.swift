import SwiftUI
import Combine

final class EndlessGameMode: ObservableObject {
    
    @Published var cards: [Card] = []
    @Published var gridSize: Int = 2
    @Published var canTap: Bool = false
    
    @Published var lives: Int = 3
    @Published var score: Int = 0
    @Published var level: Int = 1
    
    @Published var previewTime: TimeInterval = 1.5
    @Published var matchingCardsCount: Int = 2
    @Published var showTimer: Bool = false
    
    private var isClear: Bool = false
    private var selectedIndices: [Int] = []
    private var elapsedTime: TimeInterval = 0
    private var startTime: Date? = nil
    private var lastRoundMatchPositions: Set<Int> = []
    private var timerCancellable: AnyCancellable? = nil

    private func gridSizeForLevel(_ level: Int) -> Int {
        if level < 2 { return 2 }
        if level < 8 { return 3 }
        if level < 14 { return 4 }
        if level < 24 { return 5 }
        return 6
    }
    
    
    func startGame() {
        isClear = false
        selectedIndices.removeAll()
        elapsedTime = 0
        startTime = Date()
        gridSize = gridSizeForLevel(level)

        matchingCardsCount = min(15, 1 + (level-1)/2)
        previewTime = 0.5

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
        cards = values.map { Card(isMatch: $0, remainingTime: previewTime, remainingTaps: 0) }
        canTap = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for pos in matchPositions { self.cards[pos].isFaceUp = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 + previewTime) {
            for i in self.cards.indices { self.cards[i].isFaceUp = false }
            self.canTap = true
        }
    }
    
    
    func resetGame() {
        lives = 3
        level = 1
        score = 0
        isClear = false
        selectedIndices.removeAll()
        elapsedTime = 0
        startTime = nil
        timerCancellable?.cancel()
        previewTime = 1.5
        matchingCardsCount = 2
        startGame()
    }

    func tapCard(at index: Int) {
        guard canTap, !cards[index].isMatched, !selectedIndices.contains(index) else { return }
        cards[index].isFaceUp = true
        selectedIndices.append(index)

        if !cards[index].isMatch {
            canTap = false
            lives -= 1
            if lives == 0 { timerCancellable?.cancel() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.cards[index].isFaceUp = false
                self.selectedIndices.removeAll()
                self.canTap = self.lives > 0 && !self.isClear
            }
            return
        }

        cards[index].isMatched = true
        selectedIndices.removeAll()

        let matchedCount = cards.filter { $0.isMatched }.count
        if matchedCount == matchingCardsCount {
            canTap = false
            isClear = true
            let previewFactor = Int(10 / previewTime)
            let calculatedScore = level * matchingCardsCount * previewFactor
            score += calculatedScore
            timerCancellable?.cancel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.level = min(self.level + 1, 30)
                self.startGame()
            }
        }
    }
}
