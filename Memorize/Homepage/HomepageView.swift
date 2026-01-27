import SwiftUI

struct HomepageView:View {
    @State private var level: Int? = 90
    @State private var startSequenceMode = false
    @State private var startMode2 = false
    @State private var startMode3 = false
    @State private var startMode4 = false
    @State private var startEndlessMode = false
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        
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
                            AdsButtonView()
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
                    Button(action: {
                        startSequenceMode = true
                    })
                    {
                        Text("Sequence Mode")
                            .font(.title2.bold())
                            .foregroundColor(settings.secondaryColor)
                            .frame(maxWidth: settings.screenWidth * 0.8, maxHeight: settings.ScreenHeight * 0.05)
                    }
                    .background(
                        Capsule()
                            .fill(.clear)
                            .overlay(Capsule().stroke(settings.secondaryColor, lineWidth: 2))
                    )
                    Spacer()
                    
                    Button(action: {
                        startEndlessMode = true
                    })
                    {
                        Text("Endless Mode")
                            .font(.title2.bold())
                            .foregroundColor(settings.secondaryColor)
                            .frame(maxWidth: settings.screenWidth * 0.8, maxHeight: settings.ScreenHeight * 0.05)
                    }
                    .background(
                        Capsule()
                            .fill(.clear)
                            .overlay(Capsule().stroke(settings.secondaryColor, lineWidth: 2))
                    )
                }
                .frame(maxWidth: settings.screenWidth, maxHeight: settings.ScreenHeight * 0.5)
            }
            .padding()
            .background(settings.mainColor)
            .animation(.easeInOut(duration: 0.3), value: settings.secondaryColor)
        }
    }
}
