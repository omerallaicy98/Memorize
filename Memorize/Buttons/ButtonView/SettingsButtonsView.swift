import SwiftUI

struct SettingsButtonsView: View {
    @State private var showSettingsMenu = false
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        CircleButton(
            isOn: .constant(true),
            iconName: "gearshape.fill",
            action: {
                if settings.isSoundOn {
                    SoundManager.shared.playSound(named: "button_click")
                }
                withAnimation(.easeInOut) { showSettingsMenu.toggle() }
            }
        )
        .overlay(
            VStack(spacing: settings.circleButtonSize * 0.25) {
                CircleButton(
                    isOn: .constant(true),
                    iconName: "circle.lefthalf.filled",
                    action: {
                        settings.toggleMode()
                    }
                )
                CircleButton(
                    isOn: .constant(settings.isSoundOn),
                    iconName: "speaker.wave.2.fill",
                    action: {
                        settings.toggleSound()
                    }
                )
                CircleButton(
                    isOn: .constant(settings.isHapticsOn),
                    iconName: "iphone.radiowaves.left.and.right",
                    action: {
                        settings.toggleHaptics()
                    }
                )
            }
                .offset(y: showSettingsMenu ? settings.circleButtonSize * 1.5 : 0)
                .opacity(showSettingsMenu ? 1 : 0)
                .animation(.easeInOut, value: showSettingsMenu), alignment: .topTrailing)
    }
}
//Settings menu autoclose
