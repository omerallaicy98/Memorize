import SwiftUI

struct Card: Identifiable, Equatable, Hashable {
    var id = UUID()
    var isMatch: Bool
    var isFaceUp = false
    var isMatched = false
    var remainingTime: Double
    var remainingTaps: Int
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
                    RoundedRectangle(cornerRadius: cardWidth * 0.25)
                        .stroke(settings.secondaryColor, lineWidth: cardWidth * 0.025)
                )
                .opacity(card.isFaceUp ? 1 : 0)
            
            if card.remainingTime != 0 && showTimer {
                Circle()
                    .stroke(settings.mainColor.opacity(0.1), lineWidth: cardWidth * 0.025)
                    .frame(width: cardWidth * 0.5, height: cardWidth * 0.5)
                Circle()
                    .trim(from: 0, to: CGFloat(card.remainingTime))
                    .stroke(settings.mainColor, style: StrokeStyle(lineWidth: cardWidth * 0.025, lineCap: .round))
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

struct GameGridView: View {
    @EnvironmentObject private var settings: AppSettings
    var cards: [Card]
    var showTimer: Bool
    var gridSize: Int
    var canTap: Bool
    @State var tappedCard: Int?
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
        .background(settings.mainColor)
        .frame(width: settings.ScreenHeight / 2, height: settings.ScreenHeight / 2)
        .overlay(
            RoundedRectangle(cornerRadius: settings.ScreenHeight * 0.15 / CGFloat(gridSize), style: .continuous)
                .stroke(settings.secondaryColor, lineWidth: settings.ScreenHeight * 0.005)
        )
        .background(settings.mainColor)
        .clipShape(RoundedRectangle(cornerRadius: settings.ScreenHeight * 0.15 / CGFloat(gridSize), style: .continuous))
    }
}
