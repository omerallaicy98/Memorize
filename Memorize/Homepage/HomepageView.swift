import SwiftUI

struct HomepageView:View {
    @State private var level: Int? = 90
    @State private var startOrderMode = false
    @State private var startRushMode = false
    @State private var startForceMode = false
    @State private var startRecallMode = false
    @State private var startEndlessMode = false
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        ZStack {
            if startRushMode {
                RushModeView()
            }
            else if startOrderMode {
                OrderModeView()
            }
            else if startForceMode {
                ForceModeView()
            }
            else if startRecallMode {
                RecallModeView()
            }
            else if startEndlessMode {
                EndlessGameView()
            }
            else {
                VStack(alignment: .leading) {
                    VStack{
                        HStack(alignment: .top) {
                            VStack(spacing: settings.circleButtonSize * 0.5) {
                                AdButtonView()
                                ThemesButtonView()
                            }
                            Spacer()
                            
                            SettingsButtonsView()
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                    
                    VStack(alignment: .center) {
                        MainProgressView(
                            circleOneProgress: Double(settings.currentOrderLevel)/250, circleOneValue: settings.currentOrderLevel, circleOneLabel: "Order", circleTwoProgress: Double(settings.currentRushLevel)/250, circleTwoValue: settings.currentRushLevel, circleTwoLabel: "Rush", circleThreeProgress:  Double(settings.currentOrderLevel + settings.currentRushLevel + settings.currentForceLevel + settings.currentRecallLevel)/250, circleThreeValue: settings.currentOrderLevel + settings.currentRushLevel + settings.currentForceLevel + settings.currentRecallLevel, circleThreeLabel: "Memory", circleFourProgress: Double(settings.currentForceLevel)/250, circleFourValue: settings.currentForceLevel, circleFourLabel: "Force", circleFiveProgress: Double(settings.currentRecallLevel)/250, circleFiveValue: settings.currentRecallLevel, circleFiveLabel: "Recall")
                    }
                    .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                    
                    VStack(alignment: .center) {
                        Spacer()
                        HStack {
                            ModesButton(iconName: "square.stack", displayText: "Order\nChallenge") {
                                startOrderMode = true
                            }
                            Spacer()
                            ModesButton(iconName: "bolt", displayText: "Rush\nChallenge") {
                                startRushMode = true
                            }
                        }
                        
                        Spacer()
                        HStack {
                            ModesButton(iconName: "dumbbell", displayText: "Force\nChallenge") {
                                startForceMode = true
                            }
                            Spacer()
                            ModesButton(iconName: "brain", displayText: "Recall\nChallenge") {
                                startRecallMode = true
                            }
                        }
                        
                        Spacer()
                        HStack {
                            EndlessButtonView {
                                startEndlessMode = true
                            }
                            LeaderboardButtonView {
                                //action
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
                }
                .padding()
                .animation(.easeInOut(duration: 0.3), value: settings.secondaryColor)
            }
        }
    }
}
