import SwiftUI

struct AdButtonView: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        CircleButton(
            isOn: .constant(true),
            iconName: "nosign",
            action: {
            }
        )
    }
}
