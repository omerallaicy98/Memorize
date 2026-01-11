import SwiftUI

struct EndlessScoreView: View {
    @Binding var Score: Int
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        Text("\(Score)")
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .foregroundColor(settings.secondaryColor)
            .contentTransition(.numericText())
    }
}
