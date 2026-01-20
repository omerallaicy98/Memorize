import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let isMatch: Bool
    var isFaceUp = false
    var isMatched = false
}

struct GameGridView: View {
    @EnvironmentObject var settings: AppSettings

    @Binding var cards: [Card]
    @Binding var canTap: Bool
    @Binding var tappedCard: Int?
    @Binding var shakeIndex: Int?

    let gridSize: Int
    let onTapCard: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 8
            let totalSpacing = spacing * CGFloat(gridSize - 1)
            let sideLength = (geo.size.width - totalSpacing) / CGFloat(gridSize)

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.fixed(sideLength), spacing: spacing),
                    count: gridSize
                ),
                spacing: spacing
            ) {
                ForEach(cards.indices, id: \.self) { index in
                    CardView(
                        isFaceUp: cards[index].isFaceUp || cards[index].isMatched,
                        shake: shakeIndex == index
                    )
                    .frame(width: sideLength, height: sideLength)
                    .rotation3DEffect(
                        .degrees(cards[index].isFaceUp || cards[index].isMatched ? 0 : 180),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .scaleEffect(tappedCard == index ? 0.97 : 1)
                    .onTapGesture {
                        tappedCard = index
                        onTapCard(index)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            tappedCard = nil
                        }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.width, alignment: .bottom)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
        .background(settings.mainColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(settings.secondaryColor, lineWidth: 3)
        )
    }
}

struct CardView: View {
    @EnvironmentObject private var settings: AppSettings
    var isFaceUp: Bool
    var shake: Bool

    var body: some View {
        ZStack {
            // Back of the card
            RoundedRectangle(cornerRadius: 20)
                .fill(settings.secondaryColor)
                .opacity(isFaceUp ? 0 : 1)

            // Front of the card
            RoundedRectangle(cornerRadius: 20)
                .fill(settings.mainColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(settings.secondaryColor, lineWidth: 1)
                )
                .opacity(isFaceUp ? 1 : 0)
        }
        .rotation3DEffect(
            .degrees(isFaceUp ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.4), value: isFaceUp)
        .modifier(Shake(animatableData: shake ? 1 : 0))
        .animation(shake ? .default : .none, value: shake)
    }
}
