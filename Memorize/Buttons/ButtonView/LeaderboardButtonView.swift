import SwiftUI

struct LeaderboardButtonView: View {
    let action: () -> Void
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        Button(action: {
            if(settings.isSoundOn){
                SoundManager.shared.playSound(named: "button_click")
            }
            action()
        })
        {
            Image(systemName: "trophy")
                .resizable()
                .scaledToFit()
                .foregroundColor(settings.secondaryColor)
        }
        .padding()
        .frame(maxWidth: settings.screenWidth * 0.2, maxHeight: settings.ScreenHeight * 0.075)
        .background(settings.mainColor)
        .clipShape(Circle())
        .overlay(Circle().stroke(settings.secondaryColor, lineWidth: 2))
    }
}
