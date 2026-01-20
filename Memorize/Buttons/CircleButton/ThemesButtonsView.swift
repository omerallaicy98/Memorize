import SwiftUI

struct ThemesButtonView: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        CircleButton(
            isOn: .constant(true),
            iconName: "paintpalette",
            action: {
                switch settings.themeType {
                case .white:
                    settings.updateTheme(type: .maroon)
                case .maroon:
                    settings.updateTheme(type: .navy)
                case .navy:
                    settings.updateTheme(type: .olive)
                case .olive:
                    settings.updateTheme(type: .white)
                }
            }
        )
    }
}
