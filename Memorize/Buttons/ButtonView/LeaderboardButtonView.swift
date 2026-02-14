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
                .frame(maxWidth: settings.screenWidth * 0.08, maxHeight: settings.screenWidth * 0.08)
                .padding()
        }
        .frame(maxWidth: settings.ScreenHeight * 0.1, maxHeight: settings.ScreenHeight * 0.1)
        .background(settings.mainColor)
        .overlay(RoundedRectangle(cornerRadius: 50).stroke(settings.secondaryColor, lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 50))
    }
}
