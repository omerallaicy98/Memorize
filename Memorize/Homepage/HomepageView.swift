import SwiftUI

struct HomepageView:View {
    @State private var level: Int? = 90
    @State private var startSequenceMode = false
    @State private var startSpeedMode = false
    @State private var startMode3 = false
    @State private var startMode4 = false
    @State private var startEndlessMode = false
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
<<<<<<< HEAD
        if startSequenceMode {
            SequnceGameView()
        }
        else if startSpeedMode {
            SpeedGameView()
        }
        else if startMode3 {
            
        }
        else if startMode4 {
            
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
=======
        ZStack {
            NeuronBackground()

            if startSequenceMode {
                SequnceGameView()
            }
            else if startMode2 {
                
            }
            else if startMode3 {
                
            }
            else if startMode4 {
                
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
>>>>>>> 1b6e756eee743515d6d5471aa9ef04fc6d136b9a
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                    
                    VStack(alignment: .center) {
                        MainProgressView(level: $level)
                    }
                    .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                    
                    VStack(alignment: .center) {
                        HStack{
                            ModesButton(iconName: "rectangle.stack.fill", displayText: "Sequnce Mode") {
                                startSequenceMode = true
                            }
                            Spacer()
                            ModesButton(iconName: "timer", displayText: "Speed Mode") {
                                //action
                            }
                        }
                        
                        Spacer()
                        
                        HStack{
                            ModesButton(iconName: "lock.fill", displayText: "Locked") {
                                //action
                            }
                            Spacer()
                            ModesButton(iconName: "lock.fill", displayText: "Locked") {
                                //action
                            }
                        }
                        
                        Spacer()
                        
                        HStack{
                            EndlessButtonView {
                                startEndlessMode = true
                            }
                            Spacer()
                            LeaderboardButtonView {
                                //action
                            }
                            
                        }
                    }
                    .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
                }
<<<<<<< HEAD
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                
                VStack(alignment: .center) {
                    MainProgressView(level: $level)
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.25)
                
                VStack(alignment: .center) {
                    HStack{
                        ModesButton(iconName: "rectangle.stack.fill", displayText: "Sequnce Mode") {
                            startSequenceMode = true
                        }
                        Spacer()
                        ModesButton(iconName: "timer", displayText: "Speed Mode") {
                            startSpeedMode = true
                        }
                    }
                    
                    Spacer()
                    
                    HStack{
                        ModesButton(iconName: "lock.fill", displayText: "Locked") {
                            //action
                        }
                        Spacer()
                        ModesButton(iconName: "lock.fill", displayText: "Locked") {
                            //action
                        }
                    }
                    
                    Spacer()
                    
                    HStack{
                        EndlessButtonView {
                            startEndlessMode = true
                        }
                        Spacer()
                        LeaderboardButtonView {
                            //action
                        }
                        
                    }
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
            }
            .padding()
            .animation(.easeInOut(duration: 0.3), value: settings.secondaryColor)
=======
                .padding()
                .animation(.easeInOut(duration: 0.3), value: settings.secondaryColor)
            }
>>>>>>> 1b6e756eee743515d6d5471aa9ef04fc6d136b9a
        }
    }
}
