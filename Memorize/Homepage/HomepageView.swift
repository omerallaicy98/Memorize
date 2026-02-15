import SwiftUI

struct HomepageView:View {
    @State private var level: Int? = 90
    @State private var startRecallMode = false
    @State private var startRushMode = false
    @State private var startOrderMode = false
    @State private var startForceMode = false
    @State private var startEndlessMode = false
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        ZStack {
            if startRecallMode {
                //View
            }
            else if startRushMode {
                RushModeView()
            }
            else if startOrderMode {
                SequnceGameView()
            }
            else if startForceMode {
                StrengthModeGameView()
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
                        MainProgressView(level: $level)
                    }
                    .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                    
                    VStack(alignment: .center) {
                        Spacer()
                        HStack{
                            ModesButton(iconName: "brain", displayText: "Recall\nChallenge") {
                                //startRecallMode = true
                            }
                            Spacer()
                            ModesButton(iconName: "bolt", displayText: "Rush\nChallenge") {
                                startRushMode = true
                            }
                        }
                        
                        Spacer()
                        HStack{
                            ModesButton(iconName: "square.stack", displayText: "Order\nChallenge") {
                                startOrderMode = true
                            }
                            Spacer()
                            ModesButton(iconName: "dumbbell", displayText: "Force\nChallenge") {
                                startForceMode = true
                            }
                        }
                        
                        Spacer()
                        HStack{
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
