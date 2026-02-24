import SwiftUI
import Combine

final class RecallGameMode: ObservableObject {
    @Published var level: Int = 1
    @Published var gridSize: Int = 2
    @Published var cards: [Card] = []
    @Published var currentRound: Int = 1
    @Published var totalRounds: Int = 1
    @Published var currentMatchIndex: Int = 0
    @Published var sequenceLength: Int = 2
    @Published var lives: Int = 3
    @Published var canTap: Bool = false
    @Published var previewDuration: Double = 0.5
    @Published var isLevelPassed: Bool = false
    @Published var isLevelFailed: Bool = false
    @Published private(set) var sequence: [Int] = []
    
    
    private func gridSizeForLevel(_ level: Int) -> Int {
        if level < 10 { return 2 }
        if level < 25 { return 3 }
        if level < 75 { return 4 }
        if level < 150 { return 5 }
        if level < 250 { return 6 }
        return 6
    }
    
    private func baseDifficulty(_ level: Int) -> Double {
        3 + Double(level - 1) * 0.1
    }
    
    private func waveAdjustment(_ level: Int) -> Double {
        sin(Double(level) * 0.25) * 2.5
    }
    
    private func targetDifficulty(_ level: Int) -> Double {
        baseDifficulty(level) + waveAdjustment(level)
    }
    
    private func sequenceLengthForLevel(_ level: Int) -> Int {
        let grid = gridSizeForLevel(level)
        let target = targetDifficulty(level)
        let gridComponent = Double(grid * grid) * 0.35
        let raw = (target - gridComponent) / 1.5
        let length = Int(round(raw))
        return min(max(length, 2), 10)
    }
    
    private func roundsForGridSize(_ grid: Int) -> Int {
        min(grid, 4)
    }
    
    
    func startGame(_ level: Int) {
        self.level = level
        lives = 3
        currentRound = 1
        gridSize = gridSizeForLevel(level)
        totalRounds = roundsForGridSize(gridSize)
        sequenceLength = sequenceLengthForLevel(level)
        setupCards()
        startRound()
    }
    
    private func setupCards() {
        let total = gridSize * gridSize
        cards = (0..<total).map { _ in
            Card()
        }
    }
    
    private func startRound() {
        currentMatchIndex = sequenceLength - 1
        resetMatches()
        generateMatches()
        previewMatches()
    }
    
    private func resetMatches() {
        for index in cards.indices {
            cards[index].isMatch = false
            cards[index].isMatched = false
        }
    }
    
    private func generateMatches() {
        let total = cards.count
        sequence = Array((0..<total).shuffled().prefix(sequenceLength))
        for index in sequence {
            cards[index].isMatch = true
        }
    }
    
    private func previewMatches() {
        canTap = false
        
        var delay: Double = self.previewDuration
        
        for index in sequence {
            let idx = index
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.cards[idx].remainingTime = self.previewDuration
                self.cards[idx].isFaceUp = true
            }
            
            delay += self.previewDuration
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.cards[idx].isFaceUp = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.canTap = true
        }
    }
    
    
    func handleTap(on card: Card) {
        guard canTap else { return }
        guard let index = indexOfCard(card) else { return }
        
        let expectedIndex = sequence[currentMatchIndex]
        
        if index != expectedIndex {
            lives -= 1
            if lives <= 0 {
                isLevelFailed = true
            }
            return
        }
        
        cards[index].isMatched = true
        cards[index].isFaceUp = true
        currentMatchIndex -= 1
        
        if currentMatchIndex == -1 {
            canTap = false
            
            var delay: Double = 0.0
            let flipDuration: Double = 0.3
            
            // Let last card fully finish its selection animation first
            delay += flipDuration
            
            // Now flip all matched cards back smoothly
            for idx in sequence {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.cards[idx].isFaceUp = false
                }
                delay += flipDuration
            }
            
            // Move to next round AFTER all flips finish
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if self.currentRound == self.totalRounds {
                    self.isLevelPassed = true
                }
                else {
                    self.currentRound += 1
                    self.startRound()
                }
            }
        }
    }
    
    func indexOfCard(_ card: Card) -> Int? {
        cards.firstIndex { $0.id == card.id }
    }
}
