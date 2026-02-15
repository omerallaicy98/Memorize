import SwiftUI
import Combine

final class RecallGameMode: ObservableObject {
    @Published var cards: [Card] = []
    @Published var gridSize: Int = 0
    @Published var canTap: Bool = false
    @Published var lives: Int = 0
    @Published var score: Int = 0
    @Published var level: Int = 0
    @Published var previewTime: TimeInterval = 0
    @Published var matchingCardsCount: Int = 0
    @Published var showTimer: Bool = false
    
    @Published var isPreviewing: Bool = false
    @Published var isLevelComplete: Bool = false
    
    @Published var totalSequenceCardsForLevel: Int = 0
    @Published var repetitionsLeft: Int = 0
    @Published public var totalRepetitions: Int = 3
    private var sequence: [Int] = []
    private var currentSequenceIndex: Int = 0
    
    var settings: AppSettings
    init(settings: AppSettings) { self.settings = settings }
    
    func startGame() {
        level = settings.currentRecallLevel
        lives = 3
        previewTime = 0.6
        setupLevel()
    }
    
    func resetGame() {
        level = settings.currentRecallLevel
        lives = 3
        previewTime = 0.6
        setupLevel()
    }
    
    private func finishGame() {
        settings.incrementRecallLevel()
    }
    
    private func setupLevel() {
        isLevelComplete = false
        currentSequenceIndex = 0
        gridSize = settings.getGridSizeForLevel(level)
        let matching = settings.getMatchingCards(for: level)
        matchingCardsCount = matching
        totalSequenceCardsForLevel = matching
        repetitionsLeft = totalRepetitions
        let totalCards = gridSize * gridSize
        cards = (0..<totalCards).map { _ in Card(isMatch: true, remainingTime: previewTime, remainingTaps: 0) }
        generateSequence(count: matchingCardsCount)
        previewSequence()
    }
    
    private func generateSequence(count: Int) {
        let totalCards = gridSize * gridSize
        let maxSequenceLength = min(gridSize + 3, 9)
        
        var tempSequence: [Int] = []
        var remaining = count
        while remaining > 0 {
            let currentChunk = min(maxSequenceLength, remaining)
            let chunk = (0..<totalCards).shuffled().prefix(currentChunk)
            tempSequence.append(contentsOf: chunk)
            remaining -= currentChunk
        }
        sequence = tempSequence
    }
    
    private func previewSequence() {
        isPreviewing = true
        canTap = false
        for index in cards.indices {
            cards[index].remainingTime = 0
        }
        
        var delay = 0.0
        for seqIndex in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.cards[seqIndex].isFaceUp = true
                self.cards[seqIndex].remainingTime = self.previewTime
            }
            delay += previewTime
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.cards[seqIndex].isFaceUp = false
                self.cards[seqIndex].remainingTime = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.isPreviewing = false
            self.canTap = true
        }
    }
    
    func tapCard(at index: Int) {
        guard !isPreviewing else { return }
        guard canTap else { return }
        guard !isLevelComplete else { return }
        guard index >= 0 && index < cards.count else { return }
        
        if index == sequence[currentSequenceIndex] {
            cards[index].isFaceUp = true
            currentSequenceIndex += 1
            if currentSequenceIndex == sequence.count {
                isLevelComplete = true
                canTap = false
                repetitionsLeft -= 1
                
                previewTime -= 0.1
                
                if repetitionsLeft == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.finishGame()
                    }
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.setupLevel()
                    }
                }
            }
        } else {
            lives -= 1
            if lives <= 0 {
                canTap = false
            }
        }
    }
}
