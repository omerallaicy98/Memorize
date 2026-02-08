import SwiftUI

struct Card: Identifiable, Equatable, Hashable {
    let id = UUID()
    var value: Double?
    var isMatch: Bool
    var isFaceUp = false
    var isMatched = false
}

struct CardView: View {
    @EnvironmentObject private var settings: AppSettings
    
    var card: Card
    var previewTime: Double
    var showTimer: Bool = false
    var cardWidth: CGFloat
    
    var body: some View {
        let cornerRadius = cardWidth * 0.3
        let lineWidth = cardWidth * 0.01
        
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(settings.secondaryColor)
                .opacity(card.isFaceUp ? 0 : 1)

            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(settings.mainColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(settings.secondaryColor, lineWidth: lineWidth)
                )
                .opacity(card.isFaceUp ? 1 : 0)

            if showTimer, let remainingTime = card.value, !card.isFaceUp {
                let initialTime = max(remainingTime, 1.0)
                let progress = max(remainingTime / initialTime, 0)

                ZStack {
                    // Background faint circle
                    Circle()
                        .fill(settings.secondaryColor.opacity(0.15))

                    // Pie-style filling from center, clockwise
                    PieShape(progress: progress)
                        .fill(settings.mainColor)
                }
                .frame(
                    width: cardWidth * 0.4,
                    height: cardWidth * 0.4
                )
                .animation(.linear(duration: 0.05), value: progress)
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: previewTime), value: card.isFaceUp)
    }
}

struct PieShape: Shape {
    var progress: CGFloat   // 0 → 1

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        let startAngle = Angle.degrees(-90)
        let endAngle = Angle.degrees(-90 + 360 * Double(progress))

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

struct GameGridView: View {
    @EnvironmentObject private var settings: AppSettings
    
    @Binding var cards: [Card]
    @Binding var canTap: Bool
    @State var tappedCard: Int?
    let gridSize: Int
    let previewTime: Double
    let showTimer: Bool
    let onTapCard: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            let gridWidth = geo.size.width
            let columns = gridSize
            let innerGap: CGFloat = gridWidth * 0.025
            let cardSideLength =
                (gridWidth - (CGFloat(columns - 1) * innerGap) - (innerGap * 4))
                / CGFloat(columns)
            
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.fixed(cardSideLength), spacing: innerGap),
                    count: gridSize
                ),
            ) {
                ForEach(cards.indices, id: \.self) { index in
                    CardView(
                        card: cards[index],
                        previewTime: previewTime,
                        showTimer: showTimer,
                        cardWidth: cardSideLength
                    )
                    .frame(width: cardSideLength, height: cardSideLength)
                    .rotation3DEffect(
                        .degrees(cards[index].isFaceUp || cards[index].isMatched ? 0 : 180),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .scaleEffect(tappedCard == index ? 0.97 : 1)
                    .onTapGesture {
                        guard canTap, !cards[index].isFaceUp else { return }
                        tappedCard = index
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            onTapCard(index)
                            tappedCard = nil
                        }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.width, alignment: .center)
            .overlay(
                RoundedRectangle(cornerRadius: geo.size.width * 0.1)
                    .stroke(settings.secondaryColor, lineWidth: geo.size.width * 0.01)
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

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
