import SwiftUI

struct ControlsView: View {
    @EnvironmentObject private var settings: AppSettings
    var onHome: () -> Void = {}
    var onRestart: () -> Void = {}
    var lives: Int
    var level: Int

    var body: some View {
        VStack{
            HStack(alignment: .top) {
                VStack {
                    CircleButton(
                        isOn: .constant(true),
                        iconName: "house",
                        action: {
                            onHome()
                        }
                    )
                    
                    CircleButton(
                        isOn: .constant(true),
                        iconName: "arrow.counterclockwise",
                        action: {
                            onRestart()
                        }
                    )
                }
                Spacer()
                VStack() {
                    HStack(spacing: settings.circleButtonSize / 2) {
                        ForEach(0..<3, id: \.self) { index in
                            if index < lives {
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(settings.secondaryColor)
                                    .transition(
                                        AnyTransition
                                            .scale(scale: 0.1, anchor: .center)
                                            .combined(with: .opacity)
                                    )
                                    .frame(height: settings.circleButtonSize)
                            }
                        }
                    }
                    
                    Text("Level \(level)")
                        .font(.subheadline.bold())
                        .foregroundColor(settings.secondaryColor)
                        .animation(.easeOut(duration: 0.5))
                }
                Spacer()
                
                SettingsButtonsView()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight / 4)
    }
}
