import SwiftUI
import Combine

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

final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    @Published var loadingTime: CGFloat = 3
    @Published var loadingTransitionTime: CGFloat = 0.5
    @Published var screenWidth: CGFloat = 0
    @Published var ScreenHeight: CGFloat = 0
    @Published var playerLiveSize: CGFloat = 0
    @Published var circleButtonSize: CGFloat = 0
    @Published var geometrySet: CGFloat = 0
    @Published var themeType: ThemeType = .white
    
    @Published var mainColor: Color {
        didSet { saveThemeStatus() }
    }
    @Published var secondaryColor: Color {
        didSet { saveThemeStatus() }
    }
    @Published var isSoundOn: Bool {
        didSet { saveSoundStatus() }
    }
    @Published var isHapticsOn: Bool {
        didSet { saveHapticsStatus() }
    }
    
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
    
    func computeGeometry(for geometry: GeometryProxy) {
        screenWidth = geometry.size.width
        ScreenHeight = geometry.size.height
        playerLiveSize = max(45, min((min(geometry.size.width, geometry.size.height) * 0.1), 70))
        circleButtonSize = max(45, min((min(geometry.size.width, geometry.size.height) * 0.1), 70))
        geometrySet = 1
    }
}
