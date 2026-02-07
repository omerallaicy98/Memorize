import SwiftUI

struct ModesButton: View {
    let iconName: String
    let displayText: String
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
            HStack {
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(settings.secondaryColor)
                    .frame(maxWidth: settings.screenWidth * 0.25, maxHeight: settings.ScreenHeight * 0.05)
                
                Text(displayText)
                    .foregroundColor(settings.secondaryColor)
                    .frame(maxWidth: settings.screenWidth * 0.25, maxHeight: settings.ScreenHeight * 0.05)
            }
            .padding()
        }
        .frame(maxWidth: settings.screenWidth * 0.5, maxHeight: settings.ScreenHeight * 0.15)
        .background(settings.mainColor)
        .clipShape(RoundedRectangle(cornerRadius: 50))
        .overlay(RoundedRectangle(cornerRadius: 50).stroke(settings.secondaryColor, lineWidth: 2))
    }
}
