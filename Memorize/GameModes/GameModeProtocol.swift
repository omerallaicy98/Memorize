import SwiftUI

protocol GameMode: ObservableObject {
    
    var cards: [Card] { get }
    var gridSize: Int { get }
    var canTap: Bool { get }
    
    var lives: Int { get }
    var score: Int { get }
    var level: Int { get }
    
    var previewTime: TimeInterval { get }
    var matchingCardsCount: Int { get }
    
    func startGame()
    func resetGame()
    func tapCard(at index: Int)
}
