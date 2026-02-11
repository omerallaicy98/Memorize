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
                Spacer()
                Image(systemName: "infinity.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(settings.secondaryColor)
                    .frame(maxWidth: settings.screenWidth * 0.1, maxHeight: settings.screenWidth * 0.1)
                
                Spacer()
                Text("Endless Challenge")
                    .font(.subheadline.bold())
                    .foregroundColor(settings.secondaryColor)
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: settings.screenWidth * 0.5, maxHeight: settings.ScreenHeight * 0.1)
        .background(settings.mainColor)
        .clipShape(RoundedRectangle(cornerRadius: 50))
        .overlay(RoundedRectangle(cornerRadius: 50).stroke(settings.secondaryColor, lineWidth: 2))
    }
}
