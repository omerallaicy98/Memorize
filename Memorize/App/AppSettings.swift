import SwiftUI
import Combine

final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    @Published var screenWidth: CGFloat = 0
    @Published var ScreenHeight: CGFloat = 0
    @Published var playerLiveSize: CGFloat = 0
    @Published var circleButtonSize: CGFloat = 0
    @Published var geometrySet: CGFloat = 0
    
    @Published var loadingTime: CGFloat = 3
    @Published var loadingTransitionTime: CGFloat = 0.5
    
    @Published var themeType: ThemeType = .white
    @Published var mainColor: Color { didSet { saveThemeStatus() } }
    @Published var secondaryColor: Color { didSet { saveThemeStatus() } }
    @Published var isSoundOn: Bool { didSet { saveSoundStatus() } }
    @Published var isHapticsOn: Bool { didSet { saveHapticsStatus() } }
    
    @Published var currentSequenceLevel: Int { didSet { saveSequenceLevel() } }
    @Published var currentSpeedLevel: Int { didSet { saveSpeedLevel() } }
    @Published var currentStrengthLevel: Int { didSet { saveStrengthLevel() } }
    @Published var currentEndlessHighscore: Int { didSet { saveEndlessHighScore() } }
    
    init() {
        if let mainData = UserDefaults.standard.data(forKey: "themeMain"),
           let secondaryData = UserDefaults.standard.data(forKey: "themeSecondary"),
           let mainUIColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: mainData),
           let secondaryUIColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: secondaryData) {
            self.mainColor = Color(mainUIColor)
            self.secondaryColor = Color(secondaryUIColor)
        }
        else {
            self.mainColor = .white
            self.secondaryColor = .black
        }
        
        self.isSoundOn = UserDefaults.standard.object(forKey: "isSoundOn") as? Bool ?? true
        
        self.isHapticsOn = UserDefaults.standard.object(forKey: "isHapticsOn") as? Bool ?? true
        
        self.currentSequenceLevel = UserDefaults.standard.object(forKey: "currentSequenceLevel") as? Int ?? 1
        
        self.currentSpeedLevel = UserDefaults.standard.object(forKey: "currentSpeedLevel") as? Int ?? 1
        
        self.currentStrengthLevel = UserDefaults.standard.object(forKey: "currentStrengthLevel") as? Int ?? 1
        
        self.currentEndlessHighscore = UserDefaults.standard.object(forKey: "currentEndlessHighscore") as? Int ?? 0
    }
    
    private func saveThemeStatus() {
        let mainUIColor = UIColor(mainColor)
        let secondaryUIColor = UIColor(secondaryColor)
        if let mainData = try? NSKeyedArchiver.archivedData(withRootObject: mainUIColor, requiringSecureCoding: false),
           let secondaryData = try? NSKeyedArchiver.archivedData(withRootObject: secondaryUIColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(mainData, forKey: "themeMain")
            UserDefaults.standard.set(secondaryData, forKey: "themeSecondary")
        }
    }
    private func saveSoundStatus() {
        UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
    }
    private func saveHapticsStatus() {
        UserDefaults.standard.set(isHapticsOn, forKey: "isHapticsOn")
    }
    private func saveSequenceLevel() {
        UserDefaults.standard.set(currentSequenceLevel, forKey: "currentSequenceLevel")
    }
    private func saveSpeedLevel() {
        UserDefaults.standard.set(currentSpeedLevel, forKey: "currentSpeedLevel")
    }
    private func saveStrengthLevel() {
        UserDefaults.standard.set(currentStrengthLevel, forKey: "currentStrengthLevel")
    }
    private func saveEndlessHighScore() {
        UserDefaults.standard.set(currentEndlessHighscore, forKey: "currentEndlessHighscore")
    }
    
    func toggleSound() {
        isSoundOn.toggle()
    }
    func toggleHaptics() {
        isHapticsOn.toggle()
    }
    func toggleMode() {
        let temp = mainColor
        mainColor = secondaryColor
        secondaryColor = temp
    }
    func incrementSequnceLevel() {
        currentSequenceLevel+=1
    }
    func incrementSpeedLevel() {
        currentSpeedLevel+=1
    }
    func incrementStrengthLevel() {
        currentStrengthLevel+=1
    }
    
    func updateTheme(type: ThemeType) {
        themeType = type
        switch type {
            case .white:
                mainColor = .white
                secondaryColor = .black
            case .maroon:
                mainColor = .lightMaroon
                secondaryColor = .darkMaroon
            case .navy:
                mainColor = .lightNavy
                secondaryColor = .darkNavy
            case .olive:
                mainColor = .lightOlive
                secondaryColor = .darkOlive
        }
    }
    func updateEndlessHighscore(newHighScore: Int) {
        currentEndlessHighscore = newHighScore
    }
    
    func computeGeometry(for geometry: GeometryProxy) {
        screenWidth = geometry.size.width
        ScreenHeight = geometry.size.height
        playerLiveSize = max(45, min((min(geometry.size.width, geometry.size.height) * 0.1), 70))
        circleButtonSize = max(45, min((min(geometry.size.width, geometry.size.height) * 0.1), 70))
        geometrySet = 1
    }
}

enum ThemeType {
    case white, maroon, navy, olive
}

extension Color {
    static let lightMaroon = Color(red: 0.82, green: 0.60, blue: 0.68)
    static let darkMaroon = Color(red: 0.45, green: 0.05, blue: 0.18)
    static let lightOlive = Color(red: 0.72, green: 0.76, blue: 0.55)
    static let darkOlive = Color(red: 0.35, green: 0.38, blue: 0.12)
    static let lightNavy = Color(red: 0.55, green: 0.62, blue: 0.78)
    static let darkNavy = Color(red: 0.05, green: 0.10, blue: 0.30)
}
