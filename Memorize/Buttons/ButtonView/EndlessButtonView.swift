import SwiftUI

struct EndlessButtonView: View {
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
                Image(systemName: "infinity")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(settings.secondaryColor)
                    .frame(maxWidth: settings.screenWidth * 0.5, maxHeight: settings.ScreenHeight * 0.025)
                
                Text("Endless Mode")
                    .foregroundColor(settings.secondaryColor)
                    .frame(maxWidth: settings.screenWidth * 0.5, maxHeight: settings.ScreenHeight * 0.025)
            }
            .padding()
        }
        .frame(maxWidth: settings.screenWidth * 0.8, maxHeight: settings.ScreenHeight * 0.075)
        .background(settings.mainColor)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(settings.secondaryColor, lineWidth: 2))
    }
}
