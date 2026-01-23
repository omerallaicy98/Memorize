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
    @State private var progress: CGFloat = 1.0
    
    var card: Card
    var previewTime: Double
    var showTimer: Bool = false
    
    var body: some View {
        let cardWidth = settings.screenWidth / 6
        let cornerRadius = cardWidth * 0.25
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

            if showTimer, let totalTime = card.value, totalTime > 0 {
                Circle()
                    .foregroundColor(settings.mainColor)
                    .scaleEffect(progress)
                    .animation(.linear(duration: totalTime), value: progress)
                    .onAppear {
                        progress = 0
                    }
                    .onDisappear {
                        progress = 1
                    }
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: previewTime), value: card.isFaceUp)
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
        let cornerRadius = settings.screenWidth * 0.05
        let lineWidth = settings.screenWidth * 0.001
        
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
                        card: cards[index],
                        previewTime: previewTime,
                        showTimer: showTimer
                    )
                    .frame(width: sideLength, height: sideLength)
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
            .frame(width: geo.size.width, height: geo.size.width, alignment: .bottom)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
        .background(settings.mainColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(settings.secondaryColor, lineWidth: lineWidth)
        )
    }
}
