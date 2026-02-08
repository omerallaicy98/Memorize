import SwiftUI
import Combine

class SequenceGameMode: ObservableObject, GameMode {
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
    private var repetation: Int = 0
    
    private var maxLevel: Int = 250
    
    var settings: AppSettings
    init(settings: AppSettings) { self.settings = settings }
    
    func startGame() {
        level = settings.currentSequenceLevel
        lives = 3
        previewTime = 0.6
        repetation = 3
        setupLevel()
    }
    
    func resetGame() {
        level = settings.currentSequenceLevel
        lives = 3
        previewTime = 0.6
        repetation = 3
        setupLevel()
    }
    
    private func finishGame() {
        if level <= maxLevel {
            settings.incrementSequnceLevel()
        }
    }
    
    private func setupLevel() {
        isLevelComplete = false
        currentSequenceIndex = 0
        gridSize = gridSizeForLevel(level)
        matchingCardsCount = matchingCardsCountForLevel(level, gridSize: gridSize)
        totalSequenceCardsForLevel = matchingCardsCount
        repetitionsLeft = repetation
        let totalCards = gridSize * gridSize
        cards = (0..<totalCards).map { _ in Card(isMatch: true) }
        generateSequence(count: matchingCardsCount)
        previewSequence()
    }
    
    private func gridSizeForLevel(_ level: Int) -> Int {
        switch level {
        case 1...9:
            return 2
        case 10...33:
            return 3
        case 34...78:
            return 4
        case 79...150:
            return 5
        case 151...250:
            return 6
        default:
            return 6
        }
    }
    
    private func matchingCardsCountForLevel(_ level: Int, gridSize: Int) -> Int {
        let baseCount = 2
        let maxCount = gridSize * gridSize
        let levelInGrid: Int
        
        switch gridSize {
        case 2:
            levelInGrid = level - 1
        case 3:
            levelInGrid = level - 10
        case 4:
            levelInGrid = level - 34
        case 5:
            levelInGrid = level - 79
        case 6:
            levelInGrid = level - 151
        default:
            levelInGrid = 0
        }
        
        let increment = levelInGrid / 3
        return min(baseCount + increment, maxCount)
    }
    
    private func generateSequence(count: Int) {
        let totalCards = gridSize * gridSize
        sequence = (0..<totalCards).shuffled().prefix(count).map { $0 }
    }
    
    private func previewSequence() {
        isPreviewing = true
        canTap = false
        for index in cards.indices {
            cards[index].isFaceUp = false
        }
        
        var delay = 0.0
        for seqIndex in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.cards[seqIndex].isFaceUp = true
            }
            delay += previewTime
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.cards[seqIndex].isFaceUp = false
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
                repetation -= 1
                repetitionsLeft = repetation
                previewTime -= 0.1
                
                if repetation == 0 {
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
