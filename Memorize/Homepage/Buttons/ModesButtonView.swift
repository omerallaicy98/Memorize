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
                Spacer()
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(settings.secondaryColor)
                    .frame(maxWidth: settings.screenWidth * 0.1, maxHeight: settings.screenWidth * 0.1)
                
                Spacer()
                Text(displayText)
                    .font(.subheadline.bold())
                    .foregroundColor(settings.secondaryColor)
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: settings.screenWidth * 0.5, maxHeight: settings.ScreenHeight * 0.1)
        .background(settings.mainColor)
        .overlay(RoundedRectangle(cornerRadius: 50).stroke(settings.secondaryColor, lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 50))
    }
}
