import SwiftUI

struct CircleButton: View {
    @Binding var isOn: Bool
    let iconName: String
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
            Circle()
                .stroke(settings.secondaryColor, lineWidth: settings.circleButtonSize * 0.02)
                .frame(width: settings.circleButtonSize, height: settings.circleButtonSize)
                .overlay(
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: settings.circleButtonSize * 0.5, height: settings.circleButtonSize * 0.5)
                        .foregroundColor(isOn == false ? settings.secondaryColor.opacity(0.25) : settings.secondaryColor)
                )
        }
    }
}
