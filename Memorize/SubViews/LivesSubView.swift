import SwiftUI

struct LivesSubView: View {
    @Binding var lives: Int
    let maxLives: Int
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        HStack() {
            ForEach(0..<maxLives, id: \.self) { index in
                if index < lives {
                    Image(systemName: "heart.fill")
                        .foregroundColor(settings.secondaryColor)
                        .font(.system(size: settings.playerLiveSize * 0.75))
                        .transition(
                            AnyTransition
                                .scale(scale: 0.1, anchor: .center)
                                .combined(with: .opacity)
                        )
                        .frame(width: settings.playerLiveSize, height: settings.playerLiveSize)
                }
            }
        }
    }
}
