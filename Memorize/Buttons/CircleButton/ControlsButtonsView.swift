import SwiftUI

struct ControlsButtonsView: View {
    var onHome: () -> Void = {}
    var onRestart: () -> Void = {}
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(spacing: settings.circleButtonSize * 0.5) {
            CircleButton(
                isOn: .constant(true),
                iconName: "house.fill",
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
    }
}
