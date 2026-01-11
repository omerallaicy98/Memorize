import SwiftUI
import Combine

final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    @Published var loadingTime: CGFloat = 3
    @Published var loadingTransitionTime: CGFloat = 0.5
    @Published var screenWidth: CGFloat = 0
    @Published var ScreenHeight: CGFloat = 0
    @Published var playerLiveSize: CGFloat = 0
    @Published var circleButtonSize: CGFloat = 0
    @Published var geometrySet: CGFloat = 0
    
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
    
    func updateTheme(main: Color, secondary: Color) {
        self.mainColor = main
        self.secondaryColor = secondary
    }
    
    func computeGeometry(for geometry: GeometryProxy) {
        screenWidth = geometry.size.width
        ScreenHeight = geometry.size.height
        playerLiveSize = max(45, min((min(geometry.size.width, geometry.size.height) * 0.1), 70))
        circleButtonSize = max(45, min((min(geometry.size.width, geometry.size.height) * 0.1), 70))
        geometrySet = 1
    }
}
