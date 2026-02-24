import SwiftUI
import Combine

final class OrderGameMode: ObservableObject {
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
    
    private func sequenceLengthForLevel(_ level: Int) -> Int {
        let grid = gridSizeForLevel(level)
        let target = 3 + Double(level - 1) * 0.1 + sin(Double(level) * 0.25) * 2.5
        
        // Stronger scaling factor to avoid being stuck at 2
        let scaled = target * 0.6
        
        // Wave-influenced base growth
        let raw = scaled + Double(grid - 1)
        
        let length = Int(round(raw))
        
        // Clamp relative to grid size so it feels progressive
        let maxLength = min(grid * 2, 10)
        
        return min(max(length, 2), maxLength)
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
        currentMatchIndex = 0
        resetMatches()
        generateMatches()
        previewMatches()
    }
    
    private func resetMatches() {
        for index in cards.indices {
            cards[index].isMatch = false
            cards[index].isMatched = false
            cards[index].isFaceUp = false
            cards[index].remainingTime = 0
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

        // Ensure clean visual state before preview starts
        for index in cards.indices {
            cards[index].isFaceUp = false
            cards[index].remainingTime = 0
        }

        var delay: Double = 0.0
        let singleStep = previewDuration

        for index in sequence {
            let idx = index

            // Flip up
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.cards[idx].remainingTime = singleStep
                self.cards[idx].isFaceUp = true
            }

            // Flip down AFTER full preview duration
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + singleStep) {
                self.cards[idx].isFaceUp = false
            }

            // Move delay forward by full up+down cycle
            delay += singleStep
        }

        // Enable tapping only after entire preview fully finishes
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
        currentMatchIndex += 1
        
        if currentMatchIndex == sequence.count {
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
                    self.currentRound += 1
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
