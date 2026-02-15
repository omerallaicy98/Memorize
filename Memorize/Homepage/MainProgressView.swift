import SwiftUI

struct MainProgressView:View {
    @EnvironmentObject private var settings: AppSettings
    var circleOneProgress: Double
    var circleOneValue: Int
    var circleOneLabel: String
    var circleTwoProgress: Double
    var circleTwoValue: Int
    var circleTwoLabel: String
    var circleThreeProgress: Double
    var circleThreeValue: Int
    var circleThreeLabel: String
    var circleFourProgress: Double
    var circleFourValue: Int
    var circleFourLabel: String
    var circleFiveProgress: Double
    var circleFiveValue: Int
    var circleFiveLabel: String
    
    var body: some View {
        let circleFrame = settings.ScreenHeight / 15
        
        HStack() {
            CircleProgressView(
                circleFrame: circleFrame, progress: circleOneProgress,
                valueText: circleOneValue, label: circleOneLabel
            )
            CircleProgressView(
                circleFrame: circleFrame, progress: circleTwoProgress,
                valueText: circleTwoValue, label: circleTwoLabel
            )
            CircleProgressView(
                circleFrame: circleFrame * 2, progress: circleThreeProgress,
                valueText: circleThreeValue, label: circleThreeLabel
            )
            CircleProgressView(
                circleFrame: circleFrame, progress: circleFourProgress,
                valueText: circleFourValue, label: circleFourLabel
            )
            CircleProgressView(
                circleFrame: circleFrame, progress: circleFiveProgress,
                valueText: circleFiveValue, label: circleFiveLabel
            )
        }
        .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight / 4)
    }
}
