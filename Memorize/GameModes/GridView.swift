import SwiftUI

struct Card: Identifiable, Equatable, Hashable {
    var id = UUID()
    var isMatch = false
    var isFaceUp = false
    var isMatched = false
    var remainingTime: Double = 0
    var remainingTaps: Int = 0
}

struct CardView: View {
    @EnvironmentObject private var settings: AppSettings
    var card: Card
    var showTimer: Bool
    var cardWidth: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cardWidth * 0.25, style: .continuous)
                .fill(settings.secondaryColor)
                .opacity(card.isFaceUp ? 0 : 1)

            RoundedRectangle(cornerRadius: cardWidth * 0.25, style: .continuous)
                .fill(settings.mainColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cardWidth * 0.25, style: .continuous)
                        .stroke(settings.secondaryColor, lineWidth: cardWidth * 0.01)
                )
                .opacity(card.isFaceUp ? 1 : 0)
            
            if card.remainingTime != 0 && showTimer {
                Circle()
                    .stroke(settings.mainColor.opacity(0.1), lineWidth: cardWidth * 0.02)
                    .frame(width: cardWidth * 0.5, height: cardWidth * 0.5)
                Circle()
                    .trim(from: 0, to: CGFloat(card.remainingTime))
                    .stroke(settings.mainColor, style: StrokeStyle(lineWidth: cardWidth * 0.02, lineCap: .round))
                    .frame(width: cardWidth * 0.5, height: cardWidth * 0.5)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.1), value: card.remainingTime)
            }
            
            if card.remainingTaps != 0 {
                Text("\(card.remainingTaps)")
                    .font(.subheadline.bold())
                    .foregroundColor(settings.mainColor)
                    .animation(.easeOut(duration: 0.1))
            }
        }
    }
}

struct GridView: View {
    @EnvironmentObject private var settings: AppSettings
    var cards: [Card]
    var showTimer: Bool
    var gridSize: Int
    var canTap: Bool
    var levelCleared: Bool
    @State private var tappedCard: Int?
    @State private var gridRotation: Double = 0
    @State private var gridOpacity: Double = 1
    var onTapCard: (Int) -> Void

    var body: some View {
        let spacer = settings.ScreenHeight * 0.015
        let cardWidth = (settings.ScreenHeight / (2 * CGFloat(gridSize))) -
        (spacer * CGFloat(gridSize + 1) / CGFloat(gridSize))

        LazyVGrid(
            columns: Array(
                repeating: GridItem(.fixed(cardWidth), spacing: spacer),
                count: gridSize
            ),
            spacing: spacer
        ) {
            ForEach(cards.indices, id: \.self) { index in
                CardView(
                    card: cards[index],
                    showTimer: showTimer,
                    cardWidth: cardWidth
                )
                .frame(width: cardWidth, height: cardWidth)
                .scaleEffect(((tappedCard == index) && (showTimer)) ? 0.95 : 1)
                .rotation3DEffect(.degrees(cards[index].isFaceUp ? -180 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(.easeOut(duration: cards[index].remainingTime), value: cards[index].isFaceUp)
                .rotation3DEffect(.degrees(gridRotation), axis: (x: 0, y: 1, z: 0))
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
        .frame(width: settings.ScreenHeight / 2, height: settings.ScreenHeight / 2)
        .overlay(
            RoundedRectangle(cornerRadius: settings.ScreenHeight * 0.125 / CGFloat(gridSize), style: .continuous)
                .stroke(settings.secondaryColor, lineWidth: settings.ScreenHeight * 0.005)
        )
        .background(settings.mainColor)
        .clipShape(RoundedRectangle(cornerRadius: settings.ScreenHeight * 0.125 / CGFloat(gridSize), style: .continuous))
        .opacity(gridOpacity)
        .onChange(of: levelCleared) { cleared in
            guard cleared else { return }
            
            // Rotate 3 full times (1080 degrees)
            withAnimation(.easeInOut(duration: 1.2)) {
                gridRotation = -1080
            }
            
            // Fade out AFTER rotation fully completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.4)) {
                    gridOpacity = 0
                }
            }
        }
    }
}
