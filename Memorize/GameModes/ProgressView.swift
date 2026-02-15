import SwiftUI

struct CircleProgressView: View {
    @EnvironmentObject private var settings: AppSettings
    var circleFrame: Double
    var progress: Double
    var valueText: Int
    var label: String

    var body: some View {
        VStack() {
            ZStack {
                Circle()
                    .stroke(settings.secondaryColor.opacity(0.1), lineWidth: circleFrame * 0.1)
                    .frame(width: circleFrame, height: circleFrame)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(settings.secondaryColor,
                            style: StrokeStyle(lineWidth: circleFrame * 0.1, lineCap: .round))
                    .frame(width: circleFrame, height: circleFrame)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: progress)
                Text("\(valueText)")
                    .font(.subheadline.bold())
                    .foregroundColor(settings.secondaryColor)
                    .animation(.easeOut(duration: 0.5))
            }
            .background(settings.mainColor)
            .clipShape(Circle())
            
            Text(label)
                .font(.subheadline.bold())
                .foregroundColor(settings.secondaryColor)
        }
    }
}

struct ProgressView:View {
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
    
    var body: some View {
        let circleFrame = settings.ScreenHeight / 10
        
        HStack(spacing: circleFrame / 2) {
            CircleProgressView(
                circleFrame: circleFrame, progress: circleOneProgress,
                valueText: circleOneValue, label: circleOneLabel
            )
            CircleProgressView(
                circleFrame: circleFrame, progress: circleTwoProgress,
                valueText: circleTwoValue, label: circleTwoLabel
            )
            CircleProgressView(
                circleFrame: circleFrame, progress: circleThreeProgress,
                valueText: circleThreeValue, label: circleThreeLabel
            )
        }
        .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight / 4)
    }
}
